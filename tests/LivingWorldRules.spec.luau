local TestUtil = require("./TestUtil")
local ProfileSchema = require("../src/shared/ProfileSchema")
local LivingWorldRules = require("../src/shared/LivingWorldRules")

return function()
	TestUtil.equal(LivingWorldRules.itemBit("MeadowSeed"), 1)
	TestUtil.equal(LivingWorldRules.itemBit("Seashell"), 2)
	TestUtil.equal(LivingWorldRules.itemBit("WoodToken"), 4)
	TestUtil.equal(LivingWorldRules.itemBit("Carrot"), nil)

	local profile = ProfileSchema.new()
	profile.livingCollectionDay = "day-one"
	profile.livingCollectionMask = 5
	TestUtil.equal(LivingWorldRules.collectionCount(profile, "day-one"), 2)
	TestUtil.equal(LivingWorldRules.collectionCount(profile, "day-two"), 0)

	local collected, reason = LivingWorldRules.collect(profile, "Seashell", "day-one")
	TestUtil.isTrue(collected)
	TestUtil.equal(reason, "collected")
	TestUtil.equal(profile.inventory.Seashell, 1)
	TestUtil.equal(profile.livingCollectionMask, 7)
	TestUtil.equal(LivingWorldRules.collectionCount(profile, "day-one"), 3)

	collected, reason = LivingWorldRules.collect(profile, "Seashell", "day-one")
	TestUtil.isFalse(collected)
	TestUtil.equal(reason, "already_collected")
	TestUtil.equal(profile.inventory.Seashell, 1)

	collected, reason = LivingWorldRules.collect(profile, "MeadowSeed", "day-two")
	TestUtil.isTrue(collected)
	TestUtil.equal(reason, "collected")
	TestUtil.equal(profile.livingCollectionDay, "day-two")
	TestUtil.equal(profile.livingCollectionMask, 1)
	TestUtil.equal(profile.inventory.MeadowSeed, 1)
	TestUtil.equal(LivingWorldRules.collectionCount(profile, "day-two"), 1)
	TestUtil.equal(LivingWorldRules.collectionCount(profile, "day-one"), 0)

	local beforeDay = profile.livingCollectionDay
	local unsupported, unsupportedReason = LivingWorldRules.collect(profile, "Carrot", "day-three")
	TestUtil.isFalse(unsupported)
	TestUtil.equal(unsupportedReason, "unsupported_item")
	TestUtil.equal(profile.livingCollectionDay, beforeDay)
	TestUtil.equal(profile.livingCollectionMask, 1)

	local charmProfile = ProfileSchema.new()
	charmProfile.inventory.MeadowSeed = 1
	charmProfile.inventory.Seashell = 1
	charmProfile.inventory.WoodToken = 1
	TestUtil.isTrue(LivingWorldRules.canAddHomeCharm(charmProfile))
	local applied, applyReason = LivingWorldRules.addHomeCharm(charmProfile)
	TestUtil.isTrue(applied)
	TestUtil.equal(applyReason, "applied")
	TestUtil.isTrue(charmProfile.homeCharmApplied)
	TestUtil.equal(charmProfile.inventory.MeadowSeed, 0)
	TestUtil.equal(charmProfile.inventory.Seashell, 0)
	TestUtil.equal(charmProfile.inventory.WoodToken, 0)
	TestUtil.isFalse(LivingWorldRules.canAddHomeCharm(charmProfile))

	local alreadyApplied, alreadyAppliedReason = LivingWorldRules.addHomeCharm(charmProfile)
	TestUtil.isFalse(alreadyApplied)
	TestUtil.equal(alreadyAppliedReason, "already_applied")

	local missingProfile = ProfileSchema.new()
	missingProfile.inventory.MeadowSeed = 1
	missingProfile.inventory.Seashell = 1
	TestUtil.isFalse(LivingWorldRules.canAddHomeCharm(missingProfile))
	local missing, missingReason = LivingWorldRules.addHomeCharm(missingProfile)
	TestUtil.isFalse(missing)
	TestUtil.equal(missingReason, "missing_items")
	TestUtil.equal(missingProfile.inventory.MeadowSeed, 1)
	TestUtil.equal(missingProfile.inventory.Seashell, 1)
end
