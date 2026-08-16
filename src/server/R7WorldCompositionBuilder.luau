local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))

local R7WorldCompositionBuilder = {}

local ROOT_NAME = "ART_R7_WorldComposition"

local function part(
	parent: Instance,
	name: string,
	size: Vector3,
	cframe: CFrame,
	color: Color3,
	material: Enum.Material,
	role: string
): Part
	local item = Instance.new("Part")
	item.Name = name
	item.Anchored = true
	item.Size = size
	item.CFrame = cframe
	item.Color = color
	item.Material = material
	item.CanCollide = false
	item.CanTouch = false
	item.CanQuery = false
	item.CastShadow = true
	item.TopSurface = Enum.SurfaceType.Smooth
	item.BottomSurface = Enum.SurfaceType.Smooth
	item:SetAttribute("TinyWorldR7Decorative", true)
	item:SetAttribute("TinyWorldArtRole", role)
	item.Parent = parent
	return item
end

local function ball(
	parent: Instance,
	name: string,
	position: Vector3,
	size: Vector3,
	color: Color3,
	material: Enum.Material,
	role: string
): Part
	local item = part(parent, name, size, CFrame.new(position), color, material, role)
	item.Shape = Enum.PartType.Ball
	return item
end

local function verticalCylinder(
	parent: Instance,
	name: string,
	position: Vector3,
	diameter: number,
	height: number,
	color: Color3,
	material: Enum.Material,
	role: string
): Part
	local item = part(
		parent,
		name,
		Vector3.new(height, diameter, diameter),
		CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90)),
		color,
		material,
		role
	)
	item.Shape = Enum.PartType.Cylinder
	return item
end

local function planter(parent: Instance, name: string, position: Vector3, accent: Color3, scale: number)
	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("TinyWorldArtRole", "r7-rounded-planter")
	model:SetAttribute("TinyWorldR7Decorative", true)
	model.Parent = parent

	verticalCylinder(
		model,
		"PlanterBowl",
		position + Vector3.new(0, 0.55 * scale, 0),
		5.8 * scale,
		1.1 * scale,
		VisualTheme.Colors.cream,
		Enum.Material.SmoothPlastic,
		"r7-planter-bowl"
	)
	verticalCylinder(
		model,
		"Soil",
		position + Vector3.new(0, 1.08 * scale, 0),
		4.8 * scale,
		0.24 * scale,
		VisualTheme.Colors.timberDark,
		Enum.Material.Ground,
		"r7-planter-soil"
	)

	local shrub = ball(
		model,
		"Shrub",
		position + Vector3.new(0, 2.15 * scale, 0),
		Vector3.new(4.4, 2.8, 4.4) * scale,
		VisualTheme.Colors.leafLight,
		Enum.Material.LeafyGrass,
		"r7-planter-shrub"
	)
	shrub.CastShadow = true

	for index, offset in
		{
			Vector3.new(-1.35, 3.0, 0),
			Vector3.new(1.3, 3.2, 0.2),
			Vector3.new(0, 3.35, -1.1),
			Vector3.new(0.3, 3.0, 1.2),
		}
	do
		ball(
			model,
			"Bloom" .. index,
			position + offset * scale,
			Vector3.new(0.75, 0.75, 0.75) * scale,
			if index % 2 == 0 then accent else VisualTheme.Colors.lemon,
			Enum.Material.SmoothPlastic,
			"r7-planter-bloom"
		)
	end
	return model
end

local function treeCluster(parent: Instance, name: string, position: Vector3, accent: Color3, scale: number)
	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("TinyWorldArtRole", "r7-soft-tree-cluster")
	model:SetAttribute("TinyWorldR7Decorative", true)
	model.Parent = parent

	part(
		model,
		"Trunk",
		Vector3.new(1.35, 5.8, 1.35) * scale,
		CFrame.new(position + Vector3.new(0, 2.9 * scale, 0)),
		VisualTheme.Colors.timberDark,
		Enum.Material.Wood,
		"r7-tree-trunk"
	)
	local canopyData = {
		{ Vector3.new(0, 7.2, 0), Vector3.new(5.9, 4.8, 5.9), VisualTheme.Colors.leafLight },
		{ Vector3.new(-2.15, 6.6, 0.4), Vector3.new(4.6, 4.0, 4.6), VisualTheme.Colors.leaf },
		{ Vector3.new(2.0, 6.7, -0.5), Vector3.new(4.4, 3.9, 4.4), accent },
	}
	for index, data in canopyData do
		ball(
			model,
			"Canopy" .. index,
			position + data[1] * scale,
			data[2] * scale,
			data[3],
			Enum.Material.LeafyGrass,
			"r7-tree-canopy"
		)
	end
	return model
