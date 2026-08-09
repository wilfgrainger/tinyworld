local TestUtil = require("./TestUtil")
local ProfileSchema = require("../src/shared/ProfileSchema")

return function()
	local fresh = ProfileSchema.new()
	TestUtil.equal(fresh.version, 9)
	TestUtil.equal(fresh.coins, 100)
	TestUtil.equal(fresh.level, 1)
	TestUtil.equal(fresh.xp, 0)
	TestUtil.equal(fresh.houseTier, 1)
	TestUtil.equal(fresh.inventory.Carrot, 0)
	TestUtil.equal(fresh.inventory.SugarCrystal, 0)
	TestUtil.equal(fresh.inventory.MeadowSeed, 0)
	TestUtil.equal(fresh.inventory.Seashell, 0)
	TestUtil.equal(fresh.inventory.WoodToken, 0)
	TestUtil.equal(fresh.courierLevel, 1)
	TestUtil.equal(fresh.courierXp, 0)
	TestUtil.equal(fresh.farmerLevel, 1)
	TestUtil.equal(fresh.farmerXp, 0)
	TestUtil.equal(fresh.designerLevel, 1)
	TestUtil.equal(fresh.designerXp, 0)
	TestUtil.isFalse(fresh.ownsTinyBike)
	TestUtil.isFalse(fresh.bikeActive)
	TestUtil.equal(fresh.livingCollectionDay, "")
	TestUtil.equal(fresh.livingCollectionMask, 0)
	TestUtil.isFalse(fresh.homeCharmApplied)
	TestUtil.equal(fresh.homeItems.Bed, 1)
	TestUtil.equal(fresh.homeItems.KitchenCounter, 0)
	TestUtil.equal(fresh.homeTheme, "Meadow")
	TestUtil.equal(fresh.homeDecor.LanternNook, 0)
	TestUtil.equal(fresh.homeShowcaseCount, 0)
	TestUtil.equal(fresh.homeUseCount, 0)
	TestUtil.equal(fresh.dailyRouteDay, "")
	TestUtil.equal(fresh.dailyRouteMask, 0)
	TestUtil.equal(fresh.dailyRouteClaimedDay, "")
	TestUtil.equal(fresh.weeklyRouteWeek, "")
	TestUtil.equal(fresh.weeklyRouteMask, 0)
	TestUtil.equal(fresh.weeklyRouteClaimedWeek, "")
	TestUtil.equal(#fresh.gardenBeds, 3)
	TestUtil.equal(fresh.gardenBeds[1].stage, "empty")
	TestUtil.equal(fresh.lastDailyDay, "")
	TestUtil.equal(fresh.portalCompletions, 0)
	TestUtil.equal(fresh.villageContribution, 0)
	TestUtil.equal(fresh.boundaryExplorationDay, "")
	TestUtil.equal(fresh.boundaryExplorationMask, 0)
	TestUtil.equal(fresh.boundaryCompletions, 0)
	TestUtil.equal(fresh.homePrivacy, "Open")
	TestUtil.equal(fresh.displayName, "")
	TestUtil.equal(fresh.avatarStyle, "")
	TestUtil.equal(fresh.starterOutfit, "")
	TestUtil.isFalse(fresh.onboardingComplete)

	local migrated = ProfileSchema.normalize({
		version = 1,
		coins = 777,
		level = 4,
		xp = 42,
		houseTier = 3,
	})
	TestUtil.equal(migrated.version, 9)
	TestUtil.equal(migrated.coins, 777)
	TestUtil.equal(migrated.level, 4)
	TestUtil.equal(migrated.xp, 42)
	TestUtil.equal(migrated.houseTier, 3)
	TestUtil.equal(migrated.inventory.Carrot, 0)
	TestUtil.equal(migrated.inventory.MeadowSeed, 0)
	TestUtil.equal(migrated.inventory.Seashell, 0)
	TestUtil.equal(migrated.inventory.WoodToken, 0)
	TestUtil.equal(migrated.livingCollectionDay, "")
	TestUtil.equal(migrated.livingCollectionMask, 0)
	TestUtil.isFalse(migrated.homeCharmApplied)
	TestUtil.equal(migrated.courierLevel, 1)
	TestUtil.equal(migrated.farmerLevel, 1)
	TestUtil.equal(migrated.farmerXp, 0)
	TestUtil.equal(migrated.designerLevel, 1)
	TestUtil.equal(migrated.designerXp, 0)
	TestUtil.equal(migrated.displayName, "")
	TestUtil.equal(migrated.avatarStyle, "")
	TestUtil.equal(migrated.starterOutfit, "")
	TestUtil.isFalse(migrated.onboardingComplete)

	local completed = ProfileSchema.normalize({
		version = 2,
		coins = 901,
		inventory = { Carrot = 7, SugarCrystal = 3, MeadowSeed = 2, Seashell = 1, WoodToken = 4 },
		gardenBeds = {
			{ stage = "watered", readyAt = 1234 },
		},
		displayName = "Mia",
		avatarStyle = "Girl",
		starterOutfit = "Sunset",
		onboardingComplete = true,
	})
	TestUtil.equal(completed.version, 9)
	TestUtil.equal(completed.coins, 901)
	TestUtil.equal(completed.inventory.Carrot, 7)
	TestUtil.equal(completed.inventory.SugarCrystal, 3)
	TestUtil.equal(completed.inventory.MeadowSeed, 2)
	TestUtil.equal(completed.inventory.Seashell, 1)
	TestUtil.equal(completed.inventory.WoodToken, 4)
	TestUtil.equal(completed.gardenBeds[1].stage, "watered")
	TestUtil.equal(completed.displayName, "Mia")
	TestUtil.equal(completed.avatarStyle, "Girl")
	TestUtil.equal(completed.starterOutfit, "Sunset")
	TestUtil.isTrue(completed.onboardingComplete)

	local living = ProfileSchema.normalize({
		version = 4,
		inventory = { MeadowSeed = 3, Seashell = 2, WoodToken = 1 },
		livingCollectionDay = "2026-08-08",
		livingCollectionMask = 7,
		homeCharmApplied = true,
	})
	TestUtil.equal(living.version, 9)
	TestUtil.equal(living.inventory.MeadowSeed, 3)
	TestUtil.equal(living.inventory.Seashell, 2)
	TestUtil.equal(living.inventory.WoodToken, 1)
	TestUtil.equal(living.livingCollectionDay, "2026-08-08")
	TestUtil.equal(living.livingCollectionMask, 7)
	TestUtil.isTrue(living.homeCharmApplied)

	local exploration = ProfileSchema.normalize({
		version = 3,
		boundaryExplorationDay = "2026-08-08",
		boundaryExplorationClaimedDay = "2026-08-07",
		boundaryExplorationMask = 7,
		boundaryCompletions = 4,
	})
	TestUtil.equal(exploration.version, 9)
	TestUtil.equal(exploration.boundaryExplorationDay, "2026-08-08")
	TestUtil.equal(exploration.boundaryExplorationClaimedDay, "2026-08-07")
	TestUtil.equal(exploration.boundaryExplorationMask, 7)
	TestUtil.equal(exploration.boundaryCompletions, 4)

	local repaired = ProfileSchema.normalize({
		coins = -50,
		level = 0,
		xp = -10,
		houseTier = 99,
		inventory = { Carrot = -4, SugarCrystal = 2.9 },
		courierLevel = 0,
		courierXp = -1,
		farmerLevel = 0,
		farmerXp = -1,
		designerLevel = 0,
		designerXp = -1,
		gardenBeds = {
			{ stage = "broken", readyAt = -1 },
		},
		homePrivacy = "Anyone",
	})

	TestUtil.equal(repaired.coins, 0)
	TestUtil.equal(repaired.level, 1)
	TestUtil.equal(repaired.xp, 0)
	TestUtil.equal(repaired.houseTier, 5)
	TestUtil.equal(repaired.inventory.Carrot, 0)
	TestUtil.equal(repaired.inventory.SugarCrystal, 2)
	TestUtil.equal(repaired.courierLevel, 1)
	TestUtil.equal(repaired.courierXp, 0)
	TestUtil.equal(repaired.farmerLevel, 1)
	TestUtil.equal(repaired.farmerXp, 0)
	TestUtil.equal(repaired.designerLevel, 1)
	TestUtil.equal(repaired.designerXp, 0)
	TestUtil.equal(repaired.gardenBeds[1].stage, "empty")
	TestUtil.equal(repaired.gardenBeds[1].readyAt, 0)
	TestUtil.equal(repaired.homePrivacy, "Open")
	TestUtil.equal(repaired.displayName, "")
	TestUtil.equal(repaired.avatarStyle, "")
	TestUtil.equal(repaired.starterOutfit, "")
	TestUtil.isFalse(repaired.onboardingComplete)
	TestUtil.equal(repaired.boundaryExplorationDay, "")
	TestUtil.equal(repaired.boundaryExplorationClaimedDay, "")
	TestUtil.equal(repaired.boundaryExplorationMask, 0)
	TestUtil.equal(repaired.boundaryCompletions, 0)
end
