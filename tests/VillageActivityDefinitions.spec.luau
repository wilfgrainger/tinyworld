local TestUtil = require("./TestUtil")
local Definitions = require("../src/shared/VillageActivityDefinitions")

return function()
	local all = Definitions.all()
	TestUtil.equal(#all, 5)

	local seenIds = {}
	local seenRoles = {}
	for _, definition in all do
		TestUtil.isFalse(seenIds[definition.id] == true, "activity ids must be unique")
		TestUtil.isFalse(seenRoles[definition.role] == true, "activity roles must be unique")
		seenIds[definition.id] = true
		seenRoles[definition.role] = true
		TestUtil.isTrue(definition.baseCoins > 0)
		TestUtil.isTrue(definition.baseXp > 0)
	end

	TestUtil.equal(Definitions.forRole("Trader").id, "TraderRequest")
	TestUtil.equal(Definitions.forRole("Gardener").id, "VillageGarden")
	TestUtil.equal(Definitions.forRole("Fisherman").id, "Fishing")
	TestUtil.equal(Definitions.forRole("BoatKeeper").id, "CoastalDelivery")
	TestUtil.equal(Definitions.forRole("Builder").id, "BuilderRepair")
	TestUtil.equal(Definitions.get("CoastalDelivery").baseCoins, 140)
	TestUtil.equal(Definitions.get("CoastalDelivery").baseXp, 70)
	TestUtil.equal(Definitions.get("Nope"), nil)
	TestUtil.equal(Definitions.forRole("Nope"), nil)
end
