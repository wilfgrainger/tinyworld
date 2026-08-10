local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local RouteRules = require(shared:WaitForChild("RouteRules"))

local RouteService = {}
RouteService.__index = RouteService

local function completionText(scope: string): string
	local reward = RouteRules.REWARDS[scope]
	return string.format(
		"%s route complete: +%d coins, +%d XP.",
		if scope == "daily" then "Today's" else "This week's",
		reward.coins,
		reward.xp
	)
end

function RouteService.new(ProfileStore, PlayerStateService)
	local self = setmetatable({}, RouteService)
	self.ProfileStore = ProfileStore
	self.PlayerStateService = PlayerStateService
	return self
end

function RouteService:sync(player: Player, profile)
	local day = RouteRules.dayKey()
	local week = RouteRules.weekKey()
	local dailyCount, dailyTotal, dailyComplete = RouteRules.progress(profile, "daily", day)
	local weeklyCount, weeklyTotal, weeklyComplete = RouteRules.progress(profile, "weekly", week)
	local dailyMask = if profile.dailyRouteDay == day then profile.dailyRouteMask else 0
	local weeklyMask = if profile.weeklyRouteWeek == week then profile.weeklyRouteMask else 0

	player:SetAttribute("TinyWorldDailyRouteDay", day)
	player:SetAttribute("TinyWorldDailyRouteMask", dailyMask)
	player:SetAttribute("TinyWorldDailyRouteCount", dailyCount)
	player:SetAttribute("TinyWorldDailyRouteTotal", dailyTotal)
	player:SetAttribute("TinyWorldDailyRouteComplete", dailyComplete)
	player:SetAttribute("TinyWorldWeeklyRouteWeek", week)
	player:SetAttribute("TinyWorldWeeklyRouteMask", weeklyMask)
	player:SetAttribute("TinyWorldWeeklyRouteCount", weeklyCount)
	player:SetAttribute("TinyWorldWeeklyRouteTotal", weeklyTotal)
	player:SetAttribute("TinyWorldWeeklyRouteComplete", weeklyComplete)
end

function RouteService:record(player: Player, taskId: string): (boolean, string)
	local profile = self.ProfileStore.get(player)
	if profile == nil then
		return false, ""
	end

	local day = RouteRules.dayKey()
	local week = RouteRules.weekKey()
	local dailyChanged, _dailyReason, dailyComplete = RouteRules.record(profile, "daily", taskId, day)
	local weeklyChanged, _weeklyReason, weeklyComplete = RouteRules.record(profile, "weekly", taskId, week)
	local changed = dailyChanged or weeklyChanged
	if not changed then
		return false, ""
	end

	self.PlayerStateService.sync(player, profile)
	self:sync(player, profile)
	local completions = {}
	if dailyComplete then
		table.insert(completions, completionText("daily"))
	end
	if weeklyComplete then
		table.insert(completions, completionText("weekly"))
	end
	return true, table.concat(completions, " ")
end

return RouteService
