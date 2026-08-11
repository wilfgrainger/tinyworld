local VisualBudgetRules = require("./VisualBudgetRules")

local VillageCompositionRules = {}

local MANIFEST = {
	neighbourhoods = {
		{
			name = "MeadowLane",
			features = {
				curvedPath = true,
				stream = true,
				bridge = true,
				grassBanks = true,
				cottageGarden = true,
				flowerMeadow = true,
				elevation = true,
				dressing = true,
			},
		},
		{
			name = "HarbourRow",
			features = {
				curvedPath = true,
				retainingWall = true,
				dockClutter = true,
				coastalPlanting = true,
				elevation = true,
				dressing = true,
			},
		},
		{
			name = "WoodlandRise",
			features = {
				curvedPath = true,
				canopy = true,
				rockClusters = true,
				narrowPath = true,
				woodlandFence = true,
				elevation = true,
				dressing = true,
			},
		},
		{
			name = "OrchardEnd",
			features = {
				curvedPath = true,
				orchard = true,
				vegetableBeds = true,
				nursery = true,
				terrace = true,
				elevation = true,
				dressing = true,
			},
		},
	},
	civic = {
		fountainPlaza = true,
		plantedEdges = true,
		seating = true,
		lamps = true,
		framedApproaches = true,
	},
	terrain = { bandCount = 4, minimumHeight = 4, maximumHeight = 8 },
	dressing = { canCollide = false, canTouch = false, canQuery = false },
	returnFields = { "roads", "civic", "neighbourhoods", "terrain", "decorationBudget" },
	seedField = "artSeed",
	budgetField = "decorationBudget",
	budgetSource = "budgets.visual.seededDressing",
	maxSeededDressing = VisualBudgetRules.MAX_SEEDED_DRESSING,
}

function VillageCompositionRules.getManifest()
	return MANIFEST
end

function VillageCompositionRules.validate(value: any): boolean
	if type(value) ~= "table" then
		return false
	end

	if value.plotSlots then
		local visualBudget = value.budgets and value.budgets.visual
		return visualBudget ~= nil
			and value.artSeed == 2052
			and type(value.terrainBands) == "table"
			and #value.terrainBands == MANIFEST.terrain.bandCount
			and VisualBudgetRules.isWithinBudget(visualBudget)
	end

	if type(value.neighbourhoods) ~= "table" or #value.neighbourhoods ~= #MANIFEST.neighbourhoods then
		return false
	end
	for index, expected in MANIFEST.neighbourhoods do
		local actual = value.neighbourhoods[index]
		if type(actual) ~= "table" or type(actual.features) ~= "table" or actual.name ~= expected.name then
			return false
		end
		for feature, required in expected.features do
			if actual.features[feature] ~= required then
				return false
			end
		end
	end
	if type(value.civic) ~= "table" then
		return false
	end
	for feature, required in MANIFEST.civic do
		if value.civic[feature] ~= required then
			return false
		end
	end
	if type(value.dressing) ~= "table" or type(value.returnFields) ~= "table" then
		return false
	end
	if type(value.terrain) ~= "table" then
		return false
	end
	return value.dressing.canCollide == false
		and value.dressing.canTouch == false
		and value.dressing.canQuery == false
		and value.returnFields[1] == "roads"
		and value.returnFields[2] == "civic"
		and value.returnFields[3] == "neighbourhoods"
		and value.terrain.bandCount == MANIFEST.terrain.bandCount
		and value.terrain.minimumHeight == MANIFEST.terrain.minimumHeight
		and value.terrain.maximumHeight == MANIFEST.terrain.maximumHeight
		and value.returnFields[4] == "terrain"
		and value.returnFields[5] == "decorationBudget"
		and value.seedField == MANIFEST.seedField
		and value.budgetField == MANIFEST.budgetField
		and value.budgetSource == MANIFEST.budgetSource
		and value.maxSeededDressing == MANIFEST.maxSeededDressing
end

return VillageCompositionRules
