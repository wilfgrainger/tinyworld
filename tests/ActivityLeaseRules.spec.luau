local TestUtil = require("./TestUtil")
local ActivityLeaseRules = require("../src/shared/ActivityLeaseRules")

return function()
	TestUtil.equal(ActivityLeaseRules.LEASE_SECONDS, 120)
	TestUtil.isTrue(ActivityLeaseRules.canAcquire(nil, 10, 0))

	local lease = ActivityLeaseRules.new(10, 100)
	TestUtil.equal(lease.ownerId, 10)
	TestUtil.equal(lease.expiresAt, 220)
	TestUtil.isFalse(ActivityLeaseRules.isExpired(lease, 219.99))
	TestUtil.isTrue(ActivityLeaseRules.isExpired(lease, 220))
	TestUtil.isTrue(ActivityLeaseRules.isOwnedBy(lease, 10, 150))
	TestUtil.isFalse(ActivityLeaseRules.isOwnedBy(lease, 11, 150))
	TestUtil.isFalse(ActivityLeaseRules.isOwnedBy(lease, 10, 220))

	TestUtil.isTrue(ActivityLeaseRules.canAcquire(lease, 10, 150))
	TestUtil.isFalse(ActivityLeaseRules.canAcquire(lease, 11, 150))
	TestUtil.isTrue(ActivityLeaseRules.canAcquire(lease, 11, 220))

	TestUtil.isTrue(ActivityLeaseRules.refresh(lease, 10, 150))
	TestUtil.equal(lease.expiresAt, 270)
	TestUtil.isFalse(ActivityLeaseRules.refresh(lease, 11, 160))
	TestUtil.equal(lease.expiresAt, 270)
	TestUtil.isFalse(ActivityLeaseRules.refresh(lease, 10, 270))
end
