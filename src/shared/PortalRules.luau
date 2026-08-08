local Inventory
local Progression

if script ~= nil then
	Inventory = require(script.Parent.Inventory)
	Progression = require(script.Parent.Progression)
else
	Inventory = require("./Inventory")
	Progression = require("./Progression")
end

local PortalRules = {}

function PortalRules.completeGiantKitchen(profile: any)
	profile.coins += 300
	Progression.addXp(profile, 200)
	Inventory.add(profile, "SugarCrystal", 1)
	profile.portalCompletions += 1
end

return PortalRules
