local OnboardingRules = {}

local VALID_AVATAR_STYLES = {
	Boy = true,
	Girl = true,
}

local VALID_STARTER_OUTFITS = {
	Meadow = true,
	Harbor = true,
	Sunset = true,
}

function OnboardingRules.validateDisplayName(value: any): (boolean, string, string?)
	if type(value) ~= "string" then
		return false, "name_required", nil
	end

	local trimmed = string.match(value, "^%s*(.-)%s*$") or ""
	if #trimmed < 3 then
		return false, "name_too_short", nil
	end
	if #trimmed > 16 then
		return false, "name_too_long", nil
	end
	if string.match(trimmed, "^[%w%s_%-]+$") == nil then
		return false, "name_invalid_characters", nil
	end
	return true, "ok", trimmed
end

function OnboardingRules.isValidAvatarStyle(value: any): boolean
	return type(value) == "string" and VALID_AVATAR_STYLES[value] == true
end

function OnboardingRules.isValidStarterOutfit(value: any): boolean
	return type(value) == "string" and VALID_STARTER_OUTFITS[value] == true
end

function OnboardingRules.isComplete(profile: any): boolean
	local validName = OnboardingRules.validateDisplayName(profile and profile.displayName)
	return profile ~= nil
		and profile.onboardingComplete == true
		and validName == true
		and OnboardingRules.isValidAvatarStyle(profile.avatarStyle)
		and OnboardingRules.isValidStarterOutfit(profile.starterOutfit)
end

return OnboardingRules

