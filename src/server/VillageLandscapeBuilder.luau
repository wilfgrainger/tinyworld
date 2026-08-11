local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))
local ArchitecturalDetailBuilder = require(script.Parent:WaitForChild("ArchitecturalDetailBuilder"))

local VillageLandscapeBuilder = {}

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

local function pathSegment(parent: Instance, name: string, from: Vector3, to: Vector3, width: number)
	local flatFrom = Vector3.new(from.X, 0.12, from.Z)
	local flatTo = Vector3.new(to.X, 0.12, to.Z)
	local distance = (flatTo - flatFrom).Magnitude
	local midpoint = (flatFrom + flatTo) / 2
	local path = decoration(
		parent,
		name,
		Vector3.new(width, 0.18, distance),
		CFrame.lookAt(midpoint, flatTo),
		VisualTheme.Colors.pathLight,
		Enum.Material.Cobblestone,
		"village-curved-approach"
	)
	path:SetAttribute("TinyWorldLandscapeFeature", "framedApproaches")
	return path
end

local function hedge(parent: Instance, name: string, position: Vector3, size: Vector3)
	local item = decoration(
		parent,
		name,
		size,
		CFrame.new(position),
		VisualTheme.Colors.leaf,
		Enum.Material.LeafyGrass,
		"village-hedge"
	)
	item:SetAttribute("TinyWorldLandscapeFeature", "plantedEdges")
	return item
end

local function flowerBed(parent: Instance, name: string, position: Vector3, length: number, accent: Color3)
	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("TinyWorldArtRole", "village-flower-bed")
	model.Parent = parent
	decoration(
		model,
		"Soil",
		Vector3.new(length, 0.35, 2.8),
		CFrame.new(position + Vector3.new(0, 0.18, 0)),
		VisualTheme.Colors.timberDark,
		Enum.Material.Ground,
		"village-flower-bed-soil"
	)
	for index = 1, 5 do
		local offset = ((index - 3) / 4) * (length - 2)
		local stem = decoration(
			model,
			"FlowerStem" .. index,
			Vector3.new(0.2, 0.8 + ((index % 2) * 0.18), 0.2),
			CFrame.new(position + Vector3.new(offset, 0.65, ((index % 2) * 0.7) - 0.35)),
			VisualTheme.Colors.leafLight,
			Enum.Material.Grass,
			"village-flower-stem"
		)
		local bloom = decoration(
			model,
			"FlowerBloom" .. index,
			Vector3.new(0.65, 0.65, 0.65),
			stem.CFrame * CFrame.new(0, stem.Size.Y / 2 + 0.28, 0),
			if index % 2 == 0 then VisualTheme.Colors.warmLight else accent,
			Enum.Material.SmoothPlastic,
			"village-flower-bloom"
		)
		bloom.Shape = Enum.PartType.Ball
	end
	return model
end

local function tree(parent: Instance, name: string, position: Vector3, scale: number, canopyColor: Color3?)
	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("TinyWorldArtRole", "village-cluster-tree")
	model.Parent = parent
	decoration(
		model,
		"Trunk",
		Vector3.new(1.2 * scale, 6.5 * scale, 1.2 * scale),
		CFrame.new(position + Vector3.new(0, 3.25 * scale, 0)),
		VisualTheme.Colors.timberDark,
		Enum.Material.Wood,
		"village-tree-trunk"
	)
	local canopyOffsets = {
		Vector3.new(0, 7.3, 0),
		Vector3.new(-2.2, 6.6, 0.5),
		Vector3.new(2, 6.8, -0.7),
	}
	for index, offset in canopyOffsets do
		local canopy = decoration(
			model,
			"Canopy" .. index,
			Vector3.new(5.4, 4.3, 5.4) * scale,
			CFrame.new(position + (offset * scale)),
			canopyColor or VisualTheme.Colors.leaf,
			Enum.Material.LeafyGrass,
			"village-tree-canopy"
		)
		canopy.Shape = Enum.PartType.Ball
	end
	return model
end

local function rockCluster(parent: Instance, name: string, position: Vector3)
	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("TinyWorldArtRole", "village-rock-cluster")
	model.Parent = parent
	local offsets = { Vector3.new(-1.6, 0, 0), Vector3.new(0.4, 0, 0.8), Vector3.new(2, 0, -0.5) }
	for index, offset in offsets do
		local rock = decoration(
			model,
			"Rock" .. index,
			Vector3.new(2.2 + index * 0.35, 1.1 + index * 0.25, 1.8 + index * 0.2),
			CFrame.new(position + offset + Vector3.new(0, 0.55 + index * 0.1, 0))
				* CFrame.Angles(0, math.rad(index * 31), math.rad((index - 2) * 4)),
			VisualTheme.Colors.path,
			Enum.Material.Rock,
			"village-landscape-rock"
		)
		rock:SetAttribute("TinyWorldLandscapeFeature", "rockClusters")
	end
	return model
