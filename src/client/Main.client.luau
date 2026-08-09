local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local Progression = require(shared:WaitForChild("Progression"))
local VisualPalette = require(shared:WaitForChild("VisualPalette"))
local VisualQualityRules = require(shared:WaitForChild("VisualQualityRules"))

local colors = {
	ink = Color3.fromHex(VisualPalette.ink),
	inkSoft = Color3.fromHex(VisualPalette.inkSoft),
	paper = Color3.fromHex(VisualPalette.paper),
	warmLight = Color3.fromHex(VisualPalette.warmLight),
	gold = Color3.fromHex(VisualPalette.gold),
	white = Color3.fromHex(VisualPalette.white),
	metal = Color3.fromHex(VisualPalette.metal),
	meadowDeep = Color3.fromHex(VisualPalette.meadowDeep),
	skyDeep = Color3.fromHex(VisualPalette.skyDeep),
}

local function attr(name: string, fallback)
	local value = player:GetAttribute(name)
	if value == nil then
		return fallback
	end
	return value
end

local function addCorner(parent: Instance, radius: number)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = parent
end

local function addStroke(parent: Instance, color: Color3, transparency: number, thickness: number?)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Transparency = transparency
	stroke.Thickness = thickness or 1
	stroke.Parent = parent
	return stroke
end

local function addPadding(parent: Instance, horizontal: number, vertical: number)
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, horizontal)
	padding.PaddingRight = UDim.new(0, horizontal)
	padding.PaddingTop = UDim.new(0, vertical)
	padding.PaddingBottom = UDim.new(0, vertical)
	padding.Parent = parent
end

local function makeLabel(parent: Instance, name: string, textSize: number, bold: boolean): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = name
	label.BackgroundTransparency = 1
	label.TextColor3 = colors.paper
	label.Font = if bold then Enum.Font.GothamBold else Enum.Font.Gotham
	label.TextSize = textSize
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Parent = parent
	return label
end

local playerGui = player:WaitForChild("PlayerGui")
local old = playerGui:FindFirstChild("TinyWorldHUD")
if old then
	old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "TinyWorldHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 10
gui.Parent = playerGui

local function makeChip(name: string, position: UDim2, size: UDim2): Frame
	local chip = Instance.new("Frame")
	chip.Name = name
	chip.Position = position
	chip.Size = size
	chip.BackgroundColor3 = colors.ink
	chip.BackgroundTransparency = 0.08
	chip.BorderSizePixel = 0
	chip.Parent = gui
	addCorner(chip, 12)
	addStroke(chip, colors.metal, 0.72)
	return chip
end

local coinChip = makeChip("CoinChip", UDim2.fromOffset(12, 12), UDim2.fromOffset(116, 44))
coinChip.Name = "CoinChip"
local coinIcon = makeLabel(coinChip, "Icon", 20, true)
coinIcon.Position = UDim2.fromOffset(12, 0)
coinIcon.Size = UDim2.fromOffset(24, 44)
coinIcon.Text = "●"
coinIcon.TextColor3 = colors.gold
coinIcon.TextXAlignment = Enum.TextXAlignment.Center
local coinValue = makeLabel(coinChip, "Value", 17, true)
coinValue.Position = UDim2.fromOffset(42, 0)
coinValue.Size = UDim2.new(1, -50, 1, 0)
coinValue.TextColor3 = colors.warmLight

local levelChip = makeChip("LevelChip", UDim2.new(0, 136, 0, 12), UDim2.new(1, -208, 0, 44))
levelChip.Name = "LevelChip"
local levelText = makeLabel(levelChip, "Level", 14, true)
levelText.Position = UDim2.fromOffset(12, 1)
levelText.Size = UDim2.new(1, -24, 0, 25)
local levelTrack = Instance.new("Frame")
levelTrack.Name = "ProgressTrack"
levelTrack.Position = UDim2.fromOffset(12, 29)
levelTrack.Size = UDim2.new(1, -24, 0, 6)
levelTrack.BackgroundColor3 = colors.inkSoft
levelTrack.BorderSizePixel = 0
levelTrack.Parent = levelChip
addCorner(levelTrack, 3)
local levelProgress = Instance.new("Frame")
levelProgress.Name = "Progress"
levelProgress.Size = UDim2.fromScale(0, 1)
levelProgress.BackgroundColor3 = colors.gold
levelProgress.BorderSizePixel = 0
levelProgress.Parent = levelTrack
addCorner(levelProgress, 3)

