local VillageActivityRules = {}

local QUALITY_MULTIPLIER = {
	normal = 1.0,
	good = 1.15,
	perfect = 1.30,
}

function VillageActivityRules.coinReward(baseCoins: number, quality: string): number
	local multiplier = QUALITY_MULTIPLIER[quality] or QUALITY_MULTIPLIER.normal
	return math.floor((baseCoins * multiplier) + 1e-6)
end

function VillageActivityRules.gradeTiming(elapsed: number, goodMax: number, perfectMax: number): string
	if elapsed < 0 then
		return "normal"
	end
	if elapsed <= perfectMax then
		return "perfect"
	end
	if elapsed <= goodMax then
		return "good"
	end
	return "normal"
end

function VillageActivityRules.canStart(activeId: string?): boolean
	return activeId == nil
end

function VillageActivityRules.validTarget(expected: string?, actual: string?): boolean
	return expected ~= nil and expected == actual
end

function VillageActivityRules.canComplete(completed: boolean): boolean
	return not completed
end

return VillageActivityRules
