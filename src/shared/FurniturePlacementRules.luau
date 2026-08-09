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

local function finite(value: any): boolean
	return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

local function placedCount(profile: any, furnitureId: string): number
	local count = 0
	local placements = if type(profile.furniturePlacements) == "table" then profile.furniturePlacements else {}
	for _, placement in placements do
		if type(placement) == "table" and placement.furnitureId == furnitureId then
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

function FurniturePlacementRules.validate(profile: any, furnitureId: string, request: any): (boolean, string, any?)
	local definition = FurnitureDefinitions.get(furnitureId)
	if definition == nil or definition.placeable ~= true then
		return false, "unknown_furniture", nil
	end
	if type(request) ~= "table"
		or not finite(request.x)
		or not finite(request.y)
		or not finite(request.z)
		or not finite(request.rotation)
	then
		return false, "invalid_transform", nil
	end
	if request.x < FurniturePlacementRules.MIN_X
		or request.x > FurniturePlacementRules.MAX_X
		or request.y < FurniturePlacementRules.MIN_Y
		or request.y > FurniturePlacementRules.MAX_Y
		or request.z < FurniturePlacementRules.MIN_Z
		or request.z > FurniturePlacementRules.MAX_Z
	then
		return false, "out_of_bounds", nil
	end

	local owned = if type(profile.ownedFurniture) == "table" and type(profile.ownedFurniture[furnitureId]) == "number"
		then math.max(0, math.floor(profile.ownedFurniture[furnitureId]))
		else 0
	if owned <= placedCount(profile, furnitureId) then
		return false, "not_owned", nil
	end
	if totalPlacements(profile) >= FurniturePlacementRules.MAX_PLACEMENTS then
		return false, "placement_budget", nil
	end

	return true, "ok", {
		furnitureId = furnitureId,
		x = request.x,
		y = request.y,
		z = request.z,
		rotation = snapRotation(request.rotation),
	}
end

function FurniturePlacementRules.validateExisting(profile: any, placementId: string, request: any): (boolean, string, any?)
	local placements = if type(profile.furniturePlacements) == "table" then profile.furniturePlacements else {}
	local existing = placements[placementId]
	if type(existing) ~= "table" or type(existing.furnitureId) ~= "string" then
		return false, "unknown_placement", nil
	end
	if type(request) ~= "table"
		or not finite(request.x)
		or not finite(request.y)
		or not finite(request.z)
		or not finite(request.rotation)
	then
		return false, "invalid_transform", nil
	end
	if request.x < FurniturePlacementRules.MIN_X
		or request.x > FurniturePlacementRules.MAX_X
		or request.y < FurniturePlacementRules.MIN_Y
		or request.y > FurniturePlacementRules.MAX_Y
		or request.z < FurniturePlacementRules.MIN_Z
		or request.z > FurniturePlacementRules.MAX_Z
	then
		return false, "out_of_bounds", nil
	end
	return true, "ok", {
		furnitureId = existing.furnitureId,
		x = request.x,
		y = request.y,
		z = request.z,
		rotation = snapRotation(request.rotation),
	}
end

return FurniturePlacementRules
