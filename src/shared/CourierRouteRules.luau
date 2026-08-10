local CourierRouteRules = {}

local DESTINATIONS = {
	{ id = "VillageShop", displayName = "Village Shop" },
	{ id = "TownHall", displayName = "Town Hall" },
	{ id = "HomeStore", displayName = "Home Store" },
	{ id = "Workshop", displayName = "Workshop" },
}

local BY_ID = {}
for _, destination in DESTINATIONS do
	BY_ID[destination.id] = destination
end

function CourierRouteRules.destinationIds(): { string }
	local result = {}
	for _, destination in DESTINATIONS do
		table.insert(result, destination.id)
	end
	return result
end

function CourierRouteRules.displayName(destinationId: string): string?
	local destination = BY_ID[destinationId]
	return if destination then destination.displayName else nil
end

function CourierRouteRules.nextDestination(previousId: string?, nonce: number): string
	local index = (math.max(0, math.floor(nonce)) % #DESTINATIONS) + 1
	if #DESTINATIONS > 1 and DESTINATIONS[index].id == previousId then
		index = (index % #DESTINATIONS) + 1
	end
	return DESTINATIONS[index].id
end

return CourierRouteRules
