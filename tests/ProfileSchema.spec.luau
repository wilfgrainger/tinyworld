local TestUtil = require("./TestUtil")
local ProfileSchema = require("../src/shared/ProfileSchema")

return function()
	local fresh = ProfileSchema.new()
	TestUtil.equal(fresh.version, 1)
	TestUtil.equal(fresh.coins, 100)
	TestUtil.equal(fresh.level, 1)
	TestUtil.equal(fresh.xp, 0)
	TestUtil.equal(fresh.houseTier, 1)

	local repaired = ProfileSchema.normalize({
		version = "old",
		coins = -50,
		level = 0,
		xp = -10,
		houseTier = 99,
	})

	TestUtil.equal(repaired.version, 1)
	TestUtil.equal(repaired.coins, 0)
	TestUtil.equal(repaired.level, 1)
	TestUtil.equal(repaired.xp, 0)
	TestUtil.equal(repaired.houseTier, 5)
end
