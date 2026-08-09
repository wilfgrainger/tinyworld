local ProfileStoreRules = {
	SESSION_LEASE_SECONDS = 120,
	SAVE_DEBOUNCE_SECONDS = 8,
	RETRY_BASE_SECONDS = 5,
	RETRY_MAX_SECONDS = 60,
	MAX_RETRIES = 5,
}

function ProfileStoreRules.isLeaseActive(session, now: number, _ownerToken: string): boolean
	return type(session) == "table"
		and type(session.token) == "string"
		and session.token ~= ""
		and type(session.expiresAt) == "number"
		and session.expiresAt > now
end

function ProfileStoreRules.isLeaseOwned(session, now: number, ownerToken: string): boolean
	return ProfileStoreRules.isLeaseActive(session, now, ownerToken) and session.token == ownerToken
end

function ProfileStoreRules.retryDelay(attempt: number, jitter: number?): number
	local safeAttempt = math.max(0, math.floor(attempt))
	local safeJitter = math.max(0, jitter or 0)
	local exponential = ProfileStoreRules.RETRY_BASE_SECONDS * (2 ^ safeAttempt)
	return math.min(ProfileStoreRules.RETRY_MAX_SECONDS, exponential) + safeJitter
end

function ProfileStoreRules.shouldRetry(attempt: number): boolean
	return attempt < ProfileStoreRules.MAX_RETRIES
end

function ProfileStoreRules.nextSaveState(currentState: string, event: string): string
	local transitions = {
		clean = { dirty = "dirty" },
		dirty = { scheduled = "queued" },
		saving = {
			["success-current"] = "clean",
			["success-newer"] = "queued",
			["failure-retry"] = "retrying",
			["failure-final"] = "failed",
		},
	}
	return if transitions[currentState] and transitions[currentState][event]
		then transitions[currentState][event]
		else currentState
end

return ProfileStoreRules
