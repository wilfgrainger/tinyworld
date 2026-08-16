local TestUtil = require("./TestUtil")
local ProfileSchema = require("../src/shared/ProfileSchema")
local TraversalRules = require("../src/shared/TraversalRules")

return function()
	local poor = ProfileSchema.new()
	local boughtPoor, poorReason = TraversalRules.buyTinyBoat(poor)
	TestUtil.isFalse(boughtPoor)
	TestUtil.equal(poorReason, "not_enough_coins")
	TestUtil.equal(poor.coins, 100)
	TestUtil.isFalse(poor.ownsTinyBoat)

	local profile = ProfileSchema.new()
	profile.coins = TraversalRules.TINY_BOAT_PRICE
	local bought, reason = TraversalRules.buyTinyBoat(profile)
	TestUtil.isTrue(bought)
	TestUtil.equal(reason, "purchased")
	TestUtil.equal(profile.coins, 0)
	TestUtil.isTrue(profile.ownsTinyBoat)
	TestUtil.isFalse(profile.boatActive)

	local mounted, mountReason = TraversalRules.mountTinyBoat(profile)
	TestUtil.isTrue(mounted)
	TestUtil.equal(mountReason, "mounted")
	TestUtil.isTrue(profile.boatActive)

	local mountedAgain, mountedAgainReason = TraversalRules.mountTinyBoat(profile)
	TestUtil.isFalse(mountedAgain)
	TestUtil.equal(mountedAgainReason, "already_mounted")

	local returned, returnReason = TraversalRules.returnTinyBoat(profile)
	TestUtil.isTrue(returned)
	TestUtil.equal(returnReason, "returned")
	TestUtil.isFalse(profile.boatActive)

	local returnedAgain, returnedAgainReason = TraversalRules.returnTinyBoat(profile)
	TestUtil.isFalse(returnedAgain)
	TestUtil.equal(returnedAgainReason, "already_parked")

	local Zone = TraversalRules.Zone
	TestUtil.equal(TraversalRules.classifyDistanceFromVillage(10, 100, 36), Zone.VillageLand)
	TestUtil.equal(TraversalRules.classifyDistanceFromVillage(100, 100, 36), Zone.ShoreSwim)
	TestUtil.equal(TraversalRules.classifyDistanceFromVillage(135.9, 100, 36), Zone.ShoreSwim)
	TestUtil.equal(TraversalRules.classifyDistanceFromVillage(136.1, 100, 36), Zone.OuterSeaBoat)

	TestUtil.isTrue(TraversalRules.isWithinCoastalBounds(100, 100, 180))
	TestUtil.isTrue(TraversalRules.isWithinCoastalBounds(280, 100, 180))
	TestUtil.isFalse(TraversalRules.isWithinCoastalBounds(281, 100, 180))
	TestUtil.isFalse(TraversalRules.isWithinCoastalBounds(1000, 100, 180))

	local walker = ProfileSchema.new()
	local allowedWalk, walkReason = TraversalRules.canOccupyZone(walker, Zone.OuterSeaBoat)
	TestUtil.isFalse(allowedWalk)
	TestUtil.equal(walkReason, "tiny_boat_required")

	walker.ownsTinyBoat = true
	walker.boatActive = true
	local allowedBoat, boatReason = TraversalRules.canOccupyZone(walker, Zone.OuterSeaBoat)
	TestUtil.isTrue(allowedBoat)
	TestUtil.equal(boatReason, "allowed")

	local allowedSwim = TraversalRules.canOccupyZone(ProfileSchema.new(), Zone.ShoreSwim)
	TestUtil.isTrue(allowedSwim)
end
