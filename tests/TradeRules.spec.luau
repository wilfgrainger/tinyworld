local TestUtil = require("./TestUtil")
local ProfileSchema = require("../src/shared/ProfileSchema")
local TradeRules = require("../src/shared/TradeRules")

return function()
	local a = ProfileSchema.new()
	local b = ProfileSchema.new()
	a.inventory.Carrot = 1
	b.inventory.SugarCrystal = 1

	local traded, reason = TradeRules.exchange(a, "Carrot", b, "SugarCrystal")
	TestUtil.isTrue(traded)
	TestUtil.equal(reason, "traded")
	TestUtil.equal(a.inventory.Carrot, 0)
	TestUtil.equal(a.inventory.SugarCrystal, 1)
	TestUtil.equal(b.inventory.SugarCrystal, 0)
	TestUtil.equal(b.inventory.Carrot, 1)

	local poorA = ProfileSchema.new()
	local poorB = ProfileSchema.new()
	poorB.inventory.Carrot = 1
	local failed, failReason = TradeRules.exchange(poorA, "SugarCrystal", poorB, "Carrot")
	TestUtil.isFalse(failed)
	TestUtil.equal(failReason, "first_missing_item")
	TestUtil.equal(poorA.inventory.SugarCrystal, 0)
	TestUtil.equal(poorB.inventory.Carrot, 1)

	local unsupported, unsupportedReason = TradeRules.exchange(poorA, "GoldSword", poorB, "Carrot")
	TestUtil.isFalse(unsupported)
	TestUtil.equal(unsupportedReason, "unsupported_item")
end
