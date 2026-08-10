local Inventory
if script ~= nil then
	Inventory = require(script.Parent:WaitForChild("Inventory"))
else
	Inventory = require("./Inventory")
end

local HomeExpressionRules = {}

export type Theme = { id: string, name: string }
export type Decoration = {
	id: string,
	name: string,
	action: string,
	costCoins: number,
	resource: string?,
	requiresPortal: boolean,
	colour: string,
}

local THEMES: { Theme } = {
	{ id = "Meadow", name = "Meadow" },
	{ id = "Harbor", name = "Harbor" },
	{ id = "Sunset", name = "Sunset" },
}

local DECORATIONS: { Decoration } = {
	{
		id = "LanternNook",
		name = "Lantern Nook",
		action = "Collect Lantern Nook",
		costCoins = 80,
		resource = nil,
		requiresPortal = false,
		colour = "gold",
	},
	{
		id = "StoryBookStack",
		name = "Story Book Stack",
		action = "Collect Story Books",
		costCoins = 120,
		resource = nil,
		requiresPortal = false,
		colour = "paper",
	},
	{
		id = "MeadowSeedShelf",
		name = "Meadow Seed Shelf",
		action = "Craft Seed Shelf",
		costCoins = 0,
		resource = "MeadowSeed",
		requiresPortal = false,
		colour = "flower",
	},
	{
		id = "SeashellDisplay",
		name = "Seashell Display",
		action = "Craft Seashell Display",
		costCoins = 0,
		resource = "Seashell",
		requiresPortal = false,
		colour = "sky",
	},
	{
		id = "WoodlandBench",
		name = "Woodland Bench",
		action = "Craft Woodland Bench",
		costCoins = 0,
		resource = "WoodToken",
		requiresPortal = false,
		colour = "timber",
	},
	{
		id = "PortalPainting",
		name = "Portal Painting",
		action = "Collect Portal Painting",
		costCoins = 250,
		resource = nil,
		requiresPortal = true,
		colour = "portal",
	},
}

local THEMES_BY_ID = {}
for _, theme in THEMES do
	THEMES_BY_ID[theme.id] = theme
end

local DECOR_BY_ID = {}
for _, item in DECORATIONS do
	DECOR_BY_ID[item.id] = item
end

local function decorItems(profile): { [string]: number }
	if type(profile.homeDecor) ~= "table" then
		profile.homeDecor = {}
	end
	return profile.homeDecor
end

function HomeExpressionRules.allThemes(): { Theme }
	local result = {}
	for _, theme in THEMES do
		table.insert(result, theme)
	end
	return result
end

function HomeExpressionRules.allDecorations(): { Decoration }
	local result = {}
	for _, item in DECORATIONS do
		table.insert(result, item)
	end
	return result
end

function HomeExpressionRules.getDecoration(itemId: string): Decoration?
	return DECOR_BY_ID[itemId]
end

function HomeExpressionRules.hasDecoration(profile, itemId: string): boolean
	local value = decorItems(profile)[itemId]
	return type(value) == "number" and value > 0
end

function HomeExpressionRules.decorCount(profile): number
	local count = 0
	for _, item in DECORATIONS do
		if HomeExpressionRules.hasDecoration(profile, item.id) then
			count += 1
		end
	end
	return count
end

function HomeExpressionRules.nextDecoration(profile): string?
	for _, item in DECORATIONS do
		if not HomeExpressionRules.hasDecoration(profile, item.id) then
			return item.id
		end
	end
	return nil
end

function HomeExpressionRules.acquire(profile, itemId: string): (boolean, string)
	local item = DECOR_BY_ID[itemId]
	if item == nil then
		return false, "unknown_item"
	end
	if HomeExpressionRules.hasDecoration(profile, itemId) then
		return false, "already_owned"
	end
	if item.requiresPortal and (profile.portalCompletions or 0) < 1 then
		return false, "world_gate"
	end
	if (profile.coins or 0) < item.costCoins then
		return false, "not_enough_coins"
	end
	if item.resource ~= nil and not Inventory.remove(profile, item.resource, 1) then
		return false, "missing_resource"
	end
	profile.coins -= item.costCoins
	decorItems(profile)[itemId] = 1
	return true, "acquired"
end

function HomeExpressionRules.setTheme(profile, themeId: string): boolean
	if THEMES_BY_ID[themeId] == nil then
		return false
	end
	profile.homeTheme = themeId
	return true
end

function HomeExpressionRules.cycleTheme(current: string): string
	for index, theme in THEMES do
		if theme.id == current then
			return THEMES[(index % #THEMES) + 1].id
		end
	end
	return THEMES[1].id
end

function HomeExpressionRules.showcase(profile): number
	profile.homeShowcaseCount = math.max(0, (profile.homeShowcaseCount or 0) + 1)
	return profile.homeShowcaseCount
end

return HomeExpressionRules
