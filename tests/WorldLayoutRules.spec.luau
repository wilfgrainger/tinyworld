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

	for _, maxPlayers in { 0, 1, 4, 8, 16, 32, 50 } do
		local layout = WorldLayoutRules.create(maxPlayers)
		local expectedPlots = math.max(4, math.floor(maxPlayers))
		TestUtil.equal(#layout.plotSlots, expectedPlots)
		TestUtil.isTrue(layout.perimeterHalfExtent > layout.coreHalfExtent)

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
end