local questChip = makeChip("QuestChip", UDim2.fromOffset(12, 64), UDim2.new(0.72, 0, 0, 58))
questChip.Name = "QuestChip"
local questConstraint = Instance.new("UISizeConstraint")
questConstraint.MinSize = Vector2.new(250, 58)
questConstraint.MaxSize = Vector2.new(430, 58)
questConstraint.Parent = questChip
local questIcon = makeLabel(questChip, "Icon", 22, true)
questIcon.Position = UDim2.fromOffset(12, 0)
questIcon.Size = UDim2.fromOffset(30, 58)
questIcon.Text = "✦"
questIcon.TextColor3 = colors.gold
questIcon.TextXAlignment = Enum.TextXAlignment.Center
local questTitle = makeLabel(questChip, "Title", 14, true)
questTitle.Position = UDim2.fromOffset(50, 5)
questTitle.Size = UDim2.new(1, -60, 0, 25)
questTitle.TextColor3 = colors.warmLight
local questDetail = makeLabel(questChip, "Detail", 12, false)
questDetail.Position = UDim2.fromOffset(50, 27)
questDetail.Size = UDim2.new(1, -60, 0, 25)
questDetail.TextColor3 = colors.paper
questDetail.TextTransparency = 0.18

local journalButton = Instance.new("TextButton")
journalButton.Name = "JournalButton"
journalButton.AnchorPoint = Vector2.new(1, 0)
journalButton.Position = UDim2.new(1, -12, 0, 12)
journalButton.Size = UDim2.fromOffset(50, 50)
journalButton.BackgroundColor3 = colors.ink
journalButton.BackgroundTransparency = 0.08
journalButton.BorderSizePixel = 0
journalButton.Text = "☰"
journalButton.TextColor3 = colors.warmLight
journalButton.TextSize = 22
journalButton.Font = Enum.Font.GothamBold
journalButton.AutoButtonColor = true
journalButton.Parent = gui
addCorner(journalButton, 12)
addStroke(journalButton, colors.gold, 0.55)

local journalPanel = Instance.new("Frame")
journalPanel.Name = "JournalPanel"
journalPanel.AnchorPoint = Vector2.new(0.5, 0.5)
journalPanel.Position = UDim2.fromScale(0.5, 0.5)
journalPanel.Size = UDim2.new(0.88, 0, 0.78, 0)
journalPanel.BackgroundColor3 = colors.ink
journalPanel.BackgroundTransparency = 0.02
journalPanel.BorderSizePixel = 0
journalPanel.Visible = false
journalPanel.Parent = gui
addCorner(journalPanel, 18)
addStroke(journalPanel, colors.gold, 0.48, 1.5)
local journalConstraint = Instance.new("UISizeConstraint")
journalConstraint.MinSize = Vector2.new(300, 380)
journalConstraint.MaxSize = Vector2.new(720, 520)
journalConstraint.Parent = journalPanel

local journalHeading = makeLabel(journalPanel, "Heading", 22, true)
journalHeading.Position = UDim2.fromOffset(20, 10)
journalHeading.Size = UDim2.new(1, -80, 0, 38)
journalHeading.Text = "My TinyWorld Journal"
journalHeading.TextColor3 = colors.warmLight

local journalClose = Instance.new("TextButton")
journalClose.Name = "Close"
journalClose.AnchorPoint = Vector2.new(1, 0)
journalClose.Position = UDim2.new(1, -14, 0, 12)
journalClose.Size = UDim2.fromOffset(40, 40)
journalClose.BackgroundColor3 = colors.inkSoft
journalClose.BorderSizePixel = 0
journalClose.Text = "×"
journalClose.TextColor3 = colors.paper
journalClose.TextSize = 24
journalClose.Font = Enum.Font.GothamBold
journalClose.Parent = journalPanel
addCorner(journalClose, 10)

