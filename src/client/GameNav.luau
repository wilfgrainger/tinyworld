local Players = game:GetService("Players")

local UiTokens = require(script.Parent:WaitForChild("UiTokens"))

local GameNav = {}

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local existing = playerGui:FindFirstChild("TinyWorldGameNav")
if existing then
	existing:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "TinyWorldGameNav"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = UiTokens.HudDisplayOrder + 2
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "GameNav"
frame.AnchorPoint = Vector2.new(1, 1)
frame.Position = UDim2.new(1, -12, 1, -14)
frame.Size = UDim2.fromOffset(236, UiTokens.TouchTarget + 8)
frame.BackgroundColor3 = UiTokens.Colors.Paper
frame.BackgroundTransparency = 0.06
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, UiTokens.CornerRadius + 2)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = UiTokens.Colors.InkSoft
stroke.Transparency = 0.78
stroke.Thickness = 1
stroke.Parent = frame

local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 6)
padding.PaddingRight = UDim.new(0, 6)
padding.PaddingTop = UDim.new(0, 4)
padding.PaddingBottom = UDim.new(0, 4)
padding.Parent = frame

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Horizontal
layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = frame

local buttons = {}
local connections = {}

function GameNav.register(id: string, label: string, order: number, callback: () -> ())
	local button = buttons[id]
	if button == nil then
		button = Instance.new("TextButton")
		button.Name = id .. "NavButton"
		button.Size = UDim2.fromOffset(68, UiTokens.TouchTarget)
		button.BackgroundColor3 = UiTokens.Colors.PaperSoft
		button.BorderSizePixel = 0
		button.TextColor3 = UiTokens.Colors.Ink
		button.TextSize = 14
		button.Font = UiTokens.Fonts.Strong
		button.Selectable = true
		button.Parent = frame
		local buttonCorner = Instance.new("UICorner")
		buttonCorner.CornerRadius = UDim.new(0, UiTokens.CornerRadius)
		buttonCorner.Parent = button
		buttons[id] = button
	end

	button.Text = label
	button.LayoutOrder = order
	local previous = connections[id]
	if previous then
		previous:Disconnect()
	end
	connections[id] = button.Activated:Connect(callback)
	return button
end

function GameNav.setVisible(visible: boolean)
	frame.Visible = visible
end

return GameNav
