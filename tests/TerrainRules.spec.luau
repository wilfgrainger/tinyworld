local TestUtil = require("./TestUtil")
local TerrainRules = require("../src/shared/TerrainRules")

return function()
	local bands = TerrainRules.allBands()
	TestUtil.equal(#bands, 4)
	local minimum, maximum = TerrainRules.heightRange()
	TestUtil.equal(minimum, 4)
	TestUtil.equal(maximum, 8)
	TestUtil.isTrue(maximum > minimum, "terrain has actual elevation variation")
	TestUtil.equal(bands[1].id, "MeadowLaneBank")
	TestUtil.equal(bands[2].id, "HarbourSlope")
	TestUtil.equal(bands[3].id, "WoodlandRise")
	TestUtil.equal(bands[4].id, "OrchardTerrace")
	local repeated = TerrainRules.allBands()
	for index, band in bands do
		TestUtil.equal(repeated[index].id, band.id, "authored terrain is deterministic")
		TestUtil.equal(repeated[index].height, band.height, "authored terrain height is deterministic")
	end
end
