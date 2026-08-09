local TestUtil = require("./TestUtil")
local PhysicalAffordanceRules = require("../src/shared/PhysicalAffordanceRules")

return function()
	TestUtil.equal(PhysicalAffordanceRules.INVARIANT, "world-or-popup")
	TestUtil.isTrue(PhysicalAffordanceRules.isInventoryItem("Carrot"))
	TestUtil.isTrue(PhysicalAffordanceRules.isInventoryItem("SugarCrystal"))
	TestUtil.isTrue(PhysicalAffordanceRules.isInventoryItem("MeadowSeed"))
	TestUtil.isTrue(PhysicalAffordanceRules.isInventoryItem("Seashell"))
	TestUtil.isTrue(PhysicalAffordanceRules.isInventoryItem("WoodToken"))
	TestUtil.isFalse(PhysicalAffordanceRules.isInventoryItem("HomeCharm"))
	TestUtil.equal(PhysicalAffordanceRules.displayName("SugarCrystal"), "Sugar Crystal")
	TestUtil.equal(PhysicalAffordanceRules.displayName("unknown"), "unknown")

	TestUtil.isTrue(PhysicalAffordanceRules.hasEvidence(true, false))
	TestUtil.isTrue(PhysicalAffordanceRules.hasEvidence(false, true))
	TestUtil.isFalse(PhysicalAffordanceRules.hasEvidence(false, false))

	local ids = PhysicalAffordanceRules.inventoryItems()
	TestUtil.equal(#ids, 5)
	TestUtil.equal(ids[1], "Carrot")
	TestUtil.equal(ids[5], "WoodToken")
end
