local TestUtil = require("./TestUtil")
local ok, FurniturePlacementRules = pcall(require, "../src/shared/FurniturePlacementRules")

return function()
	TestUtil.isTrue(ok, "FurniturePlacementRules must exist")
	if not ok then
		return
	end

	local profile = {
		ownedFurniture = { CosyChair = 2, MeadowLamp = 1 },
		furniturePlacements = {},
	}
	local valid, reason, canonical = FurniturePlacementRules.validate(profile, "CosyChair", {
		x = 4.2,
		y = 0,
		z = -3.8,
		rotation = 91,
	})
	TestUtil.isTrue(valid)
	TestUtil.equal(reason, "ok")
	TestUtil.equal(canonical.rotation, 90)
	TestUtil.equal(canonical.x, 4.2)
	TestUtil.equal(canonical.z, -3.8)

	local outside, outsideReason = FurniturePlacementRules.validate(profile, "CosyChair", {
		x = 1000,
		y = 0,
		z = 0,
		rotation = 0,
	})
	TestUtil.isFalse(outside)
	TestUtil.equal(outsideReason, "out_of_bounds")

	local nan, nanReason = FurniturePlacementRules.validate(profile, "CosyChair", {
		x = 0 / 0,
		y = 0,
		z = 0,
		rotation = 0,
	})
	TestUtil.isFalse(nan)
	TestUtil.equal(nanReason, "invalid_transform")

	local unknown, unknownReason = FurniturePlacementRules.validate(profile, "DoesNotExist", {
		x = 0,
		y = 0,
		z = 0,
		rotation = 0,
	})
	TestUtil.isFalse(unknown)
	TestUtil.equal(unknownReason, "unknown_furniture")

	local noOwnership, noOwnershipReason = FurniturePlacementRules.validate(profile, "KitchenTable", {
		x = 0,
		y = 0,
		z = 0,
		rotation = 0,
	})
	TestUtil.isFalse(noOwnership)
	TestUtil.equal(noOwnershipReason, "not_owned")

	profile.furniturePlacements = {
		existing = { furnitureId = "MeadowLamp", x = 0, y = 0, z = 0, rotation = 0 },
	}
	local overlap, overlapReason = FurniturePlacementRules.validate(profile, "CosyChair", {
		x = 0,
		y = 0,
		z = 0,
		rotation = 0,
	})
	TestUtil.isFalse(overlap)
	TestUtil.equal(overlapReason, "overlap")

	profile.furniturePlacements = {}
	for index = 1, FurniturePlacementRules.MAX_PLACEMENTS do
		profile.furniturePlacements["p" .. tostring(index)] = { furnitureId = "CosyChair" }
	end
	local full, fullReason = FurniturePlacementRules.validate(profile, "CosyChair", {
		x = 0,
		y = 0,
		z = 0,
		rotation = 0,
	})
	TestUtil.isFalse(full)
	TestUtil.equal(fullReason, "placement_budget")
end
