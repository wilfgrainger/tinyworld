local HouseCatalog
if script ~= nil then
	HouseCatalog = require(script.Parent:WaitForChild("HouseCatalog"))
else
	HouseCatalog = require("./HouseCatalog")
end

local GoalRules = {}

function GoalRules.suggestedGoal(profile): string
	if not profile.onboardingComplete then
		return "Complete your TinyWorld setup."
	end
	if profile.inventory.Carrot < 1 then
		return "Claim the fountain reward or grow a Carrot."
	end
	if profile.courierXp == 0 and profile.courierLevel == 1 then
		return "Try a Courier delivery from the depot."
	end
	if not profile.ownsTinyBike then
		return "Save 300 coins and buy the Tiny Bike."
	end

	local nextHouse = HouseCatalog.get(profile.houseTier + 1)
	if nextHouse then
		if profile.level < nextHouse.requiredLevel then
			return string.format("Reach level %d and upgrade your home.", nextHouse.requiredLevel)
		end
		if profile.coins < nextHouse.price then
			return string.format("Save %d coins and upgrade your home.", nextHouse.price)
		end
		return "Upgrade your home to " .. nextHouse.name .. "."
	end

	if profile.portalCompletions < 1 then
		return "Enter the portal and explore the Giant Kitchen."
	end
	if profile.villageContribution < 50 then
		return "Contribute 50 coins to the Village Fund."
	end
	if profile.boundaryCompletions < 1 then
		return "Visit the woods, cliffs, and sea around the village."
	end
	if not profile.homeCharmApplied then
		return "Find the three village keepsakes and add a Home Charm."
	end
	return "Trade with a neighbour, explore the boundary, and grow your TinyWorld."
end

return GoalRules
