local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local tinyWorld = ReplicatedStorage:WaitForChild("TinyWorld")
local shared = tinyWorld:WaitForChild("Shared")
local FurnitureDefinitions = require(shared:WaitForChild("FurnitureDefinitions"))
local FurniturePlacementRules = require(shared:WaitForChild("FurniturePlacementRules"))
local UiTokens = require(script.Parent:WaitForChild("UiTokens"))
local UiScaleRules = require(script.Parent:WaitForChild("UiScaleRules"))
local ButtonFactory = require(script.Parent:WaitForChild("ButtonFactory"))
local PanelFactory = require(script.Parent:WaitForChild("PanelFactory"))
local ModalController = require(script.Parent:WaitForChild("ModalController"))
local FocusController = require(script.Parent:WaitForChild("FocusController"))

local storeRemote = tinyWorld:WaitForChild("HomeStoreRemote") :: RemoteEvent
local placementRemote = tinyWorld:WaitForChild("FurniturePlacementRemote") :: RemoteEvent
local camera = Workspace.CurrentCamera
local modalController = ModalController.new()
local ownedFurniture = {}
local furniturePlacements = {}
local currentCategory = "living"
local placementDefinition = nil
local placementRotation = 0
local placementPoint = nil
local placementValid = false
local previewPart = nil

local gui = Instance.new("ScreenGui")
gui.Name = "TinyWorldHomeLife"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = UiTokens.ModalDisplayOrder
gui.Parent = playerGui

local homeButton = Instance.new("TextButton")
homeButton.Name = "HomeLifeButton"
homeButton.AnchorPoint = Vector2.new(1, 1)
homeButton.Position = UDim2.new(1, -16, 1, -18)
homeButton.Size = UDim2.fromOffset(112, UiTokens.TouchTarget)
homeButton.BackgroundColor3 = UiTokens.Colors.Meadow
homeButton.BorderSizePixel = 0
homeButton.Text = "My Home"
homeButton.TextColor3 = UiTokens.Colors.Paper
homeButton.TextSize = 16
homeButton.Font = UiTokens.Fonts.Strong
homeButton.Selectable = true
homeButton.Parent = gui
local homeCorner = Instance.new("UICorner")
homeCorner.CornerRadius = UDim.new(0, UiTokens.CornerRadius)
homeCorner.Parent = homeButton

local backdrop = Instance.new("Frame")
backdrop.Name = "HomeLifeBackdrop"
backdrop.Size = UDim2.fromScale(1, 1)
backdrop.BackgroundColor3 = Color3.new(0, 0, 0)
backdrop.BackgroundTransparency = 0.45
backdrop.Visible = false
backdrop.Active = true
backdrop.Parent = gui

local panel = PanelFactory.create(backdrop, "HomeLifePanel")
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)

local title = Instance.new("TextLabel")
title.LayoutOrder = 1
title.Size = UDim2.new(1, 0, 0, 36)
title.BackgroundTransparency = 1
title.Text = "My Home"
title.TextColor3 = UiTokens.Colors.Ink
title.TextSize = 24
title.Font = UiTokens.Fonts.Title
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local subtitle = Instance.new("TextLabel")
subtitle.LayoutOrder = 2
subtitle.Size = UDim2.new(1, 0, 0, 38)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Buy useful things, then place them physically in your home."
subtitle.TextColor3 = UiTokens.Colors.InkSoft
subtitle.TextSize = 14
subtitle.TextWrapped = true
subtitle.Font = UiTokens.Fonts.Body
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = panel

local categoryScroll = Instance.new("ScrollingFrame")
categoryScroll.LayoutOrder = 3
categoryScroll.Size = UDim2.new(1, 0, 0, UiTokens.TouchTarget + 8)
categoryScroll.BackgroundTransparency = 1
categoryScroll.BorderSizePixel = 0
categoryScroll.ScrollBarThickness = 4
categoryScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
categoryScroll.CanvasSize = UDim2.new()
categoryScroll.ScrollingDirection = Enum.ScrollingDirection.X
categoryScroll.Parent = panel
local categoryLayout = Instance.new("UIListLayout")
categoryLayout.FillDirection = Enum.FillDirection.Horizontal
categoryLayout.Padding = UDim.new(0, 8)
categoryLayout.SortOrder = Enum.SortOrder.LayoutOrder
categoryLayout.Parent = categoryScroll

