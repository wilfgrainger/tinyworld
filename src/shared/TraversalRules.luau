local TraversalRules = {}

TraversalRules.TINY_BOAT_PRICE = 600

function TraversalRules.buyTinyBoat(profile: any): (boolean, string)
	if profile.ownsTinyBoat then
		return false, "already_owned"
	end
	if profile.coins < TraversalRules.TINY_BOAT_PRICE then
		return false, "not_enough_coins"
	end
	profile.coins -= TraversalRules.TINY_BOAT_PRICE
	profile.ownsTinyBoat = true
	return true, "purchased"
end

function TraversalRules.mountTinyBoat(profile: any): (boolean, string)
	if not profile.ownsTinyBoat then
		return false, "not_owned"
	end
	if profile.boatActive then
		return false, "already_mounted"
	end
	profile.boatActive = true
	return true, "mounted"
end

function TraversalRules.returnTinyBoat(profile: any): (boolean, string)
	if not profile.boatActive then
		return false, "already_parked"
	end
	profile.boatActive = false
	return true, "returned"
end

return TraversalRules

