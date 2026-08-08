local TestUtil = require("./TestUtil")
local ProfileSchema = require("../src/shared/ProfileSchema")
local Inventory = require("../src/shared/Inventory")

return function()
	local profile = ProfileSchema.new()
	TestUtil.equal(Inventory.get(profile, "Carrot"), 0)
	TestUtil.isTrue(Inventory.add(profile, "Carrot", 2))
	TestUtil.equal(Inventory.get(profile, "Carrot"), 2)
	TestUtil.isTrue(Inventory.remove(profile, "Carrot", 1))
	TestUtil.equal(Inventory.get(profile, "Carrot"), 1)

	TestUtil.isFalse(Inventory.add(profile, "GoldSword", 1))
	TestUtil.isFalse(Inventory.add(profile, "Carrot", -1))
	TestUtil.isFalse(Inventory.remove(profile, "Carrot", 2))
	TestUtil.equal(Inventory.get(profile, "Carrot"), 1)
end
