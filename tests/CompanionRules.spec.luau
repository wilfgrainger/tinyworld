local TestUtil = require("./TestUtil")
local CompanionRules = require("../src/shared/CompanionRules")

return function()
	local profile = { level = 9, keepsakes = {} }
	local unlockedEarly, earlyReason = CompanionRules.unlock(profile, "TinyCat")
	TestUtil.isFalse(unlockedEarly)
	TestUtil.equal(earlyReason, "level_too_low")
	TestUtil.isFalse(CompanionRules.isUnlocked(profile, "TinyCat"))

	profile.level = 10
	local unlocked, reason = CompanionRules.unlock(profile, "TinyCat")
	TestUtil.isTrue(unlocked)
	TestUtil.equal(reason, nil)
	TestUtil.isTrue(CompanionRules.isUnlocked(profile, "TinyCat"))

	local duplicate, duplicateReason = CompanionRules.unlock(profile, "TinyCat")
	TestUtil.isFalse(duplicate)
	TestUtil.equal(duplicateReason, "already_unlocked")

	local dog, dogReason = CompanionRules.unlock(profile, "TinyDog")
	TestUtil.isTrue(dog)
	TestUtil.equal(dogReason, nil)
	TestUtil.isTrue(CompanionRules.isUnlocked(profile, "TinyDog"))

	local unknown, unknownReason = CompanionRules.unlock(profile, "TinyDragon")
	TestUtil.isFalse(unknown)
	TestUtil.equal(unknownReason, "unknown_companion")
end