end

local function fence(parent: Instance, name: string, position: Vector3, length: number, yaw: number)
	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("TinyWorldArtRole", "village-low-fence")
	model.Parent = parent
	local base = CFrame.new(position) * CFrame.Angles(0, math.rad(yaw), 0)
	for _, x in { -(length / 2), 0, length / 2 } do
		decoration(
			model,
			"Post" .. tostring(x),
			Vector3.new(0.45, 2.2, 0.45),
			base * CFrame.new(x, 1.1, 0),
			VisualTheme.Colors.timberDark,
			Enum.Material.Wood,
			"village-fence-post"
		)
	end
	for _, y in { 0.8, 1.55 } do
		decoration(
			model,
			"Rail" .. tostring(y),
			Vector3.new(length, 0.28, 0.35),
			base * CFrame.new(0, y, 0),
			VisualTheme.Colors.woodLight,
			Enum.Material.Wood,
			"village-fence-rail"
		)
	end
	return model
end

local function bench(parent: Instance, name: string, position: Vector3, yaw: number)
	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("TinyWorldArtRole", "village-bench")
	model.Parent = parent
	local base = CFrame.new(position) * CFrame.Angles(0, math.rad(yaw), 0)
	decoration(
		model,
		"Seat",
		Vector3.new(6, 0.5, 1.8),
		base * CFrame.new(0, 1.6, 0),
		VisualTheme.Colors.timber,
		Enum.Material.WoodPlanks,
		"village-bench-seat"
	)
	decoration(
		model,
		"Back",
		Vector3.new(6, 2.2, 0.45),
		base * CFrame.new(0, 2.7, -0.75),
		VisualTheme.Colors.timber,
		Enum.Material.WoodPlanks,
		"village-bench-back"
	)
	for _, x in { -2.2, 2.2 } do
		decoration(
			model,
			"Leg" .. tostring(x),
			Vector3.new(0.45, 1.6, 0.45),
			base * CFrame.new(x, 0.8, 0),
			VisualTheme.Colors.inkSoft,
			Enum.Material.Metal,
			"village-bench-leg"
		)
	end
	return model
end

local function vegetableBed(parent: Instance, name: string, position: Vector3, color: Color3)
	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("TinyWorldArtRole", "village-vegetable-bed")
	model.Parent = parent
	decoration(
		model,
		"Soil",
		Vector3.new(9, 0.5, 4.5),
		CFrame.new(position + Vector3.new(0, 0.25, 0)),
		VisualTheme.Colors.timberDark,
		Enum.Material.Ground,
		"village-vegetable-soil"
	)
	for index = 1, 4 do
		local plant = decoration(
			model,
			"Plant" .. index,
			Vector3.new(1.1, 1.2 + (index % 2) * 0.25, 1.1),
			CFrame.new(position + Vector3.new(-3.2 + index * 1.5, 0.9, 0)),
			if index == 3 then color else VisualTheme.Colors.leafLight,
			Enum.Material.LeafyGrass,
			"village-vegetable-plant"
		)
		plant.Shape = Enum.PartType.Ball
	end
	return model
end

local function crateCluster(parent: Instance, name: string, position: Vector3)
	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("TinyWorldArtRole", "village-crate-cluster")
	model.Parent = parent
	local offsets = {
		Vector3.new(-1.4, 0.8, 0),
		Vector3.new(1.4, 0.8, 0.3),
		Vector3.new(0.2, 2.3, -0.2),
	}
	for index, offset in offsets do
		decoration(
			model,
			"Crate" .. index,
			Vector3.new(2.4, 1.6, 2.1),
			CFrame.new(position + offset) * CFrame.Angles(0, math.rad(index * 12), 0),
			VisualTheme.Colors.timber,
			Enum.Material.WoodPlanks,
			"village-crate"
		)
	end
	return model
end

