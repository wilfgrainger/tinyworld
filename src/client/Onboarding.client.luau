local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local OnboardingRules = require(shared:WaitForChild("OnboardingRules"))
local VisualPalette = require(shared:WaitForChild("VisualPalette"))
local remote = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("OnboardingRemote")
local playerGui = player:WaitForChild("PlayerGui")

local MIN_TOUCH_TARGET = 64
local BLOCK_ACTION = "TinyWorldOnboardingBlockMovement"

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

local moodColors = {
	Meadow = colors.meadowDeep,
	Harbor = colors.skyDeep,
	Sunset = Color3.fromRGB(222, 111, 51),
}

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

local function makeLabel(parent: Instance, name: string, size: UDim2, textSize: number, bold: boolean): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Size = size
	label.BackgroundTransparency = 1
	label.TextColor3 = colors.ink
	label.TextSize = textSize
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Font = if bold then Enum.Font.GothamBold else Enum.Font.Gotham
	label.Parent = parent
	return label
end

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
backdrop.Name = "Backdrop"
backdrop.Size = UDim2.fromScale(1, 1)
backdrop.BackgroundColor3 = colors.ink
backdrop.BackgroundTransparency = 0.34
backdrop.BorderSizePixel = 0
backdrop.Active = true
backdrop.Parent = gui

local panel = Instance.new("Frame")
panel.Name = "WelcomePanel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.new(0.9, 0, 0.84, 0)
panel.BackgroundColor3 = colors.paper
panel.BackgroundTransparency = 0.02
panel.BorderSizePixel = 0
panel.Parent = backdrop
addCorner(panel, 20)
addStroke(panel, colors.gold, 0.45, 1.5)

local panelConstraint = Instance.new("UISizeConstraint")
panelConstraint.MinSize = Vector2.new(300, 430)
panelConstraint.MaxSize = Vector2.new(620, 590)
panelConstraint.Parent = panel

