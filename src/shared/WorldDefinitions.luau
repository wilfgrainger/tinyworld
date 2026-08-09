local WorldDefinitions = {}

local WORLDS = {
	{
		id = "GiantKitchen",
		displayName = "Giant Kitchen",
		visualRule = "toy-sized player in a warm oversized working kitchen",
		mechanic = "climb-and-bounce",
		secret = "hidden recipe card behind the flour tin",
		collectibleName = "Sugar Crystal",
		inventoryItem = "SugarCrystal",
		collectibleCount = 3,
		keepsakeId = "KitchenWhiskBadge",
		coins = 300,
		xp = 200,
		homePayoff = "kitchen props and recipe keepsakes",
	},
	{
		id = "MoonlitMeadow",
		displayName = "Moonlit Meadow",
		visualRule = "plants and pathways wake when touched by moonlight",
		mechanic = "light-and-grow",
		secret = "a firefly circle opens a hidden moon garden",
		collectibleName = "Moonlit Seed",
		inventoryItem = "MeadowSeed",
		collectibleCount = 3,
		keepsakeId = "MoonPetal",
		coins = 350,
		xp = 225,
		homePayoff = "moon plants and gentle garden lighting",
	},
	{
		id = "CloudpostObservatory",
		displayName = "Cloudpost Observatory",
		visualRule = "a floating post office and observatory stitched together by drifting cloud bridges",
		mechanic = "wind-route",
		secret = "ring three sky bells in the right order to reveal the star-mail loft",
		collectibleName = "Bottled Breeze",
		inventoryItem = "WoodToken",
		collectibleCount = 3,
		keepsakeId = "CloudPostcard",
		coins = 375,
		xp = 240,
		homePayoff = "cloud mobiles, sky postcards and soft wind chimes",
	},
	{
		id = "ClockworkOrchard",
		displayName = "Clockwork Orchard",
		visualRule = "fruit trees, streams and tiny bridges move to the rhythm of an enormous garden clock",
		mechanic = "timing-and-gears",
		secret = "align the brass acorns to open the gardener's pocket workshop",
		collectibleName = "Clockwork Leaf",
		inventoryItem = "Carrot",
		collectibleCount = 3,
		keepsakeId = "ClockworkLeaf",
		coins = 400,
		xp = 250,
		homePayoff = "mechanical planters, brass ornaments and ticking garden toys",
	},
}

local BY_ID = {}
for _, world in WORLDS do
	BY_ID[world.id] = world
end

function WorldDefinitions.get(worldId: string)
	return BY_ID[worldId]
end

function WorldDefinitions.all()
	local result = {}
	for _, world in WORLDS do
		table.insert(result, world)
	end
	return result
end

return WorldDefinitions
