local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local OnboardingRules = require(shared:WaitForChild("OnboardingRules"))
local VisualPalette = require(shared:WaitForChild("VisualPalette"))
local remote = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("OnboardingRemote")
local playerGui = player:WaitForChild("PlayerGui")

local colors = {
	ink = Color3.fromHex(VisualPalette.ink),
	inkSoft = Color3.fromHex(VisualPalette.inkSoft),
	paper = Color3.fromHex(VisualPalette.paper),
	warmLight = Color3.fromHex(VisualPalette.warmLight),
	gold = Color3.fromHex(VisualPalette.gold),
	meadowDeep = Color3.fromHex(VisualPalette.meadowDeep),
	skyDeep = Color3.fromHex(VisualPalette.skyDeep),
	metal = Color3.fromHex(VisualPalette.metal),
	white = Color3.fromHex(VisualPalette.white),
}

local old = playerGui:FindFirstChild("TinyWorldOnboarding")
if old then
	old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "TinyWorldOnboarding"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 100
gui.Parent = playerGui

local backdrop = Instance.new("Frame")
backdrop.Size = UDim2.fromScale(1, 1)
backdrop.BackgroundColor3 = colors.ink
backdrop.BackgroundTransparency = 0.22
backdrop.BorderSizePixel = 0
backdrop.Active = true
backdrop.Parent = gui

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.new(0.88, 0, 0, 500)
panel.BackgroundColor3 = colors.ink
panel.BorderSizePixel = 0
panel.Parent = backdrop

local panelConstraint = Instance.new("UISizeConstraint")
panelConstraint.MinSize = Vector2.new(290, 420)
panelConstraint.MaxSize = Vector2.new(430, 540)
panelConstraint.Parent = panel

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 18)
panelCorner.Parent = panel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = colors.metal
panelStroke.Transparency = 0.62
panelStroke.Thickness = 1
panelStroke.Parent = panel

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 18)
padding.PaddingBottom = UDim.new(0, 18)
padding.PaddingLeft = UDim.new(0, 20)
padding.PaddingRight = UDim.new(0, 20)
padding.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 7)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = panel

local function makeLabel(name: string, height: number, textSize: number, bold: boolean): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Size = UDim2.new(1, 0, 0, height)
	label.BackgroundTransparency = 1
	label.TextColor3 = colors.paper
	label.TextSize = textSize
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Font = if bold then Enum.Font.GothamBold else Enum.Font.Gotham
	label.LayoutOrder = #panel:GetChildren()
	label.Parent = panel
	return label
end

local title = makeLabel("Title", 36, 25, true)
title.Text = "Welcome to TinyWorld!"
title.TextColor3 = colors.warmLight
local subtitle = makeLabel("Subtitle", 32, 15, false)
subtitle.Text = "Choose your name and a free starter look."
subtitle.TextColor3 = colors.paper
subtitle.TextTransparency = 0.12

local nameBox = Instance.new("TextBox")
nameBox.Name = "DisplayName"
nameBox.Size = UDim2.new(1, 0, 0, 42)
nameBox.BackgroundColor3 = colors.inkSoft
nameBox.BorderSizePixel = 0
nameBox.ClearTextOnFocus = false
nameBox.PlaceholderText = "Your TinyWorld name"
nameBox.PlaceholderColor3 = colors.metal
nameBox.TextColor3 = colors.white
nameBox.TextSize = 17
nameBox.Font = Enum.Font.Gotham
nameBox.TextXAlignment = Enum.TextXAlignment.Left
nameBox.LayoutOrder = #panel:GetChildren()
nameBox.Parent = panel
local namePadding = Instance.new("UIPadding")
namePadding.PaddingLeft = UDim.new(0, 12)
namePadding.PaddingRight = UDim.new(0, 12)
namePadding.Parent = nameBox
local nameCorner = Instance.new("UICorner")
nameCorner.CornerRadius = UDim.new(0, 9)
nameCorner.Parent = nameBox
local nameStroke = Instance.new("UIStroke")
nameStroke.Color = colors.metal
nameStroke.Transparency = 0.72
nameStroke.Parent = nameBox