local itemScroll = Instance.new("ScrollingFrame")
itemScroll.LayoutOrder = 4
itemScroll.Size = UDim2.new(1, 0, 1, -190)
itemScroll.BackgroundTransparency = 1
itemScroll.BorderSizePixel = 0
itemScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
itemScroll.CanvasSize = UDim2.new()
itemScroll.ScrollBarThickness = 6
itemScroll.Parent = panel
local grid = Instance.new("UIGridLayout")
grid.CellPadding = UDim2.fromOffset(10, 10)
grid.SortOrder = Enum.SortOrder.LayoutOrder
grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
grid.Parent = itemScroll

local closeButton = ButtonFactory.secondary(panel, "Close", 5)
closeButton.Size = UDim2.new(1, 0, 0, UiTokens.TouchTarget)

local placementBar = PanelFactory.create(gui, "PlacementBar")
placementBar.AnchorPoint = Vector2.new(0.5, 1)
placementBar.Position = UDim2.new(0.5, 0, 1, -18)
placementBar.Size = UDim2.new(0.92, 0, 0, 82)
placementBar.Visible = false
local placementLayout = Instance.new("UIListLayout")
placementLayout.FillDirection = Enum.FillDirection.Horizontal
placementLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
placementLayout.VerticalAlignment = Enum.VerticalAlignment.Center
placementLayout.Padding = UDim.new(0, 8)
placementLayout.Parent = placementBar
local rotateButton = ButtonFactory.secondary(placementBar, "Rotate")
rotateButton.Size = UDim2.new(0.3, 0, 0, UiTokens.TouchTarget)
local confirmButton = ButtonFactory.create(placementBar, "Place")
confirmButton.Size = UDim2.new(0.3, 0, 0, UiTokens.TouchTarget)
local cancelButton = ButtonFactory.secondary(placementBar, "Cancel")
cancelButton.Size = UDim2.new(0.3, 0, 0, UiTokens.TouchTarget)

local function viewportSize(): Vector2
	return if camera then camera.ViewportSize else Vector2.new(1280, 720)
end

local function updateResponsive()
	local viewport = viewportSize()
	panel.Size = UiScaleRules.modalSize(viewport)
	local columns = UiScaleRules.columns(viewport)
	grid.FillDirectionMaxCells = columns
	grid.CellSize = UDim2.new(1 / columns, -10, 0, if UiScaleRules.classify(viewport) == "phone" then 92 else 104)
end

local categories = { "living", "bedroom", "kitchen", "bathroom", "storage", "garden", "decoration", "lighting" }
local categoryButtons = {}
local itemButtons = {}

local function refreshItems()
	for _, child in itemScroll:GetChildren() do
		if child:IsA("GuiButton") then
			child:Destroy()
		end
	end
	table.clear(itemButtons)
	local index = 0
	for _, definition in FurnitureDefinitions.byCategory(currentCategory) do
		index += 1
		local owned = ownedFurniture[definition.id] or 0
		local button = Instance.new("TextButton")
		button.Name = "Furniture_" .. definition.id
		button.LayoutOrder = index
		button.BackgroundColor3 = if owned > 0 then UiTokens.Colors.PaperSoft else UiTokens.Colors.Paper
		button.BorderSizePixel = 0
		button.Text = string.format(
			"%s\n%s\n%d coins",
			definition.displayName,
			if owned > 0 then "Owned x" .. tostring(owned) .. " • tap to place" else "Buy",
			definition.price
		)
		button.TextColor3 = UiTokens.Colors.Ink
		button.TextSize = 13
		button.TextWrapped = true
		button.Font = UiTokens.Fonts.Strong
		button.Selectable = true
		button.Parent = itemScroll
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 10)
		corner.Parent = button
		button.Activated:Connect(function()
			if (ownedFurniture[definition.id] or 0) > 0 then
				placementDefinition = definition
				placementRotation = 0
				placementValid = false
				modalController:close(backdrop)
				backdrop.Visible = false
				placementBar.Visible = true
				homeButton.Visible = false
			else
				storeRemote:FireServer({ action = "purchase", furnitureId = definition.id })
			end
		end)
		table.insert(itemButtons, button)
	end
	FocusController.grid(itemButtons, UiScaleRules.columns(viewportSize()))
