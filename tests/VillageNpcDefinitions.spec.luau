local TestUtil = require("./TestUtil")
local VillageNpcDefinitions = require("../src/shared/VillageNpcDefinitions")

return function()
	local all = VillageNpcDefinitions.all()
	TestUtil.equal(#all, 5)
	TestUtil.equal(VillageNpcDefinitions.get("Trader").displayName, "Mara")
	TestUtil.equal(VillageNpcDefinitions.get("Gardener").displayName, "Pip")
	TestUtil.equal(VillageNpcDefinitions.get("Fisherman").displayName, "Finn")
	TestUtil.equal(VillageNpcDefinitions.get("BoatKeeper").displayName, "Skye")
	TestUtil.equal(VillageNpcDefinitions.get("Builder").displayName, "Milo")
	TestUtil.equal(VillageNpcDefinitions.get("Nope"), nil)
end
