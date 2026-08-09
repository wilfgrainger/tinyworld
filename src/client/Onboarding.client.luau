local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local OnboardingRules = require(shared:WaitForChild("OnboardingRules"))
local VisualPalette = require(shared:WaitForChild("VisualPalette"))
local remote = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("OnboardingRemote")
local playerGui = player:WaitForChild("PlayerGui")

local MIN_TOUCH_TARGET = 72
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

local outfitScenes = {
	Meadow = {
		scene = "Garden paths and picnic greens",
		sky = Color3.fromRGB(180, 219, 230),
		ground = Color3.fromRGB(104, 153, 93),
		accent = Color3.fromRGB(246, 231, 183),
	},
	Harbor = {
		scene = "Sea-blue docks and bright sails",
		sky = Color3.fromRGB(160, 207, 229),
		ground = Color3.fromRGB(67, 119, 168),
		accent = Color3.fromRGB(211, 220, 226),
	},
	Sunset = {
		scene = "Lantern orange and evening gold",
		sky = Color3.fromRGB(246, 174, 118),
		ground = Color3.fromRGB(222, 111, 51),
		accent = Color3.fromRGB(255, 205, 91),
	},
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
	label.TextColor3 = colors.paper
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
backdrop.BackgroundTransparency = 0.16
backdrop.BorderSizePixel = 0
backdrop.Active = true
backdrop.Parent = gui
local backdropGradient = Instance.new("UIGradient")
backdropGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, colors.skyDeep),
	ColorSequenceKeypoint.new(1, colors.ink),
})
backdropGradient.Rotation = 90
backdropGradient.Parent = backdrop

local panel = Instance.new("Frame")
panel.Name = "WelcomePanel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.new(0.94, 0, 0.92, 0)
panel.BackgroundColor3 = colors.ink
panel.BackgroundTransparency = 0.02
panel.BorderSizePixel = 0
panel.Parent = backdrop
addCorner(panel, 20)
addStroke(panel, colors.gold, 0.5, 1.5)
local panelConstraint = Instance.new("UISizeConstraint")
panelConstraint.MinSize = Vector2.new(300, 420)
panelConstraint.MaxSize = Vector2.new(720, 680)
panelConstraint.Parent = panel

