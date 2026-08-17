local TestUtil = require("./TestUtil")
local PlayerPhaseRules = require("../src/shared/PlayerPhaseRules")

return function()
	local allowed, reason = PlayerPhaseRules.canEnterGameplay(nil)
	TestUtil.isFalse(allowed)
	TestUtil.equal(reason, "profile_unavailable")

	allowed, reason = PlayerPhaseRules.canEnterGameplay({ onboardingComplete = false })
	TestUtil.isFalse(allowed)
	TestUtil.equal(reason, "onboarding_incomplete")

	allowed, reason = PlayerPhaseRules.canEnterGameplay({ onboardingComplete = true })
	TestUtil.isTrue(allowed)
	TestUtil.equal(reason, nil)
end
