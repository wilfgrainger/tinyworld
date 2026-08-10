local FurnitureDefinitions = {}

export type FurnitureDefinition = {
	id: string,
	displayName: string,
	category: string,
	price: number,
	prefabRole: string,
	interaction: string,
	placeable: boolean,
	footprintX: number,
	footprintZ: number,
	analyticsCategory: string,
}

local ITEMS = {}
local BY_ID = {}

local function add(
	category: string,
	id: string,
	displayName: string,
	price: number,
	prefabRole: string,
	interaction: string,
	footprintX: number?,
	footprintZ: number?
)
	local item = {
		id = id,
		displayName = displayName,
		category = category,
		price = price,
		prefabRole = prefabRole,
		interaction = interaction,
		placeable = true,
		footprintX = footprintX or 4,
		footprintZ = footprintZ or 4,
		analyticsCategory = "home_" .. category,
	}
	table.insert(ITEMS, item)
	BY_ID[id] = item
end

-- Bedroom (10)
add("bedroom", "Bed", "Cosy Bed", 0, "bed", "rest", 7, 5)
add("bedroom", "CloudBed", "Cloud Quilt Bed", 180, "bed", "rest", 7, 5)
add("bedroom", "HarborBed", "Harbour Stripe Bed", 190, "bed", "rest", 7, 5)
add("bedroom", "MoonBed", "Moonbeam Bed", 220, "bed", "rest", 7, 5)
add("bedroom", "Wardrobe", "Wardrobe", 125, "wardrobe", "dress", 4, 2)
add("bedroom", "BedsideCabinet", "Bedside Cabinet", 65, "cabinet", "open", 2, 2)
add("bedroom", "ToyChest", "Toy Chest", 95, "chest", "store", 4, 2)
add("bedroom", "BedroomRug", "Patchwork Bedroom Rug", 55, "rug", "display", 6, 4)
add("bedroom", "DressingMirror", "Dressing Mirror", 110, "mirror", "dress", 3, 2)
add("bedroom", "StoryShelf", "Bedtime Story Shelf", 90, "shelf", "read", 4, 2)

-- Kitchen (10)
add("kitchen", "KitchenCounter", "Kitchen Counter", 75, "counter", "cook", 6, 3)
add("kitchen", "KitchenTable", "Kitchen Table", 140, "table", "use", 6, 5)
add("kitchen", "BreakfastBench", "Breakfast Bench", 85, "bench", "sit", 5, 2)
add("kitchen", "KitchenChair", "Kitchen Chair", 50, "chair", "sit", 3, 3)
add("kitchen", "Fridge", "Friendly Fridge", 160, "fridge", "open", 4, 3)
add("kitchen", "Cooker", "Little Cooker", 175, "cooker", "cook", 4, 3)
add("kitchen", "KitchenSink", "Kitchen Sink", 135, "sink", "wash", 5, 3)
add("kitchen", "PantryShelf", "Pantry Shelf", 95, "shelf", "store", 4, 2)
add("kitchen", "TeaTrolley", "Tea Trolley", 105, "trolley", "craft", 4, 3)
add("kitchen", "FruitBowlTable", "Fruit Bowl Side Table", 80, "side-table", "display", 3, 3)

-- Bathroom (10)
add("bathroom", "BubbleBath", "Bubble Bath", 220, "bath", "bathe", 7, 4)
add("bathroom", "RainShower", "Rain Shower", 195, "shower", "shower", 5, 4)
add("bathroom", "BathroomSink", "Bathroom Sink", 120, "sink", "wash", 4, 3)
add("bathroom", "BathroomMirror", "Shell Edge Mirror", 85, "mirror", "use", 3, 1)
add("bathroom", "TowelRack", "Towel Rack", 55, "rack", "use", 3, 1)
add("bathroom", "BathroomCabinet", "Bathroom Cabinet", 90, "cabinet", "open", 4, 2)
add("bathroom", "LaundryBasket", "Laundry Basket", 60, "basket", "store", 3, 3)
add("bathroom", "BathMat", "Puddle Bath Mat", 45, "rug", "display", 4, 3)
add("bathroom", "SoapShelf", "Soap Shelf", 40, "shelf", "display", 2, 1)
add("bathroom", "PlantStandBathroom", "Bathroom Fern Stand", 70, "plant-stand", "water", 3, 3)

-- Living (10)
add("living", "CosyChair", "Cosy Chair", 90, "chair", "sit", 4, 4)
add("living", "FamilySofa", "Family Sofa", 210, "sofa", "sit", 8, 4)
add("living", "WindowBench", "Window Bench", 130, "bench", "sit", 6, 3)
add("living", "CoffeeTable", "Round Coffee Table", 100, "table", "use", 5, 5)
add("living", "CreativeDesk", "Creative Desk", 175, "desk", "craft", 6, 3)
add("living", "ReadingNook", "Reading Nook Chair", 120, "chair", "read", 4, 4)
add("living", "RecordPlayer", "Tiny Record Player", 145, "record-player", "switch", 4, 3)
add("living", "GameTable", "Family Game Table", 160, "table", "play", 6, 5)
add("living", "LivingRug", "Village Map Rug", 85, "rug", "display", 8, 6)
add("living", "DisplayCabinet", "Keepsake Display Cabinet", 155, "display-cabinet", "display", 5, 2)