local tabRow = Instance.new("Frame")
tabRow.Name = "Tabs"
tabRow.Position = UDim2.fromOffset(18, 58)
tabRow.Size = UDim2.new(1, -36, 0, 42)
tabRow.BackgroundTransparency = 1
tabRow.Parent = journalPanel
local tabLayout = Instance.new("UIGridLayout")
tabLayout.CellPadding = UDim2.fromOffset(6, 0)
tabLayout.CellSize = UDim2.new(0.2, -5, 1, 0)
tabLayout.FillDirectionMaxCells = 5
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = tabRow

local content = Instance.new("Frame")
content.Name = "Content"
content.Position = UDim2.fromOffset(18, 110)
content.Size = UDim2.new(1, -36, 1, -128)
content.BackgroundColor3 = colors.inkSoft
content.BackgroundTransparency = 0.28
content.BorderSizePixel = 0
content.ClipsDescendants = true
content.Parent = journalPanel
addCorner(content, 12)
addPadding(content, 14, 12)

local function makeJournalTab(text: string, order: number): TextButton
	local button = Instance.new("TextButton")
	button.LayoutOrder = order
	button.BackgroundColor3 = colors.inkSoft
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = colors.paper
	button.TextSize = 11
	button.TextWrapped = true
	button.Font = Enum.Font.GothamBold
	button.AutoButtonColor = true
	button.Parent = tabRow
	addCorner(button, 9)
	return button
end

local todayTab = makeJournalTab("Today", 1)
todayTab.Name = "TodayTab"
local bagTab = makeJournalTab("Bag", 2)
bagTab.Name = "BagTab"
local homeTab = makeJournalTab("Home", 3)
homeTab.Name = "HomeTab"
local careersTab = makeJournalTab("Careers", 4)
careersTab.Name = "CareersTab"
local collectionTab = makeJournalTab("Collection", 5)
collectionTab.Name = "CollectionTab"

local function makeJournalSection(): Frame
	local section = Instance.new("Frame")
	section.Size = UDim2.fromScale(1, 1)
	section.BackgroundTransparency = 1
	section.Visible = false
	section.Parent = content
	return section
end

local function makeSectionLabel(parent: Instance, name: string, position: UDim2, size: UDim2, textSize: number, bold: boolean): TextLabel
	local label = makeLabel(parent, name, textSize, bold)
	label.Position = position
	label.Size = size
	label.TextYAlignment = Enum.TextYAlignment.Top
	return label
end

local todaySection = makeJournalSection()
todaySection.Name = "TodaySection"
local todayHeading = makeSectionLabel(todaySection, "Heading", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 34), 20, true)
todayHeading.Text = "Today’s adventure"
todayHeading.TextColor3 = colors.gold
local todayQuest = makeSectionLabel(todaySection, "Quest", UDim2.fromOffset(0, 44), UDim2.new(1, 0, 0, 64), 16, true)
local todayProgress = makeSectionLabel(todaySection, "Progress", UDim2.fromOffset(0, 116), UDim2.new(1, 0, 0, 82), 14, false)

local bagSection = makeJournalSection()
bagSection.Name = "BagSection"
local bagHeading = makeSectionLabel(bagSection, "Heading", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 34), 20, true)
bagHeading.Text = "What’s in my bag"
bagHeading.TextColor3 = colors.gold
local bagContents = makeSectionLabel(bagSection, "Inventory", UDim2.fromOffset(0, 44), UDim2.new(1, 0, 1, -48), 15, false)

local homeSection = makeJournalSection()
homeSection.Name = "HomeSection"
local homeHeading = makeSectionLabel(homeSection, "Heading", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 34), 20, true)
homeHeading.Text = "My home"
homeHeading.TextColor3 = colors.gold
local homeDetails = makeSectionLabel(homeSection, "Details", UDim2.fromOffset(0, 44), UDim2.new(1, 0, 1, -48), 15, false)

