local Progression
if script ~= nil then
	Progression = require(script.Parent:WaitForChild("Progression"))
else
	Progression = require("./Progression")
end

local RouteRules = {}

RouteRules.COMPLETE_COUNT = 3
RouteRules.TASK_BITS = {
	daily_reward = 1,
	courier_delivery = 2,
	garden_harvest = 4,
	boundary_route = 8,
	home_design = 16,
}
RouteRules.REWARDS = {
	daily = { coins = 75, xp = 25 },
	weekly = { coins = 250, xp = 100 },
}

local DAILY_ROTATIONS = {
	{ "daily_reward", "courier_delivery", "garden_harvest" },
	{ "daily_reward", "courier_delivery", "boundary_route" },
	{ "daily_reward", "garden_harvest", "home_design" },
	{ "daily_reward", "boundary_route", "home_design" },
}

local WEEKLY_ROTATIONS = {
	{ "courier_delivery", "garden_harvest", "boundary_route" },
	{ "courier_delivery", "boundary_route", "home_design" },
	{ "garden_harvest", "boundary_route", "home_design" },
	{ "courier_delivery", "garden_harvest", "home_design" },
}

local function parseDayKey(dayKey: string): (number, number, number)
	local year, month, day = string.match(dayKey, "^(%d%d%d%d)%-(%d%d)%-(%d%d)$")
	return tonumber(year) or 1970, tonumber(month) or 1, tonumber(day) or 1
end

-- A deterministic proleptic Gregorian day number. It keeps route rotation
-- independent of the machine's local timezone and daylight-saving rules.
local function dayIndex(dayKey: string): number
	local year, month, day = parseDayKey(dayKey)
	local adjustedYear = year - (if month <= 2 then 1 else 0)
	local era = math.floor(adjustedYear / 400)
	local yearOfEra = adjustedYear - era * 400
	local monthPrime = month + (if month > 2 then -3 else 9)
	local dayOfYear = math.floor((153 * monthPrime + 2) / 5) + day - 1
	local dayOfEra = yearOfEra * 365 + math.floor(yearOfEra / 4) - math.floor(yearOfEra / 100) + dayOfYear
	return era * 146097 + dayOfEra
end

local function rotationIndex(scope: string, periodKey: string): number
	local index
	if scope == "daily" then
		index = dayIndex(periodKey)
	else
		local encodedWeek = string.match(periodKey, "^week%-(%-?%d+)$")
		index = tonumber(encodedWeek) or math.floor(dayIndex(periodKey) / 7)
	end
	local rotationCount = if scope == "daily" then #DAILY_ROTATIONS else #WEEKLY_ROTATIONS
	return (index % rotationCount) + 1
end

local function rotationsFor(scope: string)
	return if scope == "daily" then DAILY_ROTATIONS else WEEKLY_ROTATIONS
end

local function periodFields(scope: string): (string, string, string)
	if scope == "daily" then
		return "dailyRouteDay", "dailyRouteMask", "dailyRouteClaimedDay"
	end
	return "weeklyRouteWeek", "weeklyRouteMask", "weeklyRouteClaimedWeek"
end

local function hasBit(mask: number, bit: number): boolean
	return (mask % (bit * 2)) >= bit
end

local function targetMask(scope: string, periodKey: string): number
	local target = 0
	for _, taskId in RouteRules.taskIds(scope, periodKey) do
		target += RouteRules.TASK_BITS[taskId]
	end
	return target
end

function RouteRules.dayKey(timestamp: number?): string
	return os.date("!%Y-%m-%d", timestamp or os.time())
end

function RouteRules.weekKey(timestamp: number?): string
	return RouteRules.weekKeyForDay(RouteRules.dayKey(timestamp))
end

function RouteRules.weekKeyForDay(dayKey: string): string
	return string.format("week-%d", math.floor(dayIndex(dayKey) / 7))
end

function RouteRules.taskIds(scope: string, periodKey: string): { string }
	local rotations = rotationsFor(scope)
	local selected = rotations[rotationIndex(scope, periodKey)]
	local result = {}
	for _, taskId in selected do
		table.insert(result, taskId)
	end
	return result
end

function RouteRules.hasTask(scope: string, periodKey: string, taskId: string): boolean
	local bit = RouteRules.TASK_BITS[taskId]
	if bit == nil then
		return false
	end
	for _, selectedTask in RouteRules.taskIds(scope, periodKey) do
		if selectedTask == taskId then
			return true
		end
	end
	return false
end

function RouteRules.total(scope: string, periodKey: string): number
	return #RouteRules.taskIds(scope, periodKey)
end

function RouteRules.count(profile: any, scope: string, periodKey: string): number
	local periodField, maskField = periodFields(scope)
	if profile[periodField] ~= periodKey then
		return 0
	end
	local mask = profile[maskField] or 0
	local count = 0
	for _, taskId in RouteRules.taskIds(scope, periodKey) do
		if hasBit(mask, RouteRules.TASK_BITS[taskId]) then
			count += 1
		end
	end
	return count
end

function RouteRules.isComplete(profile: any, scope: string, periodKey: string): boolean
	local periodField, _maskField, claimedField = periodFields(scope)
	return profile[periodField] == periodKey and profile[claimedField] == periodKey
end

function RouteRules.progress(profile: any, scope: string, periodKey: string): (number, number, boolean)
	return RouteRules.count(profile, scope, periodKey),
		RouteRules.total(scope, periodKey),
		RouteRules.isComplete(profile, scope, periodKey)
end

function RouteRules.record(profile: any, scope: string, taskId: string, periodKey: string): (boolean, string, boolean)
	if scope ~= "daily" and scope ~= "weekly" then
		return false, "unknown_scope", false
	end
	local bit = RouteRules.TASK_BITS[taskId]
	if bit == nil or not RouteRules.hasTask(scope, periodKey, taskId) then
		return false, "not_in_route", false
	end

	local periodField, maskField, claimedField = periodFields(scope)
	if profile[periodField] ~= periodKey then
		profile[periodField] = periodKey
		profile[maskField] = 0
		profile[claimedField] = ""
	end
	if profile[claimedField] == periodKey then
		return false, "already_claimed", false
	end

	local mask = profile[maskField] or 0
	if hasBit(mask, bit) then
		return false, "already_recorded", false
	end
	mask += bit
	profile[maskField] = mask
	local complete = mask == targetMask(scope, periodKey)
	if complete then
		profile[claimedField] = periodKey
		local reward = RouteRules.REWARDS[scope]
		profile.coins += reward.coins
		Progression.addXp(profile, reward.xp)
		return true, "completed", true
	end
	return true, "recorded", false
end

return RouteRules