local function buildCivic(parent: Instance)
	local model = Instance.new("Model")
	model.Name = "ProductionCivicLandscape"
	model:SetAttribute("TinyWorldArtRole", "production-civic-landscape")
	model.Parent = parent

	local approaches = {
		{ Vector3.new(-9, 0, -8), Vector3.new(-34, 0, -2) },
		{ Vector3.new(9, 0, -8), Vector3.new(0, 0, -33) },
		{ Vector3.new(9, 0, 8), Vector3.new(34, 0, 2) },
		{ Vector3.new(-9, 0, 8), Vector3.new(0, 0, 34) },
	}
	for index, segment in approaches do
		pathSegment(model, "CivicApproach" .. index, segment[1], segment[2], 6.5)
	end

	local flowerPositions = {
		Vector3.new(-17, 0, 13),
		Vector3.new(17, 0, 13),
		Vector3.new(-17, 0, 27),
		Vector3.new(17, 0, 27),
	}
	for index, position in flowerPositions do
		flowerBed(
			model,
			"FountainPlazaBed" .. index,
			position,
			7.5,
			if index % 2 == 0 then VisualTheme.Colors.flower else VisualTheme.Colors.warmLight
		)
	end

	bench(model, "CivicBenchWest", Vector3.new(-19, 0, 3), 90)
	bench(model, "CivicBenchEast", Vector3.new(19, 0, 3), -90)
	local lampPositions = {
		Vector3.new(-23, 0, -15),
		Vector3.new(23, 0, -15),
		Vector3.new(-23, 0, 32),
		Vector3.new(23, 0, 32),
	}
	for index, position in lampPositions do
		ArchitecturalDetailBuilder.addLantern(model, {
			name = "CivicLantern" .. index,
			role = "civic-practical-lantern",
			cframe = CFrame.new(position + Vector3.new(0, 6.7, 0)),
			postHeight = 5.8,
			brightness = 0.48,
			range = 10,
		})
	end

	model:SetAttribute("TinyWorldLandscapeFeature", "fountainPlaza plantedEdges seating lamps framedApproaches")
	return model
end

local function buildMeadowLane(parent: Instance)
	local model = Instance.new("Model")
	model.Name = "MeadowLaneProductionLandscape"
	model:SetAttribute("TinyWorldNeighbourhood", "MeadowLane")
	model:SetAttribute("TinyWorldLandscapeFeature", "cottageGarden flowerMeadow stream bridge")
	model.Parent = parent
	pathSegment(model, "MeadowApproachA", Vector3.new(-48, 0, -47), Vector3.new(-64, 0, -61), 5.5)
	pathSegment(model, "MeadowApproachB", Vector3.new(-64, 0, -61), Vector3.new(-78, 0, -73), 5.5)
	flowerBed(model, "MeadowFlowersA", Vector3.new(-69, 0, -48), 10, VisualTheme.Colors.flower)
	flowerBed(model, "MeadowFlowersB", Vector3.new(-78, 0, -58), 8, VisualTheme.Colors.sky)
	hedge(model, "MeadowCottageHedge", Vector3.new(-78, 1.1, -71), Vector3.new(14, 2.2, 1.2))
	fence(model, "MeadowGardenFence", Vector3.new(-65, 0, -76), 12, 22)
	tree(model, "MeadowTreeA", Vector3.new(-76, 0, -43), 0.9, VisualTheme.Colors.leafLight)
	tree(model, "MeadowTreeB", Vector3.new(-57, 0, -71), 0.75, VisualTheme.Colors.leaf)
	return model
end

local function buildHarbourRow(parent: Instance)
	local model = Instance.new("Model")
	model.Name = "HarbourRowProductionLandscape"
	model:SetAttribute("TinyWorldNeighbourhood", "HarbourRow")
	model:SetAttribute("TinyWorldLandscapeFeature", "retainingWall dockClutter coastalPlanting")
	model.Parent = parent
	pathSegment(model, "HarbourApproachA", Vector3.new(48, 0, -47), Vector3.new(63, 0, -61), 5.5)
	pathSegment(model, "HarbourApproachB", Vector3.new(63, 0, -61), Vector3.new(78, 0, -72), 5.5)
	for index, z in { -48, -55, -62 } do
		decoration(
			model,
			"HarbourRetainingWall" .. index,
			Vector3.new(1.2, 2.4 + (index * 0.35), 6),
			CFrame.new(78, 1.2 + (index * 0.15), z),
			VisualTheme.Colors.pathEdge,
			Enum.Material.Cobblestone,
			"harbour-retaining-wall"
		)
	end
	crateCluster(model, "HarbourDockCrates", Vector3.new(66, 0, -76))
	local coastalPositions = {
		Vector3.new(53, 0, -72),
		Vector3.new(59, 0, -77),
		Vector3.new(73, 0, -54),
	}
	for index, position in coastalPositions do
		local grass = decoration(
			model,
			"CoastalGrass" .. index,
			Vector3.new(2.5, 2.2 + index * 0.3, 2.5),
			CFrame.new(position + Vector3.new(0, 1.1, 0)),
			VisualTheme.Colors.leafLight,
			Enum.Material.LeafyGrass,
			"harbour-coastal-planting"
		)
		grass.Shape = Enum.PartType.Ball
	end
	return model
