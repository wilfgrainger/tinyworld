local TestUtil = require("./TestUtil")
local ok, ProfileMigrations = pcall(require, "../src/shared/ProfileMigrations")

return function()
	TestUtil.isTrue(ok, "ProfileMigrations must exist for profile v11")
	if not ok then
		return
	end

	local legacy = {
		version = 10,
		inventory = { Carrot = 4, SugarCrystal = 2, MeadowSeed = 3, Seashell = 1, WoodToken = 5 },
		homeItems = { Bed = 1, KitchenCounter = 1, Wardrobe = 0, CreativeDesk = 1 },
		portalCompletions = 2,
	}
	local migrated, reason = ProfileMigrations.migrate(legacy)
	TestUtil.equal(reason, nil)
	TestUtil.equal(migrated.version, 11)
	TestUtil.equal(migrated.inventoryStacks.Carrot, 4)
	TestUtil.equal(migrated.inventoryStacks.SugarCrystal, 2)
	TestUtil.equal(migrated.inventoryStacks.MeadowSeed, 3)
	TestUtil.equal(migrated.inventoryStacks.Seashell, 1)
	TestUtil.equal(migrated.inventoryStacks.WoodToken, 5)
	TestUtil.equal(migrated.ownedFurniture.Bed, 1)
	TestUtil.equal(migrated.ownedFurniture.KitchenCounter, 1)
	TestUtil.equal(migrated.ownedFurniture.CreativeDesk, 1)
	TestUtil.equal(migrated.activeOutfitId, "Starter")
	TestUtil.equal(type(migrated.inventoryInstances), "table")
	TestUtil.equal(type(migrated.furniturePlacements), "table")
	TestUtil.equal(type(migrated.savedOutfits), "table")
	TestUtil.equal(type(migrated.discoveredWorlds), "table")
	TestUtil.equal(type(migrated.keepsakes), "table")

	local again, againReason = ProfileMigrations.migrate(migrated)
	TestUtil.equal(againReason, nil)
	TestUtil.equal(again.version, 11)
	TestUtil.equal(again.inventoryStacks.Carrot, 4)
	TestUtil.equal(again.ownedFurniture.CreativeDesk, 1)

	local future, futureReason = ProfileMigrations.migrate({ version = 99, coins = 100 })
	TestUtil.equal(future, nil)
	TestUtil.equal(futureReason, "future_version")
end
