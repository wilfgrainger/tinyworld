local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local DailyReward = require(shared:WaitForChild("DailyReward"))
local LivingWorldRules = require(shared:WaitForChild("LivingWorldRules"))

local LivingWorldService = {}
LivingWorldService.__index = LivingWorldService

local DISPLAY_NAMES = {
	MeadowSeed = "Meadow Seed",
	Seashell = "Seashell",
	WoodToken = "Wood Token",
}

function LivingWorldService.new(world, ProfileStore, PlayerStateService)
	local self = setmetatable({}, LivingWorldService)
	self.ProfileStore = ProfileStore
	self.PlayerStateService = PlayerStateService
	for itemName, prompt in world.livingWorld.pickupPrompts do
		prompt.Triggered:Connect(function(player)
			self:_collect(player, itemName)
		end)
	end
	return self
end

function LivingWorldService:_collect(player: Player, itemName: string)
	local profile = self.ProfileStore.get(player)
	if profile == nil then
		return
	end

	local collected, reason = LivingWorldRules.collect(profile, itemName, DailyReward.dayKey())
	if collected then
		self.PlayerStateService.sync(player, profile)
		self.PlayerStateService.message(
			player,
			"Found a "
				.. (DISPLAY_NAMES[itemName] or itemName)
				.. ". Find the other village keepsakes for a Home Charm."
		)
		self.ProfileStore.save(player)
	elseif reason == "already_collected" then
		self.PlayerStateService.message(
			player,
			"You already found today's " .. (DISPLAY_NAMES[itemName] or itemName) .. "."
		)
	end
end

return LivingWorldService