local genderLabel = makeLabel("GenderLabel", 20, 14, true)
genderLabel.Text = "Avatar style"

local function makeRow(name: string): Frame
	local row = Instance.new("Frame")
	row.Name = name
	row.Size = UDim2.new(1, 0, 0, 42)
	row.BackgroundTransparency = 1
	row.LayoutOrder = #panel:GetChildren()
	row.Parent = panel
	local rowLayout = Instance.new("UIListLayout")
	rowLayout.FillDirection = Enum.FillDirection.Horizontal
	rowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	rowLayout.Padding = UDim.new(0, 6)
	rowLayout.Parent = row
	return row
end

local function makeChoice(parent: Frame, name: string, text: string, widthScale: number): TextButton
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = UDim2.new(widthScale, -3, 1, 0)
	button.BackgroundColor3 = colors.inkSoft
	button.BorderSizePixel = 0
	button.TextColor3 = colors.paper
	button.TextSize = 15
	button.Text = text
	button.Font = Enum.Font.GothamBold
	button.AutoButtonColor = true
	button.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 9)
	corner.Parent = button
	local stroke = Instance.new("UIStroke")
	stroke.Color = colors.metal
	stroke.Transparency = 0.76
	stroke.Parent = button
	return button
end

local genderRow = makeRow("GenderChoices")
local boyButton = makeChoice(genderRow, "Boy", "Boy", 0.5)
local girlButton = makeChoice(genderRow, "Girl", "Girl", 0.5)

local outfitLabel = makeLabel("OutfitLabel", 20, 14, true)
outfitLabel.Text = "Free starter outfit"

local outfitRow = makeRow("OutfitChoices")
local meadowButton = makeChoice(outfitRow, "Meadow", "Meadow", 1 / 3)
local harborButton = makeChoice(outfitRow, "Harbor", "Harbor", 1 / 3)
local sunsetButton = makeChoice(outfitRow, "Sunset", "Sunset", 1 / 3)

local status = makeLabel("Status", 40, 14, false)
status.TextColor3 = colors.warmLight
status.Text = "Pick a style and outfit to continue."

local beginButton = Instance.new("TextButton")
beginButton.Name = "Begin"
beginButton.Size = UDim2.new(1, 0, 0, 46)
beginButton.BackgroundColor3 = colors.meadowDeep
beginButton.BorderSizePixel = 0
beginButton.TextColor3 = colors.white
beginButton.TextSize = 17
beginButton.Text = "Begin TinyWorld"
beginButton.Font = Enum.Font.GothamBold
beginButton.AutoButtonColor = true
beginButton.LayoutOrder = #panel:GetChildren()
beginButton.Parent = panel
local beginCorner = Instance.new("UICorner")
beginCorner.CornerRadius = UDim.new(0, 10)
beginCorner.Parent = beginButton
local beginStroke = Instance.new("UIStroke")
beginStroke.Color = colors.warmLight
beginStroke.Transparency = 0.62
beginStroke.Parent = beginButton

local selectedGender: string? = nil
local selectedOutfit: string? = nil
local movementSnapshot = nil
local blocking = false
local BLOCK_ACTION = "TinyWorldOnboardingBlockMovement"

local function setChoiceVisual(button: TextButton, selected: boolean)
	button.BackgroundColor3 = if selected then colors.skyDeep else colors.inkSoft
	button.TextColor3 = if selected then colors.white else colors.paper
end

local function refreshChoices()
	setChoiceVisual(boyButton, selectedGender == "Boy")
	setChoiceVisual(girlButton, selectedGender == "Girl")
	setChoiceVisual(meadowButton, selectedOutfit == "Meadow")
	setChoiceVisual(harborButton, selectedOutfit == "Harbor")
	setChoiceVisual(sunsetButton, selectedOutfit == "Sunset")
