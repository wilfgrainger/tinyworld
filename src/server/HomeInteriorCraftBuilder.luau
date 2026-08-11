local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))
local ProductionHomeVisuals = require(script.Parent:WaitForChild("ProductionHomeVisuals"))
local ProductionVisualService = require(script.Parent:WaitForChild("ProductionVisualService"))

local HomeInteriorCraftBuilder = {}
local productionVisualService = ProductionVisualService.new()

local function preserveBedsideLampInteraction(container: Instance)
	local lamp = container:FindFirstChild("HomeFurniture_BedsideLamp", true)
	if not lamp or not lamp:IsA("BasePart") then
		return
	end

	lamp:SetAttribute("TinyWorldArtRole", "home-bedside-lamp-interaction-anchor")
	lamp:SetAttribute("TinyWorldInteractionAnchor", true)
	lamp:SetAttribute("TinyWorldProductionVisualProxy", true)
	lamp.Transparency = 1
	lamp.CanCollide = false
	lamp.CanTouch = false
	lamp.CanQuery = true

	local light = lamp:FindFirstChild("CraftedWarmLight")
	if not light or not light:IsA("PointLight") then
		if light then
			light:Destroy()
		end
		light = Instance.new("PointLight")
		light.Name = "CraftedWarmLight"
		light.Parent = lamp
	end
	light.Brightness = 0.45
	light.Range = 8
	light.Color = VisualTheme.Colors.warmLight
	light.Shadows = true
	light.Enabled = false
end

function HomeInteriorCraftBuilder.apply(plot)
	local container = plot.houseContainer
	if not container or not plot.houseAnchor then
		return
	end

	preserveBedsideLampInteraction(container)
	ProductionHomeVisuals.apply(plot, nil, nil, productionVisualService)
	container:SetAttribute("TinyWorldInteriorCraft", "art-r4-production-visual-boundary")
end

return HomeInteriorCraftBuilder