end

for index, category in categories do
	local button = ButtonFactory.secondary(
		categoryScroll,
		string.upper(string.sub(category, 1, 1)) .. string.sub(category, 2),
		index
	)
	button.Size = UDim2.fromOffset(116, UiTokens.TouchTarget)
	button.Activated:Connect(function()
		currentCategory = category
		refreshItems()
	end)
	table.insert(categoryButtons, button)
end
FocusController.chain(categoryButtons)

local function openHome()
	storeRemote:FireServer({ action = "state" })
	refreshItems()
	backdrop.Visible = true
	modalController:open(backdrop, itemButtons[1] or closeButton)
end

local function updateConfirmState(valid: boolean)
	placementValid = valid
	confirmButton.Active = valid
	confirmButton.Selectable = valid
	confirmButton.AutoButtonColor = valid
	confirmButton.Text = if valid then "Place" else "Can't place"
	confirmButton.BackgroundColor3 = if valid then UiTokens.Colors.Meadow else UiTokens.Colors.Danger
	if previewPart then
		previewPart.Color = if valid then UiTokens.Colors.GhostValid else UiTokens.Colors.GhostInvalid
	end
end

local function removePreview()
	if previewPart then
		previewPart:Destroy()
		previewPart = nil
	end
	placementDefinition = nil
	placementPoint = nil
	placementValid = false
	placementBar.Visible = false
	homeButton.Visible = true
	ContextActionService:UnbindAction("TinyWorldRotateFurniture")
	ContextActionService:UnbindAction("TinyWorldConfirmFurniture")
	ContextActionService:UnbindAction("TinyWorldCancelFurniture")
end

local function ensurePreview()
	if previewPart or not placementDefinition then
		return
	end
	previewPart = Instance.new("Part")
	previewPart.Name = "TinyWorldFurniturePreview"
	previewPart.Size = Vector3.new(placementDefinition.footprintX, 0.35, placementDefinition.footprintZ)
	previewPart.Anchored = true
	previewPart.CanCollide = false
	previewPart.CanTouch = false
	previewPart.CanQuery = false
	previewPart.Material = Enum.Material.ForceField
	previewPart.Transparency = 0.45
	previewPart.Color = UiTokens.Colors.GhostInvalid
	previewPart.Parent = Workspace
end

local function rotatePlacement()
	if placementDefinition then
		placementRotation = (placementRotation + 90) % 360
		updateConfirmState(false)
	end
end

local function confirmPlacement()
	if placementDefinition and placementPoint and placementValid then
		placementRemote:FireServer({
			action = "place",
			furnitureId = placementDefinition.id,
			worldX = placementPoint.X,
			worldY = placementPoint.Y,
			worldZ = placementPoint.Z,
			rotation = placementRotation,
		})
	end
end

homeButton.Activated:Connect(openHome)
closeButton.Activated:Connect(function()
	modalController:close(backdrop)
	backdrop.Visible = false
end)
rotateButton.Activated:Connect(rotatePlacement)
confirmButton.Activated:Connect(confirmPlacement)
cancelButton.Activated:Connect(removePreview)

ContextActionService:BindActionAtPriority("TinyWorldOpenHome", function(_, state)
	if state == Enum.UserInputState.Begin and not placementDefinition then
		openHome()
	end
	return Enum.ContextActionResult.Sink
end, false, 2000, Enum.KeyCode.ButtonY)

