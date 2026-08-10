local TestUtil = require("./TestUtil")
local ProfileStoreRules = require("../src/shared/ProfileStoreRules")

return function()
	TestUtil.equal(type(ProfileStoreRules.unwrapPersisted), "function", "persisted envelope classifier must exist")
	if type(ProfileStoreRules.unwrapPersisted) == "function" then
		local fresh, freshSession, freshError = ProfileStoreRules.unwrapPersisted(nil)
		TestUtil.equal(fresh, nil)
		TestUtil.equal(freshSession, nil)
		TestUtil.equal(freshError, nil)
		local legacy = { version = 10, coins = 42 }
		local legacyProfile, legacySession, legacyError = ProfileStoreRules.unwrapPersisted(legacy)
		TestUtil.equal(legacyProfile, legacy)
		TestUtil.equal(legacySession, nil)
		TestUtil.equal(legacyError, nil)
		local nested = { version = 11, coins = 99 }
		local session = { token = "safe", expiresAt = 100 }
		local nestedProfile, nestedSession, nestedError =
			ProfileStoreRules.unwrapPersisted({ profile = nested, session = session })
		TestUtil.equal(nestedProfile, nested)
		TestUtil.equal(nestedSession, session)
		TestUtil.equal(nestedError, nil)
		local malformedProfile, _, malformedError =
			ProfileStoreRules.unwrapPersisted({ profile = "corrupt", session = session })
		TestUtil.equal(malformedProfile, nil)
		TestUtil.equal(malformedError, "invalid_envelope_profile")
		local missingProfile, _, missingError = ProfileStoreRules.unwrapPersisted({ session = session })
		TestUtil.equal(missingProfile, nil)
		TestUtil.equal(missingError, "invalid_envelope_profile")
	end
	TestUtil.equal(ProfileStoreRules.SESSION_LEASE_SECONDS, 120)
	TestUtil.equal(ProfileStoreRules.SAVE_DEBOUNCE_SECONDS, 8)
	TestUtil.equal(ProfileStoreRules.RETRY_BASE_SECONDS, 5)
	TestUtil.equal(ProfileStoreRules.RETRY_MAX_SECONDS, 60)
	TestUtil.equal(ProfileStoreRules.MAX_RETRIES, 5)

	local mutationOwner = nil
	TestUtil.isTrue(ProfileStoreRules.canAcquireMutationLock(mutationOwner, "trade:txn-1"))
	mutationOwner = ProfileStoreRules.acquireMutationLock(mutationOwner, "trade:txn-1")
	TestUtil.equal(mutationOwner, "trade:txn-1")
	TestUtil.isFalse(ProfileStoreRules.externalMutationAllowed(mutationOwner))
	TestUtil.isFalse(ProfileStoreRules.canAcquireMutationLock(mutationOwner, "reward"))
	TestUtil.equal(ProfileStoreRules.releaseMutationLock(mutationOwner, "reward"), "trade:txn-1")
	mutationOwner = ProfileStoreRules.releaseMutationLock(mutationOwner, "trade:txn-1")
	TestUtil.equal(mutationOwner, nil)
	TestUtil.isTrue(ProfileStoreRules.externalMutationAllowed(mutationOwner))

	local lease = { token = "session-a", expiresAt = 100 }
	TestUtil.isTrue(ProfileStoreRules.isLeaseActive(lease, 99, "other-owner"))
	TestUtil.isFalse(ProfileStoreRules.isLeaseActive(lease, 100, "session-a"))
	TestUtil.isFalse(ProfileStoreRules.isLeaseActive({ token = "", expiresAt = 100 }, 0, "session-a"))
	TestUtil.isFalse(ProfileStoreRules.isLeaseActive({ token = "session-a", expiresAt = "100" }, 0, "session-a"))
	TestUtil.isFalse(ProfileStoreRules.isLeaseActive(nil, 0, "session-a"))

	TestUtil.isTrue(ProfileStoreRules.isLeaseOwned(lease, 99, "session-a"))
	TestUtil.isFalse(ProfileStoreRules.isLeaseOwned(lease, 99, "session-b"))
	TestUtil.isFalse(ProfileStoreRules.isLeaseOwned(lease, 100, "session-a"))

	TestUtil.equal(ProfileStoreRules.retryDelay(0), 5)
	TestUtil.equal(ProfileStoreRules.retryDelay(1), 10)
	TestUtil.equal(ProfileStoreRules.retryDelay(2, 2), 22)
	TestUtil.equal(ProfileStoreRules.retryDelay(1.9, 2), 12)
	TestUtil.equal(ProfileStoreRules.retryDelay(-4), 5)
	TestUtil.equal(ProfileStoreRules.retryDelay(999), 60)
	TestUtil.equal(ProfileStoreRules.retryDelay(999, -4), 60)

	TestUtil.isTrue(ProfileStoreRules.shouldRetry(-1))
	TestUtil.isTrue(ProfileStoreRules.shouldRetry(ProfileStoreRules.MAX_RETRIES - 1))
	TestUtil.isFalse(ProfileStoreRules.shouldRetry(ProfileStoreRules.MAX_RETRIES))

	TestUtil.equal(ProfileStoreRules.nextSaveState("clean", "dirty"), "dirty")
	TestUtil.equal(ProfileStoreRules.nextSaveState("dirty", "scheduled"), "queued")
	TestUtil.equal(ProfileStoreRules.nextSaveState("saving", "success-current"), "clean")
	TestUtil.equal(ProfileStoreRules.nextSaveState("saving", "success-newer"), "queued")
	TestUtil.equal(ProfileStoreRules.nextSaveState("saving", "failure-retry"), "retrying")
	TestUtil.equal(ProfileStoreRules.nextSaveState("saving", "failure-final"), "failed")

	TestUtil.equal(ProfileStoreRules.nextSaveState("clean", "scheduled"), "clean")
	TestUtil.equal(ProfileStoreRules.nextSaveState("queued", "dirty"), "queued")
	TestUtil.equal(ProfileStoreRules.nextSaveState("unknown", "dirty"), "unknown")
	TestUtil.equal(ProfileStoreRules.nextSaveState("saving", "unexpected"), "saving")
end
