local UiTokens = require(script.Parent:WaitForChild("UiTokens"))

local ButtonFactory = {}

function ButtonFactory.create(parent: Instance, text: string, layoutOrder: number?): TextButton
	local button = Instance.new("TextButton")
	button.Name = "Button_" .. string.gsub(text, "%W", "")
	button.Size = UDim2.new(1, 0, 0, UiTokens.TouchTarget)
	button.AutomaticSize = Enum.AutomaticSize.None
	button.LayoutOrder = layoutOrder or 0
	button.BackgroundColor3 = UiTokens.Colors.Meadow
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = UiTokens.Colors.Paper
	button.TextSize = 16
	button.Font = UiTokens.Fonts.Strong
	button.AutoButtonColor = true
	button.Selectable = true
	button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, UiTokens.CornerRadius)
	corner.Parent = button

	local constraint = Instance.new("UISizeConstraint")
	constraint.MinSize = Vector2.new(UiTokens.TouchTarget, UiTokens.TouchTarget)
	constraint.Parent = button
	return button
end

function ButtonFactory.secondary(parent: Instance, text: string, layoutOrder: number?): TextButton
	local button = ButtonFactory.create(parent, text, layoutOrder)
	button.BackgroundColor3 = UiTokens.Colors.PaperSoft
	button.TextColor3 = UiTokens.Colors.Ink
	return button
end

return ButtonFactory
