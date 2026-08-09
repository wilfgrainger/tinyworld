local ProfileSchema = {}

ProfileSchema.VERSION = 9
ProfileSchema.MAX_HOUSE_TIER = 5

local HomeExpressionRules
if script ~= nil then
	HomeExpressionRules = require(script.Parent:WaitForChild("HomeExpressionRules"))
else
	HomeExpressionRules = require("./HomeExpressionRules")
end

export type GardenBed = { stage: string, readyAt: number }
export type Inventory = { Carrot: number, SugarCrystal: number, MeadowSeed: number, Seashell: number, WoodToken: number }
export type PlayerProfile = {
version: number,
coins: number,
level: number,
xp: number,
houseTier: number,
inventory: Inventory,
courierLevel: number,
courierXp: number,
farmerLevel: number,
farmerXp: number,
designerLevel: number,
designerXp: number,
ownsTinyBike: boolean,
bikeActive: boolean,
gardenBeds: { GardenBed },
lastDailyDay: string,
portalCompletions: number,
villageContribution: number,
boundaryExplorationDay: string,
boundaryExplorationClaimedDay: string,
boundaryExplorationMask: number,
boundaryCompletions: number,
homePrivacy: string,
displayName: string,
avatarStyle: string,
starterOutfit: string,
onboardingComplete: boolean,
livingCollectionDay: string,
livingCollectionMask: number,
homeCharmApplied: boolean,
homeItems: { [string]: number },
homeUseCount: number,
homeTheme: string,
homeDecor: { [string]: number },
homeShowcaseCount: number,
dailyRouteDay: string,
dailyRouteMask: number,
dailyRouteClaimedDay: string,
weeklyRouteWeek: string,
weeklyRouteMask: number,
weeklyRouteClaimedWeek: string,
}

local VALID_GARDEN_STAGES = { empty = true, planted = true, watered = true, ready = true }
local VALID_PRIVACY = { Open = true, Friends = true, Private = true }
local VALID_AVATAR_STYLES = { Boy = true, Girl = true }
local VALID_STARTER_OUTFITS = { Meadow = true, Harbor = true, Sunset = true }

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

local function normaliseDisplayName(value: any): string
	if type(value) ~= "string" then return "" end
	local trimmed = string.match(value, "^%s*(.-)%s*$") or ""
	if #trimmed < 3 or #trimmed > 16 then return "" end
	if string.match(trimmed, "^[%w%s_%-]+$") == nil then return "" end
	return trimmed
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
		MeadowSeed = normaliseInteger(inventory.MeadowSeed, 0, 0),
		Seashell = normaliseInteger(inventory.Seashell, 0, 0),
		WoodToken = normaliseInteger(inventory.WoodToken, 0, 0),
	}
end

local function normaliseHomeItems(value: any): { [string]: number }
	local items = if type(value) == "table" then value else {}
	return {
		Bed = normaliseInteger(items.Bed, 1, 0, 1),
		KitchenCounter = normaliseInteger(items.KitchenCounter, 0, 0, 1),
		Wardrobe = normaliseInteger(items.Wardrobe, 0, 0, 1),
		CreativeDesk = normaliseInteger(items.CreativeDesk, 0, 0, 1),
	}
end

local function normaliseHomeTheme(value: any): string
	if type(value) ~= "string" then
		return "Meadow"
	end
	for _, theme in HomeExpressionRules.allThemes() do
		if theme.id == value then
			return value
		end
	end
	return "Meadow"
end

local function normaliseHomeDecor(value: any): { [string]: number }
	local source = if type(value) == "table" then value else {}
	local decor = {}
	for _, item in HomeExpressionRules.allDecorations() do
		decor[item.id] = normaliseInteger(source[item.id], 0, 0, 1)
	end
	return decor
end

function ProfileSchema.new(): PlayerProfile
	return {
		version = 9,
		coins = 100,
		level = 1,
		xp = 0,
		houseTier = 1,
		inventory = { Carrot = 0, SugarCrystal = 0, MeadowSeed = 0, Seashell = 0, WoodToken = 0 },
		courierLevel = 1,
		courierXp = 0,
		farmerLevel = 1,
		farmerXp = 0,
		designerLevel = 1,
		designerXp = 0,
		ownsTinyBike = false,
		bikeActive = false,
		gardenBeds = { newGardenBed(), newGardenBed(), newGardenBed() },
		lastDailyDay = "",
		portalCompletions = 0,
		villageContribution = 0,
		boundaryExplorationDay = "",
		boundaryExplorationClaimedDay = "",
		boundaryExplorationMask = 0,
		boundaryCompletions = 0,
		homePrivacy = "Open",
		displayName = "",
		avatarStyle = "",
		starterOutfit = "",
		onboardingComplete = false,
		livingCollectionDay = "",
		livingCollectionMask = 0,
		homeCharmApplied = false,
		homeItems = { Bed = 1, KitchenCounter = 0, Wardrobe = 0, CreativeDesk = 0 },
		homeUseCount = 0,
		homeTheme = "Meadow",
		homeDecor = { LanternNook = 0, StoryBookStack = 0, MeadowSeedShelf = 0, SeashellDisplay = 0, WoodlandBench = 0, PortalPainting = 0 },
		homeShowcaseCount = 0,
		dailyRouteDay = "",
		dailyRouteMask = 0,
		dailyRouteClaimedDay = "",
		weeklyRouteWeek = "",
		weeklyRouteMask = 0,
		weeklyRouteClaimedWeek = "",
	}
