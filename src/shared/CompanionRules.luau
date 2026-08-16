local CompanionRules = {}

local VALID = { TinyCat = true, TinyDog = true }
local REQUIRED_LEVEL = 10

function CompanionRules.isUnlocked(profile: any, companionId: string): boolean
	return VALID[companionId] == true and profile.keepsakes["Companion:" .. companionId] == 1
end

function CompanionRules.unlock(profile: any, companionId: string): (boolean, string?)
	if VALID[companionId] ~= true then
		return false, "unknown_companion"
	end
	if profile.level < REQUIRED_LEVEL then
		return false, "level_too_low"
	end
	local key = "Companion:" .. companionId
	if profile.keepsakes[key] == 1 then
		return false, "already_unlocked"
	end
	profile.keepsakes[key] = 1
	return true, nil
end

function CompanionRules.requiredLevel(): number
	return REQUIRED_LEVEL
end

return CompanionRules
