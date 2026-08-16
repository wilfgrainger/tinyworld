local VillageActivityDefinitions = {}

local DEFINITIONS = {
	{
		id = "TraderRequest",
		role = "Trader",
		displayName = "Village Request",
		baseCoins = 60,
		baseXp = 30,
		band = "short",
	},
	{
		id = "VillageGarden",
		role = "Gardener",
		displayName = "Village Garden Round",
		baseCoins = 60,
		baseXp = 30,
		band = "short",
	},
	{
		id = "Fishing",
		role = "Fisherman",
		displayName = "Harbour Fishing",
		baseCoins = 60,
		baseXp = 30,
		band = "short",
	},
	{
		id = "CoastalDelivery",
		role = "BoatKeeper",
		displayName = "Coastal Delivery",
		baseCoins = 140,
		baseXp = 70,
		band = "coastal",
	},
	{
		id = "BuilderRepair",
		role = "Builder",
		displayName = "Village Repair",
		baseCoins = 60,
		baseXp = 30,
		band = "short",
	},
}

local BY_ID = {}
local BY_ROLE = {}
for _, definition in DEFINITIONS do
	BY_ID[definition.id] = definition
	BY_ROLE[definition.role] = definition
end

function VillageActivityDefinitions.all()
	return DEFINITIONS
end

function VillageActivityDefinitions.get(id: string)
	return BY_ID[id]
end

function VillageActivityDefinitions.forRole(role: string)
	return BY_ROLE[role]
end

return VillageActivityDefinitions
