local VillageActivityLocations = {}

local function required(world, role: string)
	local registry = world.r8Destinations
	local entry = registry and registry[role]
	if entry == nil then
		error("R8 destination missing for role: " .. role)
	end
	return entry
end

function VillageActivityLocations.npc(world, role: string): CFrame
	local entry = required(world, role)
	if entry.npcAnchor == nil then
		error("R8 NPC anchor missing for role: " .. role)
	end
	return entry.npcAnchor.CFrame
end

function VillageActivityLocations.station(world, role: string): CFrame
	local entry = required(world, role)
	if entry.promptAnchor == nil then
		error("R8 prompt anchor missing for role: " .. role)
	end
	return entry.promptAnchor.CFrame
end

function VillageActivityLocations.publicGarden(world): CFrame
	local entry = required(world, "Gardener")
	return entry.activityOrigin.CFrame
end

function VillageActivityLocations.repairFrame(world): CFrame
	local entry = required(world, "Builder")
	return entry.activityOrigin.CFrame
end

function VillageActivityLocations.fishingDock(world): CFrame
	local entry = required(world, "Fisherman")
	return entry.promptAnchor.CFrame
end

function VillageActivityLocations.fishingBobber(world): CFrame
	local entry = required(world, "Fisherman")
	return entry.fishingOrigin.CFrame
end

function VillageActivityLocations.coastalDeliveryBuoy(world): CFrame
	local entry = required(world, "CoastalDelivery")
	return entry.promptAnchor.CFrame
end

return VillageActivityLocations
