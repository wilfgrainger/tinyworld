local Progression = {}

local function isFiniteNumber(value: any): boolean
	return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

function Progression.xpForNextLevel(level: number): number
	local safeLevel = math.max(1, math.floor(level))
	return 100 + ((safeLevel - 1) * 50)
end

function Progression.addXp(profile: any, amount: number): number
	if not isFiniteNumber(amount) or amount <= 0 then
		return 0
	end

	local grant = math.floor(amount)
	if grant <= 0 then
		return 0
	end

	profile.xp += grant

	local levelsGained = 0
	while profile.xp >= Progression.xpForNextLevel(profile.level) do
		local threshold = Progression.xpForNextLevel(profile.level)
		profile.xp -= threshold
		profile.level += 1
		levelsGained += 1
	end

	return levelsGained
end

return Progression

