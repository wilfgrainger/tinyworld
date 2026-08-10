local TestUtil = require("./TestUtil")
local routeOk, CourierRouteRules = pcall(require, "../src/shared/CourierRouteRules")

return function()
	TestUtil.isTrue(routeOk, "CourierRouteRules must exist for v0.6.2 varied deliveries")
	if not routeOk then
		return
	end

	local destinations = CourierRouteRules.destinationIds()
	TestUtil.equal(#destinations, 4, "Courier must have four bounded village destinations")
	TestUtil.equal(destinations[1], "VillageShop")
	TestUtil.equal(destinations[2], "TownHall")
	TestUtil.equal(destinations[3], "HomeStore")
	TestUtil.equal(destinations[4], "Workshop")

	local first = CourierRouteRules.nextDestination(nil, 1)
	local second = CourierRouteRules.nextDestination(first, 2)
	TestUtil.isTrue(first ~= second, "Courier route must avoid an immediate repeat")
	TestUtil.equal(CourierRouteRules.displayName("VillageShop"), "Village Shop")
	TestUtil.equal(CourierRouteRules.displayName("TownHall"), "Town Hall")
	TestUtil.equal(CourierRouteRules.displayName("HomeStore"), "Home Store")
	TestUtil.equal(CourierRouteRules.displayName("Workshop"), "Workshop")
	TestUtil.equal(CourierRouteRules.displayName("unknown"), nil)
end
