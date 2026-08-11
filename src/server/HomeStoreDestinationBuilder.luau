local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))
local ArchitecturalDetailBuilder = require(script.Parent:WaitForChild("ArchitecturalDetailBuilder"))

local HomeStoreDestinationBuilder = {}

local function makePart(
	parent: Instance,
	name: string,
	size: Vector3,
	position: Vector3,
	color: Color3,
	material: Enum.Material,
	artRole: string
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
	part:SetAttribute("TinyWorldArtRole", artRole)
	part:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	part.Parent = parent
	return part
end

local function makeDecoration(
	parent: Instance,
	name: string,
	size: Vector3,
	position: Vector3,
	color: Color3,
	material: Enum.Material,
	artRole: string
): Part
	local part = makePart(parent, name, size, position, color, material, artRole)
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	return part
end

local function makeAnchor(
	parent: Instance,
	name: string,
	size: Vector3,
	position: Vector3,
	color: Color3,
	material: Enum.Material,
	artRole: string
): Part
	local part = makePart(parent, name, size, position, color, material, artRole)
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = true
	part:SetAttribute("TinyWorldInteractionAnchor", true)
	return part
end

local function makePrompt(anchor: BasePart, actionText: string, objectText: string): ProximityPrompt
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = actionText
	prompt.ObjectText = objectText
	prompt.HoldDuration = 0.2
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = anchor
	return prompt
end

local function makeSurfaceLabel(parent: BasePart, text: string)
	local gui = Instance.new("SurfaceGui")
	gui.Name = "HomeStoreSignSurface"
	gui.Face = Enum.NormalId.Front
	gui.AlwaysOnTop = false
	gui.LightInfluence = 1
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 42
	gui.Parent = parent

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Text = text
	label.TextColor3 = VisualTheme.Colors.paper
	label.TextScaled = true
	label.TextWrapped = true
	label.Font = Enum.Font.GothamBold
	label.Parent = gui

	local constraint = Instance.new("UITextSizeConstraint")
	constraint.MinTextSize = 10
	constraint.MaxTextSize = 26
	constraint.Parent = label
end

local function addPlanter(parent: Instance, name: string, position: Vector3, accent: Color3)
	makeDecoration(
		parent,
		name .. "Box",
		Vector3.new(4.2, 1, 1.8),
		position,
		VisualTheme.Colors.timber,
		Enum.Material.WoodPlanks,
		"home-store-planter"
	)
	for index, x in { -1.2, 0, 1.2 } do
		local plant = makeDecoration(
			parent,
			name .. "Plant" .. index,
			Vector3.new(1.1, 1.35 + (index % 2) * 0.25, 1.1),
			position + Vector3.new(x, 1.05, 0),
			if index == 2 then accent else VisualTheme.Colors.leafLight,
			Enum.Material.LeafyGrass,
			"home-store-planter-foliage"
		)
		plant.Shape = Enum.PartType.Ball
	end
end

local function addSofaSample(parent: Instance, origin: Vector3)
	makeDecoration(
		parent,
		"SampleSofaSeat",
		Vector3.new(7.5, 1.4, 3.6),
		origin + Vector3.new(-7.4, 1.5, 6.4),
		VisualTheme.Colors.skyDeep,
		Enum.Material.Fabric,
		"home-store-sofa-sample"
	)
	makeDecoration(
		parent,
		"SampleSofaBack",
		Vector3.new(7.5, 3.4, 1.1),
		origin + Vector3.new(-7.4, 3.1, 5.1),
		VisualTheme.Colors.skyDeep,
		Enum.Material.Fabric,
		"home-store-sofa-sample"
	)
	for _, x in { -10.5, -4.3 } do
		makeDecoration(
			parent,
			"SampleSofaArm" .. tostring(x),
			Vector3.new(1, 2.7, 3.6),
			origin + Vector3.new(x, 2.1, 6.4),
			VisualTheme.Colors.skyDeep,
			Enum.Material.Fabric,
			"home-store-sofa-sample"
		)
	end
	makeDecoration(
		parent,
		"SampleCushion",
		Vector3.new(2.2, 1.2, 0.7),
		origin + Vector3.new(-7.4, 3.4, 6.1),
		VisualTheme.Colors.flower,
		Enum.Material.Fabric,
		"home-store-cushion-sample"
	)
end

local function addTableSample(parent: Instance, origin: Vector3)
	makeDecoration(
		parent,
		"SampleTableTop",
		Vector3.new(6, 0.6, 4),
		origin + Vector3.new(7, 3.4, 5.7),
		VisualTheme.Colors.timber,
		Enum.Material.WoodPlanks,
		"home-store-table-sample"
	)
	for _, x in { 5, 9 } do
		for _, z in { 4.3, 7.1 } do
			makeDecoration(
				parent,
				"SampleTableLeg" .. tostring(x) .. tostring(z),
				Vector3.new(0.55, 3, 0.55),
				origin + Vector3.new(x, 1.7, z),
				VisualTheme.Colors.timberDark,
				Enum.Material.Wood,
				"home-store-table-sample"
			)
		end
	end
	makeDecoration(
		parent,
		"SampleVase",
		Vector3.new(1.1, 1.5, 1.1),
		origin + Vector3.new(7, 4.35, 5.7),
		VisualTheme.Colors.berry,
		Enum.Material.SmoothPlastic,
		"home-store-homeware-sample"
	)
end

local function build(parent: Instance, origin: Vector3)
	local model = Instance.new("Model")
	model.Name = "HomeStoreDestination"
	model:SetAttribute("TinyWorldArtRole", "shop-home-store")
	model:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	model:SetAttribute("TinyWorldRecognizableSilhouette", true)
	model:SetAttribute("TinyWorldVisualState", "authored-native")
	model.Parent = parent

	makePart(
		model,
		"HomeStoreFoundation",
		Vector3.new(31.5, 1.2, 25.5),
		origin + Vector3.new(0, 0.25, 0),
		VisualTheme.Colors.pathEdge,
		Enum.Material.Cobblestone,
		"home-store-foundation"
	)
	makePart(
		model,
		"HomeStoreFloor",
		Vector3.new(30, 0.7, 24),
		origin + Vector3.new(0, 0.9, 0),
		VisualTheme.Colors.timber,
		Enum.Material.WoodPlanks,
		"home-store-floor"
	)
	makePart(
		model,
		"HomeStoreBackWall",
		Vector3.new(30, 10, 1),
		origin + Vector3.new(0, 5.8, -11.5),
		VisualTheme.Colors.cream,
		Enum.Material.Plaster,
		"home-store-wall"
	)
	for _, x in { -14.5, 14.5 } do
		makePart(
			model,
			"HomeStoreSideWall" .. tostring(x),
			Vector3.new(1, 10, 24),
			origin + Vector3.new(x, 5.8, 0),
			VisualTheme.Colors.cream,
			Enum.Material.Plaster,
			"home-store-wall"
		)
	end
	for index, values in
		{
			{ x = -10.5, width = 9 },
			{ x = 10.5, width = 9 },
		}
	do
		makePart(
			model,
			"HomeStoreFrontWall" .. index,
			Vector3.new(values.width, 10, 1),
			origin + Vector3.new(values.x, 5.8, 11.5),
			VisualTheme.Colors.cream,
			Enum.Material.Plaster,
			"home-store-front-wall"
		)
	end

	ArchitecturalDetailBuilder.addPitchedRoof(model, {
		name = "HomeStorePitchedRoof",
		role = "home-store-roof",
		width = 30,
		depth = 24,
		center = origin + Vector3.new(0, 11, 0),
		rise = 5.6,
		eave = 1.4,
		color = VisualTheme.Colors.roof,
		ridgeColor = VisualTheme.Colors.berry,
		gableTrimColor = VisualTheme.Colors.creamDeep,
	})

	for index, x in { -9.5, 9.5 } do
		ArchitecturalDetailBuilder.addWindow(model, {
			name = "HomeStoreWindow" .. index,
			role = "home-store-display-window",
			width = 6.8,
			height = 5.4,
			cframe = CFrame.new(origin + Vector3.new(x, 5.7, 12.05)),
			frameColor = VisualTheme.Colors.timberDark,
			sillColor = VisualTheme.Colors.woodLight,
			glassColor = VisualTheme.Colors.inkGlass,
			transparency = 0.4,
			warmLight = true,
		})
	end

	ArchitecturalDetailBuilder.addDoor(model, {
		name = "HomeStoreEntry",
		role = "home-store-entry",
		width = 4.8,
		height = 7,
		cframe = CFrame.new(origin + Vector3.new(0, 4.5, 12.05)),
		color = VisualTheme.Colors.timberDark,
		frameColor = VisualTheme.Colors.woodLight,
	})
	ArchitecturalDetailBuilder.addPorch(model, {
		name = "HomeStoreEntryPorch",
		role = "home-store-entry-porch",
		width = 10,
		depth = 4.4,
		cframe = CFrame.new(origin + Vector3.new(0, 1.25, 13.7)),
		deckColor = VisualTheme.Colors.timber,
		canopyColor = VisualTheme.Colors.berry,
	})
	for index, x in { -5.8, 5.8 } do
		ArchitecturalDetailBuilder.addLantern(model, {
			name = "HomeStoreLantern" .. index,
			role = "home-store-practical-lantern",
			cframe = CFrame.new(origin + Vector3.new(x, 7, 12.8)),
			brightness = 0.5,
			range = 9,
		})
	end

	local sign = makeDecoration(
		model,
		"HomeStoreSign",
		Vector3.new(13, 2.6, 0.55),
		origin + Vector3.new(0, 9.1, 12.65),
		VisualTheme.Colors.berry,
		Enum.Material.WoodPlanks,
		"home-store-sign"
	)
	makeSurfaceLabel(sign, "HOME STORE")

	addSofaSample(model, origin)
	addTableSample(model, origin)
	addPlanter(model, "HomeStorePlanterLeft", origin + Vector3.new(-12, 1.2, 14), VisualTheme.Colors.flower)
	addPlanter(model, "HomeStorePlanterRight", origin + Vector3.new(12, 1.2, 14), VisualTheme.Colors.warmLight)

	local supplyCounter = makeAnchor(
		model,
		"HomeStoreSupplyCounter",
		Vector3.new(6.5, 3.6, 3),
		origin + Vector3.new(-8, 2.5, 8.4),
		VisualTheme.Colors.timber,
		Enum.Material.WoodPlanks,
		"home-supply-counter"
	)
	makeDecoration(
		model,
		"SupplyCounterTop",
		Vector3.new(7, 0.35, 3.3),
		origin + Vector3.new(-8, 4.4, 8.4),
		VisualTheme.Colors.woodLight,
		Enum.Material.Wood,
		"home-supply-counter-top"
	)
	local styleDisplay = makeAnchor(
		model,
		"HomeStoreStyleDisplay",
		Vector3.new(5.5, 4, 2.8),
		origin + Vector3.new(0, 2.6, 8.2),
		VisualTheme.Colors.flower,
		Enum.Material.Fabric,
		"home-style-display"
	)
	makeDecoration(
		model,
		"StyleDisplayFrame",
		Vector3.new(6.2, 4.7, 0.4),
		origin + Vector3.new(0, 2.7, 6.7),
		VisualTheme.Colors.timberDark,
		Enum.Material.Wood,
		"home-style-display-frame"
	)
	local galleryDisplay = makeAnchor(
		model,
		"HomeStoreGalleryDisplay",
		Vector3.new(6.5, 3.8, 3),
		origin + Vector3.new(8, 2.5, 8.4),
		VisualTheme.Colors.gold,
		Enum.Material.WoodPlanks,
		"home-decor-gallery"
	)
	makeDecoration(
		model,
		"GalleryShelf",
		Vector3.new(7, 0.4, 2.5),
		origin + Vector3.new(8, 4.4, 8.4),
		VisualTheme.Colors.woodLight,
		Enum.Material.Wood,
		"home-decor-gallery-shelf"
	)

	return model,
		makePrompt(supplyCounter, "Buy Next Essential", "Home Store"),
		makePrompt(styleDisplay, "Change Home Style", "Home Store"),
		makePrompt(galleryDisplay, "Browse Home Decor", "Home Store")
end

function HomeStoreDestinationBuilder.extend(world)
	for _, prompt in { world.homeSupplyPrompt, world.homeStylePrompt, world.homeDecorPrompt } do
		if prompt then
			prompt:Destroy()
		end
	end

	local model, supplyPrompt, stylePrompt, decorPrompt = build(world.root, Vector3.new(-44, 0, -44))
	world.homeStore = model
	world.homeSupplyPrompt = supplyPrompt
	world.homeStylePrompt = stylePrompt
	world.homeDecorPrompt = decorPrompt
	return model
end

return HomeStoreDestinationBuilder
