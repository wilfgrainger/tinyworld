local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))

local AuthoredPrefabBuilder = {}

local function makeModel(parent: Instance, name: string, artRole: string): Model
	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("TinyWorldArtRole", artRole)
	model:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	model.Parent = parent
	return model
end

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

local function makeShapeDecoration(
	parent: Instance,
	name: string,
	size: Vector3,
	position: Vector3,
	color: Color3,
	material: Enum.Material,
	shape: Enum.PartType,
	artRole: string
): Part
	local part = makeDecoration(parent, name, size, position, color, material, artRole)
	part.Shape = shape
	return part
end

local function makeWedgeDecoration(
	parent: Instance,
	name: string,
	size: Vector3,
	position: Vector3,
	orientation: Vector3,
	color: Color3,
	material: Enum.Material,
	artRole: string
): WedgePart
	local part = Instance.new("WedgePart")
	part.Name = name
	part.Anchored = true
	part.Size = size
	part.Position = position
	part.Orientation = orientation
	part.Color = color
	part.Material = material
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part:SetAttribute("TinyWorldArtRole", artRole)
	part:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	part.Parent = parent
	return part
end

local function makeAnchor(parent: Instance, name: string, size: Vector3, position: Vector3, artRole: string): Part
	local anchor =
		makePart(parent, name, size, position, VisualTheme.Colors.paper, Enum.Material.SmoothPlastic, artRole)
	anchor.Transparency = 1
	anchor.CanCollide = false
	anchor.CanTouch = false
	anchor.CanQuery = true
	anchor:SetAttribute("TinyWorldInteractionAnchor", true)
	return anchor
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

local function makeInteractablePart(
	parent: Instance,
	name: string,
	size: Vector3,
	position: Vector3,
	color: Color3,
	material: Enum.Material,
	artRole: string
): Part
	local part = makePart(parent, name, size, position, color, material, artRole)
	part.CanQuery = true
	part:SetAttribute("TinyWorldInteractionAnchor", true)
	return part
end

local function makeSurfaceLabel(parent: BasePart, text: string): TextLabel
	local gui = Instance.new("SurfaceGui")
	gui.Name = "SignSurface"
	gui.Face = Enum.NormalId.Front
	gui.AlwaysOnTop = false
	gui.LightInfluence = 1
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 42
	gui.Parent = parent

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.TextColor3 = VisualTheme.Colors.paper
	label.TextWrapped = true
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.Parent = gui
	local constraint = Instance.new("UITextSizeConstraint")
	constraint.MinTextSize = 10
	constraint.MaxTextSize = 24
	constraint.Parent = label
	return label
end

local function makeWindow(parent: Instance, name: string, position: Vector3, artRole: string)
	makeDecoration(
		parent,
		name .. "Frame",
		Vector3.new(6, 5, 0.5),
		position,
		VisualTheme.Colors.timberDark,
		Enum.Material.Wood,
		artRole .. "-window-frame"
	)
	local glass = makeDecoration(
		parent,
		name,
		Vector3.new(5, 4, 0.55),
		position + Vector3.new(0, 0, 0.08),
		VisualTheme.Colors.sky,
		Enum.Material.Glass,
		artRole .. "-window"
	)
	glass.Reflectance = 0.1
	makeDecoration(
		parent,
		name .. "Sill",
		Vector3.new(6.6, 0.5, 1.2),
		position + Vector3.new(0, -2.5, 0.4),
		VisualTheme.Colors.timber,
		Enum.Material.WoodPlanks,
		artRole .. "-window-sill"
	)
end

local function buildPortalFrameParts(model: Model, name: string, position: Vector3, accentColor: Color3)
	makeDecoration(
		model,
		name .. "Platform",
		Vector3.new(26, 0.6, 20),
		position + Vector3.new(0, 0.3, 0),
		VisualTheme.Colors.pathEdge,
		Enum.Material.Cobblestone,
		"world-portal-platform"
	)
	local glowRing = makeShapeDecoration(
		model,
		name .. "GlowRing",
		Vector3.new(28, 0.18, 22),
		position + Vector3.new(0, 0.75, 0),
		accentColor,
		Enum.Material.Neon,
		Enum.PartType.Cylinder,
		"world-portal-glow-ring"
	)
	glowRing.Transparency = 0.58
	makeDecoration(
		model,
		name .. "PortalArchLeft",
		Vector3.new(3.5, 15, 3.5),
		position + Vector3.new(-8, 8, 0),
		VisualTheme.Colors.pathEdge,
		Enum.Material.Marble,
		"world-portal-arch"
	)
	makeDecoration(
		model,
		name .. "PortalArchRight",
		Vector3.new(3.5, 15, 3.5),
		position + Vector3.new(8, 8, 0),
		VisualTheme.Colors.pathEdge,
		Enum.Material.Marble,
		"world-portal-arch"
	)
	makeWedgeDecoration(
		model,
		name .. "PortalArchTop",
		Vector3.new(19, 4, 4),
		position + Vector3.new(0, 16, 0),
		Vector3.new(0, 0, 0),
		VisualTheme.Colors.roof,
		Enum.Material.Slate,
		"world-portal-arch-crown"
	)
	makeDecoration(
		model,
		name .. "PortalArchTrim",
		Vector3.new(23, 1, 4.5),
		position + Vector3.new(0, 18.1, 0),
		accentColor,
		Enum.Material.Metal,
		"world-portal-arch-trim"
	)
	makeShapeDecoration(
		model,
		name .. "PortalCrown",
		Vector3.new(3.8, 3.8, 3.8),
		position + Vector3.new(0, 20.5, 0),
		VisualTheme.Colors.crystal,
		Enum.Material.Glass,
		Enum.PartType.Ball,
		"world-portal-crown"
	)
	for index, x in { -5, 0, 5 } do
		local crystal = makeShapeDecoration(
			model,
			name .. "PortalCrystal" .. index,
			Vector3.new(2.4, 2.4, 2.4),
			position + Vector3.new(x, 19.5, 0),
			accentColor,
			Enum.Material.Glass,
			Enum.PartType.Ball,
			"world-portal-crystal"
		)
		crystal.Reflectance = 0.12
	end
