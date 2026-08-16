local TestUtil = require("./TestUtil")
local ProfileSchema = require("../src/shared/ProfileSchema")
local TransportRules = require("../src/shared/TransportRules")
local ShopDefinitions = require("../src/shared/ShopDefinitions")

return function()
	TestUtil.equal(ShopDefinitions.priceFor("Workshop", "TinyBike"), 300, "Tiny Bike catalogue price must remain 300")
	TestUtil.equal(TransportRules.TINY_BIKE_PRICE, 300)
	local poor = ProfileSchema.new()
	local boughtPoor, poorReason = TransportRules.buyTinyBike(poor)
	TestUtil.isFalse(boughtPoor)
	TestUtil.equal(poorReason, "not_enough_coins")

	local profile = ProfileSchema.new()
	profile.coins = 400
	local bought, reason = TransportRules.buyTinyBike(profile)
	TestUtil.isTrue(bought)
	TestUtil.equal(reason, "purchased")
	local mounted, mountReason = TransportRules.mountTinyBike(profile)
	TestUtil.isTrue(mounted)
	TestUtil.equal(mountReason, "mounted")
	TestUtil.equal(TransportRules.movementSpeed(profile), 24)
	local parked, parkReason = TransportRules.dismountTinyBike(profile)
	TestUtil.isTrue(parked)
	TestUtil.equal(parkReason, "parked")

	profile.level = 7
	TestUtil.isFalse(TransportRules.canUseTinyCar(profile))
	profile.level = 8
	TestUtil.isTrue(TransportRules.canUseTinyCar(profile))
end
