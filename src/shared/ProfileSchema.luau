local ProfileSchema = {}

ProfileSchema.VERSION = 1
ProfileSchema.MAX_HOUSE_TIER = 5

export type PlayerProfile = {
	version: number,
	coins: number,
	level: number,
	xp: number,
	houseTier: number,
}

local DEFAULTS: PlayerProfile = {
	version = ProfileSchema.VERSION,
	coins = 100,
	level = 1,
	xp = 0,
	houseTier = 1,
}

local function isFiniteNumber(value: any): boolean
	return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

local function normaliseInteger(value: any, fallback: number, minimum: number, maximum: number?): number
	if not isFiniteNumber(value) then
		return fallback
	end

	local integer = math.floor(value)
	if integer < minimum then
		return minimum
	end
	if maximum ~= nil and integer > maximum then
		return maximum
	end
	return integer
end

function ProfileSchema.new(): PlayerProfile
	return {
		version = DEFAULTS.version,
		coins = DEFAULTS.coins,
		level = DEFAULTS.level,
		xp = DEFAULTS.xp,
		houseTier = DEFAULTS.houseTier,
	}
end

function ProfileSchema.normalize(value: any): PlayerProfile
	if type(value) ~= "table" then
		return ProfileSchema.new()
	end

	return {
		version = ProfileSchema.VERSION,
		coins = normaliseInteger(value.coins, DEFAULTS.coins, 0),
		level = normaliseInteger(value.level, DEFAULTS.level, 1),
		xp = normaliseInteger(value.xp, DEFAULTS.xp, 0),
		houseTier = normaliseInteger(value.houseTier, DEFAULTS.houseTier, 1, ProfileSchema.MAX_HOUSE_TIER),
	}
end

return ProfileSchema