end

function AuthoredPrefabBuilder.buildPortalFrame(parent: Instance, name: string, position: Vector3): Model
	local model = makeModel(parent, name, "world-portal-frame")
	buildPortalFrameParts(model, name, position, VisualTheme.Colors.portalGlow)
	return model
end

function AuthoredPrefabBuilder.buildWorldPortal(
	parent: Instance,
	name: string,
	position: Vector3,
	accentColor: Color3,
	labelText: string,
	actionText: string,
	objectText: string
): (Model, ProximityPrompt)
	local model = makeModel(parent, name .. "Prefab", "world-portal")
	buildPortalFrameParts(model, name .. "Frame", position, accentColor)

	local lens = makeInteractablePart(
		model,
		name,
		Vector3.new(12, 2, 12),
		position + Vector3.new(0, 6, 0),
		accentColor,
		Enum.Material.Glass,
		"world-portal-lens"
	)
	lens.Shape = Enum.PartType.Cylinder
	lens.Orientation = Vector3.new(90, 0, 0)
	lens.Transparency = 0.18
	lens.Reflectance = 0.1
	local lensGlow = makeShapeDecoration(
		model,
		name .. "PortalLens",
		Vector3.new(13.2, 0.3, 13.2),
		position + Vector3.new(0, 6, 1.1),
		accentColor,
		Enum.Material.Neon,
		Enum.PartType.Cylinder,
		"world-portal-lens-glow"
	)
	lensGlow.Orientation = Vector3.new(90, 0, 0)
	lensGlow.Transparency = 0.72
	local prompt = makePrompt(lens, actionText, objectText)
	return model, prompt
end

function AuthoredPrefabBuilder.buildSugarCrystal(
	parent: Instance,
	name: string,
	basePosition: Vector3,
	labelText: string
): (Model, ProximityPrompt)
	local model = makeModel(parent, name .. "Prefab", "portal-collectible-sugar-crystal")
	makeShapeDecoration(
		model,
		"SugarCrystalPedestal",
		Vector3.new(8, 1, 8),
		basePosition + Vector3.new(0, 0.5, 0),
		VisualTheme.Colors.pathEdge,
		Enum.Material.Marble,
		Enum.PartType.Cylinder,
		"sugar-crystal-pedestal"
	)
	makeShapeDecoration(
		model,
		"SugarCrystalPedestalInset",
		Vector3.new(6.8, 0.22, 6.8),
		basePosition + Vector3.new(0, 1.1, 0),
		VisualTheme.Colors.crystal,
		Enum.Material.Glass,
		Enum.PartType.Cylinder,
		"sugar-crystal-pedestal-inset"
	)
	local core = makeInteractablePart(
		model,
		"SugarCrystalCore",
		Vector3.new(2.8, 5.8, 2.8),
		basePosition + Vector3.new(0, 4, 0),
		VisualTheme.Colors.crystal,
		Enum.Material.Glass,
		"sugar-crystal-core"
	)
	core.CanCollide = false
	core.CanTouch = false
	core.Shape = Enum.PartType.Block
	core.Transparency = 0.08
	core.Reflectance = 0.15
	core:SetAttribute("TinyWorldCollectible", "SugarCrystal")
	core:SetAttribute("TinyWorldRecognizableSilhouette", true)
	local facetLeft = makeWedgeDecoration(
		model,
		"SugarCrystalFacetLeft",
		Vector3.new(1.6, 5, 2.6),
		basePosition + Vector3.new(-1.1, 4, 0),
		Vector3.new(0, 0, -18),
		VisualTheme.Colors.paper,
		Enum.Material.Glass,
		"sugar-crystal-facet"
	)
	facetLeft.Transparency = 0.35
	local facetRight = makeWedgeDecoration(
		model,
		"SugarCrystalFacetRight",
		Vector3.new(1.6, 5, 2.6),
		basePosition + Vector3.new(1.1, 4, 0),
		Vector3.new(0, 180, 18),
		VisualTheme.Colors.crystal,
		Enum.Material.Ice,
		"sugar-crystal-facet"
	)
	facetRight.Transparency = 0.24
	makeShapeDecoration(
		model,
		"SugarCrystalCrown",
		Vector3.new(1.4, 1.4, 1.4),
		basePosition + Vector3.new(0, 7.1, 0),
		VisualTheme.Colors.paper,
		Enum.Material.Glass,
		Enum.PartType.Ball,
		"sugar-crystal-crown"
	)
	return model, makePrompt(core, "Collect Crystal", labelText)
end

