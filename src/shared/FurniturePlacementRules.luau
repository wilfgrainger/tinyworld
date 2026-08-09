local FurnitureDefinitions
if script ~= nil then
	FurnitureDefinitions = require(script.Parent:WaitForChild("FurnitureDefinitions"))
else
	FurnitureDefinitions = require("./FurnitureDefinitions")
end

local FurniturePlacementRules = {}

FurniturePlacementRules.MAX_PLACEMENTS = 60
FurniturePlacementRules.MIN_X = -18
FurniturePlacementRules.MAX_X = 18
FurniturePlacementRules.MIN_Y = -2
FurniturePlacementRules.MAX_Y = 8
FurniturePlacementRules.MIN_Z = -14
FurniturePlacementRules.MAX_Z = 14
FurniturePlacementRules.CLEARANCE = 0.35

local function finite(value: any): boolean
	return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

local function placedCount(profile: any, furnitureId: string, ignorePlacementId: string?): number
	local count = 0
	local placements = if type(profile.furniturePlacements) == "table" then profile.furniturePlacements else {}
	for placementId, placement in placements do
		if placementId ~= ignorePlacementId and type(placement) == "table" and placement.furnitureId == furnitureId then
			count += 1
		end
	end
	return count
end

local function totalPlacements(profile: any): number
	local count = 0
	local placements = if type(profile.furniturePlacements) == "table" then profile.furniturePlacements else {}
	for _ in placements do
		count += 1
	end
	return count
end

local function snapRotation(value: number): number
	local snapped = math.floor((value + 45) / 90) * 90
	snapped %= 360
	if snapped < 0 then
		snapped += 360
	end
	return snapped
end

local function footprint(definition: any, rotation: number): (number, number)
	local x = definition.footprintX or 4
	local z = definition.footprintZ or 4
	if rotation == 90 or rotation == 270 then
		return z, x
	end
	return x, z
end

local function overlaps(profile: any, definition: any, x: number, z: number, rotation: number, ignorePlacementId: string?): boolean
	local width, depth = footprint(definition, rotation)
	local placements = if type(profile.furniturePlacements) == "table" then profile.furniturePlacements else {}
	for placementId, existing in placements do
		if placementId ~= ignorePlacementId
			and type(existing) == "table"
			and type(existing.furnitureId) == "string"
			and finite(existing.x)
			and finite(existing.z)
		then
			local existingDefinition = FurnitureDefinitions.get(existing.furnitureId)
			if existingDefinition then
				local existingRotation = if finite(existing.rotation) then snapRotation(existing.rotation) else 0
				local existingWidth, existingDepth = footprint(existingDefinition, existingRotation)
				local separatedX = math.abs(x - existing.x) >= ((width + existingWidth) / 2 + FurniturePlacementRules.CLEARANCE)
				local separatedZ = math.abs(z - existing.z) >= ((depth + existingDepth) / 2 + FurniturePlacementRules.CLEARANCE)
				if not separatedX and not separatedZ then
					return true
				end
			end
		end
	end
	return false
end

local function canonicalTransform(request: any)
	return {
		x = request.x,
		y = request.y,
		z = request.z,
		rotation = snapRotation(request.rotation),
	}
end

local function validTransform(request: any): boolean
	return type(request) == "table"
		and finite(request.x)
		and finite(request.y)
		and finite(request.z)
		and finite(request.rotation)
end

local function insideBounds(request: any): boolean
	return request.x >= FurniturePlacementRules.MIN_X
		and request.x <= FurniturePlacementRules.MAX_X
		and request.y >= FurniturePlacementRules.MIN_Y
		and request.y <= FurniturePlacementRules.MAX_Y
		and request.z >= FurniturePlacementRules.MIN_Z
		and request.z <= FurniturePlacementRules.MAX_Z
end

function FurniturePlacementRules.validate(profile: any, furnitureId: string, request: any): (boolean, string, any?)
	local definition = FurnitureDefinitions.get(furnitureId)
	if definition == nil or definition.placeable ~= true then
		return false, "unknown_furniture", nil
	end
	if not validTransform(request) then
		return false, "invalid_transform", nil
	end
	if not insideBounds(request) then
		return false, "out_of_bounds", nil
	end

	local owned = if type(profile.ownedFurniture) == "table" and type(profile.ownedFurniture[furnitureId]) == "number"
		then math.max(0, math.floor(profile.ownedFurniture[furnitureId]))
		else 0
	if owned <= placedCount(profile, furnitureId, nil) then
		return false, "not_owned", nil
	end
	if totalPlacements(profile) >= FurniturePlacementRules.MAX_PLACEMENTS then
		return false, "placement_budget", nil
	end
	local canonical = canonicalTransform(request)
	if overlaps(profile, definition, canonical.x, canonical.z, canonical.rotation, nil) then
		return false, "overlap", nil
	end
	canonical.furnitureId = furnitureId
	return true, "ok", canonical
end

function FurniturePlacementRules.validateExisting(profile: any, placementId: string, request: any): (boolean, string, any?)
	local placements = if type(profile.furniturePlacements) == "table" then profile.furniturePlacements else {}
	local existing = placements[placementId]
	if type(existing) ~= "table" or type(existing.furnitureId) ~= "string" then
		return false, "unknown_placement", nil
	end
	local definition = FurnitureDefinitions.get(existing.furnitureId)
	if definition == nil then
		return false, "unknown_furniture", nil
	end
	if not validTransform(request) then
		return false, "invalid_transform", nil
	end
	if not insideBounds(request) then
		return false, "out_of_bounds", nil
	end
	local canonical = canonicalTransform(request)
	if overlaps(profile, definition, canonical.x, canonical.z, canonical.rotation, placementId) then
		return false, "overlap", nil
	end
	canonical.furnitureId = existing.furnitureId
	canonical.instanceId = existing.instanceId
	return true, "ok", canonical
end

return FurniturePlacementRules
