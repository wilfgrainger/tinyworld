local TestUtil = require("./TestUtil")
local ProfileSchema = require("../src/shared/ProfileSchema")
local HouseCatalog = require("../src/shared/HouseCatalog")
local HouseUpgrade = require("../src/shared/HouseUpgrade")

return function()
	TestUtil.equal(HouseCatalog.maxTier, 5)
	TestUtil.equal(HouseCatalog.get(1).name, "Starter Shed")
	TestUtil.equal(HouseCatalog.get(2).name, "Cosy Cottage")
	TestUtil.equal(HouseCatalog.get(3).name, "Family Home")
	TestUtil.equal(HouseCatalog.get(4).name, "Garden House")
	TestUtil.equal(HouseCatalog.get(5).name, "Tiny Castle")

	local maxed = ProfileSchema.new()
	maxed.houseTier = 5
	local okMax, reasonMax = HouseUpgrade.tryUpgrade(maxed)
	TestUtil.isFalse(okMax)
	TestUtil.equal(reasonMax, "max_tier")

	local levelLocked = ProfileSchema.new()
	levelLocked.coins = 1000
	local okLevel, reasonLevel = HouseUpgrade.tryUpgrade(levelLocked)
	TestUtil.isFalse(okLevel)
	TestUtil.equal(reasonLevel, "level_too_low")
	TestUtil.equal(levelLocked.coins, 1000)
	TestUtil.equal(levelLocked.houseTier, 1)

	local poor = ProfileSchema.new()
	poor.level = 2
	poor.coins = 249
	local okCoins, reasonCoins = HouseUpgrade.tryUpgrade(poor)
	TestUtil.isFalse(okCoins)
	TestUtil.equal(reasonCoins, "not_enough_coins")

	local success = ProfileSchema.new()
	success.level = 2
	success.coins = 500
	local ok, reason = HouseUpgrade.tryUpgrade(success)
	TestUtil.isTrue(ok)
	TestUtil.equal(reason, "upgraded")
	TestUtil.equal(success.houseTier, 2)
	TestUtil.equal(success.coins, 250)
end
