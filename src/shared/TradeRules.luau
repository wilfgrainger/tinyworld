local Inventory

if script ~= nil then
	Inventory = require(script.Parent.Inventory)
else
	Inventory = require("./Inventory")
end

local TradeRules = {}

local function supported(itemName: string): boolean
	return Inventory.isSupported(itemName)
end

function TradeRules.exchange(profileA: any, itemA: string, profileB: any, itemB: string): (boolean, string)
	if profileA == profileB then
		return false, "same_player"
	end
	if not supported(itemA) or not supported(itemB) then
		return false, "unsupported_item"
	end
	if Inventory.get(profileA, itemA) < 1 then
		return false, "first_missing_item"
	end
	if Inventory.get(profileB, itemB) < 1 then
		return false, "second_missing_item"
	end

	Inventory.remove(profileA, itemA, 1)
	Inventory.remove(profileB, itemB, 1)
	Inventory.add(profileA, itemB, 1)
	Inventory.add(profileB, itemA, 1)
	return true, "traded"
end

return TradeRules