local content = Instance.new("ScrollingFrame")
content.Name = "Choices"
content.Position = UDim2.fromOffset(10, 10)
content.Size = UDim2.new(1, -20, 1, -20)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.CanvasSize = UDim2.fromOffset(0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.ScrollBarThickness = 5
content.ScrollBarImageColor3 = colors.gold
content.ScrollingDirection = Enum.ScrollingDirection.Y
content.Parent = panel
local contentPadding = Instance.new("UIPadding")
contentPadding.PaddingTop = UDim.new(0, 8)
contentPadding.PaddingBottom = UDim.new(0, 8)
contentPadding.PaddingLeft = UDim.new(0, 10)
contentPadding.PaddingRight = UDim.new(0, 10)
contentPadding.Parent = content
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = content

local nextOrder = 0
local function place(instance: GuiObject)
	nextOrder += 1
	instance.LayoutOrder = nextOrder
	instance.Parent = content
end

local title = makeLabel(content, "Title", UDim2.new(1, 0, 0, 34), 25, true)
title.Text = "Welcome to TinyWorld!"
title.TextColor3 = colors.warmLight
place(title)
local subtitle = makeLabel(content, "Subtitle", UDim2.new(1, 0, 0, 38), 14, false)
subtitle.Text = "Choose a name and preview the free look that feels like you."
subtitle.TextColor3 = colors.paper
subtitle.TextTransparency = 0.12
place(subtitle)

local nameBox = Instance.new("TextBox")
nameBox.Name = "DisplayName"
nameBox.Size = UDim2.new(1, 0, 0, 48)
nameBox.BackgroundColor3 = colors.inkSoft
nameBox.BorderSizePixel = 0
nameBox.ClearTextOnFocus = false
nameBox.PlaceholderText = "Your TinyWorld name"
nameBox.PlaceholderColor3 = colors.metal
nameBox.TextColor3 = colors.white
nameBox.TextSize = 17
nameBox.Font = Enum.Font.Gotham
nameBox.TextXAlignment = Enum.TextXAlignment.Left
place(nameBox)
local namePadding = Instance.new("UIPadding")
namePadding.PaddingLeft = UDim.new(0, 14)
namePadding.PaddingRight = UDim.new(0, 14)
namePadding.Parent = nameBox
addCorner(nameBox, 10)
addStroke(nameBox, colors.metal, 0.66)

local avatarLabel = makeLabel(content, "AvatarLabel", UDim2.new(1, 0, 0, 22), 14, true)
avatarLabel.Text = "Choose your avatar style"
place(avatarLabel)

local avatarRow = Instance.new("Frame")
avatarRow.Name = "AvatarCards"
avatarRow.Size = UDim2.new(1, 0, 0, 240)
avatarRow.BackgroundTransparency = 1
place(avatarRow)
local avatarGrid = Instance.new("UIGridLayout")
avatarGrid.CellPadding = UDim2.fromOffset(0, 8)
avatarGrid.CellSize = UDim2.new(1, 0, 0, 116)
avatarGrid.FillDirectionMaxCells = 1
avatarGrid.SortOrder = Enum.SortOrder.LayoutOrder
avatarGrid.Parent = avatarRow

local function makeSelectionMark(parent: Instance): TextLabel
	local mark = makeLabel(parent, "SelectionMark", UDim2.fromOffset(28, 28), 18, true)
	mark.Name = "SelectionMark"
	mark.AnchorPoint = Vector2.new(1, 0)
	mark.Position = UDim2.new(1, -8, 0, 8)
	mark.BackgroundColor3 = colors.gold
	mark.BackgroundTransparency = 0
	mark.Text = "✓"
	mark.TextColor3 = colors.ink
	mark.TextXAlignment = Enum.TextXAlignment.Center
	mark.Visible = false
	addCorner(mark, 14)
	return mark
end

local function makeAvatarCard(value: string, heading: string, description: string, accent: Color3): TextButton
	local card = Instance.new("TextButton")
	card.Size = UDim2.new(1, 0, 0, math.max(MIN_TOUCH_TARGET, 116))
	card.BackgroundColor3 = colors.inkSoft
	card.BorderSizePixel = 0
	card.Text = ""
	card.AutoButtonColor = false
	card.Parent = avatarRow
	addCorner(card, 12)
	addStroke(card, colors.metal, 0.72, 1.5)

	local preview = Instance.new("Frame")
	preview.Name = "AvatarPreview"
	preview.Position = UDim2.fromOffset(10, 10)
	preview.Size = UDim2.fromOffset(72, 96)
	preview.BackgroundColor3 = colors.paper
	preview.BackgroundTransparency = 0.9
	preview.BorderSizePixel = 0
	preview.Parent = card
	addCorner(preview, 10)

	local head = Instance.new("Frame")
	head.Name = "Head"
	head.AnchorPoint = Vector2.new(0.5, 0)
	head.Position = UDim2.new(0.5, 0, 0, 10)
	head.Size = UDim2.fromOffset(32, 32)
	head.BackgroundColor3 = colors.warmLight
	head.BorderSizePixel = 0
	head.Parent = preview
	addCorner(head, 16)

	local hair = Instance.new("Frame")
	hair.Name = "Hair"
	hair.Size = UDim2.new(1, 0, 0.42, 0)
	hair.BackgroundColor3 = colors.inkSoft
	hair.BorderSizePixel = 0
	hair.Parent = head
	addCorner(hair, 12)

	local body = Instance.new("Frame")
	body.Name = "Body"
	body.AnchorPoint = Vector2.new(0.5, 0)
	body.Position = UDim2.new(0.5, 0, 0, 46)
	body.Size = if value == "Girl" then UDim2.fromOffset(48, 42) else UDim2.fromOffset(42, 42)
	body.BackgroundColor3 = accent
	body.BorderSizePixel = 0
	body.Parent = preview
	addCorner(body, 9)

	local cardTitle = makeLabel(card, "CardTitle", UDim2.new(1, -102, 0, 28), 16, true)
	cardTitle.Position = UDim2.fromOffset(92, 20)
	cardTitle.Text = heading
	cardTitle.TextColor3 = colors.warmLight
	local cardDescription = makeLabel(card, "Description", UDim2.new(1, -102, 0, 48), 12, false)
	cardDescription.Position = UDim2.fromOffset(92, 48)
	cardDescription.Text = description
	cardDescription.TextYAlignment = Enum.TextYAlignment.Top
	makeSelectionMark(card)
	return card
end

local boyButton = makeAvatarCard("Boy", "Boy", "A bright, easy-going village silhouette.", colors.skyDeep)
boyButton.Name = "BoyCard"
local girlButton = makeAvatarCard("Girl", "Girl", "A bright, playful village silhouette.", colors.meadowDeep)
girlButton.Name = "GirlCard"

local outfitLabel = makeLabel(content, "OutfitLabel", UDim2.new(1, 0, 0, 22), 14, true)
outfitLabel.Text = "Pick a free starter outfit"
place(outfitLabel)

local outfitRow = Instance.new("Frame")
outfitRow.Name = "OutfitCards"
outfitRow.Size = UDim2.new(1, 0, 0, 440)
outfitRow.BackgroundTransparency = 1
place(outfitRow)
local outfitGrid = Instance.new("UIGridLayout")
outfitGrid.CellPadding = UDim2.fromOffset(0, 7)
outfitGrid.CellSize = UDim2.new(1, 0, 0, 142)
outfitGrid.FillDirectionMaxCells = 1
outfitGrid.SortOrder = Enum.SortOrder.LayoutOrder
outfitGrid.Parent = outfitRow

local function makeSceneDecoration(
	parent: Instance,
	name: string,
	position: UDim2,
	size: UDim2,
	color: Color3,
	round: boolean?
)
	local decoration = Instance.new("Frame")
	decoration.Name = name
	decoration.Position = position
	decoration.Size = size
	decoration.BackgroundColor3 = color
	decoration.BorderSizePixel = 0
	decoration.Parent = parent
	if round then
		addCorner(decoration, 20)
	end
	return decoration
end

local function makeOutfitCard(value: string, heading: string): TextButton
	local scene = outfitScenes[value]
	local card = Instance.new("TextButton")
	card.Size = UDim2.new(1, 0, 0, math.max(MIN_TOUCH_TARGET, 142))
	card.BackgroundColor3 = colors.inkSoft
	card.BorderSizePixel = 0
	card.Text = ""
	card.AutoButtonColor = false
	card.Parent = outfitRow
	addCorner(card, 12)
	addStroke(card, colors.metal, 0.72, 1.5)

	local preview = Instance.new("Frame")
	preview.Name = "ScenePreview"
	preview.Position = UDim2.fromOffset(9, 9)
	preview.Size = UDim2.new(1, -18, 0, 64)
	preview.BackgroundColor3 = scene.sky
	preview.BorderSizePixel = 0
	preview.ClipsDescendants = true
	preview.Parent = card
	addCorner(preview, 9)
	makeSceneDecoration(preview, "Ground", UDim2.fromScale(0, 0.58), UDim2.fromScale(1, 0.42), scene.ground)
	makeSceneDecoration(preview, "Sun", UDim2.new(1, -28, 0, 8), UDim2.fromOffset(18, 18), scene.accent, true)
	makeSceneDecoration(preview, "Path", UDim2.new(0.5, -12, 0.52, 0), UDim2.fromOffset(24, 40), colors.warmLight, true)

	local cardTitle = makeLabel(card, "CardTitle", UDim2.new(1, -16, 0, 24), 14, true)
	cardTitle.Position = UDim2.fromOffset(8, 77)
	cardTitle.Text = heading
	cardTitle.TextColor3 = colors.warmLight
	cardTitle.TextXAlignment = Enum.TextXAlignment.Center
	local cardDescription = makeLabel(card, "Description", UDim2.new(1, -14, 0, 34), 10, false)
	cardDescription.Position = UDim2.fromOffset(7, 101)
	cardDescription.Text = scene.scene
	cardDescription.TextXAlignment = Enum.TextXAlignment.Center
	cardDescription.TextYAlignment = Enum.TextYAlignment.Top
	makeSelectionMark(card)
	return card
end

local meadowButton = makeOutfitCard("Meadow", "Meadow")
meadowButton.Name = "MeadowCard"
local harborButton = makeOutfitCard("Harbor", "Harbor")
harborButton.Name = "HarborCard"
local sunsetButton = makeOutfitCard("Sunset", "Sunset")
sunsetButton.Name = "SunsetCard"

local status = makeLabel(content, "Status", UDim2.new(1, 0, 0, 38), 13, false)
status.TextColor3 = colors.warmLight
status.Text = "Pick a style and outfit to continue."
place(status)

local beginButton = Instance.new("TextButton")
beginButton.Name = "Begin"
beginButton.Size = UDim2.new(1, 0, 0, 52)
beginButton.BackgroundColor3 = colors.inkSoft
beginButton.BorderSizePixel = 0
beginButton.TextColor3 = colors.metal
beginButton.TextSize = 17
beginButton.Text = "Begin TinyWorld"
beginButton.Font = Enum.Font.GothamBold
beginButton.AutoButtonColor = true
place(beginButton)
addCorner(beginButton, 11)
addStroke(beginButton, colors.warmLight, 0.62)

local selectedGender: string? = nil
local selectedOutfit: string? = nil
local movementSnapshot = nil
local blocking = false

local function setChoiceVisual(card: TextButton, selected: boolean)
	local selectionMark = card:FindFirstChild("SelectionMark")
	if selectionMark and selectionMark:IsA("GuiObject") then
		selectionMark.Visible = selected
	end
	local stroke = card:FindFirstChildOfClass("UIStroke")
	if stroke then
		stroke.Color = if selected then colors.gold else colors.metal
		stroke.Transparency = if selected then 0.12 else 0.72
		stroke.Thickness = if selected then 2.5 else 1.5
	end
	card.BackgroundColor3 = if selected then colors.skyDeep else colors.inkSoft
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
setVisible(
	player:GetAttribute("TinyWorldOnboardingRequired") == true
		or player:GetAttribute("TinyWorldOnboardingComplete") ~= true
)
