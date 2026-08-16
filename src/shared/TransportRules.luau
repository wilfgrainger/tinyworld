local ShopDefinitions
if script ~= nil then
	ShopDefinitions = require(script.Parent:WaitForChild("ShopDefinitions"))
else
	ShopDefinitions = require("./ShopDefinitions")
end

local TransportRules = {}
local tinyBikePrice = ShopDefinitions.priceFor("Workshop", "TinyBike")
assert(type(tinyBikePrice) == "number", "Tiny Bike must have a canonical Workshop price")
TransportRules.TINY_BIKE_PRICE = tinyBikePrice
TransportRules.TINY_CAR_LEVEL = 8

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

function TransportRules.canUseTinyCar(profile: any): boolean
	return profile.level >= TransportRules.TINY_CAR_LEVEL
end

function TransportRules.movementSpeed(profile: any): number
	return if profile.ownsTinyBike and profile.bikeActive then 24 else 16
end

return TransportRules
