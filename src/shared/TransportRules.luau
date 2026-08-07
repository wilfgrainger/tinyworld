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

return TransportRules