function AuthoredPrefabBuilder.buildMoonlitSeed(
	parent: Instance,
	name: string,
	basePosition: Vector3,
	labelText: string
): (Model, ProximityPrompt)
	local model = makeModel(parent, name .. "Prefab", "portal-collectible-moonlit-seed")
	makeShapeDecoration(
		model,
		"MoonlitSeedPedestal",
		Vector3.new(7, 0.8, 7),
		basePosition + Vector3.new(0, 0.4, 0),
		VisualTheme.Colors.pathEdge,
		Enum.Material.Marble,
		Enum.PartType.Cylinder,
		"moonlit-seed-pedestal"
	)
	makeShapeDecoration(
		model,
		"MoonlitSeedSoil",
		Vector3.new(5.5, 0.22, 5.5),
		basePosition + Vector3.new(0, 0.9, 0),
		VisualTheme.Colors.timberDark,
		Enum.Material.Ground,
		Enum.PartType.Cylinder,
		"moonlit-seed-soil"
	)
	local seed = makeInteractablePart(
		model,
		"MoonlitSeedBody",
		Vector3.new(2.6, 3.8, 2.6),
		basePosition + Vector3.new(0, 2.9, 0),
		VisualTheme.Colors.flower,
		Enum.Material.SmoothPlastic,
		"moonlit-seed-body"
	)
	seed.CanCollide = false
	seed.CanTouch = false
	seed.Shape = Enum.PartType.Ball
	seed:SetAttribute("TinyWorldCollectible", "MeadowSeed")
	seed:SetAttribute("TinyWorldRecognizableSilhouette", true)
	local stem = makeDecoration(
		model,
		"MoonlitSeedStem",
		Vector3.new(0.35, 2.6, 0.35),
		basePosition + Vector3.new(0, 4.3, 0),
		VisualTheme.Colors.leaf,
		Enum.Material.Grass,
		"moonlit-seed-stem"
	)
	stem.Orientation = Vector3.new(0, 0, -12)
	local leafLeft = makeWedgeDecoration(
		model,
		"MoonlitSeedLeafLeft",
		Vector3.new(1.6, 0.35, 2.4),
		basePosition + Vector3.new(-0.9, 4.7, 0),
		Vector3.new(0, 0, -25),
		VisualTheme.Colors.leafLight,
		Enum.Material.LeafyGrass,
		"moonlit-seed-leaf"
	)
	leafLeft.Orientation = Vector3.new(0, 0, -25)
	local leafRight = makeWedgeDecoration(
		model,
		"MoonlitSeedLeafRight",
		Vector3.new(1.6, 0.35, 2.4),
		basePosition + Vector3.new(0.9, 4.5, 0),
		Vector3.new(0, 0, 25),
		VisualTheme.Colors.leaf,
		Enum.Material.LeafyGrass,
		"moonlit-seed-leaf"
	)
	leafRight.Orientation = Vector3.new(0, 0, 25)
	return model, makePrompt(seed, "Collect Seed", labelText)
end

function AuthoredPrefabBuilder.buildDailyFountain(parent: Instance, origin: Vector3): (Model, ProximityPrompt)
	local model = makeModel(parent, "DailyFountainPrefab", "civic-daily-fountain")
	makeShapeDecoration(
		model,
		"FountainBase",
		Vector3.new(16, 1, 16),
		origin + Vector3.new(0, 1, 0),
		VisualTheme.Colors.pathEdge,
		Enum.Material.Marble,
		Enum.PartType.Cylinder,
		"daily-fountain-base"
	)
	local basin = makeInteractablePart(
		model,
		"DailyFountain",
		Vector3.new(10, 2, 10),
		origin + Vector3.new(0, 2.4, 0),
		VisualTheme.Colors.cream,
		Enum.Material.Marble,
		"daily-fountain-basin"
	)
	basin.Shape = Enum.PartType.Cylinder
	makeShapeDecoration(
		model,
		"FountainBasin",
		Vector3.new(11.5, 0.9, 11.5),
		origin + Vector3.new(0, 1.9, 0),
		VisualTheme.Colors.creamDeep,
		Enum.Material.Marble,
		Enum.PartType.Cylinder,
		"daily-fountain-basin"
	)
	makeShapeDecoration(
		model,
		"FountainWater",
		Vector3.new(8.4, 0.28, 8.4),
		origin + Vector3.new(0, 3.35, 0),
		VisualTheme.Colors.water,
		Enum.Material.Glass,
		Enum.PartType.Cylinder,
		"daily-fountain-water"
	)
	makePart(
		model,
		"FountainPedestal",
		Vector3.new(3, 4, 3),
		origin + Vector3.new(0, 5.1, 0),
		VisualTheme.Colors.creamDeep,
		Enum.Material.Marble,
		"daily-fountain-pedestal"
	)
	local bowl = makeShapeDecoration(
		model,
		"FountainUpperBowl",
		Vector3.new(6, 1.2, 6),
		origin + Vector3.new(0, 7.2, 0),
		VisualTheme.Colors.cream,
		Enum.Material.Marble,
		Enum.PartType.Cylinder,
		"daily-fountain-bowl"
	)
	makeShapeDecoration(
		model,
		"FountainFinial",
		Vector3.new(1.8, 2.2, 1.8),
		origin + Vector3.new(0, 8.8, 0),
		VisualTheme.Colors.gold,
		Enum.Material.Metal,
		Enum.PartType.Ball,
		"daily-fountain-finial"
	)
	for index, offset in
		{
			Vector3.new(-3.4, 4.2, -3.4),
			Vector3.new(3.4, 4.2, -3.4),
			Vector3.new(-3.4, 4.2, 3.4),
			Vector3.new(3.4, 4.2, 3.4),
		}
	do
		makeShapeDecoration(
			model,
			"FountainWaterJet" .. index,
			Vector3.new(0.45, 1.7, 0.45),
			origin + offset,
			VisualTheme.Colors.water,
			Enum.Material.Glass,
			Enum.PartType.Cylinder,
			"daily-fountain-water-jet"
		)
	end
	local prompt = makePrompt(basin, "Claim Daily Reward", "Village Fountain")
	return model, prompt
end

