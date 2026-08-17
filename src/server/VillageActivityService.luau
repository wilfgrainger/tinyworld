local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local Progression = require(shared:WaitForChild("Progression"))
local VillageActivityDefinitions = require(shared:WaitForChild("VillageActivityDefinitions"))
local VillageActivityRules = require(shared:WaitForChild("VillageActivityRules"))

local TraderRequestActivityService = require(script.Parent:WaitForChild("TraderRequestActivityService"))
local VillageGardenActivityService = require(script.Parent:WaitForChild("VillageGardenActivityService"))
local FishingActivityService = require(script.Parent:WaitForChild("FishingActivityService"))
local CoastalDeliveryActivityService = require(script.Parent:WaitForChild("CoastalDeliveryActivityService"))
local BuilderRepairActivityService = require(script.Parent:WaitForChild("BuilderRepairActivityService"))

local VillageActivityService = {}
VillageActivityService.__index = VillageActivityService

local function safeQuality(value: string?): string
	if value == "good" or value == "perfect" then
		return value
	end
	return "normal"
end

function VillageActivityService.new(world, ProfileStore, PlayerStateService, RouteService)
	local self = setmetatable({}, VillageActivityService)
	self.world = world
	self.ProfileStore = ProfileStore
	self.PlayerStateService = PlayerStateService
	self.RouteService = RouteService
	self.active = {}
	self.characterConnections = {}

	local hooks = {
		getState = function(player)
			return self.active[player]
		end,
		profile = function(player)
			return self.ProfileStore.get(player)
		end,
		message = function(player, text)
			self.PlayerStateService.message(player, text)
		end,
		finish = function(player, activityId, quality, detail, extraCoins)
			self:_finish(player, activityId, quality, detail, extraCoins)
		end,
		routeService = RouteService,
	}

	self.handlersByRole = {
		Trader = TraderRequestActivityService.new(world, hooks),
		Gardener = VillageGardenActivityService.new(world, hooks),
		Fisherman = FishingActivityService.new(world, hooks),
		BoatKeeper = CoastalDeliveryActivityService.new(world, hooks),
		Builder = BuilderRepairActivityService.new(world, hooks),
	}
	return self
end

function VillageActivityService:_clear(player: Player)
	self.active[player] = nil
	player:SetAttribute("TinyWorldVillageActivity", "")
end

function VillageActivityService:_handlerForState(state)
	if state == nil or type(state.role) ~= "string" then
		return nil
	end
	return self.handlersByRole[state.role]
end

function VillageActivityService:abandon(player: Player, silent: boolean?)
	local state = self.active[player]
	if state == nil then
		return
	end
	local definition = VillageActivityDefinitions.get(state.id)
	local handler = self:_handlerForState(state)
	if handler then
		if handler.abandonPlayer then
			handler:abandonPlayer(player)
		elseif handler.removePlayer then
			handler:removePlayer(player)
		end
	end
	self:_clear(player)
	if silent ~= true then
		self.PlayerStateService.message(
			player,
			"Left " .. (if definition then definition.displayName else "the current village activity") .. "."
		)
	end
end

function VillageActivityService:setupPlayer(player: Player)
	local existing = self.characterConnections[player]
	if existing then
		existing:Disconnect()
	end
	self.characterConnections[player] = player.CharacterAdded:Connect(function()
		self:abandon(player, true)
	end)
end

function VillageActivityService:_finish(
	player: Player,
	activityId: string,
	quality: string?,
	detail: string?,
	extraCoins: number?
)
	local state = self.active[player]
	if state == nil or state.id ~= activityId or not VillageActivityRules.canComplete(state.completed == true) then
		return
	end
	state.completed = true

	local definition = VillageActivityDefinitions.get(activityId)
	local profile = self.ProfileStore.get(player)
	if definition == nil or profile == nil then
		self:_clear(player)
		return
	end

	local resolvedQuality = safeQuality(quality)
	local bonusCoins = if type(extraCoins) == "number" then math.max(0, math.floor(extraCoins)) else 0
	local coins = VillageActivityRules.coinReward(definition.baseCoins, resolvedQuality) + bonusCoins
	profile.coins += coins
	Progression.addXp(profile, definition.baseXp)

	self:_clear(player)
	self.PlayerStateService.sync(player, profile)
	self.ProfileStore.save(player)

	local qualityText = if resolvedQuality == "normal" then "" else " · " .. string.upper(resolvedQuality) .. " bonus"
	local detailText = if detail and detail ~= "" then " " .. detail else ""
	self.PlayerStateService.message(
		player,
		string.format(
			"%s complete: +%d coins, +%d XP%s.%s",
			definition.displayName,
			coins,
			definition.baseXp,
			qualityText,
			detailText
		)
	)
end

function VillageActivityService:startForRole(player: Player, role: string)
	local definition = VillageActivityDefinitions.forRole(role)
	if definition == nil then
		self.PlayerStateService.message(player, "That village activity is not available yet.")
		return
	end
	if self.ProfileStore.get(player) == nil then
		return
	end

	local handler = self.handlersByRole[role]
	if handler == nil then
		self.PlayerStateService.message(player, "That activity station is still being prepared.")
		return
	end

	local current = self.active[player]
	if current ~= nil then
		local currentHandler = self:_handlerForState(current)
		if currentHandler and currentHandler.isActive and not currentHandler:isActive(player) then
			self:abandon(player, true)
			current = nil
		end
	end

	if current ~= nil then
		if current.id == definition.id then
			handler:interact(player, current)
			return
		end
		local currentDefinition = VillageActivityDefinitions.get(current.id)
		self:abandon(player, true)
		self.PlayerStateService.message(
			player,
			"Left "
				.. (if currentDefinition then currentDefinition.displayName else "your current activity")
				.. " to start "
				.. definition.displayName
				.. "."
		)
	end
	if not VillageActivityRules.canStart(nil) then
		return
	end

	local state = {
		id = definition.id,
		role = role,
		startedAt = os.clock(),
		completed = false,
	}
	self.active[player] = state
	player:SetAttribute("TinyWorldVillageActivity", definition.id)

	local ok, reason = handler:start(player, state)
	if not ok then
		self:_clear(player)
		self.PlayerStateService.message(player, reason or "That activity could not start safely. Try again.")
	end
end

function VillageActivityService:removePlayer(player: Player)
	for _, handler in self.handlersByRole do
		if handler.removePlayer then
			handler:removePlayer(player)
		end
	end
	self.active[player] = nil
	local connection = self.characterConnections[player]
	if connection then
		connection:Disconnect()
		self.characterConnections[player] = nil
	end
end

function VillageActivityService:stop()
	for _, connection in self.characterConnections do
		connection:Disconnect()
	end
	table.clear(self.characterConnections)
	for _, handler in self.handlersByRole do
		if handler.stop then
			handler:stop()
		end
	end
end

return VillageActivityService
