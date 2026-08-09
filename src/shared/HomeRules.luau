local HomeCatalog
if script ~= nil then
	HomeCatalog = require(script.Parent:WaitForChild("HomeCatalog"))
else
	HomeCatalog = require("./HomeCatalog")
end

local HomeRules = {}

local function itemCount(profile: any, itemId: string): number
	local items = if type(profile.homeItems) == "table" then profile.homeItems else {}
	return if type(items[itemId]) == "number" then items[itemId] else 0
end

function HomeRules.has(profile: any, itemId: string): boolean
	return itemCount(profile, itemId) > 0
end

function HomeRules.nextItem(profile: any): string?
	for _, item in HomeCatalog.all() do
		if not HomeRules.has(profile, item.id) then
			return item.id
		end
	end
	return nil
end

function HomeRules.isComplete(profile: any): boolean
	return HomeRules.nextItem(profile) == nil
end

function HomeRules.buy(profile: any, itemId: string): (boolean, string)
	local item = HomeCatalog.get(itemId)
	if item == nil then
		return false, "unknown_item"
	end
	if HomeRules.has(profile, itemId) then
		return false, "already_owned"
	end
	if profile.coins < item.price then
		return false, "not_enough_coins"
	end
	profile.coins -= item.price
	profile.homeItems[itemId] = 1
	return true, "bought"
end

function HomeRules.use(profile: any, itemId: string): (boolean, string)
	if HomeCatalog.get(itemId) == nil then
		return false, "unknown_item"
	end
	if not HomeRules.has(profile, itemId) then
		return false, "not_owned"
	end
	profile.homeUseCount += 1
	return true, "used"
end

return HomeRules
