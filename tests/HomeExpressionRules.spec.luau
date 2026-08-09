local TestUtil = require("./TestUtil")
local ProfileSchema = require("../src/shared/ProfileSchema")
local HomeExpressionRules = require("../src/shared/HomeExpressionRules")

return function()
	local profile = ProfileSchema.new()
	TestUtil.equal(profile.homeTheme, "Meadow")
	TestUtil.equal(HomeExpressionRules.decorCount(profile), 0)
	TestUtil.equal(HomeExpressionRules.nextDecoration(profile), "LanternNook")

	local acquired, reason = HomeExpressionRules.acquire(profile, "LanternNook")
	TestUtil.isTrue(acquired)
	TestUtil.equal(reason, "acquired")
	TestUtil.equal(profile.coins, 20)
	TestUtil.isTrue(HomeExpressionRules.hasDecoration(profile, "LanternNook"))

	local duplicate, duplicateReason = HomeExpressionRules.acquire(profile, "LanternNook")
	TestUtil.isFalse(duplicate)
	TestUtil.equal(duplicateReason, "already_owned")

	local poor, poorReason = HomeExpressionRules.acquire(profile, "StoryBookStack")
	TestUtil.isFalse(poor)
	TestUtil.equal(poorReason, "not_enough_coins")

	local missing, missingReason = HomeExpressionRules.acquire(profile, "MeadowSeedShelf")
	TestUtil.isFalse(missing)
	TestUtil.equal(missingReason, "missing_resource")
	profile.inventory.MeadowSeed = 1
	local crafted, craftedReason = HomeExpressionRules.acquire(profile, "MeadowSeedShelf")
	TestUtil.isTrue(crafted)
	TestUtil.equal(craftedReason, "acquired")
	TestUtil.equal(profile.inventory.MeadowSeed, 0)

	local gated, gatedReason = HomeExpressionRules.acquire(profile, "PortalPainting")
	TestUtil.isFalse(gated)
	TestUtil.equal(gatedReason, "world_gate")
	profile.portalCompletions = 1
	profile.coins = 500
	local painting, paintingReason = HomeExpressionRules.acquire(profile, "PortalPainting")
	TestUtil.isTrue(painting)
	TestUtil.equal(paintingReason, "acquired")

	TestUtil.isTrue(HomeExpressionRules.setTheme(profile, "Harbor"))
	TestUtil.equal(profile.homeTheme, "Harbor")
	TestUtil.isFalse(HomeExpressionRules.setTheme(profile, "Unknown"))
	TestUtil.equal(HomeExpressionRules.cycleTheme("Harbor"), "Sunset")

	TestUtil.equal(HomeExpressionRules.showcase(profile), 1)
	TestUtil.equal(HomeExpressionRules.showcase(profile), 2)
	TestUtil.equal(HomeExpressionRules.decorCount(profile), 3)

	local repaired = ProfileSchema.normalize({
		homeTheme = "Unknown",
		homeDecor = { LanternNook = 2, NotARealItem = 1 },
		homeShowcaseCount = -5,
	})
	TestUtil.equal(repaired.homeTheme, "Meadow")
	TestUtil.equal(repaired.homeDecor.LanternNook, 1)
	TestUtil.equal(repaired.homeDecor.StoryBookStack, 0)
	TestUtil.equal(repaired.homeShowcaseCount, 0)
end
