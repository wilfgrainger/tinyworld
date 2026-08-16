local TestUtil = require("./TestUtil")
local Rules = require("../src/shared/VillageActivityRules")

return function()
	TestUtil.equal(Rules.coinReward(100, "normal"), 100)
	TestUtil.equal(Rules.coinReward(100, "good"), 115)
	TestUtil.equal(Rules.coinReward(100, "perfect"), 130)
	TestUtil.equal(Rules.coinReward(61, "good"), 70)

	TestUtil.equal(Rules.gradeTiming(1.0, 3.0, 1.5), "perfect")
	TestUtil.equal(Rules.gradeTiming(2.0, 3.0, 1.5), "good")
	TestUtil.equal(Rules.gradeTiming(4.0, 3.0, 1.5), "normal")
	TestUtil.equal(Rules.gradeTiming(-1.0, 3.0, 1.5), "normal")

	TestUtil.isTrue(Rules.canStart(nil))
	TestUtil.isFalse(Rules.canStart("Fishing"))
	TestUtil.isTrue(Rules.validTarget("HarborCrate", "HarborCrate"))
	TestUtil.isFalse(Rules.validTarget("HarborCrate", "TownHall"))
	TestUtil.isTrue(Rules.canComplete(false))
	TestUtil.isFalse(Rules.canComplete(true))
end
