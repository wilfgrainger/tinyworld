local TestUtil = require("./TestUtil")
local ProfileSchema = require("../src/shared/ProfileSchema")
local DailyReward = require("../src/shared/DailyReward")

return function()
	local profile = ProfileSchema.new()
	local claimed, reason = DailyReward.claim(profile, "2026-08-07")
	TestUtil.isTrue(claimed)
	TestUtil.equal(reason, "claimed")
	TestUtil.equal(profile.coins, 300)
	TestUtil.equal(profile.xp, 50)
	TestUtil.equal(profile.inventory.Carrot, 1)
	TestUtil.equal(profile.lastDailyDay, "2026-08-07")

	local claimedAgain, secondReason = DailyReward.claim(profile, "2026-08-07")
	TestUtil.isFalse(claimedAgain)
	TestUtil.equal(secondReason, "already_claimed")
	TestUtil.equal(profile.coins, 300)
	TestUtil.equal(profile.inventory.Carrot, 1)
end

