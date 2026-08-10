local FurnitureDefinitions
if script ~= nil then
	FurnitureDefinitions = require(script.Parent:WaitForChild("FurnitureDefinitions"))
else
	FurnitureDefinitions = require("./FurnitureDefinitions")
end

local ShopDefinitions = {}

local SHOPS = {
	VillageShop = {
		id = "VillageShop",
		displayName = "Village Shop",
		stock = { "Carrot", "MeadowSeed" },
	},
	HomeStore = {
		id = "HomeStore",
		displayName = "Home Store",
		stock = {},
	},
	Workshop = {
		id = "Workshop",
		displayName = "Workshop",
		stock = { "TinyBike", "TinyBoat" },
	},
}

for _, furniture in FurnitureDefinitions.all() do
	table.insert(SHOPS.HomeStore.stock, furniture.id)
end

function ShopDefinitions.get(shopId: string)
	return SHOPS[shopId]
end

function ShopDefinitions.priceFor(shopId: string, itemId: string): number?
	local shop = SHOPS[shopId]
	if shop == nil then
		return nil
	end
	local allowed = false
	for _, stockId in shop.stock do
		if stockId == itemId then
			allowed = true
			break
		end
	end
	if not allowed then
		return nil
	end
	local furniture = FurnitureDefinitions.get(itemId)
	if furniture then
		return furniture.price
	end
	local fixed = {
		Carrot = 10,
		MeadowSeed = 20,
		TinyBike = 300,
		TinyBoat = 600,
	}
	return fixed[itemId]
end

return ShopDefinitions