function AuthoredPrefabBuilder.buildTownHall(parent: Instance, origin: Vector3)
	local model = makeModel(parent, "TownHallPrefab", "civic-town-hall")
	makePart(
		model,
		"TownHallFoundation",
		Vector3.new(30, 1, 24),
		origin + Vector3.new(0, 0.5, 0),
		VisualTheme.Colors.pathEdge,
		Enum.Material.Cobblestone,
		"town-hall-foundation"
	)
	makePart(
		model,
		"TownHallBody",
		Vector3.new(26, 12, 20),
		origin + Vector3.new(0, 7, 0),
		VisualTheme.Colors.cream,
		Enum.Material.Brick,
		"town-hall-body"
	)
	makeWedgeDecoration(
		model,
		"TownHallRoofLeft",
		Vector3.new(15, 5, 24),
		origin + Vector3.new(-6.5, 15, 0),
		Vector3.new(0, 0, 0),
		VisualTheme.Colors.roof,
		Enum.Material.Slate,
		"town-hall-roof"
	)
	makeWedgeDecoration(
		model,
		"TownHallRoofRight",
		Vector3.new(15, 5, 24),
		origin + Vector3.new(6.5, 15, 0),
		Vector3.new(0, 180, 0),
		VisualTheme.Colors.roof,
		Enum.Material.Slate,
		"town-hall-roof"
	)
	makePart(
		model,
		"TownHallClockTower",
		Vector3.new(8, 9, 8),
		origin + Vector3.new(0, 18, 0),
		VisualTheme.Colors.creamDeep,
		Enum.Material.Brick,
		"town-hall-clock-tower"
	)
	local clock = makeShapeDecoration(
		model,
		"TownHallClock",
		Vector3.new(5, 0.5, 5),
		origin + Vector3.new(0, 19, 4.15),
		VisualTheme.Colors.paper,
		Enum.Material.SmoothPlastic,
		Enum.PartType.Cylinder,
		"town-hall-clock"
	)
	clock.Orientation = Vector3.new(90, 0, 0)
	makeDecoration(
		model,
		"TownHallClockHandHour",
		Vector3.new(0.35, 1.6, 0.3),
		origin + Vector3.new(0, 19.6, 4.5),
		VisualTheme.Colors.ink,
		Enum.Material.Metal,
		"town-hall-clock-hand"
	)
	makeDecoration(
		model,
		"TownHallClockHandMinute",
		Vector3.new(1.8, 0.35, 0.3),
		origin + Vector3.new(0.8, 19, 4.5),
		VisualTheme.Colors.ink,
		Enum.Material.Metal,
		"town-hall-clock-hand"
	)
	makeShapeDecoration(
		model,
		"TownHallBell",
		Vector3.new(3, 3, 3),
		origin + Vector3.new(0, 24, 0),
		VisualTheme.Colors.gold,
		Enum.Material.Metal,
		Enum.PartType.Ball,
		"town-hall-bell"
	)
	makeDecoration(
		model,
		"TownHallDoor",
		Vector3.new(5, 8, 0.6),
		origin + Vector3.new(0, 4.5, 10.3),
		VisualTheme.Colors.timberDark,
		Enum.Material.Wood,
		"town-hall-door"
	)
	makeWindow(model, "TownHallWindowLeft", origin + Vector3.new(-8, 7, 10.25), "town-hall")
	makeWindow(model, "TownHallWindowRight", origin + Vector3.new(8, 7, 10.25), "town-hall")
	for index = 1, 3 do
		makePart(
			model,
			"TownHallSteps" .. index,
			Vector3.new(12 - index, 0.5, 2),
			origin + Vector3.new(0, index * 0.25, 11 + (index * 1.6)),
			VisualTheme.Colors.pathEdge,
			Enum.Material.Cobblestone,
			"town-hall-steps"
		)
	end
	local contributionAnchor = makeAnchor(
		model,
		"TownHallContributionAnchor",
		Vector3.new(7, 5, 4),
		origin + Vector3.new(10, 2.5, 13),
		"village-fund-ledger"
	)
	makeDecoration(
		model,
		"VillageFundCounter",
		Vector3.new(8, 3, 5),
		origin + Vector3.new(10, 1.5, 13),
		VisualTheme.Colors.timber,
		Enum.Material.WoodPlanks,
		"village-fund-counter"
	)
	makeDecoration(
		model,
		"VillageFundCoinJar",
		Vector3.new(2, 2.5, 2),
		origin + Vector3.new(10, 4, 13),
		VisualTheme.Colors.gold,
		Enum.Material.Glass,
		"village-fund-coin-jar"
	)
	local noticeboard = makeAnchor(
		model,
		"CivicNoticeboard",
		Vector3.new(12, 6, 1),
		origin + Vector3.new(-10, 4, 13),
		"profession-noticeboard"
	)
	noticeboard.Transparency = 0
	noticeboard.Color = VisualTheme.Colors.warmLight
	noticeboard.Material = Enum.Material.WoodPlanks
	noticeboard.CanCollide = false
	makeDecoration(
		model,
		"CivicNoticeboardFrame",
		Vector3.new(14, 8, 0.7),
		origin + Vector3.new(-10, 4, 13.3),
		VisualTheme.Colors.timberDark,
		Enum.Material.Wood,
		"profession-noticeboard-frame"
	)
	makeDecoration(
		model,
		"CivicNoticeboardPostLeft",
		Vector3.new(0.8, 5, 0.8),
		origin + Vector3.new(-15, 2.5, 13.5),
		VisualTheme.Colors.timberDark,
		Enum.Material.Wood,
		"profession-noticeboard-post"
	)
	makeDecoration(
		model,
		"CivicNoticeboardPostRight",
		Vector3.new(0.8, 5, 0.8),
		origin + Vector3.new(-5, 2.5, 13.5),
		VisualTheme.Colors.timberDark,
		Enum.Material.Wood,
		"profession-noticeboard-post"
	)
	for index, x in { -13, -10, -7 } do
		makeDecoration(
			model,
			"CivicJobCard" .. index,
			Vector3.new(2.2, 3.2, 0.2),
			origin + Vector3.new(x, 4, 13.85),
			if index % 2 == 0 then VisualTheme.Colors.sky else VisualTheme.Colors.paper,
			Enum.Material.SmoothPlastic,
			"profession-job-card"
		)
	end
	return model, contributionAnchor, noticeboard
end

