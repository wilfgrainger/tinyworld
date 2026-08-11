local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))
local ArchitecturalDetailBuilder = require(script.Parent:WaitForChild("ArchitecturalDetailBuilder"))

local VillageArrivalPolishBuilder = {}

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

local function addBench(parent: Instance, name: string, cframe: CFrame)
	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("TinyWorldArtRole", "arrival-bench")
	model.Parent = parent

	decoration(
		model,
		"Seat",
		Vector3.new(6.2, 0.65, 1.8),
		cframe * CFrame.new(0, 2, 0),
		VisualTheme.Colors.timber,
		Enum.Material.WoodPlanks,
		"arrival-bench-seat"
	)
	decoration(
		model,
		"Back",
		Vector3.new(6.2, 2.6, 0.5),
		cframe * CFrame.new(0, 3, -0.75) * CFrame.Angles(math.rad(-8), 0, 0),
		VisualTheme.Colors.timber,
		Enum.Material.WoodPlanks,
		"arrival-bench-back"
	)
	for _, x in { -2.25, 2.25 } do
		decoration(
			model,
			"Leg" .. tostring(x),
			Vector3.new(0.5, 1.8, 0.5),
			cframe * CFrame.new(x, 1, 0),
			VisualTheme.Colors.inkSoft,
			Enum.Material.Metal,
			"arrival-bench-leg"
		)
	end
end

local function addPlantingIsland(parent: Instance, name: string, center: Vector3, mirror: number)
	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("TinyWorldArtRole", "arrival-planting-island")
	model.Parent = parent

	for index, spec in {
		{ offset = Vector3.new(0, 0, 0), size = Vector3.new(12, 0.65, 5.5), yaw = mirror * 8 },
		{ offset = Vector3.new(mirror * 4.8, 0, 2.2), size = Vector3.new(7.5, 0.65, 4.5), yaw = mirror * 18 },
	} do
		decoration(
			model,
			"StoneBed" .. index,
			spec.size,
			CFrame.new(center + spec.offset + Vector3.new(0, 0.34, 0)) * CFrame.Angles(0, math.rad(spec.yaw), 0),
			VisualTheme.Colors.pathEdge,
			Enum.Material.Cobblestone,
			"arrival-planter-edge"
		)
		decoration(
			model,
			"Soil" .. index,
			Vector3.new(spec.size.X - 1, 0.26, spec.size.Z - 1),
			CFrame.new(center + spec.offset + Vector3.new(0, 0.7, 0)) * CFrame.Angles(0, math.rad(spec.yaw), 0),
			VisualTheme.Colors.timberDark,
			Enum.Material.Ground,
			"arrival-planter-soil"
		)
	end

	local treeTrunk = decoration(
		model,
		"FeatureTreeTrunk",
		Vector3.new(1.5, 5.8, 1.5),
		CFrame.new(center + Vector3.new(mirror * 1.5, 3.6, 0)),
		VisualTheme.Colors.timberDark,
		Enum.Material.Wood,
		"arrival-feature-tree-trunk"
	)
	treeTrunk:SetAttribute("TinyWorldDestinationCue", "village-square")
	for index, offset in {
		Vector3.new(-1.3, 7.2, 0),
		Vector3.new(1.5, 7.5, 0.4),
		Vector3.new(0, 8.7, -0.8),
	} do
		local canopy = decoration(
			model,
			"FeatureTreeCanopy" .. index,
			Vector3.new(5.6, 4.8, 5.4),
			CFrame.new(center + Vector3.new(mirror * 1.5, 0, 0) + offset),
			if index == 2 then VisualTheme.Colors.leafLight else VisualTheme.Colors.leaf,
			Enum.Material.LeafyGrass,
			"arrival-feature-tree-canopy"
		)
		canopy.Shape = Enum.PartType.Ball
	end

	for index, offset in {
		Vector3.new(-4, 1.4, -1.2),
		Vector3.new(-2.3, 1.4, 1.5),
		Vector3.new(2.5, 1.4, -1.4),
		Vector3.new(4.2, 1.4, 1.2),
	} do
		local flower = decoration(
			model,
			"Flower" .. index,
			Vector3.new(1.15, 1.15, 1.15),
			CFrame.new(center + offset),
			if index % 2 == 0 then VisualTheme.Colors.flower else VisualTheme.Colors.warmLight,
			Enum.Material.SmoothPlastic,
			"arrival-flower"
		)
		flower.Shape = Enum.PartType.Ball
	end
end

function VillageArrivalPolishBuilder.apply(root: Instance)
	local old = root:FindFirstChild("VillageArrivalPolish")
	if old then
		old:Destroy()
	end

	local model = Instance.new("Model")
	model.Name = "VillageArrivalPolish"
	model:SetAttribute("TinyWorldArtRole", "village-arrival-square")
	model:SetAttribute("TinyWorldVisualState", "authored-native")
	model.Parent = root

	-- A readable route from the invisible spawn anchor toward the fountain and market.
	decoration(
		model,
		"FountainApproach",
		Vector3.new(9, 0.12, 25),
		CFrame.new(0, 0.08, 12),
		VisualTheme.Colors.pathEdge,
		Enum.Material.Cobblestone,
		"arrival-fountain-approach"
	)
	decoration(
		model,
		"FountainApproachInset",
		Vector3.new(6.7, 0.08, 24),
		CFrame.new(0, 0.15, 12),
		VisualTheme.Colors.pathLight,
		Enum.Material.Pavement,
		"arrival-fountain-approach-inset"
	)

	addPlantingIsland(model, "ArrivalGardenWest", Vector3.new(-13, 0, 7), -1)
	addPlantingIsland(model, "ArrivalGardenEast", Vector3.new(13, 0, 7), 1)

	addBench(model, "ArrivalBenchWest", CFrame.new(-14, 0, -2) * CFrame.Angles(0, math.rad(25), 0))
	addBench(model, "ArrivalBenchEast", CFrame.new(14, 0, -2) * CFrame.Angles(0, math.rad(-25), 0))

	for index, position in {
		Vector3.new(-9, 7, -5),
		Vector3.new(9, 7, -5),
		Vector3.new(-10, 7, 18),
		Vector3.new(10, 7, 18),
	} do
		ArchitecturalDetailBuilder.addLantern(model, {
			name = "ArrivalLantern" .. index,
			role = "arrival-practical-lantern",
			cframe = CFrame.new(position),
			postHeight = 5.8,
			brightness = 0.44,
			range = 9,
		})
	end

	model:SetAttribute("TinyWorldFirstFramePolish", true)
end

return VillageArrivalPolishBuilder
