local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))

local StarterHomeHeroInteriorBuilder = {}

local function decoration(
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
	item.TopSurface = Enum.SurfaceType.Smooth
	item.BottomSurface = Enum.SurfaceType.Smooth
	item:SetAttribute("TinyWorldArtRole", role)
	item:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	item.Parent = parent
	return item
end

local function clearInteriorCraft(container: Instance)
	local remove = {}
	for _, descendant in container:GetDescendants() do
		local name = descendant.Name
		if string.sub(name, 1, 7) == "Crafted" or name == "HomeStyleBanner" or name == "HomeRoomDivider" then
			table.insert(remove, descendant)
		end
	end
	for _, item in remove do
		if item.Parent then
			item:Destroy()
		end
	end
	local old = container:FindFirstChild("StarterHomeHeroInteriorR3")
	if old then
		old:Destroy()
	end
end

local function setPart(part: Instance?, size: Vector3, position: Vector3)
	if part and part:IsA("BasePart") then
		part.Size = size
		part.Position = position
	end
end

local function tuneFurniture(container: Instance, anchor: Vector3)
	local kitchen = container:FindFirstChild("HomeRoom_Kitchen")
	if kitchen then
		setPart(
			kitchen:FindFirstChild("HomeFurniture_DiningTable"),
			Vector3.new(3.7, 0.6, 2.5),
			anchor + Vector3.new(4.8, 2.7, -0.8)
		)
		setPart(
			kitchen:FindFirstChild("HomeFurniture_DiningChairLeft"),
			Vector3.new(1.35, 2.1, 1.35),
			anchor + Vector3.new(2.4, 2.55, -0.8)
		)
		setPart(
			kitchen:FindFirstChild("HomeFurniture_DiningChairRight"),
			Vector3.new(1.35, 2.1, 1.35),
			anchor + Vector3.new(7.2, 2.55, -0.8)
		)
		local food = kitchen:FindFirstChild("HomeFurniture_TableFood")
		if food and food:IsA("BasePart") then
			food.Position = anchor + Vector3.new(4.8, 3.4, -0.8)
		end
	end

	local living = container:FindFirstChild("HomeRoom_Living")
	if living then
		setPart(
			living:FindFirstChild("HomeFurniture_Sofa"),
			Vector3.new(5.1, 2.15, 2.15),
			anchor + Vector3.new(-4.2, 2.9, 5.5)
		)
		setPart(
			living:FindFirstChild("HomeFurniture_SofaBack"),
			Vector3.new(5.1, 2.55, 0.62),
			anchor + Vector3.new(-4.2, 4.1, 6.15)
		)
		setPart(
			living:FindFirstChild("HomeFurniture_BookToyShelf"),
			Vector3.new(3.4, 3.8, 1),
			anchor + Vector3.new(-7.1, 3.45, 1.9)
		)
	end
end

local function addWarmCeilingLight(parent: Instance, position: Vector3)
	local glass = decoration(
		parent,
		"HeroCeilingLight",
		Vector3.new(2.1, 0.38, 2.1),
		CFrame.new(position),
		VisualTheme.Colors.warmLight,
		Enum.Material.Glass,
		"home-hero-ceiling-light"
	)
	glass.Transparency = 0.2
	local light = Instance.new("PointLight")
	light.Name = "HeroWarmLight"
	light.Brightness = 0.5
	light.Range = 12
	light.Color = VisualTheme.Colors.warmLight
	light.Shadows = false
	light.Parent = glass
end

function StarterHomeHeroInteriorBuilder.apply(plot)
	local container = plot.houseContainer
	local anchor = plot.houseAnchor
	if not container or not anchor then
		return
	end

	clearInteriorCraft(container)
	tuneFurniture(container, anchor)

	local shell = container:FindFirstChild("ResidentialShell")
	local width = 18
	local depth = 16
	local height = 9
	if shell and shell:IsA("Model") then
		width = tonumber(shell:GetAttribute("TinyWorldHouseWidth")) or width
		depth = tonumber(shell:GetAttribute("TinyWorldHouseDepth")) or depth
		height = tonumber(shell:GetAttribute("TinyWorldHouseHeight")) or height
	end

	local model = Instance.new("Model")
	model.Name = "StarterHomeHeroInteriorR3"
	model:SetAttribute("TinyWorldArtRole", "starter-home-hero-interior")
	model:SetAttribute("TinyWorldInteriorLanguage", "starter-home-r3")
	model:SetAttribute("TinyWorldVisualState", "authored-native-r3")
	model.Parent = container

	decoration(
		model,
		"HeroCeiling",
		Vector3.new(width - 1.3, 0.38, depth - 1.3),
		CFrame.new(anchor + Vector3.new(0, height + 0.55, 0)),
		VisualTheme.Colors.paper,
		Enum.Material.Plaster,
		"home-hero-ceiling"
	)

	for _, x in { -4.7, 4.7 } do
		decoration(
			model,
			"HeroCeilingBeam" .. tostring(x),
			Vector3.new(0.42, 0.55, depth - 1.8),
			CFrame.new(anchor + Vector3.new(x, height + 0.25, 0)),
			VisualTheme.Colors.timberDark,
			Enum.Material.Wood,
			"home-hero-ceiling-beam"
		)
	end

	decoration(
		model,
		"KitchenZone",
		Vector3.new(7.6, 0.08, 7),
		CFrame.new(anchor + Vector3.new(4.7, 1.58, -3)),
		VisualTheme.Colors.creamDeep,
		Enum.Material.CeramicTiles,
		"home-zone-kitchen"
	)
	decoration(
		model,
		"LivingZone",
		Vector3.new(8.2, 0.08, 5.6),
		CFrame.new(anchor + Vector3.new(-2.4, 1.59, 4.6)),
		VisualTheme.Colors.warmLight,
		Enum.Material.Fabric,
		"home-zone-living"
	)
	decoration(
		model,
		"SleepZone",
		Vector3.new(7.6, 0.08, 7),
		CFrame.new(anchor + Vector3.new(-4.8, 1.58, -3)),
		VisualTheme.Colors.flower,
		Enum.Material.Fabric,
		"home-zone-sleep"
	)

	decoration(
		model,
		"HeroRug",
		Vector3.new(5.8, 0.1, 3.6),
		CFrame.new(anchor + Vector3.new(-2.6, 1.7, 4.7)),
		VisualTheme.Colors.cream,
		Enum.Material.Fabric,
		"home-hero-rug"
	)

	decoration(
		model,
		"HeroHalfWall",
		Vector3.new(0.38, 3.3, 5.1),
		CFrame.new(anchor + Vector3.new(0, 3.3, -3.3)),
		VisualTheme.Colors.cream,
		Enum.Material.Plaster,
		"home-hero-half-wall"
	)
	decoration(
		model,
		"HeroHalfWallCap",
		Vector3.new(0.72, 0.32, 5.35),
		CFrame.new(anchor + Vector3.new(0, 5.05, -3.3)),
		VisualTheme.Colors.timber,
		Enum.Material.WoodPlanks,
		"home-hero-half-wall-cap"
	)

	for index, x in { -5.6, 5.6 } do
		decoration(
			model,
			"HeroCurtain" .. index,
			Vector3.new(1.25, 4.6, 0.28),
			CFrame.new(anchor + Vector3.new(x, 5.35, (depth / 2) - 0.42)),
			if index == 1 then VisualTheme.Colors.flower else VisualTheme.Colors.skyDeep,
			Enum.Material.Fabric,
			"home-hero-curtain"
		)
	end

	for index, x in { 2.2, 5, 7.5 } do
		decoration(
			model,
			"HeroKitchenUpperCabinet" .. index,
			Vector3.new(2.1, 1.9, 0.75),
			CFrame.new(anchor + Vector3.new(x, 7.05, -(depth / 2) + 0.65)),
			if index == 2 then VisualTheme.Colors.skyDeep else VisualTheme.Colors.cream,
			Enum.Material.Wood,
			"home-hero-kitchen-cabinet"
		)
	end

	decoration(
		model,
		"HeroKitchenShelf",
		Vector3.new(6.7, 0.3, 0.9),
		CFrame.new(anchor + Vector3.new(4.7, 5.75, -(depth / 2) + 0.72)),
		VisualTheme.Colors.timber,
		Enum.Material.WoodPlanks,
		"home-hero-kitchen-shelf"
	)

	addWarmCeilingLight(model, anchor + Vector3.new(-3.8, height - 0.05, 3.7))
	addWarmCeilingLight(model, anchor + Vector3.new(4.2, height - 0.05, -3.2))

	container:SetAttribute("TinyWorldInteriorLanguage", "starter-home-r3")
end

return StarterHomeHeroInteriorBuilder
