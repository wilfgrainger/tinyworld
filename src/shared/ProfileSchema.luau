local ProfileSchema = {}

ProfileSchema.VERSION = 2
ProfileSchema.MAX_HOUSE_TIER = 5

export type GardenBed = { stage: string, readyAt: number }
export type Inventory = { Carrot: number, SugarCrystal: number }
export type PlayerProfile = {
version: number,
coins: number,
level: number,
xp: number,
houseTier: number,
inventory: Inventory,
courierLevel: number,
courierXp: number,
ownsTinyBike: boolean,
bikeActive: boolean,
gardenBeds: { GardenBed },
lastDailyDay: string,
portalCompletions: number,
villageContribution: number,
homePrivacy: string,
}

local VALID_GARDEN_STAGES = { empty = true, planted = true, watered = true, ready = true }
local VALID_PRIVACY = { Open = true, Friends = true, Private = true }

local function isFiniteNumber(value: any): boolean
	return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

local function normaliseInteger(value: any, fallback: number, minimum: number, maximum: number?): number
	if not isFiniteNumber(value) then return fallback end
	local integer = math.floor(value)
	if integer < minimum then return minimum end
	if maximum ~= nil and integer > maximum then return maximum end
	return integer
end

local function newGardenBed(): GardenBed
	return { stage = "empty", readyAt = 0 }
end

local function normaliseGardenBed(value: any): GardenBed
	if type(value) ~= "table" then return newGardenBed() end
	local stage = if type(value.stage) == "string" and VALID_GARDEN_STAGES[value.stage] then value.stage else "empty"
	local readyAt = normaliseInteger(value.readyAt, 0, 0)
	if stage == "empty" or stage == "planted" then readyAt = 0 end
	return { stage = stage, readyAt = readyAt }
end

local function normaliseGardenBeds(value: any): { GardenBed }
	local beds = {}
	for index = 1, 3 do
		local raw = if type(value) == "table" then value[index] else nil
		beds[index] = normaliseGardenBed(raw)
	end
	return beds
end

local function normaliseInventory(value: any): Inventory
	local inventory = if type(value) == "table" then value else {}
	return {
		Carrot = normaliseInteger(inventory.Carrot, 0, 0),
		SugarCrystal = normaliseInteger(inventory.SugarCrystal, 0, 0),
	}
end

function ProfileSchema.new(): PlayerProfile
	return {
		version = 2,
		coins = 100,
		level = 1,
		xp = 0,
		houseTier = 1,
		inventory = { Carrot = 0, SugarCrystal = 0 },
		courierLevel = 1,
		courierXp = 0,
		ownsTinyBike = false,
		bikeActive = false,
		gardenBeds = { newGardenBed(), newGardenBed(), newGardenBed() },
		lastDailyDay = "",
		portalCompletions = 0,
		villageContribution = 0,
		homePrivacy = "Open",
	}
end

function ProfileSchema.normalize(value: any): PlayerProfile
	if type(value) ~= "table" then return ProfileSchema.new() end
	local privacy = if type(value.homePrivacy) == "string" and VALID_PRIVACY[value.homePrivacy] then value.homePrivacy else "Open"
	return {
		version = 2,
		coins = normaliseInteger(value.coins, 100, 0),
		level = normaliseInteger(value.level, 1, 1),
		xp = normaliseInteger(value.xp, 0, 0),
		houseTier = normaliseInteger(value.houseTier, 1, 1, 5),
		inventory = normaliseInventory(value.inventory),
		courierLevel = normaliseInteger(value.courierLevel, 1, 1),
		courierXp = normaliseInteger(value.courierXp, 0, 0),
		ownsTinyBike = if type(value.ownsTinyBike) == "boolean" then value.ownsTinyBike else false,
		bikeActive = if type(value.bikeActive) == "boolean" then value.bikeActive else false,
		gardenBeds = normaliseGardenBeds(value.gardenBeds),
		lastDailyDay = if type(value.lastDailyDay) == "string" then value.lastDailyDay else "",
		portalCompletions = normaliseInteger(value.portalCompletions, 0, 0),
		villageContribution = normaliseInteger(value.villageContribution, 0, 0),
		homePrivacy = privacy,
	}
end

return ProfileSchema