end

local function lamp(parent: Instance, name: string, position: Vector3, accent: Color3)
	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("TinyWorldR7Decorative", true)
	model.Parent = parent

	part(
		model,
		"Post",
		Vector3.new(0.45, 5.4, 0.45),
		CFrame.new(position + Vector3.new(0, 2.7, 0)),
		VisualTheme.Colors.plum,
		Enum.Material.Metal,
		"r7-plaza-lamp-post"
	)
	local shade = verticalCylinder(
		model,
		"Shade",
		position + Vector3.new(0, 5.7, 0),
		1.75,
		0.55,
		accent,
		Enum.Material.SmoothPlastic,
		"r7-plaza-lamp-shade"
	)
	shade.CastShadow = true
	local glow = ball(
		model,
		"Glow",
		position + Vector3.new(0, 5.35, 0),
		Vector3.new(0.85, 0.85, 0.85),
		VisualTheme.Colors.warmLight,
		Enum.Material.Neon,
		"r7-plaza-lamp-glow"
	)
	local light = Instance.new("PointLight")
	light.Name = "WarmLight"
	light.Color = VisualTheme.Colors.warmLight
	light.Brightness = 0.5
	light.Range = 9
	light.Shadows = false
	light.Parent = glow
	return model
end

local function benchPocket(parent: Instance, name: string, position: Vector3, yaw: number, accent: Color3)
	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("TinyWorldR7Decorative", true)
	model.Parent = parent
	local base = CFrame.new(position) * CFrame.Angles(0, math.rad(yaw), 0)

	part(
		model,
		"Seat",
		Vector3.new(5.8, 0.45, 1.65),
		base * CFrame.new(0, 1.45, 0),
		VisualTheme.Colors.woodLight,
		Enum.Material.WoodPlanks,
		"r7-plaza-bench"
	)
	part(
		model,
		"Back",
		Vector3.new(5.8, 1.7, 0.42),
		base * CFrame.new(0, 2.25, -0.66) * CFrame.Angles(math.rad(-8), 0, 0),
		VisualTheme.Colors.woodLight,
		Enum.Material.WoodPlanks,
		"r7-plaza-bench-back"
	)
	for _, x in { -2.2, 2.2 } do
		part(
			model,
			"Leg" .. tostring(x),
			Vector3.new(0.4, 1.35, 0.4),
			base * CFrame.new(x, 0.68, 0),
			VisualTheme.Colors.plum,
			Enum.Material.Metal,
			"r7-plaza-bench-leg"
		)
	end
	ball(
		model,
		"AccentKnob",
		position + Vector3.new(0, 2.75, -0.85),
		Vector3.new(0.55, 0.55, 0.55),
		accent,
		Enum.Material.SmoothPlastic,
		"r7-plaza-bench-accent"
	)
	return model
end

local function steppingRibbon(parent: Instance, name: string, from: Vector3, to: Vector3, accent: Color3)
	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("TinyWorldR7Decorative", true)
	model.Parent = parent
	local delta = to - from
	for index = 0, 5 do
		local t = index / 5
		local position = from + delta * t
		local stone = verticalCylinder(
			model,
			"Step" .. index,
			Vector3.new(position.X, 0.16, position.Z),
			2.35 + (index % 2) * 0.35,
			0.22,
			if index % 3 == 0 then accent else VisualTheme.Colors.softStone,
			Enum.Material.SmoothPlastic,
			"r7-route-step"
		)
		stone.CFrame *= CFrame.Angles(0, math.rad(index * 11), 0)
	end
	return model
end

local function districtMarker(parent: Instance, id: string)
	local marker = Instance.new("Folder")
	marker.Name = "District_" .. id
	marker:SetAttribute("TinyWorldR7District", "district-" .. id)
	marker.Parent = parent
	return marker
end

local function buildPlaza(parent: Instance)
	local plaza = districtMarker(parent, "plaza")
	plaza:SetAttribute("TinyWorldArtRole", "r7-hero-plaza")

	for index, entry in
		{
			{ Vector3.new(-18, 0, -18), VisualTheme.Colors.pink },
			{ Vector3.new(18, 0, -18), VisualTheme.Colors.aqua },
			{ Vector3.new(-18, 0, 18), VisualTheme.Colors.lavender },
			{ Vector3.new(18, 0, 18), VisualTheme.Colors.peach },
		}
	do
		planter(plaza, "HeroPlanter" .. index, entry[1], entry[2], 1.0)
	end

	for index, entry in
		{
			{ Vector3.new(-25, 0, -7), VisualTheme.Colors.mint },
			{ Vector3.new(25, 0, -7), VisualTheme.Colors.aqua },
			{ Vector3.new(-25, 0, 25), VisualTheme.Colors.lavender },
			{ Vector3.new(25, 0, 25), VisualTheme.Colors.peach },
		}
	do
		lamp(plaza, "HeroLamp" .. index, entry[1], entry[2])
	end

	benchPocket(plaza, "SocialBenchWest", Vector3.new(-27, 0, 7), 90, VisualTheme.Colors.pink)
	benchPocket(plaza, "SocialBenchEast", Vector3.new(27, 0, 7), -90, VisualTheme.Colors.aqua)
	steppingRibbon(plaza, "MarketRibbon", Vector3.new(16, 0, -9), Vector3.new(31, 0, -26), VisualTheme.Colors.pink)
	steppingRibbon(plaza, "GardenRibbon", Vector3.new(-16, 0, 12), Vector3.new(-28, 0, 27), VisualTheme.Colors.mint)
