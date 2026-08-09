local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))
local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local VillageCompositionRules = require(shared:WaitForChild("VillageCompositionRules"))

local VillageSceneryBuilder = {}
local compositionManifest = VillageCompositionRules.getManifest()
VillageSceneryBuilder.COMPOSITION_MANIFEST = compositionManifest

local function makePart(
	parent: Instance,
	name: string,
	size: Vector3,
	position: Vector3,
	color: Color3,
	material: Enum.Material
): Part
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

local function makeSurface(
	parent: Instance,
	name: string,
	size: Vector3,
	x: number,
	z: number,
	topY: number,
	color: Color3,
	material: Enum.Material
): Part
	local part = makePart(parent, name, size, Vector3.new(x, topY - (size.Y / 2), z), color, material)
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	return part
end

local function makeDecoration(
	parent: Instance,
	name: string,
	size: Vector3,
	position: Vector3,
	color: Color3,
	material: Enum.Material
): Part
	local part = makePart(parent, name, size, position, color, material)
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	return part
end

local function makeDecorationAtTop(
	parent: Instance,
	name: string,
	size: Vector3,
	x: number,
	z: number,
	topY: number,
	color: Color3,
	material: Enum.Material
): Part
	return makeDecoration(parent, name, size, Vector3.new(x, topY - (size.Y / 2), z), color, material)
end

local function makeLantern(parent: Instance, name: string, x: number, z: number)
	makeDecorationAtTop(
		parent,
		name .. "Post",
		Vector3.new(0.6, 5, 0.6),
		x,
		z,
		5,
		VisualTheme.Colors.timberDark,
		Enum.Material.Wood
	)
	local lamp = makeDecoration(
		parent,
		name .. "Lamp",
		Vector3.new(2, 2, 2),
		Vector3.new(x, 5.8, z),
		VisualTheme.Colors.gold,
		Enum.Material.Neon
	)
	lamp.Shape = Enum.PartType.Ball
	lamp.Transparency = 0.05
end

local function makeFlowerPatch(parent: Instance, name: string, x: number, z: number, color: Color3)
	for index, offset in
		{
			{ x = -2, z = 0 },
			{ x = 0, z = 2 },
			{ x = 2, z = -1 },
		}
	do
		makeDecorationAtTop(
			parent,
			name .. "Stem" .. index,
			Vector3.new(0.3, 1.2, 0.3),
			x + offset.x,
			z + offset.z,
			1.2,
			VisualTheme.Colors.leaf,
			Enum.Material.Grass
		)
		local bloom = makeDecoration(
			parent,
			name .. "Bloom" .. index,
			Vector3.new(1.4, 1.4, 1.4),
			Vector3.new(x + offset.x, 1.7, z + offset.z),
			color,
			Enum.Material.SmoothPlastic
		)
		bloom.Shape = Enum.PartType.Ball
	end
end

local function makeBench(parent: Instance, name: string, x: number, z: number, rotation: number)
	local seat = makeDecoration(
		parent,
		name .. "Seat",
		Vector3.new(8, 0.8, 2),
		Vector3.new(x, 1.1, z),
		VisualTheme.Colors.timber,
		Enum.Material.WoodPlanks
	)
	seat.Orientation = Vector3.new(0, rotation, 0)
	local back = makeDecoration(
		parent,
		name .. "Back",
		Vector3.new(8, 2.2, 0.6),
		Vector3.new(x, 2.2, z),
		VisualTheme.Colors.timberDark,
		Enum.Material.Wood
	)
	back.Orientation = Vector3.new(0, rotation, 0)
end

local function makeMarketStall(parent: Instance, name: string, x: number, z: number, color: Color3)
	makeDecoration(
		parent,
		name .. "Counter",
		Vector3.new(10, 2, 6),
		Vector3.new(x, 1.2, z),
		VisualTheme.Colors.timber,
		Enum.Material.WoodPlanks
	)
	makeDecoration(parent, name .. "Awning", Vector3.new(12, 1, 8), Vector3.new(x, 6, z), color, Enum.Material.Fabric)
	for side, offset in { { name = "Left", value = -4 }, { name = "Right", value = 4 } } do
		makeDecoration(
			parent,
			name .. side .. "Post",
			Vector3.new(0.6, 5, 0.6),
			Vector3.new(x + offset.value, 3.5, z),
			VisualTheme.Colors.timberDark,
			Enum.Material.Wood
		)
	end
end

local function makePlanter(parent: Instance, name: string, x: number, z: number, color: Color3)
	makeDecorationAtTop(
		parent,
		name .. "Box",
		Vector3.new(5, 1, 3.4),
		x,
		z,
		1.1,
		VisualTheme.Colors.woodLight,
		Enum.Material.WoodPlanks
	)
	makeDecorationAtTop(
		parent,
		name .. "Soil",
		Vector3.new(4.1, 0.22, 2.5),
		x,
		z,
		1.68,
		VisualTheme.Colors.timberDark,
		Enum.Material.Ground
	)
	for index, offset in
		{
			{ x = -1.3, z = 0 },
			{ x = 0, z = 0.45 },
			{ x = 1.3, z = -0.2 },
		}
	do
		makeDecorationAtTop(
			parent,
			name .. "Leaf" .. index,
			Vector3.new(0.45, 1.1, 0.45),
			x + offset.x,
			z + offset.z,
			2.65,
			VisualTheme.Colors.leafLight,
			Enum.Material.LeafyGrass
		)
		local bloom = makeDecoration(
			parent,
			name .. "Bloom" .. index,
			Vector3.new(0.9, 0.9, 0.9),
			Vector3.new(x + offset.x, 3.1, z + offset.z),
			color,
			Enum.Material.SmoothPlastic
		)
		bloom.Shape = Enum.PartType.Ball
	end
