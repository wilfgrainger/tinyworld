local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local Progression = require(shared:WaitForChild("Progression"))
local VisualPalette = require(shared:WaitForChild("VisualPalette"))

local colors = {
	ink = Color3.fromHex(VisualPalette.ink),
	inkSoft = Color3.fromHex(VisualPalette.inkSoft),
	paper = Color3.fromHex(VisualPalette.paper),
	warmLight = Color3.fromHex(VisualPalette.warmLight),
	gold = Color3.fromHex(VisualPalette.gold),
	white = Color3.fromHex(VisualPalette.white),
	metal = Color3.fromHex(VisualPalette.metal),
}

local playerGui = player:WaitForChild("PlayerGui")
local old = playerGui:FindFirstChild("TinyWorldHUD")
if old then
	old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "TinyWorldHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.new(0.92, 0, 0, 440)
panel.Position = UDim2.fromOffset(12, 12)
panel.BackgroundColor3 = colors.ink
panel.BackgroundTransparency = 0.08
panel.BorderSizePixel = 0
panel.Parent = gui

local panelConstraint = Instance.new("UISizeConstraint")
panelConstraint.MinSize = Vector2.new(280, 300)
panelConstraint.MaxSize = Vector2.new(360, 480)
panelConstraint.Parent = panel

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = panel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = colors.metal
panelStroke.Transparency = 0.72
panelStroke.Thickness = 1
panelStroke.Parent = panel

local panelGradient = Instance.new("UIGradient")
panelGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, colors.ink),
	ColorSequenceKeypoint.new(1, colors.inkSoft),
})
panelGradient.Rotation = 90
panelGradient.Parent = panel

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 10)
padding.PaddingBottom = UDim.new(0, 10)
padding.PaddingLeft = UDim.new(0, 12)
padding.PaddingRight = UDim.new(0, 12)
padding.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 3)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = panel

local function makeLabel(name: string, height: number, size: number, bold: boolean): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Size = UDim2.new(1, 0, 0, height)
	label.BackgroundTransparency = 1
	label.TextColor3 = colors.paper
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.TextWrapped = true
	label.TextSize = size
	label.Font = if bold then Enum.Font.GothamBold else Enum.Font.Gotham
	label.Parent = panel
	return label
end

local eyebrow = makeLabel("Eyebrow", 16, 11, true)
eyebrow.Text = "TODAY / INVITED ALPHA • STORYBOOK"
eyebrow.TextColor3 = colors.gold
local title = makeLabel("Title", 30, 22, true)
title.TextColor3 = colors.warmLight
title.Text = "TINYWORLD | v0.1.0 ALPHA"
local sectionLabel = makeLabel("SectionLabel", 16, 10, true)
sectionLabel.Text = "YOUR TINY LIFE"
sectionLabel.TextColor3 = colors.metal
local displayName = makeLabel("DisplayName", 22, 15, false)
local stats = makeLabel("Stats", 25, 16, true)
stats.TextColor3 = colors.gold
local home = makeLabel("Home", 25, 15, false)
local inventory = makeLabel("Inventory", 25, 15, false)
local lifeKit = makeLabel("LifeKit", 25, 15, false)
local profession = makeLabel("Profession", 25, 15, false)
local transport = makeLabel("Transport", 25, 15, false)
local portal = makeLabel("Portal", 25, 15, false)
local exploration = makeLabel("Exploration", 25, 15, false)
local route = makeLabel("Route", 25, 15, true)
route.TextColor3 = colors.warmLight
local social = makeLabel("Social", 25, 15, true)
social.TextColor3 = colors.warmLight
local goal = makeLabel("Goal", 48, 14, true)
goal.BackgroundColor3 = colors.inkSoft
goal.BackgroundTransparency = 0.12
local goalCorner = Instance.new("UICorner")
goalCorner.CornerRadius = UDim.new(0, 8)
goalCorner.Parent = goal
local goalPadding = Instance.new("UIPadding")
goalPadding.PaddingLeft = UDim.new(0, 8)
goalPadding.PaddingRight = UDim.new(0, 8)
goalPadding.PaddingTop = UDim.new(0, 2)
goalPadding.PaddingBottom = UDim.new(0, 2)
goalPadding.Parent = goal
local goalStroke = Instance.new("UIStroke")
goalStroke.Color = colors.gold
goalStroke.Transparency = 0.65
goalStroke.Parent = goal
goal.TextColor3 = colors.warmLight

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 7)
statsCorner.Parent = stats
local statsPadding = Instance.new("UIPadding")
statsPadding.PaddingLeft = UDim.new(0, 6)
statsPadding.PaddingRight = UDim.new(0, 6)
statsPadding.Parent = stats
stats.BackgroundColor3 = colors.inkSoft
stats.BackgroundTransparency = 0.22

