local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local PortalRules = require(shared:WaitForChild("PortalRules"))
local PortalSessionRules = require(shared:WaitForChild("PortalSessionRules"))
local AnalyticsEvents = require(shared:WaitForChild("AnalyticsEvents"))
local TinyAnalyticsService = require(script.Parent:WaitForChild("AnalyticsService"))

local PortalService = {}
PortalService.__index = PortalService

local mechanicVisualState = setmetatable({}, { __mode = "k" })

local function teleport(player: Player, target: CFrame)
	local character = player.Character
	if character then
		character:PivotTo(target)
	end
end

local function mechanicTarget(area): number
	return if type(area.mechanicPrompts) == "table" then #area.mechanicPrompts else 0
end

local function animateMechanic(worldId: string, part: BasePart)
	local state = mechanicVisualState[part]
	if state == nil then
		state = {
			cframe = part.CFrame,
			material = part.Material,
			transparency = part.Transparency,
			pulse = 0,
		}
		mechanicVisualState[part] = state
	end
	state.pulse += 1
	local pulse = state.pulse
	part:SetAttribute("TinyWorldPortalMechanicActive", true)
	if worldId == "MoonlitMeadow" then
		part.Material = Enum.Material.Neon
		part.Transparency = 0.05
	elseif worldId == "GiantKitchen" then
		part.CFrame = state.cframe * CFrame.Angles(math.rad(35), 0, 0)
	elseif worldId == "CloudpostObservatory" then
		part.CFrame = state.cframe * CFrame.Angles(0, 0, math.rad(18))
	elseif worldId == "ClockworkOrchard" then
		part.CFrame = state.cframe * CFrame.Angles(math.rad(45), 0, 0)
	end
	task.delay(0.55, function()
		if part.Parent == nil or state.pulse ~= pulse then
			return
		end
		part.CFrame = state.cframe
		part.Material = state.material
		part.Transparency = state.transparency
		part:SetAttribute("TinyWorldPortalMechanicActive", false)
	end)
end

function PortalService.new(world, ProfileStore, PlayerStateService, PlotService)
	local self = setmetatable({}, PortalService)
	self.world = world
	self.ProfileStore = ProfileStore
	self.PlayerStateService = PlayerStateService
	self.PlotService = PlotService
	self.sessions = {}
	self.characterConnections = {}
	self.worlds = {
		GiantKitchen = world.kitchen,
		MoonlitMeadow = world.moonlitMeadow,
		CloudpostObservatory = world.cloudpostObservatory,
		ClockworkOrchard = world.clockworkOrchard,
	}
	local prompts = {
		GiantKitchen = world.villagePortalPrompt,
		MoonlitMeadow = world.moonlitPortalPrompt,
		CloudpostObservatory = world.cloudpostPortalPrompt,
		ClockworkOrchard = world.clockworkPortalPrompt,
	}
	for worldId, startPrompt in prompts do
		if startPrompt and startPrompt:IsA("ProximityPrompt") then
			self:_connectWorld(worldId, startPrompt)
		end
	end
	return self
end

function PortalService:_connectWorld(worldId: string, startPrompt: ProximityPrompt)
	local area = self.worlds[worldId]
	local definition = PortalRules.getWorld(worldId)
	if area == nil or definition == nil then
		return
	end
	startPrompt.Triggered:Connect(function(player)
		self:_start(player, worldId)
	end)
	for index, collectPrompt in area.collectPrompts do
		collectPrompt.Triggered:Connect(function(player)
			self:_collect(player, worldId, index)
		end)
	end
	if type(area.mechanicPrompts) == "table" then
		for index, mechanicPrompt in area.mechanicPrompts do
			mechanicPrompt.Triggered:Connect(function(player)
				self:_mechanic(player, worldId, index)
			end)
		end
	end
	if area.secretPrompt and area.secretPrompt:IsA("ProximityPrompt") then
		area.secretPrompt.Triggered:Connect(function(player)
			self:_secret(player, worldId)
		end)
	end
	area.returnPrompt.Triggered:Connect(function(player)
		self:_finish(player, worldId)
	end)
end

function PortalService:_resetToVillageState(player: Player, teleportHome: boolean)
	self.sessions[player] = nil
	local resetState = PortalSessionRules.resetState()
	player:SetAttribute("TinyWorldPortalCrystals", resetState.crystals)
	player:SetAttribute("TinyWorldPortalMechanics", resetState.mechanics)
	player:SetAttribute("TinyWorldPortalSecretFound", resetState.secretFound)
	player:SetAttribute("TinyWorldPortalWorld", resetState.worldId)
	if teleportHome then
		task.defer(function()
			if player.Parent ~= nil then
				teleport(player, self.world.villageReturnCFrame)
			end
		end)
	end
end

function PortalService:hasValidSession(player: Player): boolean
	return PortalSessionRules.isValid(self.sessions[player], player:GetAttribute("TinyWorldPortalWorld"))
end

function PortalService:_getSessionForWorld(player: Player, worldId: string)
	local session = self.sessions[player]
	if not PortalSessionRules.isValid(session, player:GetAttribute("TinyWorldPortalWorld")) then
		return nil
	end
	if session.worldId ~= worldId then
		return nil
	end
	return session
end

function PortalService:setupPlayer(player: Player)
	local existing = self.characterConnections[player]
	if existing then
		existing:Disconnect()
	end

	self:_resetToVillageState(player, false)
	self.characterConnections[player] = player.CharacterAdded:Connect(function()
		local portalWorld = player:GetAttribute("TinyWorldPortalWorld")
		local wasInPortal = self.sessions[player] ~= nil
			or (type(portalWorld) == "string" and portalWorld ~= "" and portalWorld ~= "Village")
		self:_resetToVillageState(player, wasInPortal)
	end)
