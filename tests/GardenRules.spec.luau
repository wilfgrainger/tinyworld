local TestUtil = require("./TestUtil")
local ProfileSchema = require("../src/shared/ProfileSchema")
local GardenRules = require("../src/shared/GardenRules")

return function()
	local profile = ProfileSchema.new()
	local bed = profile.gardenBeds[1]

	local planted, plantReason = GardenRules.plant(bed, 100)
	TestUtil.isTrue(planted)
	TestUtil.equal(plantReason, "planted")
	TestUtil.equal(bed.stage, "planted")

	local watered, waterReason = GardenRules.water(bed, 100)
	TestUtil.isTrue(watered)
	TestUtil.equal(waterReason, "watered")
	TestUtil.equal(bed.stage, "watered")
	TestUtil.equal(bed.readyAt, 105)

	TestUtil.equal(GardenRules.refresh(bed, 104), "watered")
	TestUtil.equal(GardenRules.refresh(bed, 105), "ready")

	local harvested, harvestReason = GardenRules.harvest(profile, bed, 105)
	TestUtil.isTrue(harvested)
	TestUtil.equal(harvestReason, "harvested")
	TestUtil.equal(profile.inventory.Carrot, 1)
	TestUtil.equal(profile.xp, 10)
	TestUtil.equal(bed.stage, "empty")
	TestUtil.equal(bed.readyAt, 0)

	local harvestedAgain = GardenRules.harvest(profile, bed, 105)
	TestUtil.isFalse(harvestedAgain)

	local fullProfile = ProfileSchema.new()
	fullProfile.inventory.Carrot = 999
	fullProfile.inventoryStacks.Carrot = 999
	local fullBed = fullProfile.gardenBeds[1]
	fullBed.stage = "ready"
	fullBed.readyAt = 0
	local blocked, blockedReason = GardenRules.harvest(fullProfile, fullBed, 1000)
	TestUtil.isFalse(blocked)
	TestUtil.equal(blockedReason, "inventory_full")
	TestUtil.equal(fullProfile.inventory.Carrot, 999)
	TestUtil.equal(fullProfile.xp, 0)
	TestUtil.equal(fullBed.stage, "ready")
end
