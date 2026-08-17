local ActivityLeaseRules = {}

ActivityLeaseRules.LEASE_SECONDS = 120

function ActivityLeaseRules.new(ownerId: number, now: number)
	return {
		ownerId = ownerId,
		expiresAt = now + ActivityLeaseRules.LEASE_SECONDS,
	}
end

function ActivityLeaseRules.isExpired(lease: any, now: number): boolean
	return type(lease) ~= "table" or type(lease.expiresAt) ~= "number" or now >= lease.expiresAt
end

function ActivityLeaseRules.isOwnedBy(lease: any, ownerId: number, now: number): boolean
	return type(lease) == "table" and lease.ownerId == ownerId and not ActivityLeaseRules.isExpired(lease, now)
end

function ActivityLeaseRules.canAcquire(lease: any, requesterId: number, now: number): boolean
	return ActivityLeaseRules.isExpired(lease, now) or lease.ownerId == requesterId
end

function ActivityLeaseRules.refresh(lease: any, ownerId: number, now: number): boolean
	if not ActivityLeaseRules.isOwnedBy(lease, ownerId, now) then
		return false
	end
	lease.expiresAt = now + ActivityLeaseRules.LEASE_SECONDS
	return true
end

return ActivityLeaseRules
