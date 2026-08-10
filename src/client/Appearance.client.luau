local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local root = ReplicatedStorage:WaitForChild("TinyWorld")
local shared = root:WaitForChild("Shared")
local AppearanceDefinitions = require(shared:WaitForChild("AppearanceDefinitions"))
local UiTokens = require(script.Parent:WaitForChild("UiTokens"))
local UiScaleRules = require(script.Parent:WaitForChild("UiScaleRules"))
local ButtonFactory = require(script.Parent:WaitForChild("ButtonFactory"))
local PanelFactory = require(script.Parent:WaitForChild("PanelFactory"))
local ModalController = require(script.Parent:WaitForChild("ModalController"))
local GameNav = require(script.Parent:WaitForChild("GameNav"))

local remote = root:WaitForChild("AppearanceRemote") :: RemoteEvent
local camera = Workspace.CurrentCamera
local modalController = ModalController.new()
local selectedHair = "Tousled"
local selectedOutfit = "Starter"

local gui = Instance.new("ScreenGui")
gui.Name = "TinyWorldWardrobe"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = UiTokens.ModalDisplayOrder + 1
gui.Parent = playerGui

local backdrop = Instance.new("Frame")
backdrop.Size = UDim2.fromScale(1, 1)
backdrop.BackgroundColor3 = Color3.new(0, 0, 0)
backdrop.BackgroundTransparency = 0.45
backdrop.Visible = false
backdrop.Active = true
backdrop.Parent = gui

local panel = PanelFactory.create(backdrop, "WardrobePanel")
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)

local layout = PanelFactory.verticalLayout(panel, 8)
layout.VerticalAlignment = Enum.VerticalAlignment.Top

local title = Instance.new("TextLabel")
title.LayoutOrder = 1
title.Size = UDim2.new(1, 0, 0, 36)
title.BackgroundTransparency = 1
title.Text = "My Style"
title.TextColor3 = UiTokens.Colors.Ink
title.TextSize = 24
title.Font = UiTokens.Fonts.Title
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local hint = Instance.new("TextLabel")
hint.LayoutOrder = 2
hint.Size = UDim2.new(1, 0, 0, 58)
hint.BackgroundTransparency = 1
hint.Text =
	"Your Roblox avatar stays intact while TinyWorld character art is upgraded. You can still save a style preference for later."
hint.TextColor3 = UiTokens.Colors.InkSoft
hint.TextSize = 14
hint.TextWrapped = true
hint.Font = UiTokens.Fonts.Body
hint.TextXAlignment = Enum.TextXAlignment.Left
hint.TextYAlignment = Enum.TextYAlignment.Top
hint.Parent = panel

-- v0.6.1 deliberately hides the old hair-choice row. The server keeps the
-- saved preference data, but no longer pretends a primitive Part hairstyle is
-- a finished visual option.
local hairButtons = {}
for _, hair in AppearanceDefinitions.hairStyles() do
	hairButtons[hair.id] = hair
end

local outfitScroll = Instance.new("ScrollingFrame")
outfitScroll.LayoutOrder = 3
outfitScroll.Size = UDim2.new(1, 0, 1, -176)
outfitScroll.BackgroundTransparency = 1
outfitScroll.BorderSizePixel = 0
outfitScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
outfitScroll.CanvasSize = UDim2.new()
outfitScroll.ScrollBarThickness = 6
outfitScroll.Parent = panel
local outfitLayout = Instance.new("UIGridLayout")
outfitLayout.CellPadding = UDim2.fromOffset(8, 8)
outfitLayout.CellSize = UDim2.new(0.5, -6, 0, 64)
outfitLayout.Parent = outfitScroll

local saveButton = ButtonFactory.create(panel, "Save Preference", 4)
local closeButton = ButtonFactory.secondary(panel, "Close", 5)

local outfitButtons = {}
for index, outfit in AppearanceDefinitions.outfits() do
	local button = Instance.new("TextButton")
	button.Name = "Outfit_" .. outfit.id
	button.LayoutOrder = index
	button.BackgroundColor3 = UiTokens.Colors.PaperSoft
	button.BorderSizePixel = 0
	button.Text = outfit.displayName .. "\nSTYLE"
	button.TextColor3 = UiTokens.Colors.Ink
	button.TextSize = 14
	button.TextWrapped = true
	button.Font = UiTokens.Fonts.Strong
	button.Selectable = true
	button.Parent = outfitScroll
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = button
	button.Activated:Connect(function()
		selectedOutfit = outfit.id
		for id, other in outfitButtons do
			other.BackgroundColor3 = if id == selectedOutfit then UiTokens.Colors.Gold else UiTokens.Colors.PaperSoft
		end
	end)
	outfitButtons[outfit.id] = button
end

local function updateResponsive()
	local viewport = if camera then camera.ViewportSize else Vector2.new(1280, 720)
	panel.Size = UiScaleRules.modalSize(viewport)
	local columns = math.min(3, UiScaleRules.columns(viewport))
	outfitLayout.FillDirectionMaxCells = columns
	outfitLayout.CellSize = UDim2.new(1 / columns, -8, 0, 66)
end

local function openWardrobe()
	remote:FireServer({ action = "state" })
	backdrop.Visible = true
	modalController:open(backdrop, saveButton)
end

GameNav.register("Style", "Style", 3, openWardrobe)
saveButton.Activated:Connect(function()
	remote:FireServer({ action = "save", hairId = selectedHair, outfitId = selectedOutfit })
end)
closeButton.Activated:Connect(function()
	modalController:close(backdrop)
	backdrop.Visible = false
end)

remote.OnClientEvent:Connect(function(payload)
	if type(payload) ~= "table" or payload.kind ~= "state" then
		return
	end
	if type(payload.hairId) == "string" and hairButtons[payload.hairId] then
		selectedHair = payload.hairId
	end
	if type(payload.outfitId) == "string" and outfitButtons[payload.outfitId] then
		selectedOutfit = payload.outfitId
	end
	for id, button in outfitButtons do
		button.BackgroundColor3 = if id == selectedOutfit then UiTokens.Colors.Gold else UiTokens.Colors.PaperSoft
	end
end)

if camera then
	camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateResponsive)
end
updateResponsive()
remote:FireServer({ action = "state" })
