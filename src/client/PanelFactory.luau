local UiTokens = require(script.Parent:WaitForChild("UiTokens"))

local PanelFactory = {}

function PanelFactory.create(parent: Instance, name: string): Frame
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.BackgroundColor3 = UiTokens.Colors.Paper
	frame.BorderSizePixel = 0
	frame.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, UiTokens.CornerRadius + 4)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Color = UiTokens.Colors.InkSoft
	stroke.Transparency = 0.75
	stroke.Thickness = 1
	stroke.Parent = frame

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, UiTokens.PanelPadding)
	padding.PaddingRight = UDim.new(0, UiTokens.PanelPadding)
	padding.PaddingTop = UDim.new(0, UiTokens.PanelPadding)
	padding.PaddingBottom = UDim.new(0, UiTokens.PanelPadding)
	padding.Parent = frame
	return frame
end

function PanelFactory.verticalLayout(parent: Instance, paddingPixels: number?): UIListLayout
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Top
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, paddingPixels or UiTokens.Gap)
	layout.Parent = parent
	return layout
end

return PanelFactory
