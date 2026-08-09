local TestUtil = require("./TestUtil")
local ProfileSchema = require("../src/shared/ProfileSchema")
local HomeCatalog = require("../src/shared/HomeCatalog")
local HomeRules = require("../src/shared/HomeRules")

return function()
	local profile = ProfileSchema.new()
	TestUtil.isTrue(HomeRules.has(profile, "Bed"))
	TestUtil.isFalse(HomeRules.has(profile, "KitchenCounter"))
	TestUtil.equal(HomeRules.nextItem(profile), "KitchenCounter")

	local bought, reason = HomeRules.buy(profile, "KitchenCounter")
	TestUtil.isTrue(bought)
	TestUtil.equal(reason, "bought")
	TestUtil.equal(profile.coins, 100 - HomeCatalog.get("KitchenCounter").price)
	TestUtil.isTrue(HomeRules.has(profile, "KitchenCounter"))

	bought, reason = HomeRules.buy(profile, "KitchenCounter")
	TestUtil.isFalse(bought)
	TestUtil.equal(reason, "already_owned")

	local used, useReason = HomeRules.use(profile, "KitchenCounter")
	TestUtil.isTrue(used)
	TestUtil.equal(useReason, "used")
	TestUtil.equal(profile.homeUseCount, 1)

	local missing, missingReason = HomeRules.use(profile, "CreativeDesk")
	TestUtil.isFalse(missing)
	TestUtil.equal(missingReason, "not_owned")

	local poor = ProfileSchema.new()
	poor.coins = 0
	local tooExpensive, expensiveReason = HomeRules.buy(poor, "CreativeDesk")
	TestUtil.isFalse(tooExpensive)
	TestUtil.equal(expensiveReason, "not_enough_coins")

	local unknown, unknownReason = HomeRules.buy(profile, "UnknownFurniture")
	TestUtil.isFalse(unknown)
	TestUtil.equal(unknownReason, "unknown_item")
	TestUtil.equal(HomeRules.nextItem(profile), "Wardrobe")
	profile.coins = 1000
	TestUtil.isTrue(HomeRules.buy(profile, "Wardrobe"))
	TestUtil.isTrue(HomeRules.buy(profile, "CreativeDesk"))
	TestUtil.isTrue(HomeRules.isComplete(profile))
	TestUtil.equal(HomeRules.nextItem(profile), nil)
end

