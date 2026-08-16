local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))

local VillageGroundRebuildBuilder = {}

local function patch(
	parent: Instance,
	name: string,
	position: Vector3,
	size: Vector2,
	yaw: number,
	color: Color3,
	material: Enum.Material,
	role: string
): Part
	local item = Instance.new("Part")
	item.Name = name
	item.Anchored = true
	item.Size = Vector3.new(size.X, 0.12, size.Y)
	item.CFrame = CFrame.new(position.X, 0.06, position.Z) * CFrame.Angles(0, math.rad(yaw), 0)
	item.Color = color
	item.Material = material
	item.CanCollide = false
	item.CanTouch = false
	item.CanQuery = false
	item.TopSurface = Enum.SurfaceType.Smooth
	item.BottomSurface = Enum.SurfaceType.Smooth
	item:SetAttribute("TinyWorldArtRole", role)
	item:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	item:SetAttribute("TinyWorldGroundLayer", true)
	item.Parent = parent
	return item
end

local function addDistrict(parent: Instance, name: string, center: Vector3, accent: Color3)
	local model = Instance.new("Model")
	model.Name = name .. "GroundComposition"
	model:SetAttribute("TinyWorldArtRole", "district-ground-composition")
	model:SetAttribute("TinyWorldNeighbourhood", name)
	model.Parent = parent

	patch(
		model,
		"GardenEdgeA",
		center + Vector3.new(-29, 0, 13),
		Vector2.new(23, 8),
		18,
		VisualTheme.Colors.timberDark,
		Enum.Material.Ground,
		"district-garden-soil"
	)
	patch(
		model,
		"GardenEdgeB",
		center + Vector3.new(29, 0, -16),
		Vector2.new(19, 7),
		-12,
		VisualTheme.Colors.timberDark,
		Enum.Material.Ground,
		"district-garden-soil"
	)
	patch(
		model,
		"DistrictAccent",
		center + Vector3.new(-2, 0, 29),
		Vector2.new(35, 7),
		-15,
		accent,
		Enum.Material.Cobblestone,
		"district-ground-accent"
	)
end

local function addCivicGround(parent: Instance)
	local model = Instance.new("Model")
	model.Name = "CivicGroundComposition"
	model:SetAttribute("TinyWorldArtRole", "civic-ground-composition")
	model.Parent = parent

	patch(
		model,
		"CivicGardenNorth",
		Vector3.new(0, 0, -28),
		Vector2.new(45, 9),
		0,
		VisualTheme.Colors.timberDark,
		Enum.Material.Ground,
		"civic-planted-bed"
	)
	patch(
		model,
		"CivicGardenSouth",
		Vector3.new(0, 0, 30),
		Vector2.new(46, 9),
		0,
		VisualTheme.Colors.timberDark,
		Enum.Material.Ground,
		"civic-planted-bed"
	)
	patch(
		model,
		"CivicStoneWest",
		Vector3.new(-17, 0, 16),
		Vector2.new(17, 11),
		-12,
		VisualTheme.Colors.pathLight,
		Enum.Material.Cobblestone,
		"civic-forecourt"
	)
	patch(
		model,
		"CivicStoneEast",
		Vector3.new(17, 0, 16),
		Vector2.new(17, 11),
		12,
		VisualTheme.Colors.pathLight,
		Enum.Material.Cobblestone,
		"civic-forecourt"
	)
end

local function addRouteVerges(parent: Instance)
	local model = Instance.new("Model")
	model.Name = "RouteVergeComposition"
	model:SetAttribute("TinyWorldArtRole", "route-verge-composition")
	model.Parent = parent

	for index, z in { -92, -58, -24, 24, 58, 92 } do
		local material = if index % 2 == 0 then Enum.Material.Ground else Enum.Material.Cobblestone
		local color = if index % 2 == 0 then VisualTheme.Colors.timberDark else VisualTheme.Colors.pathEdge
		patch(
			model,
			"WestVerge" .. index,
			Vector3.new(-39, 0, z),
			Vector2.new(17, 4),
			if index % 2 == 0 then -7 else 7,
			color,
			material,
			"route-verge-accent"
		)
		patch(
			model,
			"EastVerge" .. index,
			Vector3.new(39, 0, z),
			Vector2.new(17, 4),
			if index % 2 == 0 then 7 else -7,
			color,
			material,
			"route-verge-accent"
		)
	end
end

function VillageGroundRebuildBuilder.apply(root: Instance)
	local old = root:FindFirstChild("FinalGroundComposition")
	if old then
		old:Destroy()
	end

	local villageGround = root:FindFirstChild("VillageGround")
	if villageGround and villageGround:IsA("BasePart") then
		villageGround.Color = VisualTheme.Colors.meadowDeep
		villageGround.Material = Enum.Material.Grass
		villageGround:SetAttribute("TinyWorldVisualRole", "single-walkable-lawn")
	end

	local composition = Instance.new("Model")
	composition.Name = "FinalGroundComposition"
	composition:SetAttribute("TinyWorldArtRole", "final-village-ground-composition")
	composition:SetAttribute("TinyWorldVisualState", "authored-native-r6")
	composition.Parent = root

	addCivicGround(composition)
	addDistrict(composition, "MeadowLane", Vector3.new(-66, 0, -66), VisualTheme.Colors.pathLight)
	addDistrict(composition, "HarbourRow", Vector3.new(66, 0, -66), VisualTheme.Colors.skyDeep)
	addDistrict(composition, "WoodlandRise", Vector3.new(-66, 0, 66), VisualTheme.Colors.timber)
	addDistrict(composition, "OrchardEnd", Vector3.new(66, 0, 66), VisualTheme.Colors.warmLight)
	addRouteVerges(composition)
end

return VillageGroundRebuildBuilder