local message = Instance.new("TextLabel")
message.Name = "StatusMessage"
message.AnchorPoint = Vector2.new(0.5, 1)
message.Position = UDim2.new(0.5, 0, 1, -24)
message.Size = UDim2.new(0.64, 0, 0, 56)
message.BackgroundColor3 = colors.inkSoft
message.BackgroundTransparency = 0.03
message.BorderSizePixel = 0
message.TextColor3 = colors.white
message.TextWrapped = true
message.TextSize = 18
message.Font = Enum.Font.GothamBold
message.Text = "Welcome to TinyWorld."
message.Parent = gui
local messagePadding = Instance.new("UIPadding")
messagePadding.PaddingLeft = UDim.new(0, 18)
messagePadding.PaddingRight = UDim.new(0, 12)
messagePadding.Parent = message
local messageAccent = Instance.new("Frame")
messageAccent.Name = "Accent"
messageAccent.Size = UDim2.new(0, 4, 0, 28)
messageAccent.Position = UDim2.fromOffset(10, 14)
messageAccent.BackgroundColor3 = colors.gold
messageAccent.BorderSizePixel = 0
messageAccent.Parent = message
local messageCorner = Instance.new("UICorner")
messageCorner.CornerRadius = UDim.new(0, 12)
messageCorner.Parent = message
local messageStroke = Instance.new("UIStroke")
messageStroke.Color = colors.gold
messageStroke.Transparency = 0.5
messageStroke.Thickness = 1.5
messageStroke.Parent = message
local function attr(name: string, fallback)
	local value = player:GetAttribute(name)
	if value == nil then
		return fallback
	end
	return value
end

local function boundaryVisitCount(mask: number): number
	local count = 0
	for _, bit in { 1, 2, 4 } do
		if (mask % (bit * 2)) >= bit then
			count += 1
		end
	end
	return count
end

