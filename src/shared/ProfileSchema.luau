local ProfileSchema = {}

ProfileSchema.VERSION = 11
ProfileSchema.MAX_HOUSE_TIER = 5
ProfileSchema.MAX_FURNITURE_PLACEMENTS = 60

local HomeExpressionRules
local FurnitureDefinitions
local ItemDefinitions
if script ~= nil then
	HomeExpressionRules = require(script.Parent:WaitForChild("HomeExpressionRules"))
	FurnitureDefinitions = require(script.Parent:WaitForChild("FurnitureDefinitions"))
	ItemDefinitions = require(script.Parent:WaitForChild("ItemDefinitions"))
else
	HomeExpressionRules = require("./HomeExpressionRules")
	FurnitureDefinitions = require("./FurnitureDefinitions")
	ItemDefinitions = require("./ItemDefinitions")
end

export type GardenBed = { stage: string, readyAt: number }
export type Inventory =
	{ Carrot: number, SugarCrystal: number, MeadowSeed: number, Seashell: number, WoodToken: number }
export type InventoryInstance = { itemId: string, metadata: { [string]: any } }
export type FurniturePlacement = {
	furnitureId: string,
	instanceId: string?,
	x: number,
	y: number,
	z: number,
	rotation: number,
}
export type SavedOutfit = { hair: string, top: string, bottom: string, shoes: string, accessory: string }
export type PlayerProfile = {
	version: number,
	coins: number,
	level: number,
	xp: number,
	houseTier: number,
	inventory: Inventory,
	inventoryStacks: { [string]: number },
	inventoryInstances: { [string]: InventoryInstance },
	ownedFurniture: { [string]: number },
	furniturePlacements: { [string]: FurniturePlacement },
	savedOutfits: { [string]: SavedOutfit },
	activeOutfitId: string,
	discoveredWorlds: { [string]: boolean },
	keepsakes: { [string]: number },
	courierLevel: number,
	courierXp: number,
	farmerLevel: number,
	farmerXp: number,
	designerLevel: number,
	designerXp: number,
	ownsTinyBike: boolean,
	bikeActive: boolean,
	ownsTinyBoat: boolean,
	boatActive: boolean,
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

local function normaliseDisplayName(value: any): string
	if type(value) ~= "string" then
		return ""
	end
	local trimmed = string.match(value, "^%s*(.-)%s*$") or ""
	if #trimmed < 3 or #trimmed > 16 then
		return ""
	end
	if string.match(trimmed, "^[%w%s_%-]+$") == nil then
		return ""
	end
	return trimmed
end

local function newGardenBed(): GardenBed
	return { stage = "empty", readyAt = 0 }
end

local function normaliseGardenBed(value: any): GardenBed
	if type(value) ~= "table" then
		return newGardenBed()
	end
	local stage = if type(value.stage) == "string" and VALID_GARDEN_STAGES[value.stage] then value.stage else "empty"
	local readyAt = normaliseInteger(value.readyAt, 0, 0)
	if stage == "empty" or stage == "planted" then
		readyAt = 0
	end
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

local function normaliseIntegerMap(value: any): { [string]: number }
	local result = {}
	if type(value) ~= "table" then
		return result
	end
	for key, raw in value do
		if type(key) == "string" then
			result[key] = normaliseInteger(raw, 0, 0)
		end
	end
	return result
end

local function normaliseInventoryStacks(value: any, legacyInventory: Inventory): { [string]: number }
	local result = normaliseIntegerMap(value)
	for _, item in ItemDefinitions.all() do
		if item.category == "resource" then
			local legacyValue = legacyInventory[item.id]
			if legacyValue ~= nil then
				-- The five v10 compatibility resources remain legacy-authoritative
				-- until every old gameplay path has been retired. Never allow a stale
				-- v11 stack value to resurrect a resource already spent by legacy code.
				result[item.id] = normaliseInteger(legacyValue, 0, 0)
			elseif result[item.id] == nil then
				result[item.id] = 0
			end
		end
	end
	return result
end

local function normaliseMetadata(value: any): { [string]: any }
	local result = {}
	if type(value) ~= "table" then
		return result
	end
	for key, child in value do
		if type(key) == "string" and (type(child) == "string" or type(child) == "boolean" or isFiniteNumber(child)) then
			result[key] = child
		end
	end
	return result
end

local function normaliseInventoryInstances(value: any): { [string]: InventoryInstance }
	local result = {}
	if type(value) ~= "table" then
		return result
	end
	for instanceId, raw in value do
		if
			type(instanceId) == "string"
			and #instanceId <= 64
			and type(raw) == "table"
			and type(raw.itemId) == "string"
			and ItemDefinitions.get(raw.itemId) ~= nil
		then
			result[instanceId] = {
				itemId = raw.itemId,
				metadata = normaliseMetadata(raw.metadata),
			}
		end
	end
	return result
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

local function normaliseOwnedFurniture(value: any, legacyHomeItems: { [string]: number }): { [string]: number }
	local source = if type(value) == "table" then value else {}
	local result = {}
	for _, item in FurnitureDefinitions.all() do
		local legacyCount = if legacyHomeItems[item.id] ~= nil then legacyHomeItems[item.id] else 0
		local v11Count = normaliseInteger(source[item.id], 0, 0, 99)
		-- Legacy Home Supply purchases must remain owned after the v11 bridge.
		-- Taking the maximum also self-heals profiles created while the two
		-- representations could temporarily drift apart.
		result[item.id] = math.max(v11Count, legacyCount)
	end
	result.Bed = math.max(1, result.Bed or 0)
	return result
end

local function normalisePlacements(value: any): { [string]: FurniturePlacement }
	local result = {}
	if type(value) ~= "table" then
		return result
	end
	local count = 0
	for placementId, raw in value do
		if count >= ProfileSchema.MAX_FURNITURE_PLACEMENTS then
			break
		end
		if
			type(placementId) == "string"
			and #placementId <= 64
			and type(raw) == "table"
			and type(raw.furnitureId) == "string"
			and FurnitureDefinitions.get(raw.furnitureId) ~= nil
			and isFiniteNumber(raw.x)
			and isFiniteNumber(raw.y)
			and isFiniteNumber(raw.z)
			and isFiniteNumber(raw.rotation)
		then
			result[placementId] = {
				furnitureId = raw.furnitureId,
				instanceId = if type(raw.instanceId) == "string" and #raw.instanceId <= 64 then raw.instanceId else nil,
				x = raw.x,
				y = raw.y,
				z = raw.z,
				rotation = math.floor(raw.rotation) % 360,
			}
			count += 1
		end
	end
	return result
end

local function normaliseSavedOutfits(value: any): { [string]: SavedOutfit }
	local result = {}
	if type(value) == "table" then
		for outfitId, raw in value do
			if type(outfitId) == "string" and #outfitId <= 32 and type(raw) == "table" then
				result[outfitId] = {
					hair = if type(raw.hair) == "string" then raw.hair else "Tousled",
					top = if type(raw.top) == "string" then raw.top else "MeadowTop",
					bottom = if type(raw.bottom) == "string" then raw.bottom else "DenimBottom",
					shoes = if type(raw.shoes) == "string" then raw.shoes else "CanvasShoes",
					accessory = if type(raw.accessory) == "string" then raw.accessory else "None",
				}
			end
		end
	end
	if result.Starter == nil then
		result.Starter = {
			hair = "Tousled",
			top = "MeadowTop",
			bottom = "DenimBottom",
			shoes = "CanvasShoes",
			accessory = "None",
		}
	end
	return result
end

local function normaliseBooleanMap(value: any): { [string]: boolean }
	local result = {}
	if type(value) ~= "table" then
		return result
	end
	for key, raw in value do
		if type(key) == "string" and raw == true then
			result[key] = true
		end
	end
	return result
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
	local inventory = { Carrot = 0, SugarCrystal = 0, MeadowSeed = 0, Seashell = 0, WoodToken = 0 }
	local homeItems = { Bed = 1, KitchenCounter = 0, Wardrobe = 0, CreativeDesk = 0 }
	return {
		version = 11,
		coins = 100,
		level = 1,
		xp = 0,
		houseTier = 1,
		inventory = inventory,
		inventoryStacks = { Carrot = 0, SugarCrystal = 0, MeadowSeed = 0, Seashell = 0, WoodToken = 0 },
		inventoryInstances = {},
		ownedFurniture = normaliseOwnedFurniture(nil, homeItems),
		furniturePlacements = {},
		savedOutfits = normaliseSavedOutfits(nil),
		activeOutfitId = "Starter",
		discoveredWorlds = {},
		keepsakes = {},
		courierLevel = 1,
		courierXp = 0,
		farmerLevel = 1,
		farmerXp = 0,
		designerLevel = 1,
		designerXp = 0,
		ownsTinyBike = false,
		bikeActive = false,
		ownsTinyBoat = false,
		boatActive = false,
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
		homeItems = homeItems,
		homeUseCount = 0,
		homeTheme = "Meadow",
		homeDecor = {
			LanternNook = 0,
			StoryBookStack = 0,
			MeadowSeedShelf = 0,
			SeashellDisplay = 0,
			WoodlandBench = 0,
			PortalPainting = 0,
		},
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
	if type(value) ~= "table" then
		return ProfileSchema.new()
	end
	local privacy = if type(value.homePrivacy) == "string" and VALID_PRIVACY[value.homePrivacy]
		then value.homePrivacy
		else "Open"
	local displayName = normaliseDisplayName(value.displayName)
	local avatarStyle = if type(value.avatarStyle) == "string" and VALID_AVATAR_STYLES[value.avatarStyle]
		then value.avatarStyle
		else ""
	local starterOutfit = if type(value.starterOutfit) == "string" and VALID_STARTER_OUTFITS[value.starterOutfit]
		then value.starterOutfit
		else ""
	local onboardingComplete = value.onboardingComplete == true
		and displayName ~= ""
		and avatarStyle ~= ""
		and starterOutfit ~= ""
	local inventory = normaliseInventory(value.inventory)
	local homeItems = normaliseHomeItems(value.homeItems)
	local savedOutfits = normaliseSavedOutfits(value.savedOutfits)
	local activeOutfitId = if type(value.activeOutfitId) == "string"
			and savedOutfits[value.activeOutfitId] ~= nil
		then value.activeOutfitId
		else "Starter"
	return {
		version = 11,
		coins = normaliseInteger(value.coins, 100, 0),
		level = normaliseInteger(value.level, 1, 1),
		xp = normaliseInteger(value.xp, 0, 0),
		houseTier = normaliseInteger(value.houseTier, 1, 1, 5),
		inventory = inventory,
		inventoryStacks = normaliseInventoryStacks(value.inventoryStacks, inventory),
		inventoryInstances = normaliseInventoryInstances(value.inventoryInstances),
		ownedFurniture = normaliseOwnedFurniture(value.ownedFurniture, homeItems),
		furniturePlacements = normalisePlacements(value.furniturePlacements),
		savedOutfits = savedOutfits,
		activeOutfitId = activeOutfitId,
		discoveredWorlds = normaliseBooleanMap(value.discoveredWorlds),
		keepsakes = normaliseIntegerMap(value.keepsakes),
		courierLevel = normaliseInteger(value.courierLevel, 1, 1),
		courierXp = normaliseInteger(value.courierXp, 0, 0),
		farmerLevel = normaliseInteger(value.farmerLevel, 1, 1),
		farmerXp = normaliseInteger(value.farmerXp, 0, 0),
		designerLevel = normaliseInteger(value.designerLevel, 1, 1),
		designerXp = normaliseInteger(value.designerXp, 0, 0),
		ownsTinyBike = if type(value.ownsTinyBike) == "boolean" then value.ownsTinyBike else false,
		bikeActive = if type(value.bikeActive) == "boolean" then value.bikeActive else false,
		ownsTinyBoat = if type(value.ownsTinyBoat) == "boolean" then value.ownsTinyBoat else false,
		boatActive = if type(value.boatActive) == "boolean" then value.boatActive else false,
		gardenBeds = normaliseGardenBeds(value.gardenBeds),
		lastDailyDay = if type(value.lastDailyDay) == "string" then value.lastDailyDay else "",
		portalCompletions = normaliseInteger(value.portalCompletions, 0, 0),
		villageContribution = normaliseInteger(value.villageContribution, 0, 0),
		boundaryExplorationDay = if type(value.boundaryExplorationDay) == "string"
			then value.boundaryExplorationDay
			else "",
		boundaryExplorationClaimedDay = if type(value.boundaryExplorationClaimedDay) == "string"
			then value.boundaryExplorationClaimedDay
			else "",
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
		homeItems = homeItems,
		homeUseCount = normaliseInteger(value.homeUseCount, 0, 0),
		homeTheme = normaliseHomeTheme(value.homeTheme),
		homeDecor = normaliseHomeDecor(value.homeDecor),
		homeShowcaseCount = normaliseInteger(value.homeShowcaseCount, 0, 0),
		dailyRouteDay = if type(value.dailyRouteDay) == "string" then value.dailyRouteDay else "",
		dailyRouteMask = normaliseInteger(value.dailyRouteMask, 0, 0, 15),
		dailyRouteClaimedDay = if type(value.dailyRouteClaimedDay) == "string" then value.dailyRouteClaimedDay else "",
		weeklyRouteWeek = if type(value.weeklyRouteWeek) == "string" then value.weeklyRouteWeek else "",
		weeklyRouteMask = normaliseInteger(value.weeklyRouteMask, 0, 0, 15),
		weeklyRouteClaimedWeek = if type(value.weeklyRouteClaimedWeek) == "string"
			then value.weeklyRouteClaimedWeek
			else "",
	}
end

return ProfileSchema