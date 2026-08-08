local TestUtil = require("./TestUtil")
local WorldLayoutRules = require("../src/shared/WorldLayoutRules")

return function()
	local firstFour = {
		{ x = -75, z = -75 },
		{ x = 75, z = -75 },
		{ x = -75, z = 75 },
		{ x = 75, z = 75 },
	}

	for index, expected in firstFour do
		local layout = WorldLayoutRules.create(4)
		TestUtil.equal(layout.plotSlots[index].x, expected.x)
		TestUtil.equal(layout.plotSlots[index].z, expected.z)
	end

	for _, maxPlayers in { 0, 1, 4, 8, 16, 32, 50, 60 } do
		local layout = WorldLayoutRules.create(maxPlayers)
		local expectedPlots = math.max(4, math.floor(maxPlayers))
		TestUtil.equal(#layout.plotSlots, expectedPlots)
		TestUtil.isTrue(layout.perimeterHalfExtent > layout.coreHalfExtent)
		TestUtil.equal(layout.budgets.plots, expectedPlots)
		TestUtil.equal(layout.budgets.cabins, 3)
		TestUtil.equal(layout.budgets.livingPickups, 3)
		TestUtil.isTrue(layout.budgets.planters >= 6)
		TestUtil.isTrue(layout.livingWorld.cabinLaneZ > layout.coreHalfExtent)
		TestUtil.isTrue(layout.livingWorld.pickupAnchors.MeadowSeed.x < 0)
		TestUtil.isTrue(layout.livingWorld.pickupAnchors.Seashell.x > 0)
		TestUtil.isTrue(layout.livingWorld.pickupAnchors.WoodToken.x < 0)
		TestUtil.isTrue(layout.roads.mainHalfLength >= layout.coreHalfExtent)
		TestUtil.isTrue(layout.roads.laneWidth >= 10)
		TestUtil.equal(layout.civic.fountain.x, 0)
		TestUtil.equal(layout.civic.fountain.z, 0)
		TestUtil.isTrue(layout.budgets.boundaryTrees <= 240)
		TestUtil.isTrue(layout.budgets.roadParts <= 24)
		TestUtil.isTrue(layout.budgets.totalDecorations <= 2200)

		for index, slot in layout.plotSlots do
			local halfExtent = math.max(math.abs(slot.x), math.abs(slot.z)) + (layout.plotSize / 2)
			TestUtil.isTrue(halfExtent < layout.perimeterHalfExtent)
			for otherIndex = index + 1, #layout.plotSlots do
				TestUtil.isFalse(WorldLayoutRules.boundsOverlap(slot, layout.plotSlots[otherIndex], layout.plotSize, 4))
			end
		end

		for _, landmark in layout.landmarks do
			local landmarkExtent = math.max(math.abs(landmark.x), math.abs(landmark.z)) + 5
			TestUtil.isTrue(landmarkExtent < layout.perimeterHalfExtent)
		end
	end

	local fallback = WorldLayoutRules.create(nil)
	TestUtil.equal(#fallback.plotSlots, 4)
	TestUtil.equal(WorldLayoutRules.safeCount(nil, 4, 10), 4)
	TestUtil.equal(WorldLayoutRules.safeCount(math.huge, 4, 10), 10)
	TestUtil.equal(WorldLayoutRules.safeCount(3.9, 4, 10), 4)
	TestUtil.equal(WorldLayoutRules.safeCount(99, 4, 10), 10)
end
