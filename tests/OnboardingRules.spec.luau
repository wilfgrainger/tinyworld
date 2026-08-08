local TestUtil = require("./TestUtil")
local OnboardingRules = require("../src/shared/OnboardingRules")

return function()
	local valid, reason, trimmed = OnboardingRules.validateDisplayName("  Willow_7  ")
	TestUtil.isTrue(valid)
	TestUtil.equal(reason, "ok")
	TestUtil.equal(trimmed, "Willow_7")

	local tooShort = OnboardingRules.validateDisplayName("ab")
	TestUtil.isFalse(tooShort)
	local tooLong = OnboardingRules.validateDisplayName("12345678901234567")
	TestUtil.isFalse(tooLong)
	local badCharacters = OnboardingRules.validateDisplayName("Tiny.World")
	TestUtil.isFalse(badCharacters)
	local wrongType = OnboardingRules.validateDisplayName(42)
	TestUtil.isFalse(wrongType)

	TestUtil.isTrue(OnboardingRules.isValidAvatarStyle("Boy"))
	TestUtil.isTrue(OnboardingRules.isValidAvatarStyle("Girl"))
	TestUtil.isFalse(OnboardingRules.isValidAvatarStyle("Other"))
	TestUtil.isTrue(OnboardingRules.isValidStarterOutfit("Meadow"))
	TestUtil.isTrue(OnboardingRules.isValidStarterOutfit("Harbor"))
	TestUtil.isTrue(OnboardingRules.isValidStarterOutfit("Sunset"))
	TestUtil.isFalse(OnboardingRules.isValidStarterOutfit("Premium"))

	local profile = {
		displayName = "Mia",
		avatarStyle = "Girl",
		starterOutfit = "Sunset",
		onboardingComplete = true,
	}
	TestUtil.isTrue(OnboardingRules.isComplete(profile))
	profile.onboardingComplete = false
	TestUtil.isFalse(OnboardingRules.isComplete(profile))
	profile.onboardingComplete = true
	profile.displayName = ""
	TestUtil.isFalse(OnboardingRules.isComplete(profile))
end
