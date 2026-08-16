local VillageNpcDefinitions = {}

local DEFINITIONS = {
	{ id = "Trader", displayName = "Mara", anchor = "VillageShop" },
	{ id = "Gardener", displayName = "Pip", anchor = "Garden" },
	{ id = "Fisherman", displayName = "Finn", anchor = "Harbor" },
	{ id = "BoatKeeper", displayName = "Skye", anchor = "Harbor" },
	{ id = "Builder", displayName = "Milo", anchor = "Workshop" },
}

local BY_ID = {}
for _, definition in DEFINITIONS do
	BY_ID[definition.id] = definition
end

function VillageNpcDefinitions.all()
	return DEFINITIONS
end

function VillageNpcDefinitions.get(id: string)
	return BY_ID[id]
end

return VillageNpcDefinitions
