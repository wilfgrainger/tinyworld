local TestUtil = require("./TestUtil")
local ExplorationRules = require("../src/shared/ExplorationRules")
local ProfileSchema = require("../src/shared/ProfileSchema")

return function()
	local profile = ProfileSchema.new()
	local firstDay = "2026-08-08"

	local unknown, unknownReason = ExplorationRules.visit(profile, "unknown", firstDay)
	TestUtil.isFalse(unknown)
	TestUtil.equal(unknownReason, "unknown_landmark")

	local visited, visitReason = ExplorationRules.visit(profile, "woodlandTrail", firstDay)
	TestUtil.isTrue(visited)
	TestUtil.equal(visitReason, "visited")
	TestUtil.equal(ExplorationRules.count(profile), 1)

	local duplicate, duplicateReason = ExplorationRules.visit(profile, "woodlandTrail", firstDay)
	TestUtil.isFalse(duplicate)
	TestUtil.equal(duplicateReason, "already_visited")

	local incomplete, incompleteReason = ExplorationRules.claim(profile, firstDay)
	TestUtil.isFalse(incomplete)
	TestUtil.equal(incompleteReason, "incomplete")
	TestUtil.equal(profile.coins, 100)

	ExplorationRules.visit(profile, "cliffLookout", firstDay)
	ExplorationRules.visit(profile, "seaDock", firstDay)
	TestUtil.equal(ExplorationRules.count(profile), 3)

	local claimed, claimReason = ExplorationRules.claim(profile, firstDay)
	TestUtil.isTrue(claimed)
	TestUtil.equal(claimReason, "claimed")
	TestUtil.equal(profile.coins, 350)
	TestUtil.equal(profile.level, 2)
	TestUtil.equal(profile.xp, 0)
	TestUtil.equal(profile.boundaryCompletions, 1)
	TestUtil.equal(profile.boundaryExplorationMask, 0)

	local claimedAgain, claimedAgainReason = ExplorationRules.claim(profile, firstDay)
	TestUtil.isFalse(claimedAgain)
	TestUtil.equal(claimedAgainReason, "already_claimed")

	local nextDayVisit, nextDayReason = ExplorationRules.visit(profile, "seaDock", "2026-08-09")
	TestUtil.isTrue(nextDayVisit)
	TestUtil.equal(nextDayReason, "visited")
	TestUtil.equal(ExplorationRules.count(profile), 1)
end