function AuthoredPrefabBuilder.buildCourierDepot(parent: Instance, origin: Vector3)
	local model = makeModel(parent, "CourierDepotPrefab", "civic-courier-depot")
	makePart(
		model,
		"CourierDepotFloor",
		Vector3.new(28, 1, 22),
		origin + Vector3.new(0, 0.5, 0),
		VisualTheme.Colors.pathEdge,
		Enum.Material.Cobblestone,
		"courier-floor"
	)
	makePart(
		model,
		"CourierDepotBody",
		Vector3.new(24, 11, 18),
		origin + Vector3.new(0, 6, -1),
		VisualTheme.Colors.warmLight,
		Enum.Material.WoodPlanks,
		"courier-depot-body"
	)
	makeWedgeDecoration(
		model,
		"CourierDepotRoof",
		Vector3.new(28, 4, 22),
		origin + Vector3.new(0, 13, -1),
		Vector3.new(0, 0, 0),
		VisualTheme.Colors.roof,
		Enum.Material.Slate,
		"courier-depot-roof"
	)
	makeDecoration(
		model,
		"CourierLoadingAwning",
		Vector3.new(20, 1, 6),
		origin + Vector3.new(0, 9, 11),
		VisualTheme.Colors.berry,
		Enum.Material.Fabric,
		"courier-loading-awning"
	)
	makeDecoration(
		model,
		"CourierAwningPostLeft",
		Vector3.new(0.8, 8, 0.8),
		origin + Vector3.new(-9, 4, 13),
		VisualTheme.Colors.timberDark,
		Enum.Material.Wood,
		"courier-awning-post"
	)
	makeDecoration(
		model,
		"CourierAwningPostRight",
		Vector3.new(0.8, 8, 0.8),
		origin + Vector3.new(9, 4, 13),
		VisualTheme.Colors.timberDark,
		Enum.Material.Wood,
		"courier-awning-post"
	)
	makeDecoration(
		model,
		"CourierParcelShelf",
		Vector3.new(15, 6, 2),
		origin + Vector3.new(0, 3.5, -8),
		VisualTheme.Colors.timberDark,
		Enum.Material.Wood,
		"courier-parcel-shelf"
	)
	for index, x in { -5, 0, 5 } do
		makeDecoration(
			model,
			"CourierParcelBox" .. index,
			Vector3.new(3.5, 3, 3),
			origin + Vector3.new(x, 3, -6.5),
			VisualTheme.Colors.timber,
			Enum.Material.WoodPlanks,
			"courier-parcel"
		)
	end
	makeDecoration(
		model,
		"CourierHandcart",
		Vector3.new(8, 1.2, 4),
		origin + Vector3.new(-8, 2, 9),
		VisualTheme.Colors.timber,
		Enum.Material.WoodPlanks,
		"courier-handcart"
	)
	for index, x in { -4, 4 } do
		local wheel = makeShapeDecoration(
			model,
			"CourierHandcartWheel" .. index,
			Vector3.new(3.2, 0.8, 3.2),
			origin + Vector3.new(-8 + x, 1.6, 10.7),
			VisualTheme.Colors.ink,
			Enum.Material.Metal,
			Enum.PartType.Cylinder,
			"courier-handcart-wheel"
		)
		wheel.Orientation = Vector3.new(0, 0, 90)
	end
	makeDecoration(
		model,
		"CourierDeliveryCounter",
		Vector3.new(9, 3, 4),
		origin + Vector3.new(-8, 1.5, 13),
		VisualTheme.Colors.timber,
		Enum.Material.WoodPlanks,
		"courier-delivery-counter"
	)
	local pickupAnchor =
		makeAnchor(model, "CourierPickupAnchor", Vector3.new(8, 4, 5), origin + Vector3.new(3, 2, 13), "courier-pickup")
	local deliveryAnchor = makeAnchor(
		model,
		"CourierDeliveryAnchor",
		Vector3.new(8, 4, 5),
		origin + Vector3.new(-8, 2, 13),
		"courier-delivery"
	)
	return model, pickupAnchor, deliveryAnchor
end

function AuthoredPrefabBuilder.buildVillageShop(parent: Instance, origin: Vector3)
	local model = makeModel(parent, "VillageShopPrefab", "shop-village")
	makePart(
		model,
		"VillageShopFloor",
		Vector3.new(30, 1, 24),
		origin + Vector3.new(0, 0.5, 0),
		VisualTheme.Colors.pathEdge,
		Enum.Material.Cobblestone,
		"village-shop-floor"
	)
	makePart(
		model,
		"VillageShopBody",
		Vector3.new(26, 12, 20),
		origin + Vector3.new(0, 6.5, 0),
		VisualTheme.Colors.berry,
		Enum.Material.Brick,
		"village-shop-body"
	)
	makeWedgeDecoration(
		model,
		"VillageShopRoofLeft",
		Vector3.new(15, 4, 24),
		origin + Vector3.new(-6.5, 14, 0),
		Vector3.new(0, 0, 0),
		VisualTheme.Colors.roof,
		Enum.Material.Slate,
		"village-shop-roof"
	)
	makeWedgeDecoration(
		model,
		"VillageShopRoofRight",
		Vector3.new(15, 4, 24),
		origin + Vector3.new(6.5, 14, 0),
		Vector3.new(0, 180, 0),
		VisualTheme.Colors.roof,
		Enum.Material.Slate,
		"village-shop-roof"
	)
	makeDecoration(
		model,
		"ShopAwning",
		Vector3.new(24, 1.2, 5),
		origin + Vector3.new(0, 9, 12),
		VisualTheme.Colors.warmLight,
		Enum.Material.Fabric,
		"shop-awning"
	)
	makeWindow(model, "ShopfrontWindowLeft", origin + Vector3.new(-8, 6, 10.3), "shopfront")
	makeWindow(model, "ShopfrontWindowRight", origin + Vector3.new(8, 6, 10.3), "shopfront")
	makeDecoration(
		model,
		"ShopStockShelf",
		Vector3.new(18, 6, 2),
		origin + Vector3.new(0, 3.5, -8),
		VisualTheme.Colors.timberDark,
		Enum.Material.Wood,
		"shop-stock-shelf"
	)
	for index, x in { -6, 0, 6 } do
		makeDecoration(
			model,
			"ShopStockBasket" .. index,
			Vector3.new(4, 2.5, 3),
			origin + Vector3.new(x, 3, -6.5),
			if x == 0 then VisualTheme.Colors.flower else VisualTheme.Colors.gold,
			Enum.Material.Fabric,
			"shop-visible-stock"
		)
	end
	local deliveryAnchor = makeAnchor(
		model,
		"VillageShopDeliveryAnchor",
		Vector3.new(7, 5, 5),
		origin + Vector3.new(-15, 2.5, 0),
		"shop-delivery-counter"
	)
	makeDecoration(
		model,
		"VillageShopDeliveryCounter",
		Vector3.new(7, 3, 6),
		origin + Vector3.new(-14, 1.5, 0),
		VisualTheme.Colors.timber,
		Enum.Material.WoodPlanks,
		"shop-delivery-counter"
	)
	local supplyAnchor = makeAnchor(
		model,
		"HomeSupplyCounterAnchor",
		Vector3.new(7, 5, 5),
		origin + Vector3.new(-8, 2.5, 13),
		"home-supply-counter"
	)
	makeDecoration(
		model,
		"HomeSupplyCounter",
		Vector3.new(8, 3, 5),
		origin + Vector3.new(-8, 1.5, 13),
		VisualTheme.Colors.timber,
		Enum.Material.WoodPlanks,
		"home-supply-counter"
	)
	local styleAnchor = makeAnchor(
		model,
		"DecoratorCatalogueAnchor",
		Vector3.new(6, 5, 3),
		origin + Vector3.new(0, 3, 13),
		"decorator-catalogue"
	)
	makeDecoration(
		model,
		"DecoratorCatalogue",
		Vector3.new(6, 5, 1),
		origin + Vector3.new(0, 3, 13.4),
		VisualTheme.Colors.sky,
		Enum.Material.WoodPlanks,
		"decorator-catalogue"
	)
	local galleryAnchor = makeAnchor(
		model,
		"FurnishingShowroomAnchor",
		Vector3.new(7, 5, 5),
		origin + Vector3.new(8, 2.5, 13),
		"furnishing-showroom"
	)
	makeDecoration(
		model,
		"FurnishingShowroomTable",
		Vector3.new(8, 3, 5),
		origin + Vector3.new(8, 1.5, 13),
		VisualTheme.Colors.portal,
		Enum.Material.WoodPlanks,
		"furnishing-showroom"
	)
	makeDecoration(
		model,
		"FurnishingShowroomLamp",
		Vector3.new(1.5, 4, 1.5),
		origin + Vector3.new(8, 4.5, 13),
		VisualTheme.Colors.gold,
		Enum.Material.Neon,
		"furnishing-showroom-prop"
	)
	return model, deliveryAnchor, supplyAnchor, styleAnchor, galleryAnchor
