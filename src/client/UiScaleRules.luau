local UiScaleRules = {}

function UiScaleRules.classify(viewport: Vector2): string
	if viewport.X < 600 then
		return "phone"
	elseif viewport.Y > viewport.X then
		return "portrait"
	elseif viewport.X < 1100 then
		return "tablet"
	end
	return "desktop"
end

function UiScaleRules.modalSize(viewport: Vector2): UDim2
	local class = UiScaleRules.classify(viewport)
	if class == "phone" then
		return UDim2.fromScale(0.94, 0.84)
	elseif class == "portrait" then
		return UDim2.fromScale(0.82, 0.72)
	elseif class == "tablet" then
		return UDim2.fromScale(0.68, 0.68)
	end
	return UDim2.fromScale(0.52, 0.68)
end

function UiScaleRules.columns(viewport: Vector2): number
	local class = UiScaleRules.classify(viewport)
	if class == "phone" then
		return 2
	elseif class == "portrait" or class == "tablet" then
		return 3
	end
	return 4
end

return UiScaleRules
