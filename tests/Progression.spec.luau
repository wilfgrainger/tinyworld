local TestUtil = require("./TestUtil")
local ProfileSchema = require("../src/shared/ProfileSchema")
local Progression = require("../src/shared/Progression")

return function()
	TestUtil.equal(Progression.xpForNextLevel(1), 100)
	TestUtil.equal(Progression.xpForNextLevel(2), 150)

	local oneLevel = ProfileSchema.new()
	local gained = Progression.addXp(oneLevel, 100)
	TestUtil.equal(gained, 1)
	TestUtil.equal(oneLevel.level, 2)
	TestUtil.equal(oneLevel.xp, 0)

	local multi = ProfileSchema.new()
	local multiGained = Progression.addXp(multi, 400)
	TestUtil.equal(multiGained, 2)
	TestUtil.equal(multi.level, 3)
	TestUtil.equal(multi.xp, 150)

	local unchanged = ProfileSchema.new()
	TestUtil.equal(Progression.addXp(unchanged, -5), 0)
	TestUtil.equal(unchanged.level, 1)
	TestUtil.equal(unchanged.xp, 0)
end
