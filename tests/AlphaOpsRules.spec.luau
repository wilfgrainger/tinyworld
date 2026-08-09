local TestUtil = require("./TestUtil")
local Rules = require("../src/shared/AlphaOpsRules")

return function()
	TestUtil.equal(Rules.RELEASE_VERSION, "0.1.0")
	TestUtil.equal(Rules.CHANNEL, "INVITED_ALPHA")
	TestUtil.equal(Rules.RECOMMENDED_COHORT_SIZE, 8)

	TestUtil.equal(Rules.cohortState(0), "ready")
	TestUtil.equal(Rules.cohortState(8), "at-cap")
	TestUtil.equal(Rules.cohortState(9), "over-cap")

	local clean = { state = "clean", queueDepth = 0, sessionState = "active" }
	TestUtil.equal(Rules.healthState(clean, true), "ready")
	TestUtil.equal(Rules.healthState(clean, false), "setup")
	TestUtil.equal(Rules.healthState({ state = "queued", queueDepth = 1, sessionState = "active" }, true), "saving")
	TestUtil.equal(Rules.healthState({ state = "retrying", queueDepth = 1, sessionState = "active" }, true), "saving")
	TestUtil.equal(Rules.healthState({ state = "failed", queueDepth = 0, sessionState = "active" }, true), "recovery-required")
	TestUtil.equal(Rules.healthState({ state = "clean", queueDepth = 0, sessionState = "lost" }, true), "recovery-required")
	TestUtil.equal(Rules.healthState(nil, true), "recovery-required")

	local aggregate = Rules.aggregateState(3, 0, 0, 8)
	TestUtil.equal(aggregate.cohort, "ready")
	TestUtil.equal(aggregate.health, "ready")
	aggregate = Rules.aggregateState(8, 1, 2, 8)
	TestUtil.equal(aggregate.cohort, "at-cap")
	TestUtil.equal(aggregate.health, "recovery-required")
	TestUtil.equal(Rules.aggregateState(0, 0, 0, 8).health, "ready")
end
