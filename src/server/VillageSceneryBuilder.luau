local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))

local VillageSceneryBuilder = {}

local function makePart(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Size = size
	part.Position = position
	part.Color = color
	part.Material = material
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function makeSurface(parent: Instance, name: string, size: Vector3, x: number, z: number, topY: number, color: Color3, material: Enum.Material): Part
	local part = makePart(parent, name, size, Vector3.new(x, topY - (size.Y / 2), z), color, material)
	return part
end

local function makeDecoration(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material): Part
	local part = makePart(parent, name, size, position, color, material)
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	return part
end

local function makeDecorationAtTop(parent: Instance, name: string, size: Vector3, x: number, z: number, topY: number, color: Color3, material: Enum.Material): Part
	return makeDecoration(parent, name, size, Vector3.new(x, topY - (size.Y / 2), z), color, material)
end

local function makeLantern(parent: Instance, name: string, x: number, z: number)
	makeDecorationAtTop(parent, name .. "Post", Vector3.new(0.6, 5, 0.6), x, z, 5, VisualTheme.Colors.timberDark, Enum.Material.Wood)
	local lamp = makeDecoration(parent, name .. "Lamp", Vector3.new(2, 2, 2), Vector3.new(x, 5.8, z), VisualTheme.Colors.gold, Enum.Material.Neon)
	lamp.Shape = Enum.PartType.Ball
	lamp.Transparency = 0.05
end

local function makeFlowerPatch(parent: Instance, name: string, x: number, z: number, color: Color3)
	for index, offset in {
		{ x = -2, z = 0 },
		{ x = 0, z = 2 },
		{ x = 2, z = -1 },
	} do
		makeDecorationAtTop(parent, name .. "Stem" .. index, Vector3.new(0.3, 1.2, 0.3), x + offset.x, z + offset.z, 1.2, VisualTheme.Colors.leaf, Enum.Material.Grass)
		local bloom = makeDecoration(parent, name .. "Bloom" .. index, Vector3.new(1.4, 1.4, 1.4), Vector3.new(x + offset.x, 1.7, z + offset.z), color, Enum.Material.SmoothPlastic)
		bloom.Shape = Enum.PartType.Ball
	end
end

local function makeBench(parent: Instance, name: string, x: number, z: number, rotation: number)
	local seat = makeDecoration(parent, name .. "Seat", Vector3.new(8, 0.8, 2), Vector3.new(x, 1.1, z), VisualTheme.Colors.timber, Enum.Material.WoodPlanks)
	seat.Orientation = Vector3.new(0, rotation, 0)
	local back = makeDecoration(parent, name .. "Back", Vector3.new(8, 2.2, 0.6), Vector3.new(x, 2.2, z), VisualTheme.Colors.timberDark, Enum.Material.Wood)
	back.Orientation = Vector3.new(0, rotation, 0)
end

local function makeMarketStall(parent: Instance, name: string, x: number, z: number, color: Color3)
	makeDecoration(parent, name .. "Counter", Vector3.new(10, 2, 6), Vector3.new(x, 1.2, z), VisualTheme.Colors.timber, Enum.Material.WoodPlanks)
	makeDecoration(parent, name .. "Awning", Vector3.new(12, 1, 8), Vector3.new(x, 6, z), color, Enum.Material.Fabric)
	for side, offset in { { name = "Left", value = -4 }, { name = "Right", value = 4 } } do
		makeDecoration(parent, name .. side .. "Post", Vector3.new(0.6, 5, 0.6), Vector3.new(x + offset.value, 3.5, z), VisualTheme.Colors.timberDark, Enum.Material.Wood)
	end
end

local function makePlanter(parent: Instance, name: string, x: number, z: number, color: Color3)
	makeDecorationAtTop(parent, name .. "Box", Vector3.new(5, 1, 3.4), x, z, 1.1, VisualTheme.Colors.woodLight, Enum.Material.WoodPlanks)
	makeDecorationAtTop(parent, name .. "Soil", Vector3.new(4.1, 0.22, 2.5), x, z, 1.68, VisualTheme.Colors.timberDark, Enum.Material.Ground)
	for index, offset in {
		{ x = -1.3, z = 0 },
		{ x = 0, z = 0.45 },
		{ x = 1.3, z = -0.2 },
	} do
		makeDecorationAtTop(parent, name .. "Leaf" .. index, Vector3.new(0.45, 1.1, 0.45), x + offset.x, z + offset.z, 2.65, VisualTheme.Colors.leafLight, Enum.Material.LeafyGrass)
		local bloom = makeDecoration(parent, name .. "Bloom" .. index, Vector3.new(0.9, 0.9, 0.9), Vector3.new(x + offset.x, 3.1, z + offset.z), color, Enum.Material.SmoothPlastic)
		bloom.Shape = Enum.PartType.Ball
	end
end

local function makeMarketBanner(parent: Instance, name: string, x: number, z: number, color: Color3)
	makeDecoration(parent, name .. "LeftPost", Vector3.new(0.4, 4.5, 0.4), Vector3.new(x - 3, 2.5, z), VisualTheme.Colors.timberDark, Enum.Material.Wood)
	makeDecoration(parent, name .. "RightPost", Vector3.new(0.4, 4.5, 0.4), Vector3.new(x + 3, 2.5, z), VisualTheme.Colors.timberDark, Enum.Material.Wood)
	local banner = makeDecoration(parent, name, Vector3.new(5.4, 2.3, 0.25), Vector3.new(x, 3.6, z), color, Enum.Material.Fabric)
	banner.Orientation = Vector3.new(0, 0, 3)
end

local function makePavingInset(parent: Instance, name: string, size: Vector3, x: number, z: number, topY: number)
	makeDecoration(parent, name, size, Vector3.new(x, topY + (size.Y / 2) + 0.04, z), VisualTheme.Colors.pathLight, Enum.Material.Cobblestone)
end

local function makeStreetCluster(parent: Instance, name: string, x: number, z: number, color: Color3)
	makePavingInset(parent, name .. "Inset", Vector3.new(10, 0.08, 8), x, z, 0.12)
	makePlanter(parent, "VillagePlanter" .. name, x - 3, z, color)
	makeMarketBanner(parent, "MarketBanner" .. name, x + 3, z, color)
end

local function makeKerb(parent: Instance, name: string, size: Vector3, x: number, z: number)
	makeDecorationAtTop(parent, name, size, x, z, 0.3, VisualTheme.Colors.pathEdge, Enum.Material.Cobblestone)
end

function VillageSceneryBuilder.build(parent: Instance, layout: any)
	local roads = {}
	local civic = {}
	local roadTop = 0.12
	local squareTop = 0.08
	local laneWidth = layout.roads.laneWidth
	local squareSide = 64
	local halfLength = layout.roads.mainHalfLength
	local squareHalf = squareSide / 2
	local roadSpan = math.max(24, halfLength - squareHalf)

	civic.square = makeSurface(
		parent,
		"VillageSquare",
		Vector3.new(squareSide, 0.2, squareSide),
		layout.civic.fountain.x,
		layout.civic.fountain.z,
		squareTop,
		VisualTheme.Colors.pathEdge,
		Enum.Material.Cobblestone
	)

	roads.north = makeSurface(parent, "RoadNorth", Vector3.new(laneWidth, 0.18, roadSpan), 0, squareHalf + (roadSpan / 2), roadTop, VisualTheme.Colors.path, Enum.Material.Asphalt)
	roads.south = makeSurface(parent, "RoadSouth", Vector3.new(laneWidth, 0.18, roadSpan), 0, -squareHalf - (roadSpan / 2), roadTop, VisualTheme.Colors.path, Enum.Material.Asphalt)
	roads.east = makeSurface(parent, "RoadEast", Vector3.new(roadSpan, 0.18, laneWidth), squareHalf + (roadSpan / 2), 0, roadTop, VisualTheme.Colors.path, Enum.Material.Asphalt)
	roads.west = makeSurface(parent, "RoadWest", Vector3.new(roadSpan, 0.18, laneWidth), -squareHalf - (roadSpan / 2), 0, roadTop, VisualTheme.Colors.path, Enum.Material.Asphalt)

	local kerbOffset = (laneWidth / 2) + 1
	makeKerb(parent, "KerbNorthWest", Vector3.new(1.5, 0.22, roadSpan), -kerbOffset, squareHalf + (roadSpan / 2))
	makeKerb(parent, "KerbNorthEast", Vector3.new(1.5, 0.22, roadSpan), kerbOffset, squareHalf + (roadSpan / 2))
	makeKerb(parent, "KerbSouthWest", Vector3.new(1.5, 0.22, roadSpan), -kerbOffset, -squareHalf - (roadSpan / 2))
	makeKerb(parent, "KerbSouthEast", Vector3.new(1.5, 0.22, roadSpan), kerbOffset, -squareHalf - (roadSpan / 2))
	makeKerb(parent, "KerbEastNorth", Vector3.new(roadSpan, 0.22, 1.5), squareHalf + (roadSpan / 2), -kerbOffset)
	makeKerb(parent, "KerbEastSouth", Vector3.new(roadSpan, 0.22, 1.5), squareHalf + (roadSpan / 2), kerbOffset)
	makeKerb(parent, "KerbWestNorth", Vector3.new(roadSpan, 0.22, 1.5), -squareHalf - (roadSpan / 2), -kerbOffset)
	makeKerb(parent, "KerbWestSouth", Vector3.new(roadSpan, 0.22, 1.5), -squareHalf - (roadSpan / 2), kerbOffset)

	for index, position in {
		{ x = -24, z = -24 },
		{ x = 24, z = -24 },
		{ x = -24, z = 24 },
		{ x = 24, z = 24 },
	} do
		makeLantern(parent, "Lantern" .. index, position.x, position.z)
	end

	makeFlowerPatch(parent, "SquareFlowersWest", -23, 12, VisualTheme.Colors.flower)
	makeFlowerPatch(parent, "SquareFlowersEast", 23, 12, VisualTheme.Colors.warmLight)
	makeBench(parent, "SquareBenchWest", -20, -10, 0)
	makeBench(parent, "SquareBenchEast", 20, -10, 0)
	makeMarketStall(parent, "MarketStallWest", -14, -23, VisualTheme.Colors.warmLight)
	makeMarketStall(parent, "MarketStallEast", 14, -23, VisualTheme.Colors.berry)
	makeStreetCluster(parent, "West", -14, -14, VisualTheme.Colors.flower)
	makeStreetCluster(parent, "East", 14, -14, VisualTheme.Colors.warmLight)

	civic.fountain = civic.square
	civic.marketStalls = {
		parent:FindFirstChild("MarketStallWestCounter"),
		parent:FindFirstChild("MarketStallEastCounter"),
	}

	return {
		roads = roads,
		civic = civic,
	}
end

return VillageSceneryBuilder