end

local function buildWoodlandRise(parent: Instance)
	local model = Instance.new("Model")
	model.Name = "WoodlandRiseProductionLandscape"
	model:SetAttribute("TinyWorldNeighbourhood", "WoodlandRise")
	model:SetAttribute("TinyWorldLandscapeFeature", "canopy rockClusters narrowPath woodlandFence")
	model.Parent = parent
	pathSegment(model, "WoodlandNarrowPathA", Vector3.new(-48, 0, 47), Vector3.new(-62, 0, 61), 4.3)
	pathSegment(model, "WoodlandNarrowPathB", Vector3.new(-62, 0, 61), Vector3.new(-76, 0, 74), 4.3)
	tree(model, "WoodlandCanopyA", Vector3.new(-73, 0, 50), 1.1, VisualTheme.Colors.leaf)
	tree(model, "WoodlandCanopyB", Vector3.new(-57, 0, 72), 1.05, VisualTheme.Colors.meadowDeep)
	tree(model, "WoodlandCanopyC", Vector3.new(-78, 0, 69), 0.8, VisualTheme.Colors.leafLight)
	rockCluster(model, "WoodlandRocksA", Vector3.new(-69, 0, 61))
	fence(model, "WoodlandFence", Vector3.new(-55, 0, 79), 16, -18)
	return model
end

local function buildOrchardEnd(parent: Instance)
	local model = Instance.new("Model")
	model.Name = "OrchardEndProductionLandscape"
	model:SetAttribute("TinyWorldNeighbourhood", "OrchardEnd")
	model:SetAttribute("TinyWorldLandscapeFeature", "orchard vegetableBeds nursery terrace")
	model.Parent = parent
	pathSegment(model, "OrchardApproachA", Vector3.new(48, 0, 47), Vector3.new(62, 0, 61), 5.2)
	pathSegment(model, "OrchardApproachB", Vector3.new(62, 0, 61), Vector3.new(76, 0, 74), 5.2)
	local orchardPositions = {
		Vector3.new(53, 0, 71),
		Vector3.new(64, 0, 77),
		Vector3.new(76, 0, 61),
	}
	for index, position in orchardPositions do
		tree(model, "OrchardTree" .. index, position, 0.72, VisualTheme.Colors.leafLight)
		for fruit = 1, 3 do
			local apple = decoration(
				model,
				"OrchardFruit" .. index .. "_" .. fruit,
				Vector3.new(0.55, 0.55, 0.55),
				CFrame.new(position + Vector3.new(-1 + fruit * 0.6, 5.1 + (fruit % 2) * 0.7, 0.6)),
				VisualTheme.Colors.berry,
				Enum.Material.SmoothPlastic,
				"orchard-fruit"
			)
			apple.Shape = Enum.PartType.Ball
		end
	end
	vegetableBed(model, "OrchardVegetableBed", Vector3.new(72, 0, 48), VisualTheme.Colors.flower)
	flowerBed(model, "OrchardNursery", Vector3.new(55, 0, 54), 8, VisualTheme.Colors.warmLight)
	decoration(
		model,
		"OrchardTerraceEdge",
		Vector3.new(22, 1.2, 1.2),
		CFrame.new(68, 0.6, 82),
		VisualTheme.Colors.pathEdge,
		Enum.Material.Cobblestone,
		"orchard-terrace"
	)
	return model
end

function VillageLandscapeBuilder.build(parent: Instance, layout)
	local existing = parent:FindFirstChild("ProductionLandscape")
	if existing then
		existing:Destroy()
	end

	local root = Instance.new("Model")
	root.Name = "ProductionLandscape"
	root:SetAttribute("TinyWorldArtRole", "production-village-landscape")
	root:SetAttribute("TinyWorldArtSeed", layout.artSeed)
	root:SetAttribute("TinyWorldVisualState", "authored-native")
	root.Parent = parent

	local civic = buildCivic(root)
	local neighbourhoods = {
		MeadowLane = buildMeadowLane(root),
		HarbourRow = buildHarbourRow(root),
		WoodlandRise = buildWoodlandRise(root),
		OrchardEnd = buildOrchardEnd(root),
	}

	return {
		model = root,
		civic = civic,
		neighbourhoods = neighbourhoods,
	}
end

return VillageLandscapeBuilder