end

local function buildHomes(parent: Instance)
	local homes = districtMarker(parent, "homes")
	for index, position in
		{
			Vector3.new(-54, 0, -52),
			Vector3.new(-76, 0, -50),
			Vector3.new(-54, 0, 55),
			Vector3.new(-76, 0, 58),
			Vector3.new(52, 0, 60),
		}
	do
		treeCluster(
			homes,
			"HomeTreeCluster" .. index,
			position,
			if index % 2 == 0 then VisualTheme.Colors.mintDeep else VisualTheme.Colors.leaf,
			0.84 + (index % 3) * 0.08
		)
	end
	planter(homes, "HomeCornerPlanterA", Vector3.new(-45, 0, -43), VisualTheme.Colors.pink, 0.78)
	planter(homes, "HomeCornerPlanterB", Vector3.new(-45, 0, 47), VisualTheme.Colors.lavender, 0.78)
end

local function buildMarket(parent: Instance)
	local market = districtMarker(parent, "market")
	planter(market, "MarketPlanterA", Vector3.new(38, 0, -43), VisualTheme.Colors.pink, 0.82)
	planter(market, "MarketPlanterB", Vector3.new(48, 0, -34), VisualTheme.Colors.peach, 0.72)
	lamp(market, "MarketLamp", Vector3.new(43, 0, -40), VisualTheme.Colors.pink)
end

local function buildGarden(parent: Instance)
	local garden = districtMarker(parent, "garden")
	planter(garden, "GardenWelcomePlanter", Vector3.new(-39, 0, 37), VisualTheme.Colors.mint, 0.9)
	treeCluster(garden, "GardenShadeTree", Vector3.new(-47, 0, 40), VisualTheme.Colors.mintDeep, 0.78)
	steppingRibbon(garden, "GardenSteps", Vector3.new(-20, 0, 18), Vector3.new(-34, 0, 33), VisualTheme.Colors.mint)
end

local function buildHarbour(parent: Instance, layout)
	local harbour = districtMarker(parent, "harbour")
	local half = if layout and layout.perimeterHalfExtent then layout.perimeterHalfExtent else 128
	local shoreX = half - 22
	for index, z in { -35, -15, 10, 35 } do
		planter(
			harbour,
			"HarbourPlanter" .. index,
			Vector3.new(shoreX - 3, 0, z),
			if index % 2 == 0 then VisualTheme.Colors.aqua else VisualTheme.Colors.lemon,
			0.68
		)
	end
	for index, z in { -42, 42 } do
		lamp(harbour, "HarbourLamp" .. index, Vector3.new(shoreX - 8, 0, z), VisualTheme.Colors.aqua)
	end
	for index, z in { -29, -2, 27 } do
		local buoy = ball(
			harbour,
			"ShoreBuoy" .. index,
			Vector3.new(half + 4, 1.15, z),
			Vector3.new(1.35, 1.35, 1.35),
			if index % 2 == 0 then VisualTheme.Colors.coral else VisualTheme.Colors.aqua,
			Enum.Material.SmoothPlastic,
			"r7-harbour-shoreline-frame"
		)
		buoy.CastShadow = false
	end
end

function R7WorldCompositionBuilder.apply(root: Instance, layout)
	local existing = root:FindFirstChild(ROOT_NAME)
	if existing then
		existing:Destroy()
	end

	local model = Instance.new("Model")
	model.Name = ROOT_NAME
	model:SetAttribute("TinyWorldArtRole", "r7-premium-world-composition")
	model:SetAttribute("TinyWorldVisualState", "authored-native-r7")
	model:SetAttribute("TinyWorldR7Decorative", true)
	model.Parent = root

	buildPlaza(model)
	buildHomes(model)
	buildMarket(model)
	buildGarden(model)
	buildHarbour(model, layout)

	return model
end

return R7WorldCompositionBuilder
