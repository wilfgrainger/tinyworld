local PhysicalAffordanceRules = {}

PhysicalAffordanceRules.INVARIANT = "world-or-popup"

local ITEM_IDS = {
	"Carrot",
	"SugarCrystal",
	"MeadowSeed",
	"Seashell",
	"WoodToken",
}

local DISPLAY_NAMES = {
	Carrot = "Carrot",
	SugarCrystal = "Sugar Crystal",
	MeadowSeed = "Meadow Seed",
	Seashell = "Seashell",
	WoodToken = "Wood Token",
}

function PhysicalAffordanceRules.inventoryItems(): { string }
	local result = {}
	for _, itemId in ITEM_IDS do
		table.insert(result, itemId)
	end
	return result
end

function PhysicalAffordanceRules.isInventoryItem(itemId: string): boolean
	return DISPLAY_NAMES[itemId] ~= nil
end

function PhysicalAffordanceRules.displayName(itemId: string): string
	return DISPLAY_NAMES[itemId] or itemId
end

function PhysicalAffordanceRules.hasEvidence(hasWorldObject: boolean, hasNamedPopup: boolean): boolean
	return hasWorldObject or hasNamedPopup
end

return PhysicalAffordanceRules
