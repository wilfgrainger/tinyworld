local PortalSessionRules = {}

function PortalSessionRules.new(worldId: string)
	return {
		active = true,
		worldId = worldId,
		collected = {},
		mechanics = {},
		secretFound = false,
	}
end

function PortalSessionRules.isValid(session: any, portalWorld: any): boolean
	return type(session) == "table"
		and session.active == true
		and type(session.worldId) == "string"
		and session.worldId ~= ""
		and session.worldId ~= "Village"
		and portalWorld == session.worldId
end

function PortalSessionRules.resetState()
	return {
		worldId = "Village",
		crystals = 0,
		mechanics = 0,
		secretFound = false,
	}
end

local function markedCount(values: any): number
	local count = 0
	if type(values) ~= "table" then
		return count
	end
	for _, marked in values do
		if marked == true then
			count += 1
		end
	end
	return count
end

function PortalSessionRules.collectedCount(session: any): number
	return markedCount(session.collected)
end

function PortalSessionRules.mechanicCount(session: any): number
	return markedCount(session.mechanics)
end

function PortalSessionRules.markCollectible(session: any, index: number): boolean
	if type(session.collected) ~= "table" or session.collected[index] == true then
		return false
	end
	session.collected[index] = true
	return true
end

function PortalSessionRules.markMechanic(session: any, index: number): boolean
	if type(session.mechanics) ~= "table" or session.mechanics[index] == true then
		return false
	end
	session.mechanics[index] = true
	return true
end

function PortalSessionRules.findSecret(session: any): boolean
	if session.secretFound == true then
		return false
	end
	session.secretFound = true
	return true
end

function PortalSessionRules.canFinish(session: any, collectibleTarget: number, mechanicTarget: number): boolean
	return PortalSessionRules.collectedCount(session) >= collectibleTarget
		and PortalSessionRules.mechanicCount(session) >= mechanicTarget
end

return PortalSessionRules