local content = Instance.new("ScrollingFrame")
content.Name = "Choices"
content.Position = UDim2.fromOffset(16, 16)
content.Size = UDim2.new(1, -32, 1, -32)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.CanvasSize = UDim2.fromOffset(0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.ScrollBarThickness = 4
content.ScrollBarImageColor3 = colors.gold
content.ScrollingDirection = Enum.ScrollingDirection.Y
content.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = content

local nextOrder = 0
local function place(instance: GuiObject)
	nextOrder += 1
	instance.LayoutOrder = nextOrder
	instance.Parent = content
end

local title = makeLabel(content, "Title", UDim2.new(1, 0, 0, 36), 26, true)
title.Text = "Welcome to TinyWorld"
title.TextColor3 = colors.ink
place(title)

local subtitle = makeLabel(content, "Subtitle", UDim2.new(1, 0, 0, 42), 14, false)
subtitle.Text = "Choose your TinyWorld name and save the style you like."
subtitle.TextColor3 = colors.inkSoft
place(subtitle)

local nameBox = Instance.new("TextBox")
nameBox.Name = "DisplayName"
nameBox.Size = UDim2.new(1, 0, 0, 50)
nameBox.BackgroundColor3 = colors.warmLight
nameBox.BorderSizePixel = 0
nameBox.ClearTextOnFocus = false
nameBox.PlaceholderText = "Your TinyWorld name"
nameBox.PlaceholderColor3 = colors.inkSoft
nameBox.TextColor3 = colors.ink
nameBox.TextSize = 17
nameBox.Font = Enum.Font.Gotham
nameBox.TextXAlignment = Enum.TextXAlignment.Left
place(nameBox)
addCorner(nameBox, 11)
addStroke(nameBox, colors.inkSoft, 0.72)

local namePadding = Instance.new("UIPadding")
namePadding.PaddingLeft = UDim.new(0, 14)
namePadding.PaddingRight = UDim.new(0, 14)
namePadding.Parent = nameBox

local avatarLabel = makeLabel(content, "AvatarLabel", UDim2.new(1, 0, 0, 22), 14, true)
avatarLabel.Text = "Character preference"
place(avatarLabel)

local avatarNote = makeLabel(content, "AvatarNote", UDim2.new(1, 0, 0, 36), 12, false)
avatarNote.Text =
	"Your Roblox avatar stays exactly as it is. TinyWorld simply remembers this preference for future character styles."
avatarNote.TextColor3 = colors.inkSoft
avatarNote.TextYAlignment = Enum.TextYAlignment.Top
place(avatarNote)

local avatarRow = Instance.new("Frame")
avatarRow.Name = "AvatarChoices"
avatarRow.Size = UDim2.new(1, 0, 0, MIN_TOUCH_TARGET)
avatarRow.BackgroundTransparency = 1
place(avatarRow)

local avatarGrid = Instance.new("UIGridLayout")
avatarGrid.CellPadding = UDim2.fromOffset(8, 0)
avatarGrid.CellSize = UDim2.new(0.5, -4, 1, 0)
avatarGrid.FillDirectionMaxCells = 2
avatarGrid.SortOrder = Enum.SortOrder.LayoutOrder
avatarGrid.Parent = avatarRow

local moodLabel = makeLabel(content, "MoodLabel", UDim2.new(1, 0, 0, 22), 14, true)
moodLabel.Text = "Favourite TinyWorld mood"
place(moodLabel)

local moodNote = makeLabel(content, "MoodNote", UDim2.new(1, 0, 0, 32), 12, false)
moodNote.Text = "This is a saved preference, not a costume forced onto your avatar."
moodNote.TextColor3 = colors.inkSoft
place(moodNote)

local moodRow = Instance.new("Frame")
moodRow.Name = "MoodChoices"
moodRow.Size = UDim2.new(1, 0, 0, MIN_TOUCH_TARGET)
moodRow.BackgroundTransparency = 1
place(moodRow)

local moodGrid = Instance.new("UIGridLayout")
moodGrid.CellPadding = UDim2.fromOffset(8, 0)
moodGrid.CellSize = UDim2.new(1 / 3, -6, 1, 0)
moodGrid.FillDirectionMaxCells = 3
moodGrid.SortOrder = Enum.SortOrder.LayoutOrder
moodGrid.Parent = moodRow

local function makeChoiceButton(parent: Instance, name: string, text: string, order: number, accent: Color3): TextButton
	local button = Instance.new("TextButton")
	button.Name = name
	button.LayoutOrder = order
	button.BackgroundColor3 = colors.warmLight
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = colors.ink
	button.TextSize = 15
	button.TextWrapped = true
	button.Font = Enum.Font.GothamBold
	button.AutoButtonColor = true
	button.Selectable = true
	button.Parent = parent
	button:SetAttribute("TinyWorldChoiceAccent", accent)
	addCorner(button, 11)
	addStroke(button, colors.inkSoft, 0.72, 1.5)
	return button
end

local boyButton = makeChoiceButton(avatarRow, "BoyChoice", "Boy", 1, colors.skyDeep)
local girlButton = makeChoiceButton(avatarRow, "GirlChoice", "Girl", 2, colors.meadowDeep)

local meadowButton = makeChoiceButton(moodRow, "MeadowChoice", "Meadow", 1, moodColors.Meadow)
local harborButton = makeChoiceButton(moodRow, "HarborChoice", "Harbor", 2, moodColors.Harbor)
local sunsetButton = makeChoiceButton(moodRow, "SunsetChoice", "Sunset", 3, moodColors.Sunset)

local status = makeLabel(content, "Status", UDim2.new(1, 0, 0, 38), 13, false)
status.TextColor3 = colors.inkSoft
status.Text = "Choose a name and both preferences to continue."
place(status)

local beginButton = Instance.new("TextButton")
beginButton.Name = "Begin"
beginButton.Size = UDim2.new(1, 0, 0, 52)
beginButton.BackgroundColor3 = colors.warmLight
beginButton.BorderSizePixel = 0
beginButton.TextColor3 = colors.inkSoft
beginButton.TextSize = 17
beginButton.Text = "Begin TinyWorld"
beginButton.Font = Enum.Font.GothamBold
beginButton.AutoButtonColor = true
place(beginButton)
addCorner(beginButton, 11)
addStroke(beginButton, colors.gold, 0.42, 1.5)

local selectedGender: string? = nil
local selectedOutfit: string? = nil
local movementSnapshot = nil
local blocking = false

local function setChoiceVisual(button: TextButton, selected: boolean)
	local stroke = button:FindFirstChildOfClass("UIStroke")
	local accent = button:GetAttribute("TinyWorldChoiceAccent")
	local accentColor = if typeof(accent) == "Color3" then accent else colors.gold
	button.BackgroundColor3 = if selected then accentColor else colors.warmLight
	button.TextColor3 = if selected then colors.white else colors.ink
	if stroke then
		stroke.Color = if selected then colors.gold else colors.inkSoft
		stroke.Transparency = if selected then 0.16 else 0.72
		stroke.Thickness = if selected then 2.5 else 1.5
	end
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
		ContextActionService:BindAction(
			BLOCK_ACTION,
			sinkMovement,
			false,
			Enum.KeyCode.W,
			Enum.KeyCode.A,
			Enum.KeyCode.S,
			Enum.KeyCode.D,
			Enum.KeyCode.Up,
			Enum.KeyCode.Down,
			Enum.KeyCode.Left,
			Enum.KeyCode.Right,
			Enum.KeyCode.Space
		)
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
end

local function updateSubmitState()
	local validName = OnboardingRules.validateDisplayName(nameBox.Text)
	local ready = validName and selectedGender ~= nil and selectedOutfit ~= nil
	beginButton.Active = ready
	beginButton.Selectable = ready
	beginButton.AutoButtonColor = ready
	beginButton.BackgroundColor3 = if ready then colors.meadowDeep else colors.warmLight
	beginButton.TextColor3 = if ready then colors.white else colors.inkSoft
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
		status.Text = "Choose a valid name and both preferences first."
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
setVisible(
	player:GetAttribute("TinyWorldOnboardingRequired") == true
		or player:GetAttribute("TinyWorldOnboardingComplete") ~= true
)
