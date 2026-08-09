local TestUtil = require("./TestUtil")
local ProfileSchema = require("../src/shared/ProfileSchema")
local HomeExpressionRules = require("../src/shared/HomeExpressionRules")

return function()
	local themes = HomeExpressionRules.allThemes()
	TestUtil.equal(#themes, 3)
	TestUtil.equal(themes[1].id, "Meadow")
	TestUtil.equal(themes[2].id, "Harbor")
	TestUtil.equal(themes[3].id, "Sunset")
	table.insert(themes, { id = "Mutation", name = "Mutation" })
	TestUtil.equal(#HomeExpressionRules.allThemes(), 3)

	local decorations = HomeExpressionRules.allDecorations()
	TestUtil.equal(#decorations, 6)
	local lantern = HomeExpressionRules.getDecoration("LanternNook")
	TestUtil.isTrue(lantern ~= nil)
	TestUtil.equal(lantern.name, "Lantern Nook")
	TestUtil.equal(lantern.costCoins, 80)
	TestUtil.equal(lantern.resource, nil)
	TestUtil.isFalse(lantern.requiresPortal)
	TestUtil.equal(HomeExpressionRules.getDecoration("NotARealDecoration"), nil)

	local profile = ProfileSchema.new()
	TestUtil.isFalse(HomeExpressionRules.hasDecoration(profile, "LanternNook"))
	TestUtil.equal(HomeExpressionRules.decorCount(profile), 0)
	TestUtil.equal(HomeExpressionRules.nextDecoration(profile), "LanternNook")

	local acquired, reason = HomeExpressionRules.acquire(profile, "LanternNook")
	TestUtil.isTrue(acquired)
	TestUtil.equal(reason, "acquired")
	TestUtil.equal(profile.coins, 20)
	TestUtil.isTrue(HomeExpressionRules.hasDecoration(profile, "LanternNook"))
	TestUtil.equal(HomeExpressionRules.decorCount(profile), 1)
	TestUtil.equal(HomeExpressionRules.nextDecoration(profile), "StoryBookStack")

	local duplicate, duplicateReason = HomeExpressionRules.acquire(profile, "LanternNook")
	TestUtil.isFalse(duplicate)
	TestUtil.equal(duplicateReason, "already_owned")
	TestUtil.equal(profile.coins, 20)

	local poor = ProfileSchema.new()
	poor.coins = 79
	local tooExpensive, expensiveReason = HomeExpressionRules.acquire(poor, "LanternNook")
	TestUtil.isFalse(tooExpensive)
	TestUtil.equal(expensiveReason, "not_enough_coins")
	TestUtil.equal(poor.coins, 79)

	local resourceProfile = ProfileSchema.new()
	resourceProfile.inventory.MeadowSeed = 1
	local crafted, craftReason = HomeExpressionRules.acquire(resourceProfile, "MeadowSeedShelf")
	TestUtil.isTrue(crafted)
	TestUtil.equal(craftReason, "acquired")
	TestUtil.equal(resourceProfile.coins, 100)
	TestUtil.equal(resourceProfile.inventory.MeadowSeed, 0)
	TestUtil.isTrue(HomeExpressionRules.hasDecoration(resourceProfile, "MeadowSeedShelf"))

	local missingResource = ProfileSchema.new()
	local missing, missingReason = HomeExpressionRules.acquire(missingResource, "MeadowSeedShelf")
	TestUtil.isFalse(missing)
	TestUtil.equal(missingReason, "missing_resource")
	TestUtil.equal(missingResource.coins, 100)

	local gated = ProfileSchema.new()
	gated.coins = 250
	local locked, lockedReason = HomeExpressionRules.acquire(gated, "PortalPainting")
	TestUtil.isFalse(locked)
	TestUtil.equal(lockedReason, "world_gate")
	TestUtil.equal(gated.coins, 250)
	gated.portalCompletions = 1
	local unlocked, unlockReason = HomeExpressionRules.acquire(gated, "PortalPainting")
	TestUtil.isTrue(unlocked)
	TestUtil.equal(unlockReason, "acquired")
	TestUtil.equal(gated.coins, 0)

	local unknown, unknownReason = HomeExpressionRules.acquire(profile, "UnknownDecoration")
	TestUtil.isFalse(unknown)
	TestUtil.equal(unknownReason, "unknown_item")

	TestUtil.isFalse(HomeExpressionRules.setTheme(profile, "NotATheme"))
	TestUtil.equal(profile.homeTheme, "Meadow")
	TestUtil.isTrue(HomeExpressionRules.setTheme(profile, "Harbor"))
	TestUtil.equal(profile.homeTheme, "Harbor")
	TestUtil.equal(HomeExpressionRules.cycleTheme("Meadow"), "Harbor")
	TestUtil.equal(HomeExpressionRules.cycleTheme("Harbor"), "Sunset")
	TestUtil.equal(HomeExpressionRules.cycleTheme("Sunset"), "Meadow")
	TestUtil.equal(HomeExpressionRules.cycleTheme("Unknown"), "Meadow")

	TestUtil.equal(HomeExpressionRules.showcase(profile), 1)
	TestUtil.equal(HomeExpressionRules.showcase(profile), 2)
	local repairedShowcase = { homeShowcaseCount = -4 }
	TestUtil.equal(HomeExpressionRules.showcase(repairedShowcase), 0)
	TestUtil.equal(repairedShowcase.homeShowcaseCount, 0)

	local bareProfile = { coins = 80 }
	local bareAcquired, bareReason = HomeExpressionRules.acquire(bareProfile, "LanternNook")
	TestUtil.isTrue(bareAcquired)
	TestUtil.equal(bareReason, "acquired")
	TestUtil.isTrue(type(bareProfile.homeDecor) == "table")
	TestUtil.equal(bareProfile.homeDecor.LanternNook, 1)
end
