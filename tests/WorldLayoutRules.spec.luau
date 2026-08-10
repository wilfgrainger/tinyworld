local TestUtil = require("./TestUtil")
local WorldLayoutRules = require("../src/shared/WorldLayoutRules")

local EXPECTED_NEIGHBOURHOODS = {
	"MeadowLane",
	"HarbourRow",
	"WoodlandRise",
	"OrchardEnd",
}

local function assertSlotEqual(actual, expected, message: string)
	TestUtil.equal(actual.x, expected.x, message .. " x")
	TestUtil.equal(actual.z, expected.z, message .. " z")
	TestUtil.equal(actual.neighbourhood, expected.neighbourhood, message .. " neighbourhood")
	TestUtil.equal(actual.rotation, expected.rotation, message .. " rotation")
	TestUtil.equal(actual.setback, expected.setback, message .. " setback")
end

return function()
	TestUtil.equal(WorldLayoutRules.MAX_PLOTS, 16)
	TestUtil.equal(WorldLayoutRules.MAX_SERVER_PLAYERS, 16)
	TestUtil.isTrue(WorldLayoutRules.canAdmitPlayer(0))
	TestUtil.isTrue(WorldLayoutRules.canAdmitPlayer(15))
	TestUtil.isFalse(WorldLayoutRules.canAdmitPlayer(16))
	TestUtil.isFalse(WorldLayoutRules.canAdmitPlayer(99))
	TestUtil.isFalse(WorldLayoutRules.canAdmitPlayer(-1))
	TestUtil.equal(#WorldLayoutRules.NEIGHBOURHOODS, 4)
	for index, expected in EXPECTED_NEIGHBOURHOODS do
		TestUtil.equal(WorldLayoutRules.NEIGHBOURHOODS[index], expected)
	end

	local minimumLayout = WorldLayoutRules.create(nil)
	local fullLayout = WorldLayoutRules.create(60)
	local repeatedLayout = WorldLayoutRules.create(60)
	TestUtil.equal(#minimumLayout.plotSlots, 4)
	TestUtil.equal(#fullLayout.plotSlots, 16)
	TestUtil.equal(fullLayout.artSeed, 2052)
	TestUtil.equal(#fullLayout.neighbourhoods, 4)

	local represented = {}
	for index, slot in fullLayout.plotSlots do
		represented[slot.neighbourhood] = true
		TestUtil.equal(type(slot.rotation), "number", string.format("slot %d rotation", index))
		TestUtil.equal(type(slot.setback), "number", string.format("slot %d setback", index))
		assertSlotEqual(slot, repeatedLayout.plotSlots[index], string.format("deterministic slot %d", index))
		for previousIndex = 1, index - 1 do
			TestUtil.isFalse(
				WorldLayoutRules.boundsOverlap(fullLayout.plotSlots[previousIndex], slot, fullLayout.plotSize, 4),
				string.format("slots %d and %d overlap", previousIndex, index)
			)
		end
	end

	for index, expected in EXPECTED_NEIGHBOURHOODS do
		TestUtil.equal(fullLayout.neighbourhoods[index], expected)
		TestUtil.isTrue(represented[expected], expected .. " is not represented")
		TestUtil.equal(minimumLayout.plotSlots[index].neighbourhood, expected)
	end
end