local function update()
	local coins = attr("TinyWorldCoins", 0)
	local level = attr("TinyWorldLevel", 1)
	local xp = attr("TinyWorldXP", 0)
	local threshold = Progression.xpForNextLevel(level)
	displayName.Text = string.format("Name: %s   |   Style: %s   |   Outfit: %s", attr("TinyWorldDisplayName", "New TinyWorlder"), attr("TinyWorldAvatarStyle", "-"), attr("TinyWorldStarterOutfit", "-"))
	stats.Text = string.format("Coins: %d  |  Level %d  |  XP %d/%d", coins, level, xp, threshold)
	home.Text = string.format("Home: %s T%d  |  %s  |  Items %d/4", attr("TinyWorldHouseName", "Starter Nook"), attr("TinyWorldHouseTier", 1), attr("TinyWorldHomePrivacy", "Open"), attr("TinyWorldHomeOwnedCount", 1))
	inventory.Text = string.format("Bag: %d Carrot(s)  |  %d Sugar Crystal(s)", attr("TinyWorldCarrots", 0), attr("TinyWorldSugarCrystals", 0))
	local charm = if attr("TinyWorldHomeCharm", false) then "  |  Home charm" else ""
	lifeKit.Text = string.format("Life kit: %d seed  |  %d shell  |  %d wood", attr("TinyWorldMeadowSeeds", 0), attr("TinyWorldSeashells", 0), attr("TinyWorldWoodTokens", 0)) .. charm
	profession.Text = string.format("Profession: Courier Lv.%d  |  XP %d", attr("TinyWorldCourierLevel", 1), attr("TinyWorldCourierXP", 0))
	local bikeState = attr("TinyWorldBikeState", if attr("TinyWorldBikeActive", false) then "mounted" else "parked")
	local bikeText = if bikeState == "mounted" then "Tiny Bike MOUNTED" elseif bikeState == "parked" and attr("TinyWorldOwnsBike", false) then "Tiny Bike PARKED" else "Tiny Bike not owned"
	transport.Text = "Transport: " .. bikeText
	portal.Text = string.format("Portal: %d completion(s)  |  Run crystals %d/3", attr("TinyWorldPortalCompletions", 0), attr("TinyWorldPortalCrystals", 0))
	exploration.Text = string.format("Explore: %d/3 boundary landmarks  |  Routes %d", boundaryVisitCount(attr("TinyWorldBoundaryMask", 0)), attr("TinyWorldBoundaryCompletions", 0))
	route.Text = string.format("Return loop: today %d/%d  |  week %d/%d", attr("TinyWorldDailyRouteCount", 0), attr("TinyWorldDailyRouteTotal", 3), attr("TinyWorldWeeklyRouteCount", 0), attr("TinyWorldWeeklyRouteTotal", 3))
	local partyText = if attr("TinyWorldPartyMember", false) then string.format("Village Walk %d/4", attr("TinyWorldPartySize", 0)) else "Village Walk: join Meetup"
	local visit = attr("TinyWorldVisitingHome", "")
	local visitText = if visit == "" then "" else "  |  Visiting " .. visit
	social.Text = string.format("Social: %s  |  Shared %d%s", partyText, attr("TinyWorldSharedActivityCount", 0), visitText)
	local carry = if attr("TinyWorldCarryingParcel", false) then "  |  PARCEL ACTIVE" else ""
	goal.Text = "TODAY: " .. attr("TinyWorldSuggestedGoal", "Explore the village.") .. carry
	message.Text = attr("TinyWorldLastMessage", "Welcome to TinyWorld.")
end

local observed = {
	"TinyWorldCoins",
	"TinyWorldLevel",
	"TinyWorldXP",
	"TinyWorldHouseName",
	"TinyWorldHouseTier",
	"TinyWorldHomePrivacy",
	"TinyWorldCarrots",
	"TinyWorldSugarCrystals",
	"TinyWorldMeadowSeeds",
	"TinyWorldSeashells",
	"TinyWorldWoodTokens",
	"TinyWorldLifeKitCount",
	"TinyWorldHomeCharm",
	"TinyWorldCourierLevel",
	"TinyWorldCourierXP",
	"TinyWorldOwnsBike",
	"TinyWorldBikeActive",
	"TinyWorldBikeState",
	"TinyWorldPortalCompletions",
	"TinyWorldBoundaryMask",
	"TinyWorldBoundaryCompletions",
	"TinyWorldPortalCrystals",
	"TinyWorldSuggestedGoal",
	"TinyWorldCarryingParcel",
	"TinyWorldDailyRouteCount",
	"TinyWorldDailyRouteTotal",
	"TinyWorldDailyRouteComplete",
	"TinyWorldWeeklyRouteCount",
	"TinyWorldWeeklyRouteTotal",
	"TinyWorldWeeklyRouteComplete",
	"TinyWorldPartyMember",
	"TinyWorldPartySize",
	"TinyWorldPartyLeader",
	"TinyWorldSharedActivityCount",
	"TinyWorldVisitingHome",
	"TinyWorldHomeOwnedCount",
	"TinyWorldHomeUseCount",
	"TinyWorldHomeLastAction",
	"TinyWorldMessageNonce",
	"TinyWorldDisplayName",
	"TinyWorldAvatarStyle",
	"TinyWorldStarterOutfit",
	"TinyWorldOnboardingComplete",
	"TinyWorldOnboardingRequired",
}

for _, name in observed do
	player:GetAttributeChangedSignal(name):Connect(update)
end

update()
