local TraversalRules = {}

TraversalRules.TINY_BOAT_PRICE = 600

TraversalRules.Zone = {
	VillageLand = "village_land",
	ShoreSwim = "shore_swim",
	OuterSeaBoat = "outer_sea_boat",
}

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

function TraversalRules.classifyDistanceFromVillage(
	distance: number,
	shorelineDistance: number,
	swimDistance: number
): string
	if distance < shorelineDistance then
		return TraversalRules.Zone.VillageLand
	end
	if distance <= shorelineDistance + swimDistance then
		return TraversalRules.Zone.ShoreSwim
	end
	return TraversalRules.Zone.OuterSeaBoat
end

function TraversalRules.canOccupyZone(profile: any, zone: string): (boolean, string)
	if zone ~= TraversalRules.Zone.OuterSeaBoat then
		return true, "allowed"
	end
	if profile.ownsTinyBoat and profile.boatActive then
		return true, "allowed"
	end
	return false, "tiny_boat_required"
end

return TraversalRules
