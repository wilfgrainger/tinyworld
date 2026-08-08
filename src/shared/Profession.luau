local Profession = {}

local function isFiniteNumber(value: any): boolean
	return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

function Profession.xpForNextCourierLevel(level: number): number
	local safeLevel = math.max(1, math.floor(level))
	return 200 + ((safeLevel - 1) * 100)
end

function Profession.addCourierXp(profile: any, amount: number): number
	if not isFiniteNumber(amount) or amount <= 0 then
		return 0
	end
	local grant = math.floor(amount)
	if grant <= 0 then
		return 0
	end
	profile.courierXp += grant
	local gained = 0
	while profile.courierXp >= Profession.xpForNextCourierLevel(profile.courierLevel) do
		local threshold = Profession.xpForNextCourierLevel(profile.courierLevel)
		profile.courierXp -= threshold
		profile.courierLevel += 1
		gained += 1
	end
	return gained
end

return Profession
