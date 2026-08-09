local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local PortalRules = require(shared:WaitForChild("PortalRules"))
local AnalyticsEvents = require(shared:WaitForChild("AnalyticsEvents"))
local TinyAnalyticsService = require(script.Parent:WaitForChild("AnalyticsService"))

local PortalService = {}
PortalService.__index = PortalService

local function teleport(player: Player, target: CFrame)
	local character = player.Character
	if character then
		character:PivotTo(target)
	end
end

local function collectedCount(session): number
	local count = 0
	for _, collected in session.collected do
		if collected then
			count += 1
		end
	end
	return count
end

function PortalService.new(world, ProfileStore, PlayerStateService)
	local self = setmetatable({}, PortalService)
	self.world = world
	self.ProfileStore = ProfileStore
	self.PlayerStateService = PlayerStateService
	self.sessions = {}
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
	area.returnPrompt.Triggered:Connect(function(player)
		self:_finish(player, worldId)
	end)
end

function PortalService:setupPlayer(player: Player)
	player:SetAttribute("TinyWorldPortalCrystals", 0)
	player:SetAttribute("TinyWorldPortalWorld", "Village")
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
	self.sessions[player] = { active = true, worldId = worldId, collected = {} }
	player:SetAttribute("TinyWorldPortalCrystals", 0)
	player:SetAttribute("TinyWorldPortalWorld", worldId)
	teleport(player, area.arrivalCFrame)
	TinyAnalyticsService.log(player, AnalyticsEvents.PortalEntered)
	self.PlayerStateService.message(
		player,
		string.format(
			"Portal mission started: find all %d %ss in %s, then return through the portal.",
			definition.collectibleCount,
			definition.collectibleName,
			definition.displayName
		)
	)
end

function PortalService:_collect(player: Player, worldId: string, index: number)
	local session = self.sessions[player]
	local definition = PortalRules.getWorld(worldId)
	if session == nil or not session.active or session.worldId ~= worldId or definition == nil then
		self.PlayerStateService.message(player, "Enter this world through its village portal to start the mission.")
		return
	end
	if session.collected[index] then
		self.PlayerStateService.message(
			player,
			string.format("You already collected this %s on this run.", definition.collectibleName)
		)
		return
	end
	session.collected[index] = true
	local count = collectedCount(session)
	player:SetAttribute("TinyWorldPortalCrystals", count)
	self.PlayerStateService.message(
		player,
		string.format("%s found: %d/%d.", definition.collectibleName, count, definition.collectibleCount)
	)
end

function PortalService:_finish(player: Player, worldId: string)
	local session = self.sessions[player]
	local definition = PortalRules.getWorld(worldId)
	if session == nil or not session.active or session.worldId ~= worldId or definition == nil then
		teleport(player, self.world.villageReturnCFrame)
		player:SetAttribute("TinyWorldPortalWorld", "Village")
		self.PlayerStateService.message(player, "Returned to TinyWorld village.")
		return
	end
	local count = collectedCount(session)
	if count < definition.collectibleCount then
		self.PlayerStateService.message(
			player,
			string.format(
				"The portal needs all %d %ss. You have %d/%d.",
				definition.collectibleCount,
				definition.collectibleName,
				count,
				definition.collectibleCount
			)
		)
		return
	end
	local profile = self.ProfileStore.get(player)
	if profile == nil or not PortalRules.completeWorld(profile, worldId) then
		return
	end
	self.sessions[player] = nil
	player:SetAttribute("TinyWorldPortalCrystals", 0)
	player:SetAttribute("TinyWorldPortalWorld", "Village")
	self.PlayerStateService.sync(player, profile)
	self.ProfileStore.save(player)
	teleport(player, self.world.villageReturnCFrame)
	TinyAnalyticsService.log(player, AnalyticsEvents.PortalCompleted)
	self.PlayerStateService.message(player, definition.completionMessage)
end

function PortalService:removePlayer(player: Player)
	self.sessions[player] = nil
end

return PortalService
