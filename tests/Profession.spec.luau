local TestUtil = require("./TestUtil")
local ProfileSchema = require("../src/shared/ProfileSchema")
local Profession = require("../src/shared/Profession")

return function()
	local profile = ProfileSchema.new()
	TestUtil.equal(Profession.xpForNextCourierLevel(1), 200)
	TestUtil.equal(Profession.addCourierXp(profile, 100), 0)
	TestUtil.equal(profile.courierLevel, 1)
	TestUtil.equal(profile.courierXp, 100)

	TestUtil.equal(Profession.addCourierXp(profile, 350), 1)
	TestUtil.equal(profile.courierLevel, 2)
	TestUtil.equal(profile.courierXp, 250)
	TestUtil.equal(Profession.addCourierXp(profile, -10), 0)
end
