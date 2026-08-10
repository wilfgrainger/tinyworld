local TestUtil = require("./TestUtil")

local furnitureOk, FurnitureDefinitions = pcall(require, "../src/shared/FurnitureDefinitions")
local activityOk, ActivityDefinitions = pcall(require, "../src/shared/ActivityDefinitions")
local worldOk, WorldDefinitions = pcall(require, "../src/shared/WorldDefinitions")
local itemOk, ItemDefinitions = pcall(require, "../src/shared/ItemDefinitions")
local appearanceOk, AppearanceDefinitions = pcall(require, "../src/shared/AppearanceDefinitions")

local function countEntries(values): number
	local count = 0
	for _ in values do
		count += 1
	end
	return count
end

return function()
	TestUtil.isTrue(furnitureOk, "FurnitureDefinitions must exist")
	TestUtil.isTrue(activityOk, "ActivityDefinitions must exist")
	TestUtil.isTrue(worldOk, "WorldDefinitions must exist")
	TestUtil.isTrue(itemOk, "ItemDefinitions must exist")
	TestUtil.isTrue(appearanceOk, "AppearanceDefinitions must exist")
	if not (furnitureOk and activityOk and worldOk and itemOk and appearanceOk) then
		return
	end

	local furniture = FurnitureDefinitions.all()
	TestUtil.isTrue(#furniture >= 80, "v1 target requires at least 80 furniture/home items")

	local categories = {}
	local meaningful = 0
	for _, item in furniture do
		categories[item.category] = true
		if item.interaction ~= nil and item.interaction ~= "display" then
			meaningful += 1
		end
		TestUtil.equal(type(item.id), "string")
		TestUtil.equal(type(item.prefabRole), "string")
		TestUtil.isTrue(item.price >= 0)
	end
	for _, required in { "bedroom", "kitchen", "bathroom", "living", "storage", "garden", "decoration", "lighting" } do
		TestUtil.isTrue(categories[required] == true, "missing furniture category: " .. required)
	end
	TestUtil.isTrue(meaningful >= 20, "v1 target requires at least 20 meaningful home interactions")

	local activityIds = { "Courier", "Gardener", "Designer", "VillageExplorer" }
	TestUtil.equal(#ActivityDefinitions.all(), #activityIds, "v0.6.2 exposes exactly four canonical village activities")
	for _, activityId in activityIds do
		TestUtil.isTrue(ActivityDefinitions.get(activityId) ~= nil, "missing canonical village activity: " .. activityId)
	end
	TestUtil.equal(ActivityDefinitions.get("HarborHelper"), nil, "obsolete HarborHelper activity must not survive v0.6.2")
	TestUtil.equal(ActivityDefinitions.get("Gardener").professionId, "Farmer", "Gardener must preserve Farmer persistence")

	TestUtil.equal(#WorldDefinitions.all(), 4)
	TestUtil.equal(WorldDefinitions.get("GiantKitchen").displayName, "Giant Kitchen")
	TestUtil.equal(WorldDefinitions.get("MoonlitMeadow").displayName, "Moonlit Meadow")
	TestUtil.isTrue(countEntries(ItemDefinitions.keepsakes()) >= 30, "v1 target requires at least 30 keepsakes")
	TestUtil.isTrue(#AppearanceDefinitions.outfits() >= 6, "character expression needs meaningful free starter variety")
	TestUtil.isTrue(#AppearanceDefinitions.hairStyles() >= 6, "character expression needs multiple hair choices")
end