-- Storage (10)
add("storage", "HallChest", "Hall Storage Chest", 80, "chest", "store", 5, 3)
add("storage", "BootRack", "Boot Rack", 55, "rack", "store", 4, 2)
add("storage", "TallBookcase", "Tall Bookcase", 120, "bookcase", "read", 5, 2)
add("storage", "CubeShelf", "Cubby Shelf", 95, "shelf", "store", 5, 2)
add("storage", "CraftCupboard", "Craft Cupboard", 130, "cabinet", "craft", 5, 2)
add("storage", "GardenLocker", "Garden Locker", 110, "locker", "store", 4, 3)
add("storage", "KeepsakeTrunk", "Keepsake Trunk", 150, "chest", "store", 5, 3)
add("storage", "WallHooks", "Colourful Wall Hooks", 45, "wall-hooks", "store", 4, 1)
add("storage", "BasketStack", "Basket Stack", 65, "basket", "store", 3, 3)
add("storage", "ParcelShelf", "Parcel Shelf", 90, "shelf", "store", 5, 2)

-- Garden (10)
add("garden", "MeadowPlanter", "Meadow Planter", 85, "planter", "plant", 4, 4)
add("garden", "HerbBox", "Kitchen Herb Box", 70, "planter", "plant", 4, 2)
add("garden", "WateringStand", "Watering Can Stand", 65, "watering-stand", "water", 3, 3)
add("garden", "GardenBench", "Woodland Garden Bench", 125, "bench", "sit", 6, 3)
add("garden", "PottingBench", "Potting Bench", 145, "potting-bench", "craft", 6, 3)
add("garden", "BerryPatch", "Berry Patch", 95, "crop-patch", "harvest", 5, 5)
add("garden", "SunflowerPatch", "Sunflower Patch", 90, "crop-patch", "harvest", 5, 5)
add("garden", "BirdBath", "Bird Bath", 105, "bird-bath", "use", 4, 4)
add("garden", "PicnicTable", "Picnic Table", 165, "picnic-table", "sit", 7, 6)
add("garden", "GardenArch", "Flower Garden Arch", 150, "garden-arch", "display", 7, 2)

-- Decoration (10)
add("decoration", "PortalPainting", "Portal Painting", 200, "painting", "display", 5, 1)
add("decoration", "VillagePainting", "Village Painting", 120, "painting", "display", 5, 1)
add("decoration", "HarborPainting", "Harbour Painting", 120, "painting", "display", 5, 1)
add("decoration", "MoonMobile", "Moon Mobile", 100, "hanging-decor", "display", 3, 3)
add("decoration", "ShellBowl", "Shell Display Bowl", 80, "display-bowl", "display", 3, 3)
add("decoration", "SeedShelf", "Meadow Seed Shelf", 90, "shelf", "display", 4, 2)
add("decoration", "StoryBookStack", "Story Book Stack", 60, "book-stack", "read", 3, 3)
add("decoration", "CushionPile", "Cushion Pile", 70, "cushions", "sit", 4, 4)
add("decoration", "WallClock", "Village Wall Clock", 85, "wall-clock", "display", 3, 1)
add("decoration", "TinyWorldGlobe", "TinyWorld Globe", 135, "globe", "use", 3, 3)

-- Lighting (10)
add("lighting", "MeadowLamp", "Meadow Lamp", 70, "floor-lamp", "switch", 3, 3)
add("lighting", "HarborLamp", "Harbour Lamp", 75, "floor-lamp", "switch", 3, 3)
add("lighting", "MoonLamp", "Moon Lamp", 85, "table-lamp", "switch", 2, 2)
add("lighting", "BedsideLamp", "Bedside Lamp", 60, "table-lamp", "switch", 2, 2)
add("lighting", "LanternNook", "Lantern Nook", 95, "lantern", "switch", 3, 3)
add("lighting", "GardenLantern", "Garden Lantern", 80, "lantern", "switch", 2, 2)
add("lighting", "StringLights", "Warm String Lights", 90, "string-lights", "switch", 6, 1)
add("lighting", "CloudLight", "Cloud Ceiling Light", 110, "ceiling-light", "switch", 4, 4)
add("lighting", "ShellNightlight", "Shell Nightlight", 55, "nightlight", "switch", 2, 2)
add("lighting", "WorkshopLight", "Workshop Cage Light", 75, "ceiling-light", "switch", 3, 3)

function FurnitureDefinitions.get(itemId: string): FurnitureDefinition?
	return BY_ID[itemId]
end

function FurnitureDefinitions.all(): { FurnitureDefinition }
	local result = {}
	for _, item in ITEMS do
		table.insert(result, item)
	end
	return result
end

function FurnitureDefinitions.byCategory(category: string): { FurnitureDefinition }
	local result = {}
	for _, item in ITEMS do
		if item.category == category then
			table.insert(result, item)
		end
	end
	return result
end

function FurnitureDefinitions.starterEssentials(): { FurnitureDefinition }
	return {
		BY_ID.Bed,
		BY_ID.KitchenCounter,
		BY_ID.Wardrobe,
		BY_ID.CreativeDesk,
	}
end

return FurnitureDefinitions
