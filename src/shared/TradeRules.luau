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
	local canTrade, reason = TradeRules.canExchange(profileA, itemA, profileB, itemB)
	if not canTrade then
		return false, reason
	end

	local removedA = Inventory.remove(profileA, itemA, 1)
	local removedB = Inventory.remove(profileB, itemB, 1)
	if not (removedA and removedB) then
		if removedA then
			Inventory.add(profileA, itemA, 1)
		end
		if removedB then
			Inventory.add(profileB, itemB, 1)
		end
		return false, "inventory_changed"
	end
	local addedA = Inventory.add(profileA, itemB, 1)
	local addedB = Inventory.add(profileB, itemA, 1)
	if not (addedA and addedB) then
		-- canExchange preflights these additions, so reaching this branch means
		-- state changed unexpectedly inside the operation. Restore what we can
		-- and report failure rather than silently dropping an item.
		if addedA then
			Inventory.remove(profileA, itemB, 1)
		end
		if addedB then
			Inventory.remove(profileB, itemA, 1)
		end
		Inventory.add(profileA, itemA, 1)
		Inventory.add(profileB, itemB, 1)
		return false, "inventory_changed"
	end
	return true, "traded"
end

function TradeRules.canExchange(profileA: any, itemA: string, profileB: any, itemB: string): (boolean, string)
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
	if itemA ~= itemB and not Inventory.canAdd(profileA, itemB, 1) then
		return false, "first_inventory_full"
	end
	if itemA ~= itemB and not Inventory.canAdd(profileB, itemA, 1) then
		return false, "second_inventory_full"
	end
	return true, "ready"
end

return TradeRules
