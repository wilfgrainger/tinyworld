local TransportRules = {}
TransportRules.TINY_BIKE_PRICE = 300

function TransportRules.buyTinyBike(profile: any): (boolean, string)
	if profile.ownsTinyBike then
		return false, "already_owned"
	end
	if profile.coins < TransportRules.TINY_BIKE_PRICE then
		return false, "not_enough_coins"
	end
	profile.coins -= TransportRules.TINY_BIKE_PRICE
	profile.ownsTinyBike = true
	return true, "purchased"
end

function TransportRules.mountTinyBike(profile: any): (boolean, string)
	if not profile.ownsTinyBike then
		return false, "not_owned"
	end
	if profile.bikeActive then
		return false, "already_mounted"
	end
	profile.bikeActive = true
	return true, "mounted"
end

function TransportRules.dismountTinyBike(profile: any): (boolean, string)
	if not profile.bikeActive then
		return false, "already_parked"
	end
	profile.bikeActive = false
	return true, "parked"
end

function TransportRules.movementSpeed(profile: any): number
	return if profile.ownsTinyBike and profile.bikeActive then 24 else 16
end

return TransportRules
