local Inventory = {}

local SUPPORTED = {
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
	return SUPPORTED[itemName] == true
end

function Inventory.get(profile: any, itemName: string): number
	if not Inventory.isSupported(itemName) then
		return 0
	end
	local inventory = profile.inventory
	if type(inventory) ~= "table" then
		return 0
	end
	local value = inventory[itemName]
	if type(value) ~= "number" or value < 0 then
		return 0
	end
	return math.floor(value)
end

function Inventory.add(profile: any, itemName: string, amount: number): boolean
	if not Inventory.isSupported(itemName) or not validAmount(amount) then
		return false
	end
	profile.inventory[itemName] = Inventory.get(profile, itemName) + amount
	return true
end

function Inventory.remove(profile: any, itemName: string, amount: number): boolean
	if not Inventory.isSupported(itemName) or not validAmount(amount) then
		return false
	end
	local current = Inventory.get(profile, itemName)
	if current < amount then
		return false
	end
	profile.inventory[itemName] = current - amount
	return true
end

return Inventory

