local TestUtil = require("./TestUtil")
local ProfileSchema = require("../src/shared/ProfileSchema")
local PortalRules = require("../src/shared/PortalRules")

return function()
	local profile = ProfileSchema.new()
	PortalRules.completeGiantKitchen(profile)
	TestUtil.equal(profile.coins, 400)
	TestUtil.equal(profile.level, 2)
	TestUtil.equal(profile.xp, 100)
	TestUtil.equal(profile.inventory.SugarCrystal, 1)
	TestUtil.equal(profile.portalCompletions, 1)
end
