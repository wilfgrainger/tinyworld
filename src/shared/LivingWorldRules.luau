local Inventory

if script ~= nil then
	Inventory = require(script.Parent.Inventory)
else
	Inventory = require("./Inventory")
end

local LivingWorldRules = {}

LivingWorldRules.ITEMS = { "MeadowSeed", "Seashell", "WoodToken" }

local ITEM_BITS = {
	MeadowSeed = 1,
	Seashell = 2,
	WoodToken = 4,
}

function LivingWorldRules.itemBit(itemName: string): number?
	return ITEM_BITS[itemName]
end

function LivingWorldRules.collectionCount(profile: any, dayKey: string): number
	if profile.livingCollectionDay ~= dayKey then
		return 0
	end

	local count = 0
	for _, itemName in LivingWorldRules.ITEMS do
		local bit = ITEM_BITS[itemName]
		local mask = profile.livingCollectionMask or 0
		if math.floor(mask / bit) % 2 == 1 then
			count += 1
		end
	end
	return count
end

function LivingWorldRules.collect(profile: any, itemName: string, dayKey: string): (boolean, string)
	local bit = ITEM_BITS[itemName]
	if bit == nil then
		return false, "unsupported_item"
	end

	if profile.livingCollectionDay ~= dayKey then
		profile.livingCollectionDay = dayKey
		profile.livingCollectionMask = 0
	end

	local mask = profile.livingCollectionMask or 0
	if math.floor(mask / bit) % 2 == 1 then
		return false, "already_collected"
	end

	if not Inventory.add(profile, itemName, 1) then
		return false, "inventory_rejected"
	end

	profile.livingCollectionMask = mask + bit
	return true, "collected"
end

function LivingWorldRules.canAddHomeCharm(profile: any): boolean
	return profile.homeCharmApplied ~= true
		and Inventory.get(profile, "MeadowSeed") >= 1
		and Inventory.get(profile, "Seashell") >= 1
		and Inventory.get(profile, "WoodToken") >= 1
end

function LivingWorldRules.addHomeCharm(profile: any): (boolean, string)
	if profile.homeCharmApplied == true then
		return false, "already_applied"
	end
	if not LivingWorldRules.canAddHomeCharm(profile) then
		return false, "missing_items"
	end

	Inventory.remove(profile, "MeadowSeed", 1)
	Inventory.remove(profile, "Seashell", 1)
	Inventory.remove(profile, "WoodToken", 1)
	profile.homeCharmApplied = true
	return true, "applied"
end

return LivingWorldRules
