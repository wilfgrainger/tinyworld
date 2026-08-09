local TestUtil = require("./TestUtil")
local ProfileSchema = require("../src/shared/ProfileSchema")
local OnboardingRules = require("../src/shared/OnboardingRules")

return function()
	local valid, reason, normalized = OnboardingRules.validateDisplayName("  River-7  ")
	TestUtil.isTrue(valid)
	TestUtil.equal(reason, "ok")
	TestUtil.equal(normalized, "River-7")

	local exactMinimum, minimumReason = OnboardingRules.validateDisplayName("Mia")
	TestUtil.isTrue(exactMinimum)
	TestUtil.equal(minimumReason, "ok")
	local exactMaximum = string.rep("a", 16)
	TestUtil.isTrue(OnboardingRules.validateDisplayName(exactMaximum))

	local missing, missingReason, missingValue = OnboardingRules.validateDisplayName(nil)
	TestUtil.isFalse(missing)
	TestUtil.equal(missingReason, "name_required")
	TestUtil.equal(missingValue, nil)

	local tooShort, tooShortReason = OnboardingRules.validateDisplayName("ab")
	TestUtil.isFalse(tooShort)
	TestUtil.equal(tooShortReason, "name_too_short")
	local tooLong, tooLongReason = OnboardingRules.validateDisplayName(string.rep("b", 17))
	TestUtil.isFalse(tooLong)
	TestUtil.equal(tooLongReason, "name_too_long")
	local invalidCharacters, invalidReason = OnboardingRules.validateDisplayName("Mia!")
	TestUtil.isFalse(invalidCharacters)
	TestUtil.equal(invalidReason, "name_invalid_characters")
	local wrongType, wrongTypeReason = OnboardingRules.validateDisplayName(123)
	TestUtil.isFalse(wrongType)
	TestUtil.equal(wrongTypeReason, "name_required")

	TestUtil.isTrue(OnboardingRules.isValidAvatarStyle("Boy"))
	TestUtil.isTrue(OnboardingRules.isValidAvatarStyle("Girl"))
	TestUtil.isFalse(OnboardingRules.isValidAvatarStyle("Robot"))
	TestUtil.isFalse(OnboardingRules.isValidAvatarStyle(nil))
	TestUtil.isTrue(OnboardingRules.isValidStarterOutfit("Meadow"))
	TestUtil.isTrue(OnboardingRules.isValidStarterOutfit("Harbor"))
	TestUtil.isTrue(OnboardingRules.isValidStarterOutfit("Sunset"))
	TestUtil.isFalse(OnboardingRules.isValidStarterOutfit("Forest"))

	local incomplete = ProfileSchema.new()
	TestUtil.isFalse(OnboardingRules.isComplete(incomplete))
	TestUtil.isFalse(OnboardingRules.isComplete(nil))

	incomplete.displayName = "Ari_7"
	incomplete.avatarStyle = "Girl"
	incomplete.starterOutfit = "Harbor"
	incomplete.onboardingComplete = true
	TestUtil.isTrue(OnboardingRules.isComplete(incomplete))

	incomplete.displayName = "Ari!"
	TestUtil.isFalse(OnboardingRules.isComplete(incomplete))
	incomplete.displayName = "Ari_7"
	incomplete.onboardingComplete = false
	TestUtil.isFalse(OnboardingRules.isComplete(incomplete))
end
