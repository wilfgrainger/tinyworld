local HomeCatalog = {}

export type Item = { id: string, name: string, price: number, action: string, colour: string }

local ITEMS = {
	{ id = "Bed", name = "Cosy Bed", price = 0, action = "Rest", colour = "warmLight" },
	{ id = "KitchenCounter", name = "Kitchen Counter", price = 75, action = "Use Kitchen", colour = "sky" },
	{ id = "Wardrobe", name = "Wardrobe", price = 125, action = "Open Wardrobe", colour = "berry" },
	{ id = "CreativeDesk", name = "Creative Desk", price = 175, action = "Use Creative Desk", colour = "gold" },
}

local BY_ID = {}
for _, item in ITEMS do
	BY_ID[item.id] = item
end

function HomeCatalog.get(itemId: string): Item?
	return BY_ID[itemId]
end

function HomeCatalog.all(): { Item }
	local result = {}
	for _, item in ITEMS do
		table.insert(result, item)
	end
	return result
end

return HomeCatalog

