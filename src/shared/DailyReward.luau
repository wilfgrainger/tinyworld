local Inventory
local Progression

if script ~= nil then
	Inventory = require(script.Parent.Inventory)
	Progression = require(script.Parent.Progression)
else
	Inventory = require("./Inventory")
	Progression = require("./Progression")
end

local DailyReward = {}

function DailyReward.dayKey(timestamp: number?): string
	return os.date("!%Y-%m-%d", timestamp or os.time())
end

function DailyReward.claim(profile: any, dayKey: string): (boolean, string)
	if profile.lastDailyDay == dayKey then
		return false, "already_claimed"
	end
	profile.lastDailyDay = dayKey
	profile.coins += 200
	Progression.addXp(profile, 50)
	Inventory.add(profile, "Carrot", 1)
	return true, "claimed"
end

return DailyReward
