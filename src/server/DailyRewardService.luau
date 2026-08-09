local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local DailyReward = require(shared:WaitForChild("DailyReward"))
local AnalyticsEvents = require(shared:WaitForChild("AnalyticsEvents"))
local TinyAnalyticsService = require(script.Parent:WaitForChild("AnalyticsService"))

local DailyRewardService = {}
DailyRewardService.__index = DailyRewardService

function DailyRewardService.new(world, ProfileStore, PlayerStateService, RouteService)
	local self = setmetatable({}, DailyRewardService)
	self.ProfileStore = ProfileStore
	self.PlayerStateService = PlayerStateService
	self.RouteService = RouteService

	world.dailyPrompt.Triggered:Connect(function(player)
		local profile = ProfileStore.get(player)
		if profile == nil then
			return
		end
		local claimed, reason = DailyReward.claim(profile, DailyReward.dayKey())
		if claimed then
			local _routeChanged, routeText = self.RouteService:record(player, "daily_reward")
			PlayerStateService.sync(player, profile)
			local suffix = if routeText == "" then "" else " " .. routeText
			PlayerStateService.message(player, "Daily reward claimed: +200 coins, +50 XP, +1 Carrot." .. suffix)
			ProfileStore.save(player)
			TinyAnalyticsService.log(player, AnalyticsEvents.CurrencyEarned, 200)
		elseif reason == "already_claimed" then
			PlayerStateService.message(player, "You already claimed today's village reward. Come back tomorrow.")
		elseif reason == "inventory_full" then
			PlayerStateService.message(player, "Your Carrot stack is full. Make room before claiming today's village reward.")
		end
	end)

	return self
end

return DailyRewardService