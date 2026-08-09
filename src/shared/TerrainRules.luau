local TerrainRules = {}

-- These are authored composition bands, not noise. The server places a small
-- number of bounded WedgeParts so neighbourhoods have readable elevation and
-- the same art seed always produces the same village silhouette.
TerrainRules.BANDS = {
	{ id = "MeadowLaneBank", x = -226, z = -132, width = 42, depth = 150, height = 4, rotation = -8, material = "Grass" },
	{ id = "HarbourSlope", x = 226, z = -118, width = 46, depth = 152, height = 6, rotation = 10, material = "Grass" },
	{ id = "WoodlandRise", x = -92, z = 226, width = 142, depth = 42, height = 8, rotation = 7, material = "Grass" },
	{ id = "OrchardTerrace", x = 92, z = 226, width = 142, depth = 42, height = 5, rotation = -6, material = "Ground" },
}

function TerrainRules.allBands()
	local bands = {}
	for index, band in TerrainRules.BANDS do
		bands[index] = {
			id = band.id,
			x = band.x,
			z = band.z,
			width = band.width,
			depth = band.depth,
			height = band.height,
			rotation = band.rotation,
			material = band.material,
		}
	end
	return bands
end

function TerrainRules.heightRange(): (number, number)
	local minimum = math.huge
	local maximum = -math.huge
	for _, band in TerrainRules.BANDS do
		minimum = math.min(minimum, band.height)
		maximum = math.max(maximum, band.height)
	end
	return minimum, maximum
end

return TerrainRules
