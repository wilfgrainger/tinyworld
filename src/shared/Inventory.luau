local ItemDefinitions
local PlayerMutationLock
if script ~= nil then
	ItemDefinitions = require(script.Parent:WaitForChild("ItemDefinitions"))
	PlayerMutationLock = require(script.Parent:WaitForChild("PlayerMutationLock"))
else
	ItemDefinitions = require("./ItemDefinitions")
	PlayerMutationLock = require("./PlayerMutationLock")
end

local Inventory = {}

-- The five vertical-slice resources remain compatibility fields during schema
-- v11 because existing services still mutate profile.inventory directly. New
-- code should use this module so both representations stay synchronized.
local LEGACY = {
	Carrot = true,
	SugarCrystal = true,
	MeadowSeed = true,
	Seashell = true,
	WoodToken = true,
}

local function validAmount(amount: any): boolean
	return type(amount) == "number" and amount == math.floor(amount) and amount > 0 and amount < math.huge
end

function Inventory.isSupported(itemName: string): boolean
	local definition = ItemDefinitions.get(itemName)
	return definition ~= nil and definition.stackable == true
end

function Inventory.get(profile: any, itemName: string): number
	if not Inventory.isSupported(itemName) then
		return 0
	end
	if LEGACY[itemName] and type(profile.inventory) == "table" then
		local legacy = profile.inventory[itemName]
		if type(legacy) == "number" and legacy >= 0 then
			return math.floor(legacy)
		end
	end
	if type(profile.inventoryStacks) == "table" then
		local stacked = profile.inventoryStacks[itemName]
		if type(stacked) == "number" and stacked >= 0 then
			return math.floor(stacked)
		end
	end
	return 0
end

local function set(profile: any, itemName: string, amount: number)
	if type(profile.inventoryStacks) ~= "table" then
		profile.inventoryStacks = {}
	end
	profile.inventoryStacks[itemName] = amount
	if LEGACY[itemName] then
		if type(profile.inventory) ~= "table" then
			profile.inventory = {}
		end
		profile.inventory[itemName] = amount
	end
end

function Inventory.canAdd(profile: any, itemName: string, amount: number): boolean
	if not Inventory.isSupported(itemName) or not validAmount(amount) then
		return false
	end
	local definition = ItemDefinitions.get(itemName)
	return definition ~= nil and Inventory.get(profile, itemName) + amount <= definition.maxStack
end

function Inventory.add(profile: any, itemName: string, amount: number, mutationOwner: string?): boolean
	if not PlayerMutationLock.canMutate(profile, mutationOwner) or not Inventory.canAdd(profile, itemName, amount) then
		return false
	end
	set(profile, itemName, Inventory.get(profile, itemName) + amount)
	return true
end

function Inventory.remove(profile: any, itemName: string, amount: number, mutationOwner: string?): boolean
	if
		not PlayerMutationLock.canMutate(profile, mutationOwner)
		or not Inventory.isSupported(itemName)
		or not validAmount(amount)
	then
		return false
	end
	local current = Inventory.get(profile, itemName)
	if current < amount then
		return false
	end
	set(profile, itemName, current - amount)
	return true
end

return Inventory
