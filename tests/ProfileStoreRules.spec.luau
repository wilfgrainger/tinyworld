local TestUtil = require("./TestUtil")
local Rules = require("../src/shared/ProfileStoreRules")

return function()
	TestUtil.isTrue(Rules.isLeaseActive({ token = "a", expiresAt = 100 }, 99, "a"))
	TestUtil.isTrue(Rules.isLeaseActive({ token = "a", expiresAt = 100 }, 99, "b"))
	TestUtil.isFalse(Rules.isLeaseActive({ token = "a", expiresAt = 100 }, 101, "b"))
	TestUtil.isFalse(Rules.isLeaseActive(nil, 101, "b"))

	TestUtil.equal(Rules.retryDelay(0, 0), 5)
	TestUtil.equal(Rules.retryDelay(1, 0), 10)
	TestUtil.equal(Rules.retryDelay(5, 0), 60)
	TestUtil.equal(Rules.retryDelay(1, 0.5), 10.5)
	TestUtil.isTrue(Rules.shouldRetry(0))
	TestUtil.isFalse(Rules.shouldRetry(5))

	TestUtil.equal(Rules.nextSaveState("clean", "dirty"), "dirty")
	TestUtil.equal(Rules.nextSaveState("dirty", "scheduled"), "queued")
	TestUtil.equal(Rules.nextSaveState("saving", "success-current"), "clean")
	TestUtil.equal(Rules.nextSaveState("saving", "success-newer"), "queued")
	TestUtil.equal(Rules.nextSaveState("saving", "failure-retry"), "retrying")
	TestUtil.equal(Rules.nextSaveState("saving", "failure-final"), "failed")
end
