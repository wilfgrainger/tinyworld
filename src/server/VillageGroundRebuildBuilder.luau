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
	item.Size = Vector3.new(size.X, 0.04, size.Y)
	item.CFrame = CFrame.new(position.X, 0.01, position.Z) * CFrame.Angles(0, math.rad(yaw), 0)
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

local function addDistrict(
	parent: Instance,
	name: string,
	center: Vector3,
	primary: Color3,
	secondary: Color3,
	accentMaterial: Enum.Material
)
	local model = Instance.new("Model")
	model.Name = name .. "GroundComposition"
	model:SetAttribute("TinyWorldArtRole", "district-ground-composition")
	model:SetAttribute("TinyWorldNeighbourhood", name)
	model.Parent = parent

	patch(
		model,
		"FieldA",
		center + Vector3.new(-13, 0, -8),
		Vector2.new(58, 46),
		-8,
		primary,
		Enum.Material.Grass,
		"district-lawn"
	)
	patch(
		model,
		"FieldB",
		center + Vector3.new(16, 0, 11),
		Vector2.new(48, 36),
		11,
		secondary,
		Enum.Material.Grass,
		"district-lawn-secondary"
	)
	patch(
		model,
		"FieldC",
		center + Vector3.new(-2, 0, 29),
		Vector2.new(35, 19),
		-15,
		primary,
		accentMaterial,
		"district-ground-accent"
	)
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
end

local function addCivicGround(parent: Instance)
	local model = Instance.new("Model")
	model.Name = "CivicGroundComposition"
	model:SetAttribute("TinyWorldArtRole", "civic-ground-composition")
	model.Parent = parent

	patch(
		model,
		"CivicGreenWest",
		Vector3.new(-28, 0, 2),
		Vector2.new(32, 24),
		-8,
		VisualTheme.Colors.meadowDeep,
		Enum.Material.Grass,
		"civic-pocket-green"
	)
	patch(
		model,
		"CivicGreenEast",
		Vector3.new(28, 0, 2),
		Vector2.new(32, 24),
		8,
		VisualTheme.Colors.leafLight,
		Enum.Material.Grass,
		"civic-pocket-green"
	)
	patch(
		model,
		"CivicGardenNorth",
		Vector3.new(0, 0, -28),
		Vector2.new(45, 13),
		0,
		VisualTheme.Colors.meadowDeep,
		Enum.Material.Grass,
		"civic-planted-verge"
	)
	patch(
		model,
		"CivicGardenSouth",
		Vector3.new(0, 0, 30),
		Vector2.new(46, 14),
		0,
		VisualTheme.Colors.leaf,
		Enum.Material.Grass,
		"civic-planted-verge"
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
		patch(
			model,
			"WestVerge" .. index,
			Vector3.new(-39, 0, z),
			Vector2.new(17, 7),
			if index % 2 == 0 then -7 else 7,
			if index % 2 == 0 then VisualTheme.Colors.meadowDeep else VisualTheme.Colors.leaf,
			Enum.Material.Grass,
			"route-verge"
		)
		patch(
			model,
			"EastVerge" .. index,
			Vector3.new(39, 0, z),
			Vector2.new(17, 7),
			if index % 2 == 0 then 7 else -7,
			if index % 2 == 0 then VisualTheme.Colors.leaf else VisualTheme.Colors.meadowDeep,
			Enum.Material.Grass,
			"route-verge"
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
		villageGround:SetAttribute("TinyWorldVisualRole", "fallback-ground-only")
	end

	local composition = Instance.new("Model")
	composition.Name = "FinalGroundComposition"
	composition:SetAttribute("TinyWorldArtRole", "final-village-ground-composition")
	composition:SetAttribute("TinyWorldVisualState", "authored-native")
	composition.Parent = root

	addCivicGround(composition)
	addDistrict(
		composition,
		"MeadowLane",
		Vector3.new(-66, 0, -66),
		VisualTheme.Colors.leafLight,
		VisualTheme.Colors.meadow,
		Enum.Material.Grass
	)
	addDistrict(
		composition,
		"HarbourRow",
		Vector3.new(66, 0, -66),
		VisualTheme.Colors.meadowDeep,
		VisualTheme.Colors.leafLight,
		Enum.Material.Ground
	)
	addDistrict(
		composition,
		"WoodlandRise",
		Vector3.new(-66, 0, 66),
		VisualTheme.Colors.leaf,
		VisualTheme.Colors.meadowDeep,
		Enum.Material.Ground
	)
	addDistrict(
		composition,
		"OrchardEnd",
		Vector3.new(66, 0, 66),
		VisualTheme.Colors.leafLight,
		VisualTheme.Colors.meadow,
		Enum.Material.Ground
	)
	addRouteVerges(composition)
end

return VillageGroundRebuildBuilder
