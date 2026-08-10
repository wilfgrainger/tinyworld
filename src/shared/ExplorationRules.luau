local Progression
if script ~= nil then
	Progression = require(script.Parent:WaitForChild("Progression"))
else
	Progression = require("./Progression")
end

local ExplorationRules = {}

ExplorationRules.REWARD_COINS = 250
ExplorationRules.REWARD_XP = 100
ExplorationRules.COMPLETE_MASK = 7
ExplorationRules.LANDMARK_MASKS = {
	woodlandTrail = 1,
	cliffLookout = 2,
	seaDock = 4,
}

local function prepareDay(profile, dayKey: string)
	if profile.boundaryExplorationDay ~= dayKey then
		profile.boundaryExplorationDay = dayKey
		profile.boundaryExplorationMask = 0
	end
end

local function hasMask(mask: number, bit: number): boolean
	return (mask % (bit * 2)) >= bit
end

function ExplorationRules.count(profile): number
	local mask = profile.boundaryExplorationMask
	local count = 0
	for _, bit in ExplorationRules.LANDMARK_MASKS do
		if hasMask(mask, bit) then
			count += 1
		end
	end
	return count
end

function ExplorationRules.visit(profile, landmark: string, dayKey: string): (boolean, string)
	local bit = ExplorationRules.LANDMARK_MASKS[landmark]
	if bit == nil then
		return false, "unknown_landmark"
	end
	prepareDay(profile, dayKey)
	if hasMask(profile.boundaryExplorationMask, bit) then
		return false, "already_visited"
	end
	profile.boundaryExplorationMask += bit
	return true, "visited"
end

function ExplorationRules.claim(profile, dayKey: string): (boolean, string)
	prepareDay(profile, dayKey)
	if profile.boundaryExplorationClaimedDay == dayKey then
		return false, "already_claimed"
	end
	if profile.boundaryExplorationMask ~= ExplorationRules.COMPLETE_MASK then
		return false, "incomplete"
	end
	profile.boundaryExplorationClaimedDay = dayKey
	profile.boundaryExplorationMask = 0
	profile.coins += ExplorationRules.REWARD_COINS
	Progression.addXp(profile, ExplorationRules.REWARD_XP)
	profile.boundaryCompletions += 1
	return true, "claimed"
end

return ExplorationRules
