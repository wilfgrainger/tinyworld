local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local DailyReward = require(shared:WaitForChild("DailyReward"))

local DailyRewardService = {}
DailyRewardService.__index = DailyRewardService

function DailyRewardService.new(world, ProfileStore, PlayerStateService)
	local self = setmetatable({}, DailyRewardService)
	self.ProfileStore = ProfileStore
	self.PlayerStateService = PlayerStateService

	world.dailyPrompt.Triggered:Connect(function(player)
		local profile = ProfileStore.get(player)
		if profile == nil then
			return
		end
		local claimed, reason = DailyReward.claim(profile, DailyReward.dayKey())
		if claimed then
			PlayerStateService.sync(player, profile)
			PlayerStateService.message(player, "Daily reward claimed: +200 coins, +50 XP, +1 Carrot.")
			ProfileStore.save(player)
		elseif reason == "already_claimed" then
			PlayerStateService.message(player, "You already claimed today's village reward. Come back tomorrow.")
		end
	end)

	return self
end

return DailyRewardService
