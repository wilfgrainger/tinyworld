local Profession = {}

local CATALOG = {
	Courier = { id = "Courier", name = "Courier", levelField = "courierLevel", xpField = "courierXp" },
	Farmer = { id = "Farmer", name = "Farmer", levelField = "farmerLevel", xpField = "farmerXp" },
	Designer = { id = "Designer", name = "Designer", levelField = "designerLevel", xpField = "designerXp" },
}

local function isFiniteNumber(value: any): boolean
	return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

function Profession.all()
	local result = {}
	for _, profession in CATALOG do
		table.insert(result, profession)
	end
	return result
end

function Profession.get(professionId: string)
	return CATALOG[professionId]
end

function Profession.xpForNextLevel(level: number): number
	local safeLevel = math.max(1, math.floor(level))
	return 200 + ((safeLevel - 1) * 100)
end

function Profession.xpForNextCourierLevel(level: number): number
	return Profession.xpForNextLevel(level)
end

function Profession.addXp(profile: any, professionId: string, amount: number): number
	local profession = CATALOG[professionId]
	if profession == nil then
		return 0
	end
	if not isFiniteNumber(amount) or amount <= 0 then
		return 0
	end
	local grant = math.floor(amount)
	if grant <= 0 then
		return 0
	end
	local levelField = profession.levelField
	local xpField = profession.xpField
	profile[levelField] = math.max(1, math.floor(profile[levelField] or 1))
	profile[xpField] = math.max(0, math.floor(profile[xpField] or 0))
	profile[xpField] += grant
	local gained = 0
	while profile[xpField] >= Profession.xpForNextLevel(profile[levelField]) do
		local threshold = Profession.xpForNextLevel(profile[levelField])
		profile[xpField] -= threshold
		profile[levelField] += 1
		gained += 1
	end
	return gained
end

function Profession.addCourierXp(profile: any, amount: number): number
	return Profession.addXp(profile, "Courier", amount)
end

return Profession

