local AppearanceDefinitions = {}

local HAIR = {
	{ id = "Tousled", displayName = "Tousled", assetRole = "hair-tousled" },
	{ id = "Bob", displayName = "Soft Bob", assetRole = "hair-bob" },
	{ id = "Braids", displayName = "Twin Braids", assetRole = "hair-braids" },
	{ id = "Curls", displayName = "Cloud Curls", assetRole = "hair-curls" },
	{ id = "Crop", displayName = "Short Crop", assetRole = "hair-crop" },
	{ id = "Ponytail", displayName = "High Ponytail", assetRole = "hair-ponytail" },
	{ id = "Waves", displayName = "Harbour Waves", assetRole = "hair-waves" },
	{ id = "Bun", displayName = "Garden Bun", assetRole = "hair-bun" },
}

local OUTFITS = {
	{ id = "Starter", displayName = "TinyWorld Starter", top = "MeadowTop", bottom = "DenimBottom", shoes = "CanvasShoes", accessory = "None" },
	{ id = "Meadow", displayName = "Meadow Day", top = "MeadowTop", bottom = "LeafBottom", shoes = "GardenShoes", accessory = "FlowerPin" },
	{ id = "Harbor", displayName = "Harbour Day", top = "HarborTop", bottom = "DenimBottom", shoes = "DeckShoes", accessory = "ShellPin" },
	{ id = "Sunset", displayName = "Sunset Day", top = "SunsetTop", bottom = "BerryBottom", shoes = "CanvasShoes", accessory = "StarPin" },
	{ id = "Courier", displayName = "Courier Ready", top = "CourierTop", bottom = "CourierBottom", shoes = "RunnerShoes", accessory = "ParcelPin" },
	{ id = "Workshop", displayName = "Workshop Day", top = "WorkshopTop", bottom = "WorkshopBottom", shoes = "BootShoes", accessory = "CogPin" },
	{ id = "Moonlight", displayName = "Moonlight", top = "MoonTop", bottom = "MoonBottom", shoes = "SoftShoes", accessory = "MoonPin" },
	{ id = "Cloudpost", displayName = "Cloudpost", top = "CloudTop", bottom = "SkyBottom", shoes = "CloudShoes", accessory = "SkyBellPin" },
}

function AppearanceDefinitions.hairStyles()
	local result = {}
	for _, style in HAIR do
		table.insert(result, style)
	end
	return result
end

function AppearanceDefinitions.outfits()
	local result = {}
	for _, outfit in OUTFITS do
		table.insert(result, outfit)
	end
	return result
end

function AppearanceDefinitions.getOutfit(outfitId: string)
	for _, outfit in OUTFITS do
		if outfit.id == outfitId then
			return outfit
		end
	end
	return nil
end

function AppearanceDefinitions.getHair(hairId: string)
	for _, style in HAIR do
		if style.id == hairId then
			return style
		end
	end
	return nil
end

return AppearanceDefinitions