end

local function makeMarketBanner(parent: Instance, name: string, x: number, z: number, color: Color3)
	makeDecoration(
		parent,
		name .. "LeftPost",
		Vector3.new(0.4, 4.5, 0.4),
		Vector3.new(x - 3, 2.5, z),
		VisualTheme.Colors.timberDark,
		Enum.Material.Wood
	)
	makeDecoration(
		parent,
		name .. "RightPost",
		Vector3.new(0.4, 4.5, 0.4),
		Vector3.new(x + 3, 2.5, z),
		VisualTheme.Colors.timberDark,
		Enum.Material.Wood
	)
	local banner =
		makeDecoration(parent, name, Vector3.new(5.4, 2.3, 0.25), Vector3.new(x, 3.6, z), color, Enum.Material.Fabric)
	banner.Orientation = Vector3.new(0, 0, 3)
end

local function makePavingInset(parent: Instance, name: string, size: Vector3, x: number, z: number, topY: number)
	makeDecoration(
		parent,
		name,
		size,
		Vector3.new(x, topY + (size.Y / 2) + 0.04, z),
		VisualTheme.Colors.pathLight,
		Enum.Material.Cobblestone
	)
end

local function makeStreetCluster(parent: Instance, name: string, x: number, z: number, color: Color3)
	makePavingInset(parent, name .. "Inset", Vector3.new(10, 0.08, 8), x, z, 0.12)
	makePlanter(parent, "VillagePlanter" .. name, x - 3, z, color)
	makeMarketBanner(parent, "MarketBanner" .. name, x + 3, z, color)
end

local function makeKerb(parent: Instance, name: string, size: Vector3, x: number, z: number)
	makeDecorationAtTop(parent, name, size, x, z, 0.3, VisualTheme.Colors.pathEdge, Enum.Material.Cobblestone)
end

local function rotateOffset(x: number, z: number, rotation: number): (number, number)
	local radians = math.rad(rotation)
	local cosine = math.cos(radians)
	local sine = math.sin(radians)
	return (x * cosine) - (z * sine), (x * sine) + (z * cosine)
end

local TREE_VARIANTS = {
	{ scale = 0.72, lean = -4 },
	{ scale = 0.82, lean = 3 },
	{ scale = 0.9, lean = -2 },
	{ scale = 1, lean = 4 },
}

local ROCK_VARIANTS = {
	{ scale = 0.7, yaw = 12 },
	{ scale = 0.85, yaw = 37 },
	{ scale = 1, yaw = 61 },
	{ scale = 0.78, yaw = 88 },
}

local function authoredVariant(seed: number, index: number, count: number): number
	return ((seed + (index * 17)) % count) + 1
end

local function makeCurvedPath(parent: Instance, name: string, x: number, z: number, rotation: number, width: number)
	for index, segment in
		{
			{ x = -10, z = 11, yaw = -18 },
			{ x = 0, z = 0, yaw = 0 },
			{ x = 10, z = -11, yaw = 18 },
		}
	do
		local path = makeSurface(
			parent,
			name .. "CurvedSegment" .. index,
			Vector3.new(width, 0.14, 18),
			x + segment.x,
			z + segment.z,
			0.16,
			VisualTheme.Colors.pathLight,
			Enum.Material.Cobblestone
		)
		path.Orientation = Vector3.new(0, rotation + segment.yaw, 0)
	end
end

local function makeGrassBank(parent: Instance, name: string, x: number, z: number, rotation: number, length: number)
	local bank = makeDecoration(
		parent,
		name,
		Vector3.new(8, 2.4, length),
		Vector3.new(x, 0.4, z),
		VisualTheme.Colors.meadowDeep,
		Enum.Material.Grass
	)
	bank.Orientation = Vector3.new(0, rotation, 4)
end

local function makeBridge(parent: Instance, name: string, x: number, z: number)
	makeDecoration(
		parent,
		name .. "Deck",
		Vector3.new(18, 0.5, 9),
		Vector3.new(x, 0.55, z),
		VisualTheme.Colors.timber,
		Enum.Material.WoodPlanks
	)
	for _, offset in { -7, 7 } do
		makeDecoration(
			parent,
			name .. "Rail" .. tostring(offset),
			Vector3.new(0.45, 2.4, 8),
			Vector3.new(x + offset, 1.6, z),
			VisualTheme.Colors.timberDark,
			Enum.Material.Wood
		)
	end
end

local function makeStream(parent: Instance)
	for index, section in
		{
			{ x = -73, z = -102, yaw = -4 },
			{ x = -75, z = -142, yaw = 3 },
			{ x = -72, z = -182, yaw = -2 },
		}
	do
		local water = makeSurface(
			parent,
			"MeadowStream" .. index,
			Vector3.new(7, 0.12, 44),
			section.x,
			section.z,
			0.1,
			VisualTheme.Colors.water,
			Enum.Material.Water
		)
		water.Orientation = Vector3.new(0, section.yaw, 0)
		water.Transparency = 0.18
		makeGrassBank(parent, "MeadowStreamWestBank" .. index, section.x - 5.5, section.z, section.yaw, 43)
		makeGrassBank(parent, "MeadowStreamEastBank" .. index, section.x + 5.5, section.z, section.yaw, 43)
	end
	makeBridge(parent, "MeadowBridge", -74, -142)
