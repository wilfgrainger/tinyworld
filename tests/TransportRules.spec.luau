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
	TestUtil.isFalse(profile.bikeActive)
	TestUtil.equal(TransportRules.movementSpeed(profile), 16)

	local mounted, mountReason = TransportRules.mountTinyBike(profile)
	TestUtil.isTrue(mounted)
	TestUtil.equal(mountReason, "mounted")
	TestUtil.isTrue(profile.bikeActive)
	TestUtil.equal(TransportRules.movementSpeed(profile), 24)

	local mountedAgain, mountedAgainReason = TransportRules.mountTinyBike(profile)
	TestUtil.isFalse(mountedAgain)
	TestUtil.equal(mountedAgainReason, "already_mounted")

	local parked, parkReason = TransportRules.dismountTinyBike(profile)
	TestUtil.isTrue(parked)
	TestUtil.equal(parkReason, "parked")
	TestUtil.isFalse(profile.bikeActive)
	TestUtil.equal(TransportRules.movementSpeed(profile), 16)

	local parkedAgain, parkedAgainReason = TransportRules.dismountTinyBike(profile)
	TestUtil.isFalse(parkedAgain)
	TestUtil.equal(parkedAgainReason, "already_parked")

	local boughtAgain, secondReason = TransportRules.buyTinyBike(profile)
	TestUtil.isFalse(boughtAgain)
	TestUtil.equal(secondReason, "already_owned")
	TestUtil.equal(profile.coins, 100)
end
