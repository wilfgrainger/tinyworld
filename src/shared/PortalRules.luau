local Inventory
local Progression
local WorldDefinitions

if script ~= nil then
	Inventory = require(script.Parent.Inventory)
	Progression = require(script.Parent.Progression)
	WorldDefinitions = require(script.Parent.WorldDefinitions)
else
	Inventory = require("./Inventory")
	Progression = require("./Progression")
	WorldDefinitions = require("./WorldDefinitions")
end

local PortalRules = {}

PortalRules.WORLDS = {}
for _, source in WorldDefinitions.all() do
	local world = {}
	for key, value in source do
		world[key] = value
	end
	world.completionMessage = string.format(
		"%s complete: +%d coins, +%d XP, +1 %s and a %s keepsake!",
		world.displayName,
		world.coins,
		world.xp,
		world.collectibleName,
		world.keepsakeId
	)
	PortalRules.WORLDS[world.id] = world
end

function PortalRules.getWorld(worldId: string)
	return PortalRules.WORLDS[worldId]
end

function PortalRules.completeWorld(profile: any, worldId: string): boolean
	local world = PortalRules.getWorld(worldId)
	if world == nil then
		return false
	end
	if not Inventory.canAdd(profile, world.inventoryItem, 1) then
		return false
	end
	profile.coins += world.coins
	Progression.addXp(profile, world.xp)
	Inventory.add(profile, world.inventoryItem, 1)
	profile.portalCompletions += 1
	if type(profile.discoveredWorlds) ~= "table" then
		profile.discoveredWorlds = {}
	end
	profile.discoveredWorlds[worldId] = true
	if type(profile.keepsakes) ~= "table" then
		profile.keepsakes = {}
	end
	profile.keepsakes[world.keepsakeId] = (profile.keepsakes[world.keepsakeId] or 0) + 1
	return true
end

function PortalRules.completeGiantKitchen(profile: any)
	return PortalRules.completeWorld(profile, "GiantKitchen")
end

return PortalRules