end

local function makeTreeCluster(parent: Instance, name: string, x: number, z: number, variantIndex: number)
	local variant = TREE_VARIANTS[variantIndex]
	for index, offset in
		{
			{ x = -5, z = 2 },
			{ x = 3, z = -3 },
			{ x = 7, z = 5 },
		}
	do
		local scale = variant.scale + ((index - 2) * 0.05)
		local trunk = makeDecoration(
			parent,
			name .. "Trunk" .. index,
			Vector3.new(1.5 * scale, 6 * scale, 1.5 * scale),
			Vector3.new(x + offset.x, 3 * scale, z + offset.z),
			VisualTheme.Colors.timberDark,
			Enum.Material.Wood
		)
		trunk.Orientation = Vector3.new(variant.lean, index * 23, variant.lean / 2)
		local canopy = makeDecoration(
			parent,
			name .. "Canopy" .. index,
			Vector3.new(7.5 * scale, 7 * scale, 7.5 * scale),
			Vector3.new(x + offset.x, 8 * scale, z + offset.z),
			VisualTheme.Colors.leaf,
			Enum.Material.LeafyGrass
		)
		canopy.Shape = Enum.PartType.Ball
	end
end

local function makeRockCluster(parent: Instance, name: string, x: number, z: number, variantIndex: number)
	local variant = ROCK_VARIANTS[variantIndex]
	for index, offset in
		{
			{ x = -3, z = 0 },
			{ x = 1, z = 2 },
			{ x = 4, z = -2 },
		}
	do
		local rock = makeDecoration(
			parent,
			name .. index,
			Vector3.new(4 * variant.scale, 2.6 * variant.scale, 3.2 * variant.scale),
			Vector3.new(x + offset.x, 1.2 * variant.scale, z + offset.z),
			VisualTheme.Colors.path,
			Enum.Material.Rock
		)
		rock.Shape = Enum.PartType.Ball
		rock.Orientation = Vector3.new(index * 5, variant.yaw + (index * 11), index * 3)
	end
end

local function makeFenceRun(
	parent: Instance,
	name: string,
	x: number,
	z: number,
	rotation: number,
	variantIndex: number
)
	local postSpacing = 5 + ((variantIndex - 1) * 0.35)
	for index = -2, 2 do
		local offsetX, offsetZ = rotateOffset(index * postSpacing, 0, rotation)
		local post = makeDecoration(
			parent,
			name .. "Post" .. tostring(index),
			Vector3.new(0.55, 2.6 + ((index + variantIndex) % 2) * 0.5, 0.55),
			Vector3.new(x + offsetX, 1.4, z + offsetZ),
			VisualTheme.Colors.timberDark,
			Enum.Material.Wood
		)
		post.Orientation = Vector3.new(0, rotation + (index * 2), (index % 2) * 3)
	end
	local rail = makeDecoration(
		parent,
		name .. "Rail",
		Vector3.new(postSpacing * 4, 0.45, 0.45),
		Vector3.new(x, 1.8, z),
		VisualTheme.Colors.timber,
		Enum.Material.Wood
	)
	rail.Orientation = Vector3.new(0, rotation, (variantIndex - 2) * 1.5)
end

local function makeVegetableBed(parent: Instance, name: string, x: number, z: number, rotation: number)
	local soil = makeDecoration(
		parent,
		name .. "Soil",
		Vector3.new(11, 0.35, 5),
		Vector3.new(x, 0.25, z),
		VisualTheme.Colors.timberDark,
		Enum.Material.Ground
	)
	soil.Orientation = Vector3.new(0, rotation, 0)
	for index = -2, 2 do
		local leaf = makeDecoration(
			parent,
			name .. "Leaf" .. tostring(index),
			Vector3.new(0.8, 1.2, 0.8),
			Vector3.new(x + (index * 2), 0.95, z),
			VisualTheme.Colors.leafLight,
			Enum.Material.LeafyGrass
		)
		leaf.Shape = Enum.PartType.Ball
	end
end

local function makeOrchardTree(parent: Instance, name: string, x: number, z: number, variantIndex: number)
	local variant = TREE_VARIANTS[variantIndex]
	makeDecoration(
		parent,
		name .. "Trunk",
		Vector3.new(1.5, 5.5, 1.5),
		Vector3.new(x, 2.75, z),
		VisualTheme.Colors.timberDark,
		Enum.Material.Wood
	)
	local canopy = makeDecoration(
		parent,
		name .. "Canopy",
		Vector3.new(7 * variant.scale, 6 * variant.scale, 7 * variant.scale),
		Vector3.new(x, 7, z),
		VisualTheme.Colors.leafLight,
		Enum.Material.LeafyGrass
	)
	canopy.Shape = Enum.PartType.Ball
	for fruitIndex, offset in { { x = -2, z = 1 }, { x = 2, z = -1 } } do
		local fruit = makeDecoration(
			parent,
			name .. "Fruit" .. fruitIndex,
			Vector3.new(1, 1, 1),
			Vector3.new(x + offset.x, 7, z + offset.z),
			VisualTheme.Colors.berry,
			Enum.Material.SmoothPlastic
		)
		fruit.Shape = Enum.PartType.Ball
	end
