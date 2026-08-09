local HouseCatalog

if script ~= nil then
	HouseCatalog = require(script.Parent.HouseCatalog)
else
	HouseCatalog = require("./HouseCatalog")
end

local HouseUpgrade = {}

function HouseUpgrade.tryUpgrade(profile: any): (boolean, string)
	local currentTier = math.floor(profile.houseTier)
	if currentTier >= HouseCatalog.maxTier then
		return false, "max_tier"
	end

	local nextTier = HouseCatalog.get(currentTier + 1)
	if nextTier == nil then
		return false, "max_tier"
	end

	if profile.level < nextTier.requiredLevel then
		return false, "level_too_low"
	end

	if profile.coins < nextTier.price then
		return false, "not_enough_coins"
	end

	profile.coins -= nextTier.price
	profile.houseTier = nextTier.tier

	return true, "upgraded"
end

return HouseUpgrade
