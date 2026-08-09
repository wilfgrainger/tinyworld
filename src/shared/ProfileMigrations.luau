local ProfileMigrations = {}

ProfileMigrations.CURRENT_VERSION = 11
ProfileMigrations.OLDEST_SUPPORTED_VERSION = 1

local function deepCopy(value: any): any
	if type(value) ~= "table" then
		return value
	end
	local result = {}
	for key, child in value do
		result[deepCopy(key)] = deepCopy(child)
	end
	return result
end

local function nonNegativeInteger(value: any): number
	if type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge then
		return 0
	end
	return math.max(0, math.floor(value))
end

local function migrate10To11(profile: any)
	local nextProfile = deepCopy(profile)

	local legacyInventory = if type(nextProfile.inventory) == "table" then nextProfile.inventory else {}
	local stacks = if type(nextProfile.inventoryStacks) == "table" then deepCopy(nextProfile.inventoryStacks) else {}
	for itemId, quantity in legacyInventory do
		if type(itemId) == "string" and stacks[itemId] == nil then
			stacks[itemId] = nonNegativeInteger(quantity)
		end
	end
	nextProfile.inventoryStacks = stacks

	if type(nextProfile.inventoryInstances) ~= "table" then
		nextProfile.inventoryInstances = {}
	end

	local legacyHomeItems = if type(nextProfile.homeItems) == "table" then nextProfile.homeItems else {}
	local ownedFurniture = if type(nextProfile.ownedFurniture) == "table" then deepCopy(nextProfile.ownedFurniture) else {}
	for itemId, quantity in legacyHomeItems do
		if type(itemId) == "string" and ownedFurniture[itemId] == nil then
			ownedFurniture[itemId] = nonNegativeInteger(quantity)
		end
	end
	if ownedFurniture.Bed == nil then
		ownedFurniture.Bed = 1
	end
	nextProfile.ownedFurniture = ownedFurniture

	if type(nextProfile.furniturePlacements) ~= "table" then
		nextProfile.furniturePlacements = {}
	end
	if type(nextProfile.savedOutfits) ~= "table" then
		nextProfile.savedOutfits = {
			Starter = {
				hair = "Tousled",
				top = "MeadowTop",
				bottom = "DenimBottom",
				shoes = "CanvasShoes",
				accessory = "None",
			},
		}
	end
	if type(nextProfile.activeOutfitId) ~= "string" or nextProfile.activeOutfitId == "" then
		nextProfile.activeOutfitId = "Starter"
	end
	if type(nextProfile.discoveredWorlds) ~= "table" then
		nextProfile.discoveredWorlds = {}
	end
	if type(nextProfile.keepsakes) ~= "table" then
		nextProfile.keepsakes = {}
	end

	nextProfile.version = 11
	return nextProfile
end

local MIGRATIONS = {
	[10] = migrate10To11,
}

function ProfileMigrations.migrate(raw: any): (any?, string?)
	if type(raw) ~= "table" then
		return { version = ProfileMigrations.CURRENT_VERSION }, nil
	end

	local working = deepCopy(raw)
	local rawVersion = if type(working.version) == "number" then math.floor(working.version) else ProfileMigrations.OLDEST_SUPPORTED_VERSION
	if rawVersion > ProfileMigrations.CURRENT_VERSION then
		return nil, "future_version"
	end
	if rawVersion < ProfileMigrations.OLDEST_SUPPORTED_VERSION then
		rawVersion = ProfileMigrations.OLDEST_SUPPORTED_VERSION
	end

	-- Versions 1-9 used additive normalization only. They are first promoted to
	-- the last legacy shape, then the explicit v10 -> v11 migration runs.
	if rawVersion < 10 then
		working.version = 10
		rawVersion = 10
	end

	while rawVersion < ProfileMigrations.CURRENT_VERSION do
		local migration = MIGRATIONS[rawVersion]
		if migration == nil then
			return nil, "missing_migration"
		end
		working = migration(working)
		rawVersion = working.version
	end

	return working, nil
end

return ProfileMigrations