end

function PortalService:_start(player: Player, worldId: string)
	if self.ProfileStore.get(player) == nil then
		return
	end
	local definition = PortalRules.getWorld(worldId)
	local area = self.worlds[worldId]
	if definition == nil or area == nil then
		return
	end
	self.sessions[player] = PortalSessionRules.new(worldId)
	player:SetAttribute("TinyWorldPortalCrystals", 0)
	player:SetAttribute("TinyWorldPortalMechanics", 0)
	player:SetAttribute("TinyWorldPortalSecretFound", false)
	player:SetAttribute("TinyWorldPortalWorld", worldId)
	teleport(player, area.arrivalCFrame)
	TinyAnalyticsService.log(player, AnalyticsEvents.PortalEntered)
	self.PlayerStateService.message(
		player,
		string.format(
			"%s: find all %d %ss and complete %d %s interaction(s), then return through the portal.",
			definition.displayName,
			definition.collectibleCount,
			definition.collectibleName,
			mechanicTarget(area),
			area.mechanicName or "world"
		)
	)
end

function PortalService:_collect(player: Player, worldId: string, index: number)
	local session = self:_getSessionForWorld(player, worldId)
	local definition = PortalRules.getWorld(worldId)
	if session == nil or definition == nil then
		self.PlayerStateService.message(player, "Enter this world through its village portal to start the mission.")
		return
	end
	if not PortalSessionRules.markCollectible(session, index) then
		self.PlayerStateService.message(
			player,
			string.format("You already collected this %s on this run.", definition.collectibleName)
		)
		return
	end
	local count = PortalSessionRules.collectedCount(session)
	player:SetAttribute("TinyWorldPortalCrystals", count)
	self.PlayerStateService.message(
		player,
		string.format("%s found: %d/%d.", definition.collectibleName, count, definition.collectibleCount)
	)
end

function PortalService:_mechanic(player: Player, worldId: string, index: number)
	local session = self:_getSessionForWorld(player, worldId)
	local area = self.worlds[worldId]
	if session == nil or area == nil then
		self.PlayerStateService.message(
			player,
			"Enter this world through its village portal before using its main mechanism."
		)
		return
	end
	if not PortalSessionRules.markMechanic(session, index) then
		self.PlayerStateService.message(player, "You already completed this part of the world mechanism on this run.")
		return
	end
	local count = PortalSessionRules.mechanicCount(session)
	local target = mechanicTarget(area)
	local part = if type(area.mechanicParts) == "table" then area.mechanicParts[index] else nil
	if part and part:IsA("BasePart") then
		animateMechanic(worldId, part)
	end
	player:SetAttribute("TinyWorldPortalMechanics", count)
	self.PlayerStateService.message(
		player,
		string.format("%s activated: %d/%d.", area.mechanicName or "World mechanism", count, target)
	)
end

function PortalService:_secret(player: Player, worldId: string)
	local session = self:_getSessionForWorld(player, worldId)
	local area = self.worlds[worldId]
	if session == nil or area == nil then
		self.PlayerStateService.message(player, "That secret only makes sense while you are exploring this world.")
		return
	end
	if not PortalSessionRules.findSecret(session) then
		self.PlayerStateService.message(player, "You already discovered this secret on this run.")
		return
	end
	player:SetAttribute("TinyWorldPortalSecretFound", true)
	self.PlayerStateService.message(
		player,
		"Secret discovered: " .. tostring(area.secretName or "something curious was hidden here") .. "."
	)
end

function PortalService:_finish(player: Player, worldId: string)
	local session = self:_getSessionForWorld(player, worldId)
	local definition = PortalRules.getWorld(worldId)
	local area = self.worlds[worldId]
	if session == nil or definition == nil or area == nil then
		self:_resetToVillageState(player, true)
		self.PlayerStateService.message(player, "Returned to TinyWorld village.")
		return
	end
	local collected = PortalSessionRules.collectedCount(session)
	local mechanisms = PortalSessionRules.mechanicCount(session)
	local requiredMechanisms = mechanicTarget(area)
	if not PortalSessionRules.canFinish(session, definition.collectibleCount, requiredMechanisms) then
		self.PlayerStateService.message(
			player,
			string.format(
				"The return reward is not ready yet: %d/%d %ss and %d/%d %s interaction(s).",
				collected,
				definition.collectibleCount,
				definition.collectibleName,
				mechanisms,
				requiredMechanisms,
				area.mechanicName or "world"
			)
		)
		return
	end
	local profile = self.ProfileStore.get(player)
	if profile == nil or not PortalRules.completeWorld(profile, worldId) then
		self.PlayerStateService.message(
			player,
			"Your collection is full for this world reward. Make room and try the return portal again."
		)
		return
	end
	self:_resetToVillageState(player, true)
	self.PlayerStateService.sync(player, profile)
	if self.PlotService then
		self.PlotService:refreshKeepsakes(player, profile)
	end
	self.ProfileStore.save(player)
	TinyAnalyticsService.log(player, AnalyticsEvents.PortalCompleted)
	TinyAnalyticsService.log(player, AnalyticsEvents.CurrencyEarned, definition.coins)
	self.PlayerStateService.message(
		player,
		definition.completionMessage .. " A keepsake is now displayed back at home."
	)
end

function PortalService:removePlayer(player: Player)
	self.sessions[player] = nil
	local connection = self.characterConnections[player]
	if connection then
		connection:Disconnect()
		self.characterConnections[player] = nil
	end
end

return PortalService
