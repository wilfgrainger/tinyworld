local TestUtil = require("./TestUtil")
local WorldLayoutRules = require("../src/shared/WorldLayoutRules")
local VisualBudgetRules = require("../src/shared/VisualBudgetRules")
local VillageCompositionRules = require("../src/shared/VillageCompositionRules")

return function()
	local manifest = VillageCompositionRules.getManifest()
	TestUtil.isTrue(VillageCompositionRules.validate(manifest), "composition manifest validates")
	TestUtil.equal(#manifest.neighbourhoods, 4)
	TestUtil.equal(manifest.neighbourhoods[1].name, "MeadowLane")
	TestUtil.isTrue(manifest.neighbourhoods[1].features.stream, "Meadow Lane stream")
	TestUtil.isTrue(manifest.neighbourhoods[1].features.bridge, "Meadow Lane bridge")
	TestUtil.isTrue(manifest.neighbourhoods[1].features.grassBanks, "Meadow Lane grass banks")

	for _, neighbourhood in manifest.neighbourhoods do
		TestUtil.isTrue(neighbourhood.features.curvedPath, neighbourhood.name .. " curved path")
		TestUtil.isTrue(neighbourhood.features.dressing, neighbourhood.name .. " dressing")
	end
	TestUtil.equal(manifest.dressing.canCollide, false)
	TestUtil.equal(manifest.dressing.canTouch, false)
	TestUtil.equal(manifest.dressing.canQuery, false)
	TestUtil.equal(manifest.returnFields[1], "roads")
	TestUtil.equal(manifest.returnFields[2], "civic")
	TestUtil.equal(manifest.returnFields[3], "neighbourhoods")
	TestUtil.equal(manifest.returnFields[4], "terrain")
	TestUtil.equal(manifest.returnFields[5], "decorationBudget")

	for _, plotCount in { 4, 16 } do
		local layout = WorldLayoutRules.create(plotCount)
		TestUtil.isTrue(VillageCompositionRules.validate(layout), tostring(plotCount) .. " plot composition")
		TestUtil.equal(layout.artSeed, 2052)
		TestUtil.equal(layout[manifest.seedField], 2052)
		TestUtil.equal(#layout.terrainBands, 4)
		TestUtil.equal(manifest.budgetSource, "budgets.visual.seededDressing")
		TestUtil.equal(layout.budgets.visual.seededDressing, math.min(VisualBudgetRules.MAX_SEEDED_DRESSING, 160 + (plotCount * 12)))
		TestUtil.isTrue(VisualBudgetRules.isWithinBudget(layout.budgets.visual), tostring(plotCount) .. " plot budget")
	end
end
