local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))

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

local function build(parent: Instance, origin: Vector3)
	local model = Instance.new("Model")
	model.Name = "HomeStoreDestination"
	model:SetAttribute("TinyWorldArtRole", "shop-home-store")
	model:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	model:SetAttribute("TinyWorldRecognizableSilhouette", true)
	model.Parent = parent

	makePart(
		model,
		"HomeStoreFloor",
		Vector3.new(30, 1, 24),
		origin + Vector3.new(0, 0.5, 0),
		VisualTheme.Colors.timber,
		Enum.Material.WoodPlanks,
		"home-store-floor"
	)
	makePart(
		model,
		"HomeStoreBackWall",
		Vector3.new(30, 10, 1),
		origin + Vector3.new(0, 5, -11.5),
		VisualTheme.Colors.cream,
		Enum.Material.Plaster,
		"home-store-wall"
	)
	for _, x in { -14.5, 14.5 } do
		makePart(
			model,
			"HomeStoreSideWall" .. tostring(x),
			Vector3.new(1, 10, 24),
			origin + Vector3.new(x, 5, 0),
			VisualTheme.Colors.cream,
			Enum.Material.Plaster,
			"home-store-wall"
		)
	end

	local roof = makeDecoration(
		model,
		"HomeStoreRoof",
		Vector3.new(34, 2.4, 28),
		origin + Vector3.new(0, 11.2, 0),
		VisualTheme.Colors.roof,
		Enum.Material.Slate,
		"home-store-roof"
	)
	roof:SetAttribute("TinyWorldVisualState", "authored-native")
	makeDecoration(
		model,
		"HomeStoreRoofCrown",
		Vector3.new(18, 2.5, 6),
		origin + Vector3.new(0, 13.2, -2),
		VisualTheme.Colors.berry,
		Enum.Material.Slate,
		"home-store-roof-crown"
	)

	for index, x in { -8, 8 } do
		local glass = makeDecoration(
			model,
			"HomeStoreWindow" .. index,
			Vector3.new(10, 6.5, 0.5),
			origin + Vector3.new(x, 5.2, 11.55),
			VisualTheme.Colors.sky,
			Enum.Material.Glass,
			"home-store-window"
		)
		glass.Transparency = 0.18
	end

	local sign = makeDecoration(
		model,
		"HomeStoreSign",
		Vector3.new(16, 3.4, 0.6),
		origin + Vector3.new(0, 9.2, 12),
		VisualTheme.Colors.berry,
		Enum.Material.WoodPlanks,
		"home-store-sign"
	)
	makeSurfaceLabel(sign, "HOME STORE")

	makeDecoration(
		model,
		"HomeStoreAwning",
		Vector3.new(22, 1, 5),
		origin + Vector3.new(0, 7.5, 13.5),
		VisualTheme.Colors.warmLight,
		Enum.Material.Fabric,
		"home-store-awning"
	)

	-- Exterior furniture samples create a furnishing-store read before text is needed.
	makeDecoration(
		model,
		"SampleSofaSeat",
		Vector3.new(8, 1.5, 3.5),
		origin + Vector3.new(-7, 1.4, 6),
		VisualTheme.Colors.skyDeep,
		Enum.Material.Fabric,
		"home-store-sofa-sample"
	)
	makeDecoration(
		model,
		"SampleSofaBack",
		Vector3.new(8, 3.5, 1.2),
		origin + Vector3.new(-7, 3.1, 4.8),
		VisualTheme.Colors.skyDeep,
		Enum.Material.Fabric,
		"home-store-sofa-sample"
	)
	makeDecoration(
		model,
		"SampleTableTop",
		Vector3.new(6, 0.6, 4),
		origin + Vector3.new(7, 3.4, 5),
		VisualTheme.Colors.timber,
		Enum.Material.WoodPlanks,
		"home-store-table-sample"
	)
	for _, x in { 5, 9 } do
		makeDecoration(
			model,
			"SampleTableLeg" .. tostring(x),
			Vector3.new(0.6, 3, 0.6),
			origin + Vector3.new(x, 1.7, 5),
			VisualTheme.Colors.timberDark,
			Enum.Material.Wood,
			"home-store-table-sample"
		)
	end

	local supplyCounter = makeAnchor(
		model,
		"HomeStoreSupplyCounter",
		Vector3.new(7, 4, 3),
		origin + Vector3.new(-9, 2.4, 9),
		VisualTheme.Colors.timber,
		Enum.Material.WoodPlanks,
		"home-supply-counter"
	)
	local styleDisplay = makeAnchor(
		model,
		"HomeStoreStyleDisplay",
		Vector3.new(7, 4, 3),
		origin + Vector3.new(0, 2.4, 9),
		VisualTheme.Colors.flower,
		Enum.Material.Fabric,
		"home-style-display"
	)
	local galleryDisplay = makeAnchor(
		model,
		"HomeStoreGalleryDisplay",
		Vector3.new(7, 4, 3),
		origin + Vector3.new(9, 2.4, 9),
		VisualTheme.Colors.gold,
		Enum.Material.WoodPlanks,
		"home-decor-gallery"
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
