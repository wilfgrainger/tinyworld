local PlayerPhaseRules = {}

function PlayerPhaseRules.canEnterGameplay(profile: any): (boolean, string?)
	if type(profile) ~= "table" then
		return false, "profile_unavailable"
	end
	if profile.onboardingComplete ~= true then
		return false, "onboarding_incomplete"
	end
	return true, nil
end

return PlayerPhaseRules
