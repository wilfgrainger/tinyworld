local TestUtil = require("./TestUtil")
local PhysicalAffordanceRules = require("../src/shared/PhysicalAffordanceRules")

return function()
	TestUtil.equal(PhysicalAffordanceRules.INVARIANT, "world-or-popup")

	local expectedItems = { "Carrot", "SugarCrystal", "MeadowSeed", "Seashell", "WoodToken" }
	local items = PhysicalAffordanceRules.inventoryItems()
	TestUtil.equal(#items, #expectedItems)
	for index, itemId in expectedItems do
		TestUtil.equal(items[index], itemId)
	end

	items[1] = "MutatedCopy"
	local freshItems = PhysicalAffordanceRules.inventoryItems()
	TestUtil.equal(freshItems[1], "Carrot")
	TestUtil.equal(#freshItems, 5)

	for _, itemId in expectedItems do
		TestUtil.isTrue(PhysicalAffordanceRules.isInventoryItem(itemId))
	end
	TestUtil.isFalse(PhysicalAffordanceRules.isInventoryItem("UnknownItem"))
	TestUtil.isFalse(PhysicalAffordanceRules.isInventoryItem(42))

	TestUtil.equal(PhysicalAffordanceRules.displayName("Carrot"), "Carrot")
	TestUtil.equal(PhysicalAffordanceRules.displayName("SugarCrystal"), "Sugar Crystal")
	TestUtil.equal(PhysicalAffordanceRules.displayName("MeadowSeed"), "Meadow Seed")
	TestUtil.equal(PhysicalAffordanceRules.displayName("WoodToken"), "Wood Token")
	TestUtil.equal(PhysicalAffordanceRules.displayName("FutureItem"), "FutureItem")

	TestUtil.isFalse(PhysicalAffordanceRules.hasEvidence(false, false))
	TestUtil.isTrue(PhysicalAffordanceRules.hasEvidence(true, false))
	TestUtil.isTrue(PhysicalAffordanceRules.hasEvidence(false, true))
	TestUtil.isTrue(PhysicalAffordanceRules.hasEvidence(true, true))
end
