local TraversalSafetyRules = {}

TraversalSafetyRules.RECOVERY_Y = -20
TraversalSafetyRules.Action = {
	Allow = "allow",
	RecoverShore = "recover_shore",
	RecoverWorld = "recover_world",
	PortalExempt = "portal_exempt",
}

function TraversalSafetyRules.decide(input)
	if input.y < TraversalSafetyRules.RECOVERY_Y then
		return TraversalSafetyRules.Action.RecoverWorld
	end

	local portalWorld = input.portalWorld
	if
		type(portalWorld) == "string"
		and portalWorld ~= ""
		and portalWorld ~= "Village"
		and input.hasValidPortalSession == true
	then
		return TraversalSafetyRules.Action.PortalExempt
	end

	if input.distance > input.shorelineDistance + input.waterBelt then
		return TraversalSafetyRules.Action.RecoverShore
	end

	return TraversalSafetyRules.Action.Allow
end

return TraversalSafetyRules
