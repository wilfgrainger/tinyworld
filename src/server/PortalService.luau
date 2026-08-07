local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local PortalRules = require(shared:WaitForChild("PortalRules"))

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

	world.villagePortalPrompt.Triggered:Connect(function(player)
		self:_start(player)
	end)
	for index, prompt in world.kitchen.crystalPrompts do
		prompt.Triggered:Connect(function(player)
			self:_collect(player, index)
		end)
	end
	world.kitchen.returnPrompt.Triggered:Connect(function(player)
		self:_finish(player)
	end)
	return self
end

function PortalService:_start(player: Player)
	if self.ProfileStore.get(player) == nil then
		return
	end
	self.sessions[player] = { active = true, collected = {} }
	player:SetAttribute("TinyWorldPortalCrystals", 0)
	teleport(player, self.world.kitchen.arrivalCFrame)
	self.PlayerStateService.message(player, "Portal mission started: collect all 3 Sugar Crystals, then find the return portal.")
end

function PortalService:_collect(player: Player, index: number)
	local session = self.sessions[player]
	if session == nil or not session.active then
		self.PlayerStateService.message(player, "Enter the Giant Kitchen through the village portal to start this mission.")
		return
	end
	if session.collected[index] then
		self.PlayerStateService.message(player, "You already collected this crystal on this run.")
		return
	end
	session.collected[index] = true
	local count = collectedCount(session)
	player:SetAttribute("TinyWorldPortalCrystals", count)
	self.PlayerStateService.message(player, string.format("Sugar Crystal found: %d/3.", count))
end

function PortalService:_finish(player: Player)
	local session = self.sessions[player]
	if session == nil or not session.active then
		teleport(player, self.world.villageReturnCFrame)
		self.PlayerStateService.message(player, "Returned to TinyWorld village.")
		return
	end
	local count = collectedCount(session)
	if count < 3 then
		self.PlayerStateService.message(player, string.format("The portal needs all 3 crystals. You have %d/3.", count))
		return
	end
	local profile = self.ProfileStore.get(player)
	if profile == nil then
		return
	end
	PortalRules.completeGiantKitchen(profile)
	self.sessions[player] = nil
	player:SetAttribute("TinyWorldPortalCrystals", 0)
	self.PlayerStateService.sync(player, profile)
	self.ProfileStore.save(player)
	teleport(player, self.world.villageReturnCFrame)
	self.PlayerStateService.message(player, "Giant Kitchen complete: +300 coins, +200 XP, +1 permanent Sugar Crystal!")
end

function PortalService:removePlayer(player: Player)
	self.sessions[player] = nil
end

return PortalService