local careersSection = makeJournalSection()
careersSection.Name = "CareersSection"
local careersHeading = makeSectionLabel(careersSection, "Heading", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 34), 20, true)
careersHeading.Text = "Things I’m learning"
careersHeading.TextColor3 = colors.gold
local careersDetails = makeSectionLabel(careersSection, "Details", UDim2.fromOffset(0, 44), UDim2.new(1, 0, 1, -48), 15, false)

local collectionSection = makeJournalSection()
collectionSection.Name = "CollectionSection"
local collectionHeading = makeSectionLabel(collectionSection, "Heading", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 34), 20, true)
collectionHeading.Text = "Places and keepsakes"
collectionHeading.TextColor3 = colors.gold
local collectionDetails = makeSectionLabel(collectionSection, "Details", UDim2.fromOffset(0, 44), UDim2.new(1, 0, 1, -48), 15, false)

local tabEntries = {
	{ button = todayTab, section = todaySection },
	{ button = bagTab, section = bagSection },
	{ button = homeTab, section = homeSection },
	{ button = careersTab, section = careersSection },
	{ button = collectionTab, section = collectionSection },
}

local function selectJournalTab(selectedButton: TextButton)
	for _, entry in tabEntries do
		local selected = entry.button == selectedButton
		entry.section.Visible = selected
		entry.button.BackgroundColor3 = if selected then colors.gold else colors.inkSoft
		entry.button.TextColor3 = if selected then colors.ink else colors.paper
	end
end

for _, entry in tabEntries do
	entry.button.Activated:Connect(function()
		selectJournalTab(entry.button)
	end)
end
selectJournalTab(todayTab)

journalButton.Activated:Connect(function()
	journalPanel.Visible = not journalPanel.Visible
end)
journalClose.Activated:Connect(function()
	journalPanel.Visible = false
end)

local toast = Instance.new("Frame")
toast.Name = "Toast"
toast.AnchorPoint = Vector2.new(0.5, 1)
toast.Position = UDim2.new(0.5, 0, 1, 76)
toast.Size = UDim2.new(0.74, 0, 0, 62)
toast.BackgroundColor3 = colors.ink
toast.BackgroundTransparency = 0.03
toast.BorderSizePixel = 0
toast.Visible = false
toast.Parent = gui
addCorner(toast, 14)
addStroke(toast, colors.gold, 0.42, 1.5)
local toastConstraint = Instance.new("UISizeConstraint")
toastConstraint.MinSize = Vector2.new(260, 62)
toastConstraint.MaxSize = Vector2.new(520, 62)
toastConstraint.Parent = toast
local toastIcon = makeLabel(toast, "Icon", 22, true)
toastIcon.Position = UDim2.fromOffset(12, 0)
toastIcon.Size = UDim2.fromOffset(34, 62)
toastIcon.Text = "✦"
toastIcon.TextColor3 = colors.gold
toastIcon.TextXAlignment = Enum.TextXAlignment.Center
local toastText = makeLabel(toast, "Message", 15, true)
toastText.Position = UDim2.fromOffset(54, 5)
toastText.Size = UDim2.new(1, -66, 1, -10)
toastText.TextColor3 = colors.white

local toastToken = 0
local lastMessageNonce = attr("TinyWorldMessageNonce", 0)

local function showToast(message: string)
	toastToken += 1
	local currentToastToken = toastToken
	toastText.Text = message
	toast.Visible = true
	toast.Position = UDim2.new(0.5, 0, 1, 76)
	TweenService:Create(toast, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, 0, 1, -20),
	}):Play()

	task.delay(VisualQualityRules.TOAST_DURATION_SECONDS, function()
		if currentToastToken ~= toastToken then
			return
		end
		local hideTween = TweenService:Create(toast, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = UDim2.new(0.5, 0, 1, 76),
		})
		hideTween.Completed:Connect(function()
			if currentToastToken ~= toastToken then
				return
			end
			toast.Visible = false
		end)
		hideTween:Play()
	end)
end

