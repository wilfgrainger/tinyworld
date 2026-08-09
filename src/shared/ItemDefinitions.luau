local ItemDefinitions = {}

export type ItemDefinition = {
	id: string,
	displayName: string,
	category: string,
	stackable: boolean,
	maxStack: number,
	tradePolicy: string,
	analyticsCategory: string,
}

local ITEMS = {
	{
		id = "Carrot",
		displayName = "Carrot",
		category = "resource",
		stackable = true,
		maxStack = 999,
		tradePolicy = "standard",
		analyticsCategory = "garden",
	},
	{
		id = "SugarCrystal",
		displayName = "Sugar Crystal",
		category = "resource",
		stackable = true,
		maxStack = 999,
		tradePolicy = "standard",
		analyticsCategory = "portal",
	},
	{
		id = "MeadowSeed",
		displayName = "Meadow Seed",
		category = "resource",
		stackable = true,
		maxStack = 999,
		tradePolicy = "standard",
		analyticsCategory = "garden",
	},
	{
		id = "Seashell",
		displayName = "Seashell",
		category = "resource",
		stackable = true,
		maxStack = 999,
		tradePolicy = "standard",
		analyticsCategory = "exploration",
	},
	{
		id = "WoodToken",
		displayName = "Wood Token",
		category = "resource",
		stackable = true,
		maxStack = 999,
		tradePolicy = "standard",
		analyticsCategory = "village",
	},
}

local KEEPSAKE_NAMES = {
	{ "KitchenWhiskBadge", "Pocket Whisk" },
	{ "SugarStar", "Sugar Star" },
	{ "TinyTeacup", "Tiny Teacup" },
	{ "MoonPetal", "Moon Petal" },
	{ "FireflyJar", "Firefly Jar" },
	{ "MoonstoneButton", "Moonstone Button" },
	{ "CloudPostcard", "Cloud Postcard" },
	{ "BottledBreeze", "Bottled Breeze" },
	{ "SkyBell", "Sky Bell" },
	{ "ClockworkLeaf", "Clockwork Leaf" },
	{ "BrassAcorn", "Brass Acorn" },
	{ "PocketGear", "Pocket Gear" },
	{ "HarborCompass", "Harbor Compass" },
	{ "GlassBuoy", "Glass Buoy" },
	{ "SaltglassShell", "Saltglass Shell" },
	{ "MeadowRibbon", "Meadow Ribbon" },
	{ "GardenMedal", "Garden Medal" },
	{ "SunseedCharm", "Sunseed Charm" },
	{ "CourierStamp", "Courier Stamp" },
	{ "ParcelPin", "Parcel Pin" },
	{ "VillagePostcard", "Village Postcard" },
	{ "WorkshopCog", "Workshop Cog" },
	{ "BikeBellMiniature", "Mini Bike Bell" },
	{ "PaintedSpanner", "Painted Spanner" },
	{ "MarketToken", "Market Token" },
	{ "FestivalRibbon", "Festival Ribbon" },
	{ "TownHallSeal", "Town Hall Seal" },
	{ "SecretKey", "Tiny Secret Key" },
	{ "PortalShard", "Portal Shard" },
	{ "HomeHeart", "Home Heart" },
	{ "StarMapFragment", "Star Map Fragment" },
	{ "ImpossiblePebble", "Impossible Pebble" },
}

for _, entry in KEEPSAKE_NAMES do
	table.insert(ITEMS, {
		id = entry[1],
		displayName = entry[2],
		category = "keepsake",
		stackable = true,
		maxStack = 99,
		tradePolicy = "locked",
		analyticsCategory = "collection",
	})
end

local BY_ID = {}
for _, item in ITEMS do
	BY_ID[item.id] = item
end

function ItemDefinitions.get(itemId: string): ItemDefinition?
	return BY_ID[itemId]
end

function ItemDefinitions.all(): { ItemDefinition }
	local result = {}
	for _, item in ITEMS do
		table.insert(result, item)
	end
	return result
end

function ItemDefinitions.keepsakes(): { ItemDefinition }
	local result = {}
	for _, item in ITEMS do
		if item.category == "keepsake" then
			result[item.id] = item
		end
	end
	return result
end

return ItemDefinitions