local function bindPlacementActions()
	ContextActionService:BindAction("TinyWorldRotateFurniture", function(_, state)
		if state == Enum.UserInputState.Begin then
			rotatePlacement()
		end
		return Enum.ContextActionResult.Sink
	end, false, Enum.KeyCode.R, Enum.KeyCode.ButtonX)
	ContextActionService:BindAction("TinyWorldConfirmFurniture", function(_, state)
		if state == Enum.UserInputState.Begin then
			confirmPlacement()
		end
		return Enum.ContextActionResult.Sink
	end, false, Enum.KeyCode.Return, Enum.KeyCode.ButtonA)
	ContextActionService:BindAction("TinyWorldCancelFurniture", function(_, state)
		if state == Enum.UserInputState.Begin then
			removePreview()
		end
		return Enum.ContextActionResult.Sink
	end, false, Enum.KeyCode.Escape, Enum.KeyCode.ButtonB)
end

local function previewRequest(worldPoint: Vector3)
	if not placementDefinition then
		return nil
	end
	local homeCFrame = player:GetAttribute("TinyWorldHomePlacementCFrame")
	if typeof(homeCFrame) ~= "CFrame" then
		return nil
	end
	local localPoint = homeCFrame:PointToObjectSpace(worldPoint)
	return {
		x = localPoint.X,
		y = localPoint.Y,
		z = localPoint.Z,
		rotation = placementRotation,
	}
end

local function validatePreview(worldPoint: Vector3): boolean
	if not placementDefinition then
		return false
	end
	local request = previewRequest(worldPoint)
	if request == nil then
		return false
	end
	local valid = FurniturePlacementRules.validate({
		ownedFurniture = ownedFurniture,
		furniturePlacements = furniturePlacements,
	}, placementDefinition.id, request)
	return valid == true
end

local wasPlacing = false
RunService.RenderStepped:Connect(function()
	if not placementDefinition then
		wasPlacing = false
		return
	end
	if not wasPlacing then
		wasPlacing = true
		bindPlacementActions()
	end
	ensurePreview()
	if camera == nil then
		updateConfirmState(false)
		return
	end
	local viewport = camera.ViewportSize
	local pointer = if UserInputService.MouseEnabled or UserInputService.TouchEnabled
		then UserInputService:GetMouseLocation()
		else Vector2.new(viewport.X / 2, viewport.Y / 2)
	local ray = camera:ViewportPointToRay(pointer.X, pointer.Y)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local character = player.Character
	params.FilterDescendantsInstances = if character then { character, previewPart } else { previewPart }
	local hit = Workspace:Raycast(ray.Origin, ray.Direction * 250, params)
	if hit then
		placementPoint = hit.Position
		previewPart.CFrame = CFrame.new(hit.Position + Vector3.new(0, 0.2, 0))
			* CFrame.Angles(0, math.rad(placementRotation), 0)
		updateConfirmState(validatePreview(hit.Position))
	else
		placementPoint = nil
		updateConfirmState(false)
	end
end)

storeRemote.OnClientEvent:Connect(function(payload)
	if type(payload) ~= "table" then
		return
	end
	if payload.kind == "state" and type(payload.ownedFurniture) == "table" then
		ownedFurniture = payload.ownedFurniture
		furniturePlacements = if type(payload.furniturePlacements) == "table" then payload.furniturePlacements else {}
		refreshItems()
	elseif payload.kind == "result" and payload.ok == false then
		local reason = tostring(payload.reason or "purchase_failed")
		player:SetAttribute("TinyWorldHomeUiMessage", reason)
	end
end)

placementRemote.OnClientEvent:Connect(function(payload)
	if type(payload) ~= "table" then
		return
	end
	if payload.ok == true and payload.reason == "placed" then
		removePreview()
		storeRemote:FireServer({ action = "state" })
	elseif payload.ok == false then
		updateConfirmState(false)
		player:SetAttribute("TinyWorldHomeUiMessage", tostring(payload.reason or "placement_failed"))
	end
end)

if camera then
	camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateResponsive)
end
updateResponsive()
storeRemote:FireServer({ action = "state" })