end

function AuthoredPrefabBuilder.buildTransportWorkshop(parent: Instance, origin: Vector3)
	local model = makeModel(parent, "TransportWorkshopPrefab", "transport-workshop")
	makePart(
		model,
		"WorkshopFloor",
		Vector3.new(30, 1, 24),
		origin + Vector3.new(0, 0.5, 0),
		VisualTheme.Colors.pathEdge,
		Enum.Material.Concrete,
		"workshop-floor"
	)
	makePart(
		model,
		"WorkshopBackWall",
		Vector3.new(26, 11, 1),
		origin + Vector3.new(0, 6, -10),
		VisualTheme.Colors.sky,
		Enum.Material.Brick,
		"workshop-wall"
	)
	makePart(
		model,
		"WorkshopLeftWall",
		Vector3.new(1, 11, 20),
		origin + Vector3.new(-13, 6, 0),
		VisualTheme.Colors.sky,
		Enum.Material.Brick,
		"workshop-wall"
	)
	makePart(
		model,
		"WorkshopRightWall",
		Vector3.new(1, 11, 20),
		origin + Vector3.new(13, 6, 0),
		VisualTheme.Colors.sky,
		Enum.Material.Brick,
		"workshop-wall"
	)
	makeDecoration(
		model,
		"WorkshopGarage",
		Vector3.new(18, 9, 0.8),
		origin + Vector3.new(0, 5, 10),
		VisualTheme.Colors.inkSoft,
		Enum.Material.Metal,
		"workshop-open-garage"
	)
	makeDecoration(
		model,
		"WorkshopGarageTop",
		Vector3.new(27, 2, 1.5),
		origin + Vector3.new(0, 11, 10),
		VisualTheme.Colors.roof,
		Enum.Material.Slate,
		"workshop-garage-frame"
	)
	makeWedgeDecoration(
		model,
		"WorkshopRoof",
		Vector3.new(30, 4, 24),
		origin + Vector3.new(0, 14, 0),
		Vector3.new(0, 0, 0),
		VisualTheme.Colors.roof,
		Enum.Material.Slate,
		"workshop-roof"
	)
	makeDecoration(
		model,
		"WorkshopBikeStand",
		Vector3.new(12, 2, 3),
		origin + Vector3.new(-3, 1.5, 5),
		VisualTheme.Colors.timberDark,
		Enum.Material.Metal,
		"workshop-bike-stand"
	)
	for index, x in { -4, 4 } do
		local wheel = makeShapeDecoration(
			model,
			"WorkshopBikeWheel" .. index,
			Vector3.new(5, 0.8, 5),
			origin + Vector3.new(-3 + x, 4, 5),
			VisualTheme.Colors.ink,
			Enum.Material.Metal,
			Enum.PartType.Cylinder,
			"workshop-bike-wheel"
		)
		wheel.Orientation = Vector3.new(0, 0, 90)
	end
	makeDecoration(
		model,
		"WorkshopBikeFrame",
		Vector3.new(9, 0.7, 0.7),
		origin + Vector3.new(-3, 4.2, 5),
		VisualTheme.Colors.skyDeep,
		Enum.Material.Metal,
		"workshop-bike-frame"
	)
	makeDecoration(
		model,
		"WorkshopToolRack",
		Vector3.new(9, 6, 1),
		origin + Vector3.new(7, 4, -9),
		VisualTheme.Colors.timberDark,
		Enum.Material.Wood,
		"workshop-tool-rack"
	)
	for index, x in { -3, 0, 3 } do
		makeDecoration(
			model,
			"WorkshopTool" .. index,
			Vector3.new(0.6, 4, 0.6),
			origin + Vector3.new(7 + x, 4, -8.3),
			VisualTheme.Colors.metal,
			Enum.Material.Metal,
			"workshop-tool"
		)
	end
	local wheelSign = makeShapeDecoration(
		model,
		"WorkshopWheelSign",
		Vector3.new(7, 0.8, 7),
		origin + Vector3.new(9, 10, 10.7),
		VisualTheme.Colors.gold,
		Enum.Material.Metal,
		Enum.PartType.Cylinder,
		"workshop-wheel-sign"
	)
	wheelSign.Orientation = Vector3.new(90, 0, 0)
	local transportAnchor = makeAnchor(
		model,
		"TransportAnchor",
		Vector3.new(7, 5, 6),
		origin + Vector3.new(-14, 2.5, 0),
		"transport-bike-counter"
	)
	makeDecoration(
		model,
		"TransportServiceCounter",
		Vector3.new(7, 3, 6),
		origin + Vector3.new(-14, 1.5, 0),
		VisualTheme.Colors.skyDeep,
		Enum.Material.WoodPlanks,
		"transport-bike-counter"
	)
	return model, transportAnchor