end

local function makeFishingClutter(parent: Instance, name: string, x: number, z: number, rotation: number)
	local crate = makeDecoration(
		parent,
		name .. "Crate",
		Vector3.new(4, 3, 4),
		Vector3.new(x, 1.5, z),
		VisualTheme.Colors.timber,
		Enum.Material.WoodPlanks
	)
	crate.Orientation = Vector3.new(0, rotation, 0)
	makeDecoration(
		parent,
		name .. "Rod",
		Vector3.new(0.35, 7, 0.35),
		Vector3.new(x + 3, 3.4, z),
		VisualTheme.Colors.timberDark,
		Enum.Material.Wood
	).Orientation =
		Vector3.new(0, rotation, 12)
	local float = makeDecoration(
		parent,
		name .. "Float",
		Vector3.new(1.2, 1.2, 1.2),
		Vector3.new(x - 3, 0.8, z + 1),
		VisualTheme.Colors.berry,
		Enum.Material.SmoothPlastic
	)
	float.Shape = Enum.PartType.Ball
end

local function buildNeighbourhoodScenery(parent: Instance, layout: any)
	local neighbourhoods = {}
	for _, entry in compositionManifest.neighbourhoods do
		local neighbourhoodName = entry.name
		local model = Instance.new("Model")
		model.Name = neighbourhoodName
		model.Parent = parent
		neighbourhoods[neighbourhoodName] = model
	end

	makeStream(neighbourhoods.MeadowLane)
	makeCurvedPath(neighbourhoods.MeadowLane, "MeadowLanePath", -108, -76, 88, 9)
	makeFlowerPatch(neighbourhoods.MeadowLane, "MeadowPlanting", -96, -76, VisualTheme.Colors.flower)

	makeCurvedPath(neighbourhoods.HarbourRow, "HarbourDescendingPath", 110, -82, -88, 8)
	for index = 1, 3 do
		makeDecoration(
			neighbourhoods.HarbourRow,
			"HarbourRetainingWall" .. index,
			Vector3.new(22, 1.2 + index, 2),
			Vector3.new(118 + (index * 18), index * 0.35, -76),
			VisualTheme.Colors.pathEdge,
			Enum.Material.Cobblestone
		)
	end
	makeFishingClutter(neighbourhoods.HarbourRow, "HarbourFishingClutter", 154, -76, 7)

	makeCurvedPath(neighbourhoods.WoodlandRise, "WoodlandNarrowPath", -108, 78, 92, 6)
	makeTreeCluster(
		neighbourhoods.WoodlandRise,
		"WoodlandTreeClusterA",
		-82,
		146,
		authoredVariant(layout.artSeed, 3, #TREE_VARIANTS)
	)
	makeTreeCluster(
		neighbourhoods.WoodlandRise,
		"WoodlandTreeClusterB",
		-216,
		146,
		authoredVariant(layout.artSeed, 8, #TREE_VARIANTS)
	)
	makeRockCluster(
		neighbourhoods.WoodlandRise,
		"WoodlandRocks",
		-76,
		190,
		authoredVariant(layout.artSeed, 6, #ROCK_VARIANTS)
	)

	makeCurvedPath(neighbourhoods.OrchardEnd, "OrchardEndPath", 108, 78, -92, 8)
	for index, position in { { x = 78, z = 150 }, { x = 80, z = 180 }, { x = 214, z = 150 }, { x = 212, z = 180 } } do
		makeOrchardTree(
			neighbourhoods.OrchardEnd,
			"OrchardTree" .. index,
			position.x,
			position.z,
			authoredVariant(layout.artSeed, index + 10, #TREE_VARIANTS)
		)
	end
	makeVegetableBed(neighbourhoods.OrchardEnd, "OrchardVegetableBedA", 146, 78, 3)
	makeVegetableBed(neighbourhoods.OrchardEnd, "OrchardVegetableBedB", 164, 78, -4)
	makeSurface(
		neighbourhoods.OrchardEnd,
		"NurseryGreen",
		Vector3.new(24, 0.12, 16),
		190,
		78,
		0.14,
		VisualTheme.Colors.meadowDeep,
		Enum.Material.Grass
	)

	for index, slot in layout.plotSlots do
		local model = neighbourhoods[slot.neighbourhood]
		local variantIndex = authoredVariant(layout.artSeed, index, 4)
		local side = if variantIndex % 2 == 0 then -1 else 1
		makeFenceRun(model, "PlotFence" .. index, slot.x, slot.z + (side * 29), slot.rotation, variantIndex)
		makeLantern(model, "PlotLamp" .. index, slot.x + (side * 20), slot.z + slot.setback - 20)
		makeFlowerPatch(
			model,
			"PlotFlowers" .. index,
			slot.x - (side * 19),
			slot.z - slot.setback + 19,
			if variantIndex <= 2 then VisualTheme.Colors.flower else VisualTheme.Colors.warmLight
		)
	end

	return neighbourhoods
end

local function buildTerrain(parent: Instance, layout: any)
	local model = Instance.new("Model")
	model.Name = "VillageTerrain"
	model:SetAttribute("TinyWorldArtRole", "authored-terrain")
	model:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	model:SetAttribute("TinyWorldTerrainContract", "bounded-authored-elevation")
	model.Parent = parent

	local bands = {}
	for index, band in layout.terrainBands do
		local terrainBand = Instance.new("WedgePart")
		terrainBand.Name = "TerrainBand_" .. band.id
		terrainBand.Anchored = true
		terrainBand.Size = Vector3.new(band.width, band.height, band.depth)
		terrainBand.Position = Vector3.new(band.x, band.height / 2, band.z)
		terrainBand.Orientation = Vector3.new(0, band.rotation, 0)
		terrainBand.Color = if band.material == "Ground"
			then VisualTheme.Colors.meadowDeep
			else VisualTheme.Colors.meadow
		terrainBand.Material = if band.material == "Ground" then Enum.Material.Ground else Enum.Material.Grass
		-- Elevation bands are visual dressing. VillageGround and plot bases
		-- remain the stable collision foundation, so a sloped band can never
		-- cut across an assigned plot or intercept gameplay raycasts.
		terrainBand.CanCollide = false
		terrainBand.CanTouch = false
		terrainBand.CanQuery = false
		terrainBand:SetAttribute("TinyWorldArtRole", "terrain-elevation-band")
		terrainBand:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
		terrainBand:SetAttribute("TinyWorldTerrainHeight", band.height)
		terrainBand:SetAttribute(
			"TinyWorldTerrainNeighbourhood",
			if index == 1
				then "MeadowLane"
				elseif index == 2 then "HarbourRow"
				elseif index == 3 then "WoodlandRise"
				else "OrchardEnd"
		)
		terrainBand.Parent = model
		table.insert(bands, terrainBand)
	end
	model:SetAttribute("TinyWorldTerrainBandCount", #bands)
	model:SetAttribute("TinyWorldTerrainMinimumHeight", 4)
	model:SetAttribute("TinyWorldTerrainMaximumHeight", 8)
	return { model = model, bands = bands }
end

function VillageSceneryBuilder.build(parent: Instance, layout: any)
	local terrain = buildTerrain(parent, layout)
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

	roads.north = makeSurface(
		parent,
		"RoadNorth",
		Vector3.new(laneWidth, 0.18, roadSpan),
		0,
		squareHalf + (roadSpan / 2),
		roadTop,
		VisualTheme.Colors.path,
		Enum.Material.Asphalt
	)
	roads.south = makeSurface(
		parent,
		"RoadSouth",
		Vector3.new(laneWidth, 0.18, roadSpan),
		0,
		-squareHalf - (roadSpan / 2),
		roadTop,
		VisualTheme.Colors.path,
		Enum.Material.Asphalt
	)
	roads.east = makeSurface(
		parent,
		"RoadEast",
		Vector3.new(roadSpan, 0.18, laneWidth),
		squareHalf + (roadSpan / 2),
		0,
		roadTop,
		VisualTheme.Colors.path,
		Enum.Material.Asphalt
	)
	roads.west = makeSurface(
		parent,
		"RoadWest",
		Vector3.new(roadSpan, 0.18, laneWidth),
		-squareHalf - (roadSpan / 2),
		0,
		roadTop,
		VisualTheme.Colors.path,
		Enum.Material.Asphalt
	)

	local kerbOffset = (laneWidth / 2) + 1
	makeKerb(parent, "KerbNorthWest", Vector3.new(1.5, 0.22, roadSpan), -kerbOffset, squareHalf + (roadSpan / 2))
	makeKerb(parent, "KerbNorthEast", Vector3.new(1.5, 0.22, roadSpan), kerbOffset, squareHalf + (roadSpan / 2))
	makeKerb(parent, "KerbSouthWest", Vector3.new(1.5, 0.22, roadSpan), -kerbOffset, -squareHalf - (roadSpan / 2))
	makeKerb(parent, "KerbSouthEast", Vector3.new(1.5, 0.22, roadSpan), kerbOffset, -squareHalf - (roadSpan / 2))
	makeKerb(parent, "KerbEastNorth", Vector3.new(roadSpan, 0.22, 1.5), squareHalf + (roadSpan / 2), -kerbOffset)
	makeKerb(parent, "KerbEastSouth", Vector3.new(roadSpan, 0.22, 1.5), squareHalf + (roadSpan / 2), kerbOffset)
	makeKerb(parent, "KerbWestNorth", Vector3.new(roadSpan, 0.22, 1.5), -squareHalf - (roadSpan / 2), -kerbOffset)
	makeKerb(parent, "KerbWestSouth", Vector3.new(roadSpan, 0.22, 1.5), -squareHalf - (roadSpan / 2), kerbOffset)

	for index, position in
		{
			{ x = -24, z = -24 },
			{ x = 24, z = -24 },
			{ x = -24, z = 24 },
			{ x = 24, z = 24 },
		}
	do
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
	local neighbourhoods = buildNeighbourhoodScenery(parent, layout)

	civic.fountain = civic.square
	civic.marketStalls = {
		parent:FindFirstChild("MarketStallWestCounter"),
		parent:FindFirstChild("MarketStallEastCounter"),
	}

	return {
		terrain = terrain,
		roads = roads,
		civic = civic,
		neighbourhoods = neighbourhoods,
		decorationBudget = layout.budgets.visual.seededDressing,
	}
end

local WATER_HIGHLIGHT_POSITIONS = {
	Vector3.new(-73, 0.24, -102),
	Vector3.new(-75, 0.24, -142),
	Vector3.new(-72, 0.24, -182),
	Vector3.new(-70, 0.24, -122),
	Vector3.new(-76, 0.24, -162),
	Vector3.new(-2.5, 5.08, 16),
	Vector3.new(2.5, 5.08, 16),
}

local BIRD_POSITIONS = {
	Vector3.new(-72, 25, -118),
	Vector3.new(74, 23, -102),
	Vector3.new(-102, 27, 96),
	Vector3.new(106, 24, 118),
	Vector3.new(-18, 29, 12),
	Vector3.new(26, 26, -38),
	Vector3.new(58, 25, 54),
}

local BUTTERFLY_POSITIONS = {
	Vector3.new(-96, 3.2, -76),
	Vector3.new(-82, 3.7, -108),
	Vector3.new(-28, 3.4, 14),
	Vector3.new(24, 3.1, 12),
	Vector3.new(78, 3.6, 150),
	Vector3.new(98, 3.3, 84),
	Vector3.new(-86, 3.5, 148),
	Vector3.new(146, 3.8, 78),
	Vector3.new(12, 3.2, -18),
}

local function makeAmbientDecoration(
	parent: Instance,
	name: string,
	size: Vector3,
	position: Vector3,
	color: Color3,
	material: Enum.Material,
	effect: string
): Part
	local part = makeDecoration(parent, name, size, position, color, material)
	part:SetAttribute("TinyWorldAmbientEffect", effect)
	return part
end

local function collectParts(parent: Instance, predicate: (BasePart) -> boolean): { BasePart }
	local parts = {}
	for _, descendant in parent:GetDescendants() do
		if descendant:IsA("BasePart") and predicate(descendant) then
			table.insert(parts, descendant)
		end
	end
	table.sort(parts, function(left, right)
		return left:GetFullName() < right:GetFullName()
	end)
	return parts
end

local function takeEffectBudget(remaining: { number }, requested: number): number
	local granted = math.min(remaining[1], requested)
	remaining[1] -= granted
	return granted
end

local function makeSmokeEmitter(parent: Instance, name: string): ParticleEmitter
	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = name
	emitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
	emitter.Color = ColorSequence.new(VisualTheme.Colors.paper, VisualTheme.Colors.inkSoft)
	emitter.LightInfluence = 0.8
	emitter.Lifetime = NumberRange.new(3.5, 5)
	emitter.Rate = VisualTheme.Ambient.SMOKE_RATE
	emitter.RotSpeed = NumberRange.new(-8, 8)
	emitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.8),
		NumberSequenceKeypoint.new(1, 3.2),
	})
	emitter.Speed = NumberRange.new(1.1, 1.8)
	emitter.SpreadAngle = Vector2.new(9, 9)
	emitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.45),
		NumberSequenceKeypoint.new(0.7, 0.72),
		NumberSequenceKeypoint.new(1, 1),
	})
	emitter.Parent = parent
	return emitter