end

local function sinkMovement(): Enum.ContextActionResult
	return Enum.ContextActionResult.Sink
end

local function setMovementBlocked(value: boolean)
	if blocking == value then
		return
	end
	blocking = value
	local character = player.Character
	local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
	if value then
		if humanoid then
			movementSnapshot = {
				walkSpeed = humanoid.WalkSpeed,
				jumpPower = humanoid.JumpPower,
				jumpHeight = humanoid.JumpHeight,
				autoRotate = humanoid.AutoRotate,
			}
			humanoid.WalkSpeed = 0
			humanoid.JumpPower = 0
			humanoid.JumpHeight = 0
			humanoid.AutoRotate = false
		end
		ContextActionService:BindAction(BLOCK_ACTION, sinkMovement, false,
			Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D,
			Enum.KeyCode.Up, Enum.KeyCode.Down, Enum.KeyCode.Left, Enum.KeyCode.Right,
			Enum.KeyCode.Space)
	else
		ContextActionService:UnbindAction(BLOCK_ACTION)
		if humanoid and movementSnapshot then
			humanoid.WalkSpeed = movementSnapshot.walkSpeed
			humanoid.JumpPower = movementSnapshot.jumpPower
			humanoid.JumpHeight = movementSnapshot.jumpHeight
			humanoid.AutoRotate = movementSnapshot.autoRotate
		end
		movementSnapshot = nil
	end
end

local function setVisible(value: boolean)
	gui.Enabled = value
	setMovementBlocked(value)
	if value then
		nameBox:CaptureFocus()
	end
end

local function updateSubmitState()
	local validName = OnboardingRules.validateDisplayName(nameBox.Text)
	local ready = validName and selectedGender ~= nil and selectedOutfit ~= nil
	beginButton.Active = ready
	beginButton.BackgroundColor3 = if ready then colors.meadowDeep else colors.inkSoft
	beginButton.TextColor3 = if ready then colors.white else colors.metal
end

boyButton.Activated:Connect(function()
	selectedGender = "Boy"
	refreshChoices()
	updateSubmitState()
end)

girlButton.Activated:Connect(function()
	selectedGender = "Girl"
	refreshChoices()
	updateSubmitState()
end)

meadowButton.Activated:Connect(function()
	selectedOutfit = "Meadow"
	refreshChoices()
	updateSubmitState()
end)

harborButton.Activated:Connect(function()
	selectedOutfit = "Harbor"
	refreshChoices()
	updateSubmitState()
end)

sunsetButton.Activated:Connect(function()
	selectedOutfit = "Sunset"
	refreshChoices()
	updateSubmitState()
end)

nameBox:GetPropertyChangedSignal("Text"):Connect(updateSubmitState)

beginButton.Activated:Connect(function()
	local validName = OnboardingRules.validateDisplayName(nameBox.Text)
	if not validName or selectedGender == nil or selectedOutfit == nil then
		status.Text = "Choose a valid name, style, and outfit first."
		updateSubmitState()
		return
	end
	beginButton.Active = false
	status.Text = "Saving your TinyWorld setup..."
	remote:FireServer({
		displayName = nameBox.Text,
		avatarStyle = selectedGender,
		starterOutfit = selectedOutfit,
	})
end)

remote.OnClientEvent:Connect(function(result)
	if type(result) ~= "table" then
		return
	end
	status.Text = result.message or "TinyWorld replied."
	if result.ok == true then
		setVisible(false)
	else
		updateSubmitState()
	end
end)

player:GetAttributeChangedSignal("TinyWorldOnboardingRequired"):Connect(function()
	setVisible(player:GetAttribute("TinyWorldOnboardingRequired") == true)
end)

refreshChoices()
updateSubmitState()
setVisible(player:GetAttribute("TinyWorldOnboardingRequired") == true or player:GetAttribute("TinyWorldOnboardingComplete") ~= true)
