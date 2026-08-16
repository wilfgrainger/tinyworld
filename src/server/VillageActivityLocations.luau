local VillageActivityLocations = {}

local function faceVillage(position: Vector3): CFrame
	local target = Vector3.new(0, position.Y, 0)
	return CFrame.lookAt(position, target)
end

local function perimeterHalf(world): number
	return world.layout.perimeterHalfExtent
end

function VillageActivityLocations.npc(world, role: string): CFrame
	local half = perimeterHalf(world)
	local positions = {
		Trader = Vector3.new(34, 0, -34),
		Gardener = Vector3.new(-32, 0, 30),
		Fisherman = Vector3.new(half - 52, 0, 14),
		BoatKeeper = Vector3.new(half - 52, 0, -14),
		Builder = Vector3.new(54, 0, 10),
	}
	return faceVillage(positions[role] or Vector3.new(0, 0, 34))
end

function VillageActivityLocations.station(world, role: string): CFrame
	local npc = VillageActivityLocations.npc(world, role)
	return npc * CFrame.new(0, 0, 5.5)
end

function VillageActivityLocations.publicGarden(world): CFrame
	local npc = VillageActivityLocations.npc(world, "Gardener")
	return npc * CFrame.new(0, 0, 10)
end

function VillageActivityLocations.repairFrame(world): CFrame
	local npc = VillageActivityLocations.npc(world, "Builder")
	return npc * CFrame.new(0, 1.8, 9)
end

function VillageActivityLocations.fishingDock(world): CFrame
	local half = perimeterHalf(world)
	return CFrame.lookAt(Vector3.new(half - 9, 1, 18), Vector3.new(half + 12, 1, 18))
end

function VillageActivityLocations.fishingBobber(world): CFrame
	local half = perimeterHalf(world)
	return CFrame.new(half + 5, 0.8, 18)
end

function VillageActivityLocations.coastalDeliveryBuoy(world): CFrame
	local half = perimeterHalf(world)
	return CFrame.new(half + 65, 3.5, -20)
end

return VillageActivityLocations