end

local function addWarmWindowLights(windowTargets: { Instance }, seed: number, count: number): number
	local windows = {}
	for _, target in windowTargets do
		for _, window in
			collectParts(target, function(part)
				return part.Material == Enum.Material.Glass and string.find(part.Name, "Window") ~= nil
			end)
		do
			table.insert(windows, window)
		end
	end
	table.sort(windows, function(left, right)
		return left:GetFullName() < right:GetFullName()
	end)

	local lightCount = math.min(count, #windows)
	for index = 1, lightCount do
		local window = windows[authoredVariant(seed, index, #windows)]
		window.Color = VisualTheme.Colors.warmLight
		window.Transparency = 0.18
		window:SetAttribute("TinyWorldAmbientEffect", "warm-window")
		local light = Instance.new("PointLight")
		light.Name = "WarmWindowLight"
		light.Brightness = 0.7
		light.Color = VisualTheme.Colors.warmLight
		light.Range = 12
		light.Shadows = false
		light.Parent = window
	end
	return lightCount
end

local function addHomeWarmWindowLight(window: BasePart): PointLight
	window.Color = VisualTheme.Colors.warmLight
	window.Transparency = 0.18
	window:SetAttribute("TinyWorldAmbientEffect", "home-warm-window")
	local light = Instance.new("PointLight")
	light.Name = "HomeWarmWindowLight"
	light.Brightness = 0.7
	light.Color = VisualTheme.Colors.warmLight
	light.Range = 12
	light.Shadows = false
	light.Parent = window
	return light
end

local function makeWaterHighlight(parent: Instance, position: Vector3, index: number, seed: number)
	local highlight = makeAmbientDecoration(
		parent,
		"WaterHighlight" .. index,
		Vector3.new(3.6, 0.06, 1.1),
		position,
		VisualTheme.Colors.warmLight,
		Enum.Material.Glass,
		"water-highlight"
	)
	highlight.Orientation = Vector3.new(0, authoredVariant(seed, index, 12) * 15, 0)
	highlight.Transparency = 0.48
	local hook = Instance.new("Attachment")
	hook.Name = "WaterHighlightHook"
	hook.Parent = highlight
end

local function addFoliageHooks(parent: Instance, seed: number, count: number): number
	local foliage = collectParts(parent, function(part)
		return string.find(part.Name, "Canopy") ~= nil or string.find(part.Name, "Leaf") ~= nil
	end)
	local hookCount = math.min(count, #foliage)
	for index = 1, hookCount do
		local leaf = foliage[authoredVariant(seed, index, #foliage)]
		leaf:SetAttribute("TinyWorldAmbientEffect", "foliage-sway")
		local hook = Instance.new("Attachment")
		hook.Name = "FoliageSwayHook"
		hook:SetAttribute("TinyWorldAmbientMotion", "local-gentle-sway")
		hook.Parent = leaf
	end
	return hookCount
end

local function makeBirdHook(parent: Instance, position: Vector3, index: number, seed: number)
	local model = Instance.new("Model")
	model.Name = "BirdAmbient" .. index
	model:SetAttribute("TinyWorldAmbientEffect", "bird")
	model.Parent = parent
	local body = makeAmbientDecoration(
		model,
		"BirdBody",
		Vector3.new(1.6, 0.8, 0.8),
		position,
		VisualTheme.Colors.inkSoft,
		Enum.Material.SmoothPlastic,
		"bird"
	)
	body.Shape = Enum.PartType.Ball
	body.Orientation = Vector3.new(0, authoredVariant(seed, index, 12) * 30, 0)
	local leftWing = makeAmbientDecoration(
		model,
		"BirdWingLeft",
		Vector3.new(1.8, 0.2, 0.7),
		position + Vector3.new(-1, 0.25, 0),
		VisualTheme.Colors.inkSoft,
		Enum.Material.SmoothPlastic,
		"bird"
	)
	leftWing.Orientation = Vector3.new(0, 0, 20)
	local rightWing = makeAmbientDecoration(
		model,
		"BirdWingRight",
		Vector3.new(1.8, 0.2, 0.7),
		position + Vector3.new(1, 0.25, 0),
		VisualTheme.Colors.inkSoft,
		Enum.Material.SmoothPlastic,
		"bird"
	)
	rightWing.Orientation = Vector3.new(0, 0, -20)
	local hook = Instance.new("Attachment")
	hook.Name = "BirdMotionHook"
	hook:SetAttribute("TinyWorldAmbientMotion", "local-wide-circle")
	hook.Parent = body
end

local function makeButterflyHook(parent: Instance, position: Vector3, index: number, seed: number)
	local model = Instance.new("Model")
	model.Name = "ButterflyAmbient" .. index
	model:SetAttribute("TinyWorldAmbientEffect", "butterfly")
	model.Parent = parent
	local body = makeAmbientDecoration(
		model,
		"ButterflyBody",
		Vector3.new(0.2, 0.6, 0.2),
		position,
		VisualTheme.Colors.inkSoft,
		Enum.Material.SmoothPlastic,
		"butterfly"
	)
	local color = if authoredVariant(seed, index, 2) == 1 then VisualTheme.Colors.flower else VisualTheme.Colors.gold
	local leftWing = makeAmbientDecoration(
		model,
		"ButterflyWingLeft",
		Vector3.new(0.9, 0.12, 0.7),
		position + Vector3.new(-0.45, 0.15, 0),
		color,
		Enum.Material.SmoothPlastic,
		"butterfly"
	)
	leftWing.Shape = Enum.PartType.Ball
	leftWing.Orientation = Vector3.new(0, 0, 18)
	local rightWing = makeAmbientDecoration(
		model,
		"ButterflyWingRight",
		Vector3.new(0.9, 0.12, 0.7),
		position + Vector3.new(0.45, 0.15, 0),
		color,
		Enum.Material.SmoothPlastic,
		"butterfly"
	)
	rightWing.Shape = Enum.PartType.Ball
	rightWing.Orientation = Vector3.new(0, 0, -18)
	local hook = Instance.new("Attachment")
	hook.Name = "ButterflyMotionHook"
	hook:SetAttribute("TinyWorldAmbientMotion", "local-short-flutter")
	hook.Parent = body
end

function VillageSceneryBuilder.buildAmbientLife(parent: Instance, layout: any, windowTargets: { Instance })
	local model = Instance.new("Model")
	model.Name = "AmbientLife"
	model:SetAttribute("TinyWorldArtRole", "village-ambient-life")
	model:SetAttribute("TinyWorldAmbientSeed", layout.artSeed)
	model:SetAttribute("TinyWorldAmbientScope", "world")
	model.Parent = parent

	local effectBudget = math.min(layout.budgets.visual.seededDressing, VisualTheme.Ambient.MAX_TOTAL_EFFECTS)
	local remaining = { effectBudget }
	-- Residential ambience is bound after a player receives a home. Reserve the
	-- effect budget for real house windows and chimneys instead of hard-coded
	-- world positions that can drift away from the authored home prefab.
	local warmWindowCount = takeEffectBudget(remaining, 2)
	local waterCount = takeEffectBudget(remaining, VisualTheme.Ambient.MAX_WATER_HIGHLIGHTS)
	local foliageCount = takeEffectBudget(remaining, VisualTheme.Ambient.MAX_FOLIAGE_HOOKS)
	local birdCount = takeEffectBudget(remaining, VisualTheme.Ambient.MAX_BIRD_HOOKS)
	local butterflyCount = takeEffectBudget(remaining, VisualTheme.Ambient.MAX_BUTTERFLY_HOOKS)

	warmWindowCount = addWarmWindowLights(windowTargets, layout.artSeed, warmWindowCount)
	for index = 1, waterCount do
		makeWaterHighlight(
			model,
			WATER_HIGHLIGHT_POSITIONS[authoredVariant(layout.artSeed, index, #WATER_HIGHLIGHT_POSITIONS)],
			index,
			layout.artSeed
		)
	end
	foliageCount = addFoliageHooks(parent, layout.artSeed, foliageCount)
	for index = 1, birdCount do
		makeBirdHook(
			model,
			BIRD_POSITIONS[authoredVariant(layout.artSeed, index, #BIRD_POSITIONS)],
			index,
			layout.artSeed
		)
	end
	for index = 1, butterflyCount do
		makeButterflyHook(
			model,
			BUTTERFLY_POSITIONS[authoredVariant(layout.artSeed, index, #BUTTERFLY_POSITIONS)],
			index,
			layout.artSeed
		)
	end

	local effectCount = warmWindowCount + waterCount + foliageCount + birdCount + butterflyCount
	model:SetAttribute("TinyWorldAmbientEffectCount", effectCount)
	model:SetAttribute("TinyWorldAmbientEmitterCount", 0)
	model:SetAttribute("TinyWorldAmbientLightCount", warmWindowCount)
	model:SetAttribute("TinyWorldAmbientBudget", effectBudget)

	return {
		parent = parent,
		model = model,
		effectCount = effectCount,
		emitterCount = 0,
		lightCount = warmWindowCount,
		remainingBudget = remaining,
		homeBindings = {},
	}
end

local function updateAmbientState(ambientLife)
	ambientLife.model:SetAttribute("TinyWorldAmbientEffectCount", ambientLife.effectCount)
	ambientLife.model:SetAttribute("TinyWorldAmbientEmitterCount", ambientLife.emitterCount)
	ambientLife.model:SetAttribute("TinyWorldAmbientLightCount", ambientLife.lightCount)
	ambientLife.parent:SetAttribute("TinyWorldAmbientEffectCount", ambientLife.effectCount)
end

local function removeHomeAmbientArtifacts(houseContainer: Instance)
	for _, descendant in houseContainer:GetDescendants() do
		if descendant:IsA("PointLight") and descendant.Name == "HomeWarmWindowLight" then
			descendant:Destroy()
		elseif descendant:IsA("ParticleEmitter") and descendant.Name == "HomeChimneySmokeEmitter" then
			descendant:Destroy()
		elseif descendant:IsA("Attachment") and descendant.Name == "HomeChimneySmokeHook" then
			descendant:Destroy()
		end
	end
end

function VillageSceneryBuilder.releaseHomeAmbient(ambientLife, plotIndex: number)
	if ambientLife == nil then
		return
	end
	local binding = ambientLife.homeBindings[plotIndex]
	if binding == nil then
		return
	end
	if binding.light then
		ambientLife.lightCount -= 1
		ambientLife.remainingBudget[1] += 1
	end
	if binding.smoke then
		ambientLife.emitterCount -= 1
		ambientLife.remainingBudget[1] += 1
	end
	ambientLife.effectCount -= (if binding.light then 1 else 0) + (if binding.smoke then 1 else 0)
	ambientLife.homeBindings[plotIndex] = nil
	updateAmbientState(ambientLife)
end

function VillageSceneryBuilder.bindHomeAmbient(
	ambientLife,
	houseContainer: Instance,
	plotIndex: number,
	seed: number
): boolean
	if ambientLife == nil or houseContainer == nil then
		return false
	end
	VillageSceneryBuilder.releaseHomeAmbient(ambientLife, plotIndex)
	removeHomeAmbientArtifacts(houseContainer)

	local binding = { light = false, smoke = false }
	local windows = collectParts(houseContainer, function(part)
		return part.Material == Enum.Material.Glass and string.find(part.Name, "HouseWindow") ~= nil
	end)
	if
		#windows > 0
		and ambientLife.lightCount < VisualTheme.Ambient.MAX_WARM_WINDOW_LIGHTS
		and ambientLife.remainingBudget[1] > 0
	then
		local window = windows[authoredVariant(seed, plotIndex, #windows)]
		addHomeWarmWindowLight(window)
		binding.light = true
		ambientLife.lightCount += 1
		ambientLife.remainingBudget[1] -= 1
	end

	local chimney = houseContainer:FindFirstChild("CabinChimney", true)
	if
		chimney
		and chimney:IsA("BasePart")
		and ambientLife.emitterCount < VisualTheme.Ambient.MAX_CHIMNEY_SMOKE_EMITTERS
		and ambientLife.remainingBudget[1] > 0
	then
		local hook = Instance.new("Attachment")
		hook.Name = "HomeChimneySmokeHook"
		hook.Position = Vector3.new(0, chimney.Size.Y / 2, 0)
		hook.Parent = chimney
		makeSmokeEmitter(hook, "HomeChimneySmokeEmitter")
		chimney:SetAttribute("TinyWorldAmbientEffect", "home-chimney-smoke")
		binding.smoke = true
		ambientLife.emitterCount += 1
		ambientLife.remainingBudget[1] -= 1
	end

	ambientLife.effectCount += (if binding.light then 1 else 0) + (if binding.smoke then 1 else 0)
	ambientLife.homeBindings[plotIndex] = binding
	updateAmbientState(ambientLife)
	return binding.light or binding.smoke
end

VillageSceneryBuilder.rotateOffset = rotateOffset

return VillageSceneryBuilder
