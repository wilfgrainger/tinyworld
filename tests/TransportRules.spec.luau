local TestUtil = require("./TestUtil")
local ProfileSchema = require("../src/shared/ProfileSchema")
local TransportRules = require("../src/shared/TransportRules")

return function()
	local poor = ProfileSchema.new()
	local boughtPoor, poorReason = TransportRules.buyTinyBike(poor)
	TestUtil.isFalse(boughtPoor)
	TestUtil.equal(poorReason, "not_enough_coins")
	TestUtil.equal(poor.coins, 100)
	TestUtil.isFalse(poor.ownsTinyBike)

	local profile = ProfileSchema.new()
	profile.coins = 400
	local bought, reason = TransportRules.buyTinyBike(profile)
	TestUtil.isTrue(bought)
	TestUtil.equal(reason, "purchased")
	TestUtil.equal(profile.coins, 100)
	TestUtil.isTrue(profile.ownsTinyBike)

	local boughtAgain, secondReason = TransportRules.buyTinyBike(profile)
	TestUtil.isFalse(boughtAgain)
	TestUtil.equal(secondReason, "already_owned")
	TestUtil.equal(profile.coins, 100)
end
