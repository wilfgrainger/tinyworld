local TestUtil = require("./TestUtil")
local ok, PortalSessionRules = pcall(require, "../src/shared/PortalSessionRules")

return function()
	TestUtil.isTrue(ok, "PortalSessionRules must exist")
	if not ok then
		return
	end

	local session = PortalSessionRules.new("GiantKitchen")
	TestUtil.equal(PortalSessionRules.collectedCount(session), 0)
	TestUtil.equal(PortalSessionRules.mechanicCount(session), 0)
	TestUtil.isFalse(PortalSessionRules.canFinish(session, 3, 3))

	TestUtil.isTrue(PortalSessionRules.markCollectible(session, 1))
	TestUtil.isFalse(PortalSessionRules.markCollectible(session, 1))
	TestUtil.isTrue(PortalSessionRules.markMechanic(session, 1))
	TestUtil.isFalse(PortalSessionRules.markMechanic(session, 1))

	PortalSessionRules.markCollectible(session, 2)
	PortalSessionRules.markCollectible(session, 3)
	PortalSessionRules.markMechanic(session, 2)
	PortalSessionRules.markMechanic(session, 3)
	TestUtil.isTrue(PortalSessionRules.canFinish(session, 3, 3))

	TestUtil.isFalse(session.secretFound)
	TestUtil.isTrue(PortalSessionRules.findSecret(session))
	TestUtil.isFalse(PortalSessionRules.findSecret(session))
	TestUtil.isTrue(session.secretFound)
end
