local TestUtil = require("./TestUtil")
local TraversalSafetyRules = require("../src/shared/TraversalSafetyRules")

local function decide(distance: number, y: number?, portalWorld: string?, hasValidPortalSession: boolean?)
	return TraversalSafetyRules.decide({
		distance = distance,
		y = y or 0,
		shorelineDistance = 210,
		waterBelt = 180,
		portalWorld = portalWorld or "Village",
		hasValidPortalSession = hasValidPortalSession == true,
	})
end

return function()
	local Action = TraversalSafetyRules.Action

	TestUtil.equal(decide(389), Action.Allow)
	TestUtil.equal(decide(390), Action.Allow)
	TestUtil.equal(decide(391), Action.RecoverShore)
	TestUtil.equal(decide(510), Action.RecoverShore)
	TestUtil.equal(decide(511), Action.RecoverShore)
	TestUtil.equal(decide(570), Action.RecoverShore)
	TestUtil.equal(decide(571), Action.RecoverShore)
	TestUtil.equal(decide(10000), Action.RecoverShore)

	TestUtil.equal(decide(100, -20), Action.Allow)
	TestUtil.equal(decide(100, -20.1), Action.RecoverWorld)

	TestUtil.equal(decide(10000, 0, "GiantKitchen", true), Action.PortalExempt)
	TestUtil.equal(decide(10000, -100, "GiantKitchen", true), Action.PortalExempt)
	TestUtil.equal(decide(10000, 0, "GiantKitchen", false), Action.RecoverShore)
	TestUtil.equal(decide(10000, -100, "GiantKitchen", false), Action.RecoverWorld)
	TestUtil.equal(decide(10000, 0, "Village", true), Action.RecoverShore)
	TestUtil.equal(decide(10000, 0, "", true), Action.RecoverShore)
end