local function friendlyQuest(): (string, string)
	local portalWorld = attr("TinyWorldPortalWorld", "Village")
	local portalFinds = attr("TinyWorldPortalCrystals", 0)
	if portalWorld == "MoonlitMeadow" then
		return "Moonlit Meadow", string.format("Find the missing moon seeds  •  %d of 3", portalFinds)
	end
	if portalWorld == "GiantKitchen" then
		return "Giant Kitchen", string.format("Gather the sugar crystals  •  %d of 3", portalFinds)
	end
	if attr("TinyWorldCarryingParcel", false) then
		return "Courier round", "Carry the parcel to the village shop"
	end

	local suggested = attr("TinyWorldSuggestedGoal", "Explore the village.")
	local friendlyGoals = {
		["Complete your TinyWorld setup."] = "Choose your TinyWorld look",
		["Claim the fountain reward or grow a Carrot."] = "Grow your first carrot",
		["Try a Courier delivery from the depot."] = "Visit the courier depot",
		["Save 300 coins and buy the Tiny Bike."] = "Save for a Tiny Bike",
		["Enter the portal and explore the Giant Kitchen."] = "Explore the Giant Kitchen",
		["Open the second portal and explore the Moonlit Meadow."] = "Explore Moonlit Meadow",
	}
	return "Today", friendlyGoals[suggested] or suggested
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

local function portalJournalCopy(): string
	local completions = attr("TinyWorldPortalCompletions", 0)
	if completions < 1 then
		return "The Giant Kitchen is waiting beyond the first portal."
	end
	if completions < 2 then
		return "Giant Kitchen  ●\nMoonlit Meadow  ○"
	end
	return "Giant Kitchen  ●\nMoonlit Meadow  ●"
end

local updateDebug = function() end

local function update()
	local coins = attr("TinyWorldCoins", 0)
	local level = attr("TinyWorldLevel", 1)
	local xp = attr("TinyWorldXP", 0)
	local threshold = Progression.xpForNextLevel(level)
	coinValue.Text = tostring(coins)
	levelText.Text = string.format("Level %d  •  %d / %d", level, xp, threshold)
	levelProgress.Size = UDim2.fromScale(math.clamp(xp / math.max(threshold, 1), 0, 1), 1)

	local title, detail = friendlyQuest()
	questTitle.Text = title
	questDetail.Text = detail
	todayQuest.Text = title .. "\n" .. detail
	todayProgress.Text = portalJournalCopy()

	bagContents.Text = string.format(
		"Carrots  %d\nSugar crystals  %d\nMoonlit seeds  %d\nSeashells  %d\nWood tokens  %d",
		attr("TinyWorldCarrots", 0),
		attr("TinyWorldSugarCrystals", 0),
		attr("TinyWorldMeadowSeeds", 0),
		attr("TinyWorldSeashells", 0),
		attr("TinyWorldWoodTokens", 0)
	)

	local privacy = attr("TinyWorldHomePrivacy", "Open")
	local charm = if attr("TinyWorldHomeCharm", false) then "Garden charm found" else "Garden charm still to discover"
	homeDetails.Text = string.format(
		"%s  •  Tier %d\n%s style\nDoor: %s\n%d furnishing pieces  •  %d decorations\n%s",
		attr("TinyWorldHouseName", "Starter Nook"),
		attr("TinyWorldHouseTier", 1),
		attr("TinyWorldHomeTheme", "Meadow"),
		privacy,
		attr("TinyWorldHomeOwnedCount", 1),
		attr("TinyWorldHomeDecorCount", 0),
		charm
	)

	careersDetails.Text = string.format(
		"Courier  •  Level %d  •  %d XP\nFarmer  •  Level %d  •  %d XP\nDesigner  •  Level %d  •  %d XP",
		attr("TinyWorldCourierLevel", 1),
		attr("TinyWorldCourierXP", 0),
		attr("TinyWorldFarmerLevel", 1),
		attr("TinyWorldFarmerXP", 0),
		attr("TinyWorldDesignerLevel", 1),
		attr("TinyWorldDesignerXP", 0)
	)

	local visited = boundaryVisitCount(attr("TinyWorldBoundaryMask", 0))
	local dailyCount = attr("TinyWorldDailyRouteCount", 0)
	local dailyTotal = attr("TinyWorldDailyRouteTotal", 3)
	collectionDetails.Text = string.format(
		"%s\n\nVillage edges visited  %d of 3\nToday’s village trail  %d of %d\nHome showcases shared  %d",
		portalJournalCopy(),
		visited,
		dailyCount,
		dailyTotal,
		attr("TinyWorldHomeShowcaseCount", 0)
	)
	updateDebug()
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
	"TinyWorldHomeCharm",
	"TinyWorldHomeTheme",
	"TinyWorldHomeDecorCount",
	"TinyWorldHomeShowcaseCount",
	"TinyWorldCourierLevel",
	"TinyWorldCourierXP",
	"TinyWorldFarmerLevel",
	"TinyWorldFarmerXP",
	"TinyWorldDesignerLevel",
	"TinyWorldDesignerXP",
	"TinyWorldPortalCompletions",
	"TinyWorldBoundaryMask",
	"TinyWorldPortalCrystals",
	"TinyWorldPortalWorld",
	"TinyWorldSuggestedGoal",
	"TinyWorldCarryingParcel",
	"TinyWorldDailyRouteCount",
	"TinyWorldDailyRouteTotal",
	"TinyWorldHomeOwnedCount",
	"TinyWorldDisplayName",
	"TinyWorldAvatarStyle",
	"TinyWorldStarterOutfit",
}

