local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local AlphaOpsRules = require(shared:WaitForChild("AlphaOpsRules"))

local AlphaOpsService = {}
AlphaOpsService.__index = AlphaOpsService

local OBSERVED_ATTRIBUTES = {
	"TinyWorldOnboardingComplete",
	"TinyWorldSaveState",
	"TinyWorldSessionState",
	"TinyWorldSaveRetryAttempt",
}

local function safeCount(value: any): number
	if type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge then
		return 0
	end
	return math.max(0, math.floor(value))
end

function AlphaOpsService.new(world, ProfileStore, PlayerStateService)
	local self = setmetatable({}, AlphaOpsService)
	self.root = world.root
	self.ProfileStore = ProfileStore
	self.PlayerStateService = PlayerStateService
	self.players = {}
	self.events = {
		onboardingCompletions = 0,
		recoveryTransitions = 0,
	}
	self.running = true
	self:_setStaticAttributes()
	self:_syncAggregate()
	task.spawn(function()
		while self.running do
			task.wait(AlphaOpsRules.HEALTH_POLL_SECONDS)
			if self.running then
				self:syncAll()
			end
		end
	end)
	return self
end

function AlphaOpsService:_setStaticAttributes()
	self.root:SetAttribute("TinyWorldAlphaReleaseVersion", AlphaOpsRules.RELEASE_VERSION)
	self.root:SetAttribute("TinyWorldAlphaChannel", AlphaOpsRules.CHANNEL)
	self.root:SetAttribute("TinyWorldAlphaRecommendedCohort", AlphaOpsRules.RECOMMENDED_COHORT_SIZE)
	self.root:SetAttribute("TinyWorldAlphaDiagnosticsScope", "aggregate-only")
end

function AlphaOpsService:_syncPlayer(player: Player)
	local record = self.players[player]
	if record == nil or player.Parent == nil then
		return
	end

	local diagnostics = self.ProfileStore.getDiagnostics(player)
	local onboardingComplete = player:GetAttribute("TinyWorldOnboardingComplete") == true
	local health = AlphaOpsRules.healthState(diagnostics, onboardingComplete)
	local previousHealth = record.health
	record.health = health
	if previousHealth == nil and onboardingComplete then
		self.events.onboardingCompletions += 1
	elseif previousHealth == "setup" and onboardingComplete then
		self.events.onboardingCompletions += 1
	end
	if previousHealth ~= "recovery-required" and health == "recovery-required" then
		self.events.recoveryTransitions += 1
		self.PlayerStateService.message(player, "TinyWorld needs a safe session restart. Please rejoin before continuing.")
	end

	player:SetAttribute("TinyWorldAlphaReleaseVersion", AlphaOpsRules.RELEASE_VERSION)
	player:SetAttribute("TinyWorldAlphaChannel", AlphaOpsRules.CHANNEL)
	player:SetAttribute("TinyWorldAlphaHealth", health)
	player:SetAttribute("TinyWorldAlphaRecoveryRequired", health == "recovery-required")
	player:SetAttribute("TinyWorldAlphaCohortLimit", AlphaOpsRules.RECOMMENDED_COHORT_SIZE)
	player:SetAttribute("TinyWorldAlphaCohortState", AlphaOpsRules.cohortState(#Players:GetPlayers()))
end

function AlphaOpsService:_syncAggregate()
	local active = 0
	local ready = 0
	local setup = 0
	local saving = 0
	local recovery = 0
	for player, record in self.players do
		if player.Parent ~= nil then
			active += 1
			if record.health == "ready" then
				ready += 1
			elseif record.health == "setup" then
				setup += 1
			elseif record.health == "saving" then
				saving += 1
			elseif record.health == "recovery-required" then
				recovery += 1
			end
		end
	end
	local diagnostics = self.ProfileStore.getDiagnostics()
	local aggregate = AlphaOpsRules.aggregateState(active, saving, recovery)
	self.root:SetAttribute("TinyWorldAlphaActivePlayers", active)
	self.root:SetAttribute("TinyWorldAlphaReadyPlayers", ready)
	self.root:SetAttribute("TinyWorldAlphaSetupPlayers", setup)
	self.root:SetAttribute("TinyWorldAlphaSavingPlayers", saving)
	self.root:SetAttribute("TinyWorldAlphaRecoveryPlayers", recovery)
	self.root:SetAttribute("TinyWorldAlphaQueueDepth", safeCount(diagnostics and diagnostics.queueDepth))
	self.root:SetAttribute("TinyWorldAlphaCohortState", aggregate.cohort)
	self.root:SetAttribute("TinyWorldAlphaHealth", aggregate.health)
	self.root:SetAttribute("TinyWorldAlphaOnboardingCompletions", self.events.onboardingCompletions)
	self.root:SetAttribute("TinyWorldAlphaRecoveryTransitions", self.events.recoveryTransitions)
	self.root:SetAttribute("TinyWorldAlphaLastSyncAt", os.time())
end

function AlphaOpsService:setupPlayer(player: Player)
	if self.players[player] ~= nil then
		return
	end
	local record = { connections = {}, health = nil }
	self.players[player] = record
	for _, attribute in OBSERVED_ATTRIBUTES do
		table.insert(record.connections, player:GetAttributeChangedSignal(attribute):Connect(function()
			self:_syncPlayer(player)
			self:_syncAggregate()
		end))
	end
	self:_syncPlayer(player)
	self:_syncAggregate()
end

function AlphaOpsService:syncAll()
	for player in self.players do
		self:_syncPlayer(player)
	end
	self:_syncAggregate()
end

function AlphaOpsService:removePlayer(player: Player)
	local record = self.players[player]
	if record == nil then
		return
	end
	for _, connection in record.connections do
		connection:Disconnect()
	end
	self.players[player] = nil
	self:_syncAggregate()
end

function AlphaOpsService:stop()
	self.running = false
	for player, record in self.players do
		for _, connection in record.connections do
			connection:Disconnect()
		end
		self.players[player] = nil
	end
end

return AlphaOpsService
