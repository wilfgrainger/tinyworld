local TestUtil = require("./TestUtil")
local ProfileSchema = require("../src/shared/ProfileSchema")
local RouteRules = require("../src/shared/RouteRules")

return function()
	local profile = ProfileSchema.new()
	local day = "2026-08-09"
	local week = RouteRules.weekKeyForDay(day)

	local dailyTasks = RouteRules.taskIds("daily", day)
	TestUtil.equal(#dailyTasks, 3)
	TestUtil.isTrue(RouteRules.hasTask("daily", day, "daily_reward"))
	TestUtil.equal(RouteRules.count(profile, "daily", day), 0)
	TestUtil.equal(RouteRules.total("daily", day), 3)
	TestUtil.isFalse(RouteRules.isComplete(profile, "daily", day))

	local changed, reason, complete = RouteRules.record(profile, "daily", "daily_reward", day)
	TestUtil.isTrue(changed)
	TestUtil.equal(reason, "recorded")
	TestUtil.isFalse(complete)
	TestUtil.equal(RouteRules.count(profile, "daily", day), 1)
	TestUtil.equal(profile.coins, 100)

	changed, reason = RouteRules.record(profile, "daily", "daily_reward", day)
	TestUtil.isFalse(changed)
	TestUtil.equal(reason, "already_recorded")
	TestUtil.equal(profile.coins, 100)

	local remaining = {}
	for _, taskId in dailyTasks do
		if taskId ~= "daily_reward" then
			table.insert(remaining, taskId)
		end
	end
	changed, reason, complete = RouteRules.record(profile, "daily", remaining[1], day)
	TestUtil.isTrue(changed)
	TestUtil.equal(reason, "recorded")
	TestUtil.isFalse(complete)
	changed, reason, complete = RouteRules.record(profile, "daily", remaining[2], day)
	TestUtil.isTrue(changed)
	TestUtil.equal(reason, "completed")
	TestUtil.isTrue(complete)
	TestUtil.isTrue(RouteRules.isComplete(profile, "daily", day))
	TestUtil.equal(profile.coins, 175)
	TestUtil.equal(profile.xp, 25)

	changed, reason = RouteRules.record(profile, "daily", remaining[2], day)
	TestUtil.isFalse(changed)
	TestUtil.equal(reason, "already_claimed")
	TestUtil.equal(profile.coins, 175)
	TestUtil.equal(profile.xp, 25)

	local otherDay = "2026-08-10"
	TestUtil.isTrue(RouteRules.hasTask("daily", otherDay, "daily_reward"))
	TestUtil.isFalse(table.concat(RouteRules.taskIds("daily", day), ",") == table.concat(RouteRules.taskIds("daily", otherDay), ","))
	TestUtil.equal(RouteRules.count(profile, "daily", otherDay), 0)
	changed, reason = RouteRules.record(profile, "daily", "daily_reward", otherDay)
	TestUtil.isTrue(changed)
	TestUtil.equal(reason, "recorded")
	TestUtil.equal(profile.dailyRouteDay, otherDay)
	TestUtil.equal(profile.dailyRouteClaimedDay, "")

	changed, reason = RouteRules.record(profile, "daily", "not_a_task", otherDay)
	TestUtil.isFalse(changed)
	TestUtil.equal(reason, "not_in_route")

	local weeklyTasks = RouteRules.taskIds("weekly", week)
	TestUtil.equal(#weeklyTasks, 3)
	for _, taskId in weeklyTasks do
		changed, reason = RouteRules.record(profile, "weekly", taskId, week)
		TestUtil.isTrue(changed)
		TestUtil.isTrue(reason == "recorded" or reason == "completed")
	end
	TestUtil.isTrue(RouteRules.isComplete(profile, "weekly", week))
	TestUtil.equal(profile.coins, 425)
	TestUtil.equal(profile.level, 2)
	TestUtil.equal(profile.xp, 25)
	local nextWeek = RouteRules.weekKeyForDay("2026-08-16")
	TestUtil.isFalse(table.concat(RouteRules.taskIds("weekly", week), ",") == table.concat(RouteRules.taskIds("weekly", nextWeek), ","))

	local legacy = ProfileSchema.normalize({ version = 5, coins = 500 })
	TestUtil.equal(legacy.version, 7)
	TestUtil.equal(legacy.homeItems.Bed, 1)
	TestUtil.equal(legacy.homeUseCount, 0)
	TestUtil.equal(legacy.dailyRouteDay, "")
	TestUtil.equal(legacy.dailyRouteMask, 0)
	TestUtil.equal(legacy.dailyRouteClaimedDay, "")
	TestUtil.equal(legacy.weeklyRouteWeek, "")
	TestUtil.equal(legacy.weeklyRouteMask, 0)
	TestUtil.equal(legacy.weeklyRouteClaimedWeek, "")

	local repaired = ProfileSchema.normalize({
		dailyRouteDay = day,
		dailyRouteMask = 999,
		dailyRouteClaimedDay = day,
		weeklyRouteWeek = week,
		weeklyRouteMask = -2,
		weeklyRouteClaimedWeek = week,
	})
	TestUtil.equal(repaired.dailyRouteMask, 15)
	TestUtil.equal(repaired.weeklyRouteMask, 0)
	TestUtil.equal(repaired.dailyRouteClaimedDay, day)
	TestUtil.equal(repaired.weeklyRouteClaimedWeek, week)
end
