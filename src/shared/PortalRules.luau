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

PortalRules.WORLDS = {
	GiantKitchen = {
		id = "GiantKitchen",
		displayName = "Giant Kitchen",
		collectibleName = "Sugar Crystal",
		inventoryItem = "SugarCrystal",
		collectibleCount = 3,
		coins = 300,
		xp = 200,
		completionMessage = "Giant Kitchen complete: +300 coins, +200 XP, +1 permanent Sugar Crystal!",
	},
	MoonlitMeadow = {
		id = "MoonlitMeadow",
		displayName = "Moonlit Meadow",
		collectibleName = "Moonlit Seed",
		inventoryItem = "MeadowSeed",
		collectibleCount = 3,
		coins = 350,
		xp = 225,
		completionMessage = "Moonlit Meadow complete: +350 coins, +225 XP, +1 Meadow Seed!",
	},
}

function PortalRules.getWorld(worldId: string)
	return PortalRules.WORLDS[worldId]
end

function PortalRules.completeWorld(profile: any, worldId: string): boolean
	local world = PortalRules.getWorld(worldId)
	if world == nil then
		return false
	end
	profile.coins += world.coins
	Progression.addXp(profile, world.xp)
	Inventory.add(profile, world.inventoryItem, 1)
	profile.portalCompletions += 1
	return true
end

function PortalRules.completeGiantKitchen(profile: any)
	return PortalRules.completeWorld(profile, "GiantKitchen")
end

return PortalRules