if RunService:IsStudio() then
	local debugButton = Instance.new("TextButton")
	debugButton.Name = "DebugButton"
	debugButton.AnchorPoint = Vector2.new(1, 0)
	debugButton.Position = UDim2.new(1, -70, 0, 12)
	debugButton.Size = UDim2.fromOffset(50, 26)
	debugButton.BackgroundColor3 = colors.inkSoft
	debugButton.BorderSizePixel = 0
	debugButton.Text = "DEBUG"
	debugButton.TextColor3 = colors.metal
	debugButton.TextSize = 9
	debugButton.Font = Enum.Font.Code
	debugButton.Parent = gui
	addCorner(debugButton, 7)

	local debugPanel = Instance.new("ScrollingFrame")
	debugPanel.Name = "DebugPanel"
	debugPanel.AnchorPoint = Vector2.new(1, 0)
	debugPanel.Position = UDim2.new(1, -12, 0, 70)
	debugPanel.Size = UDim2.fromOffset(360, 420)
	debugPanel.BackgroundColor3 = colors.ink
	debugPanel.BackgroundTransparency = 0.04
	debugPanel.BorderSizePixel = 0
	debugPanel.CanvasSize = UDim2.fromOffset(0, 0)
	debugPanel.AutomaticCanvasSize = Enum.AutomaticSize.Y
	debugPanel.ScrollBarThickness = 5
	debugPanel.Visible = false
	debugPanel.Parent = gui
	addCorner(debugPanel, 10)
	addPadding(debugPanel, 10, 10)

	local debugText = makeLabel(debugPanel, "RawAttributes", 12, false)
	debugText.Size = UDim2.new(1, -4, 0, 0)
	debugText.AutomaticSize = Enum.AutomaticSize.Y
	debugText.Font = Enum.Font.Code
	debugText.TextYAlignment = Enum.TextYAlignment.Top

	updateDebug = function()
		local lines = {}
		local attributes = player:GetAttributes()
		local names = {}
		for name in attributes do
			table.insert(names, name)
		end
		table.sort(names)
		for _, name in names do
			table.insert(lines, string.format("%s = %s", name, tostring(attributes[name])))
		end
		debugText.Text = table.concat(lines, "\n")
	end

	debugButton.Activated:Connect(function()
		debugPanel.Visible = not debugPanel.Visible
		if debugPanel.Visible then
			updateDebug()
		end
	end)
end

for _, name in observed do
	player:GetAttributeChangedSignal(name):Connect(update)
end

player:GetAttributeChangedSignal("TinyWorldMessageNonce"):Connect(function()
	local nonce = attr("TinyWorldMessageNonce", 0)
	if nonce == lastMessageNonce then
		return
	end
	lastMessageNonce = nonce
	showToast(tostring(attr("TinyWorldLastMessage", "Something happened in TinyWorld.")))
	updateDebug()
end)

update()
