local AlphaOpsRules = {}

AlphaOpsRules.RELEASE_VERSION = "0.1.0"
AlphaOpsRules.CHANNEL = "INVITED_ALPHA"
AlphaOpsRules.RECOMMENDED_COHORT_SIZE = 8
AlphaOpsRules.HEALTH_POLL_SECONDS = 5

local function safeCount(value: any): number
	if type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge then
		return 0
	end
	return math.max(0, math.floor(value))
end

function AlphaOpsRules.cohortState(activeCount: number, limit: number?): string
	local active = safeCount(activeCount)
	local cap = math.max(1, safeCount(limit or AlphaOpsRules.RECOMMENDED_COHORT_SIZE))
	if active > cap then
		return "over-cap"
	end
	if active == cap then
		return "at-cap"
	end
	return "ready"
end

function AlphaOpsRules.healthState(diagnostics, onboardingComplete: boolean): string
	if type(diagnostics) ~= "table" then
		return "recovery-required"
	end
	if diagnostics.sessionState ~= "active" or diagnostics.state == "failed" then
		return "recovery-required"
	end
	if onboardingComplete ~= true then
		return "setup"
	end
	if
		safeCount(diagnostics.queueDepth) > 0
		or diagnostics.state == "dirty"
		or diagnostics.state == "queued"
		or diagnostics.state == "saving"
		or diagnostics.state == "retrying"
	then
		return "saving"
	end
	return "ready"
end

function AlphaOpsRules.aggregateState(
	activeCount: number,
	savingCount: number,
	recoveryCount: number,
	cohortLimit: number?
): { cohort: string, health: string }
	local recovery = safeCount(recoveryCount)
	local saving = safeCount(savingCount)
	return {
		cohort = AlphaOpsRules.cohortState(activeCount, cohortLimit),
		health = if recovery > 0 then "recovery-required" elseif saving > 0 then "saving" else "ready",
	}
end

return AlphaOpsRules
