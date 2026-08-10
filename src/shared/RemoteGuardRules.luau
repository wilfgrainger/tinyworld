local RemoteGuardRules = {}

function RemoteGuardRules.isFiniteNumber(value: any): boolean
	return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

function RemoteGuardRules.numberInRange(value: any, minimum: number, maximum: number): boolean
	return RemoteGuardRules.isFiniteNumber(value) and value >= minimum and value <= maximum
end

function RemoteGuardRules.integerInRange(value: any, minimum: number, maximum: number): boolean
	return RemoteGuardRules.numberInRange(value, minimum, maximum) and math.floor(value) == value
end

function RemoteGuardRules.stringWithin(value: any, minimumLength: number, maximumLength: number): boolean
	return type(value) == "string" and #value >= minimumLength and #value <= maximumLength
end

function RemoteGuardRules.allowedId(value: any, allowed: any): boolean
	return type(value) == "string" and type(allowed) == "table" and allowed[value] == true
end

function RemoteGuardRules.consumeWindow(state: any, now: number, limit: number, windowSeconds: number): (boolean, any)
	local nextState = if type(state) == "table" then { startedAt = state.startedAt, count = state.count } else nil
	if
		nextState == nil
		or not RemoteGuardRules.isFiniteNumber(nextState.startedAt)
		or type(nextState.count) ~= "number"
		or now - nextState.startedAt >= windowSeconds
	then
		nextState = { startedAt = now, count = 0 }
	end

	if nextState.count >= limit then
		return false, nextState
	end
	nextState.count += 1
	return true, nextState
end

return RemoteGuardRules
