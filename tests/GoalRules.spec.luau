local TestUtil = require("./TestUtil")
local ProfileSchema = require("../src/shared/ProfileSchema")
local GoalRules = require("../src/shared/GoalRules")

local function readyProfile()
	local profile = ProfileSchema.new()
	profile.onboardingComplete = true
	profile.inventory.Carrot = 1
	profile.courierXp = 100
	profile.courierLevel = 2
	profile.ownsTinyBike = true
	profile.houseTier = 1
	return profile
end

return function()
	local onboarding = ProfileSchema.new()
	TestUtil.equal(GoalRules.suggestedGoal(onboarding), "Complete your TinyWorld setup.")

	local carrot = ProfileSchema.new()
	carrot.onboardingComplete = true
	TestUtil.equal(GoalRules.suggestedGoal(carrot), "Claim the fountain reward or grow a Carrot.")

	local courier = readyProfile()
	courier.inventory.Carrot = 1
	courier.courierXp = 0
	courier.courierLevel = 1
	courier.ownsTinyBike = false
	TestUtil.equal(GoalRules.suggestedGoal(courier), "Try a Courier delivery from the depot.")

	local bike = readyProfile()
	bike.ownsTinyBike = false
	TestUtil.equal(GoalRules.suggestedGoal(bike), "Save 300 coins and buy the Tiny Bike.")

	local levelLocked = readyProfile()
	levelLocked.level = 1
	levelLocked.coins = 100
	TestUtil.equal(GoalRules.suggestedGoal(levelLocked), "Reach level 2 and upgrade your home.")

	local coinLocked = readyProfile()
	coinLocked.level = 2
	coinLocked.coins = 100
	TestUtil.equal(GoalRules.suggestedGoal(coinLocked), "Save 250 coins and upgrade your home.")

	local readyToUpgrade = readyProfile()
	readyToUpgrade.level = 4
	readyToUpgrade.coins = 900
	TestUtil.equal(GoalRules.suggestedGoal(readyToUpgrade), "Upgrade your home to Cosy Cottage.")

	local portal = readyProfile()
	portal.houseTier = 5
	portal.level = 4
	portal.coins = 900
	portal.portalCompletions = 0
	TestUtil.equal(GoalRules.suggestedGoal(portal), "Enter the portal and explore the Giant Kitchen.")

	local secondPortal = readyProfile()
	secondPortal.houseTier = 5
	secondPortal.portalCompletions = 1
	TestUtil.equal(GoalRules.suggestedGoal(secondPortal), "Open the second portal and explore the Moonlit Meadow.")

	local finished = readyProfile()
	finished.houseTier = 5
	finished.portalCompletions = 2
	finished.villageContribution = 50
	finished.boundaryCompletions = 1
	finished.homeCharmApplied = true
	TestUtil.equal(GoalRules.suggestedGoal(finished), "Trade with a neighbour, explore the boundary, and grow your TinyWorld.")

	local charm = readyProfile()
	charm.houseTier = 5
	charm.portalCompletions = 2
	charm.villageContribution = 50
	charm.boundaryCompletions = 1
	TestUtil.equal(GoalRules.suggestedGoal(charm), "Find the three village keepsakes and add a Home Charm.")

	local boundary = readyProfile()
	boundary.houseTier = 5
	boundary.portalCompletions = 2
	boundary.villageContribution = 50
	TestUtil.equal(GoalRules.suggestedGoal(boundary), "Visit the woods, cliffs, and sea around the village.")
end

