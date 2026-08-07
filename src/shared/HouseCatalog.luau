local HouseCatalog = {}

export type HouseTier = {
	tier: number,
	name: string,
	price: number,
	requiredLevel: number,
}

local TIERS: { HouseTier } = {
	{ tier = 1, name = "Starter Nook", price = 0, requiredLevel = 1 },
	{ tier = 2, name = "Cosy Cottage", price = 250, requiredLevel = 2 },
	{ tier = 3, name = "Family Home", price = 750, requiredLevel = 4 },
	{ tier = 4, name = "Garden House", price = 1500, requiredLevel = 7 },
	{ tier = 5, name = "Grand Villa", price = 3000, requiredLevel = 10 },
}

HouseCatalog.maxTier = #TIERS

function HouseCatalog.get(tier: number): HouseTier?
	local index = math.floor(tier)
	return TIERS[index]
end

return HouseCatalog