end

function ProfileSchema.normalize(value: any): PlayerProfile
	if type(value) ~= "table" then return ProfileSchema.new() end
	local privacy = if type(value.homePrivacy) == "string" and VALID_PRIVACY[value.homePrivacy] then value.homePrivacy else "Open"
	local displayName = normaliseDisplayName(value.displayName)
	local avatarStyle = if type(value.avatarStyle) == "string" and VALID_AVATAR_STYLES[value.avatarStyle] then value.avatarStyle else ""
	local starterOutfit = if type(value.starterOutfit) == "string" and VALID_STARTER_OUTFITS[value.starterOutfit] then value.starterOutfit else ""
	local onboardingComplete = value.onboardingComplete == true
		and displayName ~= ""
		and avatarStyle ~= ""
		and starterOutfit ~= ""
	return {
		version = 9,
		coins = normaliseInteger(value.coins, 100, 0),
		level = normaliseInteger(value.level, 1, 1),
		xp = normaliseInteger(value.xp, 0, 0),
		houseTier = normaliseInteger(value.houseTier, 1, 1, 5),
		inventory = normaliseInventory(value.inventory),
		courierLevel = normaliseInteger(value.courierLevel, 1, 1),
		courierXp = normaliseInteger(value.courierXp, 0, 0),
		farmerLevel = normaliseInteger(value.farmerLevel, 1, 1),
		farmerXp = normaliseInteger(value.farmerXp, 0, 0),
		designerLevel = normaliseInteger(value.designerLevel, 1, 1),
		designerXp = normaliseInteger(value.designerXp, 0, 0),
		ownsTinyBike = if type(value.ownsTinyBike) == "boolean" then value.ownsTinyBike else false,
		bikeActive = if type(value.bikeActive) == "boolean" then value.bikeActive else false,
		gardenBeds = normaliseGardenBeds(value.gardenBeds),
		lastDailyDay = if type(value.lastDailyDay) == "string" then value.lastDailyDay else "",
		portalCompletions = normaliseInteger(value.portalCompletions, 0, 0),
		villageContribution = normaliseInteger(value.villageContribution, 0, 0),
		boundaryExplorationDay = if type(value.boundaryExplorationDay) == "string" then value.boundaryExplorationDay else "",
		boundaryExplorationClaimedDay = if type(value.boundaryExplorationClaimedDay) == "string" then value.boundaryExplorationClaimedDay else "",
		boundaryExplorationMask = normaliseInteger(value.boundaryExplorationMask, 0, 0, 7),
		boundaryCompletions = normaliseInteger(value.boundaryCompletions, 0, 0),
		homePrivacy = privacy,
		displayName = displayName,
		avatarStyle = avatarStyle,
		starterOutfit = starterOutfit,
		onboardingComplete = onboardingComplete,
		livingCollectionDay = if type(value.livingCollectionDay) == "string" then value.livingCollectionDay else "",
		livingCollectionMask = normaliseInteger(value.livingCollectionMask, 0, 0, 7),
		homeCharmApplied = value.homeCharmApplied == true,
		homeItems = normaliseHomeItems(value.homeItems),
		homeUseCount = normaliseInteger(value.homeUseCount, 0, 0),
		homeTheme = normaliseHomeTheme(value.homeTheme),
		homeDecor = normaliseHomeDecor(value.homeDecor),
		homeShowcaseCount = normaliseInteger(value.homeShowcaseCount, 0, 0),
		dailyRouteDay = if type(value.dailyRouteDay) == "string" then value.dailyRouteDay else "",
		dailyRouteMask = normaliseInteger(value.dailyRouteMask, 0, 0, 15),
		dailyRouteClaimedDay = if type(value.dailyRouteClaimedDay) == "string" then value.dailyRouteClaimedDay else "",
		weeklyRouteWeek = if type(value.weeklyRouteWeek) == "string" then value.weeklyRouteWeek else "",
		weeklyRouteMask = normaliseInteger(value.weeklyRouteMask, 0, 0, 15),
		weeklyRouteClaimedWeek = if type(value.weeklyRouteClaimedWeek) == "string" then value.weeklyRouteClaimedWeek else "",
	}
end

return ProfileSchema