end

function AuthoredPrefabBuilder.buildMarket(parent: Instance, origin: Vector3)
	local model = makeModel(parent, "VillageMarketPrefab", "market-table")
	makePart(
		model,
		"MarketPlatform",
		Vector3.new(38, 1, 26),
		origin,
		VisualTheme.Colors.pathEdge,
		Enum.Material.Cobblestone,
		"market-platform"
	)
	makeDecoration(
		model,
		"MarketTable",
		Vector3.new(27, 2, 12),
		origin + Vector3.new(0, 3, 4),
		VisualTheme.Colors.timber,
		Enum.Material.WoodPlanks,
		"market-table"
	)
	for index, x in { -11, 11 } do
		makeDecoration(
			model,
			"MarketTableLeg" .. index,
			Vector3.new(2, 5, 2),
			origin + Vector3.new(x, 1.5, 4),
			VisualTheme.Colors.timberDark,
			Enum.Material.Wood,
			"market-table-leg"
		)
	end
	makeDecoration(
		model,
		"MarketAwning",
		Vector3.new(34, 1, 20),
		origin + Vector3.new(0, 12, 2),
		VisualTheme.Colors.warmLight,
		Enum.Material.Fabric,
		"market-awning"
	)
	for index, x in { -15, 15 } do
		makeDecoration(
			model,
			"MarketAwningPost" .. index,
			Vector3.new(1, 12, 1),
			origin + Vector3.new(x, 6, 2),
			VisualTheme.Colors.timberDark,
			Enum.Material.Wood,
			"market-awning-post"
		)
	end
	makeDecoration(
		model,
		"MarketCrate",
		Vector3.new(6, 4, 5),
		origin + Vector3.new(0, 2.5, -8),
		VisualTheme.Colors.timberDark,
		Enum.Material.WoodPlanks,
		"market-stock-crate"
	)
	local sign = makeDecoration(
		model,
		"MarketStatusSign",
		Vector3.new(20, 6, 1),
		origin + Vector3.new(0, 8, -9),
		VisualTheme.Colors.timberDark,
		Enum.Material.Wood,
		"market-status-sign"
	)
	local statusLabel = makeSurfaceLabel(sign, "Trading Post")

	local sides = {}
	local sideSpecs = {
		{
			name = "A",
			x = -9,
			stoolName = "MarketStoolA",
			trayName = "TradeOfferTrayA",
			ledgerName = "MarketConfirmLedgerA",
			joinAnchorName = "MarketJoinAnchorA",
			offerAnchorName = "MarketOfferAnchorA",
			confirmAnchorName = "MarketConfirmAnchorA",
		},
		{
			name = "B",
			x = 9,
			stoolName = "MarketStoolB",
			trayName = "TradeOfferTrayB",
			ledgerName = "MarketConfirmLedgerB",
			joinAnchorName = "MarketJoinAnchorB",
			offerAnchorName = "MarketOfferAnchorB",
			confirmAnchorName = "MarketConfirmAnchorB",
		},
	}
	for side, spec in sideSpecs do
		makeDecoration(
			model,
			spec.stoolName,
			Vector3.new(5, 1.2, 5),
			origin + Vector3.new(spec.x, 1.2, -3),
			VisualTheme.Colors.skyDeep,
			Enum.Material.WoodPlanks,
			"market-stool"
		)
		makeDecoration(
			model,
			spec.trayName,
			Vector3.new(8, 0.8, 6),
			origin + Vector3.new(spec.x, 4.3, 4),
			VisualTheme.Colors.gold,
			Enum.Material.WoodPlanks,
			"market-offer-tray"
		)
		makeDecoration(
			model,
			spec.ledgerName,
			Vector3.new(5, 0.5, 4),
			origin + Vector3.new(spec.x, 4.7, 8),
			VisualTheme.Colors.leaf,
			Enum.Material.Fabric,
			"market-confirm-ledger"
		)
		local joinAnchor = makeAnchor(
			model,
			spec.joinAnchorName,
			Vector3.new(6, 4, 6),
			origin + Vector3.new(spec.x, 2, -3),
			"market-join"
		)
		local offerAnchor = makeAnchor(
			model,
			spec.offerAnchorName,
			Vector3.new(8, 4, 6),
			origin + Vector3.new(spec.x, 4, 4),
			"market-offer"
		)
		local confirmAnchor = makeAnchor(
			model,
			spec.confirmAnchorName,
			Vector3.new(6, 4, 5),
			origin + Vector3.new(spec.x, 4, 8),
			"market-confirm"
		)
		sides[side] = {
			joinPrompt = makePrompt(joinAnchor, "Join Trade " .. spec.name, "Trading Post"),
			offerPrompt = makePrompt(offerAnchor, "Choose Offer", "Trading Post"),
			confirmPrompt = makePrompt(confirmAnchor, "Confirm Trade", "Trading Post"),
		}
	end

	return model, sides, statusLabel
end

