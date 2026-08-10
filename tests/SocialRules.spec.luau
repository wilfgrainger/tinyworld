local TestUtil = require("./TestUtil")
local SocialRules = require("../src/shared/SocialRules")

return function()
	TestUtil.isTrue(SocialRules.privacyAllows("Open", false, false))
	TestUtil.isTrue(SocialRules.privacyAllows("Friends", false, true))
	TestUtil.isFalse(SocialRules.privacyAllows("Friends", false, false))
	TestUtil.isFalse(SocialRules.privacyAllows("Private", false, true))
	TestUtil.isTrue(SocialRules.privacyAllows("Private", true, false))
	TestUtil.isFalse(SocialRules.privacyAllows("Unknown", false, true))

	local members = {}
	local joined, reason = SocialRules.joinParty(members, 101)
	TestUtil.isTrue(joined)
	TestUtil.equal(reason, "joined")
	TestUtil.equal(SocialRules.partySize(members), 1)

	joined, reason = SocialRules.joinParty(members, 101)
	TestUtil.isFalse(joined)
	TestUtil.equal(reason, "already_member")

	for userId = 102, 104 do
		joined, reason = SocialRules.joinParty(members, userId)
		TestUtil.isTrue(joined)
		TestUtil.equal(reason, "joined")
	end
	TestUtil.equal(SocialRules.partySize(members), SocialRules.MAX_PARTY_SIZE)
	joined, reason = SocialRules.joinParty(members, 105)
	TestUtil.isFalse(joined)
	TestUtil.equal(reason, "party_full")
	TestUtil.isTrue(SocialRules.canShareActivity(members, 101))

	local left, leaveReason = SocialRules.leaveParty(members, 105)
	TestUtil.isFalse(left)
	TestUtil.equal(leaveReason, "not_member")
	left, leaveReason = SocialRules.leaveParty(members, 102)
	TestUtil.isTrue(left)
	TestUtil.equal(leaveReason, "left")
	TestUtil.equal(SocialRules.partySize(members), 3)
	TestUtil.isTrue(SocialRules.canShareActivity(members, 101))

	local solo = { ["only"] = true }
	TestUtil.isFalse(SocialRules.canShareActivity(solo, "only"))
	TestUtil.isFalse(SocialRules.canShareActivity({}, "nobody"))
end
