local TestUtil = require("./TestUtil")
local MermaidQuestRules = require("../src/shared/MermaidQuestRules")

return function()
	local profile = {
		ownsTinyBoat = true,
		boatActive = true,
		coins = 0,
		xp = 0,
		keepsakes = {},
		discoveredWorlds = {},
	}

	local allowed, reason = MermaidQuestRules.canEnter(profile, true)
	TestUtil.isTrue(allowed)
	TestUtil.equal(reason, nil)

	local quests = MermaidQuestRules.all()
	TestUtil.equal(#quests, 5)
	for _, questId in quests do
		local completed, completeReason = MermaidQuestRules.complete(profile, questId)
		TestUtil.isTrue(completed)
		TestUtil.equal(completeReason, nil)
	end
	TestUtil.equal(MermaidQuestRules.completedCount(profile), 5)
	TestUtil.isTrue(profile.discoveredWorlds.MermaidLand)
	TestUtil.equal(profile.coins, 700)
	TestUtil.equal(profile.xp, 425)

	local coins = profile.coins
	local xp = profile.xp
	local duplicate, duplicateReason = MermaidQuestRules.complete(profile, "PearlTrail")
	TestUtil.isFalse(duplicate)
	TestUtil.equal(duplicateReason, "already_complete")
	TestUtil.equal(profile.coins, coins)
	TestUtil.equal(profile.xp, xp)

	profile.boatActive = false
	local blocked, blockedReason = MermaidQuestRules.canEnter(profile, true)
	TestUtil.isFalse(blocked)
	TestUtil.equal(blockedReason, "boat_not_active")
end