function AuthoredPrefabBuilder.buildPlotAffordances(parent: Instance, origin: Vector3)
	local model = makeModel(parent, "PlotAffordances", "plot-affordances")

	local drawingBoard = makeModel(model, "ArchitectDrawingBoard", "plot-architect-drawing-board")
	makeDecoration(
		drawingBoard,
		"DrawingBoardTop",
		Vector3.new(9, 0.8, 6),
		origin + Vector3.new(-14, 4.5, 23),
		VisualTheme.Colors.timber,
		Enum.Material.WoodPlanks,
		"architect-drawing-board"
	)
	makeDecoration(
		drawingBoard,
		"DrawingBoardPlan",
		Vector3.new(7, 0.2, 4),
		origin + Vector3.new(-14, 5, 23),
		VisualTheme.Colors.paper,
		Enum.Material.Fabric,
		"architect-house-plan"
	)
	makeWedgeDecoration(
		drawingBoard,
		"DrawingBoardLegLeft",
		Vector3.new(1, 5, 1),
		origin + Vector3.new(-17, 2.5, 23),
		Vector3.new(0, 0, -12),
		VisualTheme.Colors.timberDark,
		Enum.Material.Wood,
		"architect-easel-leg"
	)
	makeWedgeDecoration(
		drawingBoard,
		"DrawingBoardLegRight",
		Vector3.new(1, 5, 1),
		origin + Vector3.new(-11, 2.5, 23),
		Vector3.new(0, 0, 12),
		VisualTheme.Colors.timberDark,
		Enum.Material.Wood,
		"architect-easel-leg"
	)
	local upgradeAnchor = makeAnchor(
		drawingBoard,
		"ArchitectDrawingBoardAnchor",
		Vector3.new(8, 5, 6),
		origin + Vector3.new(-14, 3, 23),
		"plot-upgrade-anchor"
	)

	local gate = makeModel(model, "PlotGate", "plot-front-gate")
	makeDecoration(
		gate,
		"PlotGatePostLeft",
		Vector3.new(1, 6, 1),
		origin + Vector3.new(-4, 3, 29),
		VisualTheme.Colors.timberDark,
		Enum.Material.Wood,
		"plot-gate-post"
	)
	makeDecoration(
		gate,
		"PlotGatePostRight",
		Vector3.new(1, 6, 1),
		origin + Vector3.new(4, 3, 29),
		VisualTheme.Colors.timberDark,
		Enum.Material.Wood,
		"plot-gate-post"
	)
	makeDecoration(
		gate,
		"PlotGateDoor",
		Vector3.new(7, 4, 0.8),
		origin + Vector3.new(0, 2.5, 29),
		VisualTheme.Colors.timber,
		Enum.Material.WoodPlanks,
		"plot-gate-door"
	)
	makeShapeDecoration(
		gate,
		"FrontDoorBell",
		Vector3.new(1.3, 1.3, 1.3),
		origin + Vector3.new(4.2, 4, 29.7),
		VisualTheme.Colors.gold,
		Enum.Material.Metal,
		Enum.PartType.Ball,
		"front-door-bell"
	)
	makeDecoration(
		gate,
		"GatePrivacySign",
		Vector3.new(5, 3, 0.6),
		origin + Vector3.new(7, 3, 29.5),
		VisualTheme.Colors.sky,
		Enum.Material.WoodPlanks,
		"gate-privacy-sign"
	)
	local privacyAnchor = makeAnchor(
		gate,
		"FrontDoorBellAnchor",
		Vector3.new(4, 5, 3),
		origin + Vector3.new(7, 3, 29),
		"plot-privacy-anchor"
	)
	local visitAnchor =
		makeAnchor(gate, "PlotGateAnchor", Vector3.new(7, 5, 3), origin + Vector3.new(0, 3, 29), "plot-visit-anchor")

	local garden = makeModel(model, "PottingBenchAndFlowerArch", "plot-garden-charm")
	makeDecoration(
		garden,
		"PottingBench",
		Vector3.new(10, 2, 5),
		origin + Vector3.new(0, 2, -23),
		VisualTheme.Colors.timber,
		Enum.Material.WoodPlanks,
		"potting-bench"
	)
	makeDecoration(
		garden,
		"PottingBenchShelf",
		Vector3.new(9, 0.6, 3),
		origin + Vector3.new(0, 5, -24),
		VisualTheme.Colors.timberDark,
		Enum.Material.Wood,
		"potting-bench-shelf"
	)
	makeDecoration(
		garden,
		"FlowerArchLeft",
		Vector3.new(1, 8, 1),
		origin + Vector3.new(-6, 4, -23),
		VisualTheme.Colors.leaf,
		Enum.Material.LeafyGrass,
		"flower-arch"
	)
	makeDecoration(
		garden,
		"FlowerArchRight",
		Vector3.new(1, 8, 1),
		origin + Vector3.new(6, 4, -23),
		VisualTheme.Colors.leaf,
		Enum.Material.LeafyGrass,
		"flower-arch"
	)
	makeDecoration(
		garden,
		"FlowerArch",
		Vector3.new(13, 1, 1),
		origin + Vector3.new(0, 8, -23),
		VisualTheme.Colors.flower,
		Enum.Material.LeafyGrass,
		"flower-arch"
	)
	for index, x in { -4, 0, 4 } do
		makeShapeDecoration(
			garden,
			"PottingFlower" .. index,
			Vector3.new(1.5, 1.5, 1.5),
			origin + Vector3.new(x, 5.7, -24),
			if x == 0 then VisualTheme.Colors.warmLight else VisualTheme.Colors.flower,
			Enum.Material.SmoothPlastic,
			Enum.PartType.Ball,
			"potting-flower"
		)
	end
	local homeCharmAnchor = makeAnchor(
		garden,
		"PottingBenchAnchor",
		Vector3.new(9, 5, 5),
		origin + Vector3.new(0, 3, -23),
		"plot-home-charm-anchor"
	)

	return makePrompt(upgradeAnchor, "Upgrade Home", "Home Builder"),
		makePrompt(privacyAnchor, "Change Privacy", "Home Access"),
		makePrompt(visitAnchor, "Enter Home", "Front Gate"),
		makePrompt(homeCharmAnchor, "Add Home Charm", "Home Garden")
end

return AuthoredPrefabBuilder
