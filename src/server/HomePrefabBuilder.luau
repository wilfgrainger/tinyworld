local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))
local ArchitecturalDetailBuilder = require(script.Parent:WaitForChild("ArchitecturalDetailBuilder"))

local HomePrefabBuilder = {}

local function makePart(
	parent: Instance,
	name: string,
	size: Vector3,
	position: Vector3,
	color: Color3,
	material: Enum.Material?,
	artRole: string
): Part
	local item = Instance.new("Part")
	item.Name = name
	item.Anchored = true
	item.Size = size
	item.Position = position
	item.Color = color
	item.Material = material or Enum.Material.SmoothPlastic
	item.TopSurface = Enum.SurfaceType.Smooth
	item.BottomSurface = Enum.SurfaceType.Smooth
	item:SetAttribute("TinyWorldArtRole", artRole)
	item:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	item.Parent = parent
	return item
end

local function makeDecoration(
	parent: Instance,
	name: string,
	size: Vector3,
	position: Vector3,
	color: Color3,
	material: Enum.Material?,
	artRole: string
): Part
	local item = makePart(parent, name, size, position, color, material, artRole)
	item.CanCollide = false
	item.CanTouch = false
	item.CanQuery = false
	return item
end

local function makeAnchor(parent: Instance, name: string, size: Vector3, position: Vector3, artRole: string): Part
	local anchor = makeDecoration(
		parent,
		name,
		size,
		position,
		VisualTheme.Colors.paper,
		Enum.Material.SmoothPlastic,
		artRole
	)
	anchor.Transparency = 1
	anchor.CanQuery = true
	anchor:SetAttribute("TinyWorldInteractionAnchor", true)
	return anchor
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

local function addFlowerBox(parent: Instance, name: string, position: Vector3, accent: Color3)
	makeDecoration(
		parent,
		name .. "Box",
		Vector3.new(4.7, 0.65, 1.15),
		position,
		VisualTheme.Colors.timber,
		Enum.Material.WoodPlanks,
		"home-window-box"
	)
	for index, offset in { -1.3, 0, 1.3 } do
		local bloom = makeDecoration(
			parent,
			name .. "Bloom" .. index,
			Vector3.new(0.85, 0.85, 0.85),
			position + Vector3.new(offset, 0.8, 0),
			if index == 2 then VisualTheme.Colors.warmLight else accent,
			Enum.Material.SmoothPlastic,
			"home-window-bloom"
		)
		bloom.Shape = Enum.PartType.Ball
	end
end

local function addFoundation(parent: Instance, anchor: Vector3, width: number, depth: number)
	makePart(
		parent,
		"FoundationPlinth",
		Vector3.new(width + 1.2, 1.3, depth + 1.2),
		anchor + Vector3.new(0, 0.2, 0),
		VisualTheme.Colors.pathEdge,
		Enum.Material.Cobblestone,
		"home-foundation"
	)
	makePart(
		parent,
		"Floor",
		Vector3.new(width, 0.8, depth),
		anchor + Vector3.new(0, 0.85, 0),
		VisualTheme.Colors.timber,
		Enum.Material.WoodPlanks,
		"home-floor"
	)
end

local function addFrontWindows(
	parent: Instance,
	anchor: Vector3,
	width: number,
	height: number,
	frontZ: number,
	accent: Color3
)
	for index, x in { -width * 0.29, width * 0.29 } do
		ArchitecturalDetailBuilder.addWindow(parent, {
			name = "HouseWindow" .. index,
			role = "home-window",
			width = 4.4,
			height = 3.8,
			cframe = CFrame.new(anchor + Vector3.new(x, math.min(height - 2.8, 5.6), frontZ + 0.58)),
			frameColor = VisualTheme.Colors.timberDark,
			sillColor = VisualTheme.Colors.woodLight,
			glassColor = VisualTheme.Colors.inkGlass,
			transparency = 0.38,
			warmLight = true,
		})
		addFlowerBox(
			parent,
			"HouseWindowBox" .. index,
			anchor + Vector3.new(x, math.min(height - 4.7, 3.8), frontZ + 1.12),
			accent
		)
	end
end

local function addSideWindow(parent: Instance, anchor: Vector3, width: number, depth: number, height: number)
	local model = ArchitecturalDetailBuilder.addWindow(parent, {
		name = "HouseWindowSide",
		role = "home-window-side",
		width = 4,
		height = 3.4,
		cframe = CFrame.new(anchor + Vector3.new((width / 2) + 0.58, math.min(height - 2.8, 5.2), -depth * 0.18))
			* CFrame.Angles(0, math.rad(90), 0),
		frameColor = VisualTheme.Colors.timberDark,
		glassColor = VisualTheme.Colors.inkGlass,
		transparency = 0.4,
	})
	model:SetAttribute("TinyWorldArtRole", "home-side-window")
end

local function addTierDetails(parent: Instance, anchor: Vector3, tier: number, width: number, depth: number, height: number, wallColor: Color3, roofColor: Color3)
	if tier < 3 then
		return
	end

	local upperWidth = math.min(width * 0.48, 15)
	local upperDepth = math.min(depth * 0.48, 11)
	local upperHeight = 5.5 + (tier - 3)
	local upperCenter = anchor + Vector3.new(-width * 0.14, height + (upperHeight / 2) - 0.2, -1.2)
	makePart(
		parent,
		"UpperFeature",
		Vector3.new(upperWidth, upperHeight, upperDepth),
		upperCenter,
		wallColor,
		Enum.Material.Plaster,
		"home-upper-storey"
	)
	ArchitecturalDetailBuilder.addPitchedRoof(parent, {
		name = "UpperPitchedRoof",
		role = "home-upper-roof",
		width = upperWidth,
		depth = upperDepth,
		center = upperCenter + Vector3.new(0, upperHeight / 2 + 0.15, 0),
		rise = 3.2,
		eave = 0.8,
		color = roofColor,
		gableTrimColor = VisualTheme.Colors.creamDeep,
	})
	ArchitecturalDetailBuilder.addWindow(parent, {
		name = "HouseWindowUpper",
		role = "home-upper-window",
		width = 3.8,
		height = 3.2,
		cframe = CFrame.new(upperCenter + Vector3.new(0, 0.3, (upperDepth / 2) + 0.55)),
		frameColor = VisualTheme.Colors.timberDark,
		glassColor = VisualTheme.Colors.inkGlass,
		transparency = 0.4,
		warmLight = true,
	})

	if tier >= 4 then
		makeDecoration(
			parent,
			"UpperBalconyRail",
			Vector3.new(upperWidth * 0.7, 0.45, 0.45),
			upperCenter + Vector3.new(0, -upperHeight * 0.2, (upperDepth / 2) + 1.7),
			VisualTheme.Colors.timberDark,
			Enum.Material.Wood,
			"home-balcony-rail"
		)
	end

	if tier == 5 then
		local towerCenter = anchor + Vector3.new(width * 0.31, height + 3.8, -depth * 0.18)
		makePart(
			parent,
			"VillaTower",
			Vector3.new(6.5, 8, 6.5),
			towerCenter,
			wallColor,
			Enum.Material.Plaster,
			"home-villa-tower"
		)
		ArchitecturalDetailBuilder.addPitchedRoof(parent, {
			name = "VillaTowerRoof",
			role = "home-villa-tower-roof",
			width = 6.5,
			depth = 6.5,
			center = towerCenter + Vector3.new(0, 4.2, 0),
			rise = 3.6,
			eave = 0.7,
			color = VisualTheme.Colors.roofLight,
		})
	end
end

function HomePrefabBuilder.buildShell(parent: Instance, anchor: Vector3, profile, house)
	local shell = Instance.new("Model")
	shell.Name = "ResidentialShell"
	shell:SetAttribute("TinyWorldArtRole", "hero-home-shell")
	shell:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	shell:SetAttribute("TinyWorldRecognizableSilhouette", true)
	shell:SetAttribute("TinyWorldVisualState", "authored-native")
	shell.Parent = parent

	local tier = profile.houseTier
	local width = 18 + ((tier - 1) * 5)
	local depth = 16 + ((tier - 1) * 4)
	local height = 9 + ((tier - 1) * 2)
	local wallColors = {
		VisualTheme.Colors.cream,
		VisualTheme.Colors.warmLight,
		VisualTheme.Colors.paper,
		VisualTheme.Colors.cream,
		VisualTheme.Colors.paper,
	}
	local styleColours = {
		Meadow = VisualTheme.Colors.flower,
		Harbor = VisualTheme.Colors.skyDeep,
		Sunset = VisualTheme.Colors.berry,
	}
	local wallColor = wallColors[tier] or VisualTheme.Colors.cream
	local roofColor = if tier >= 3 then VisualTheme.Colors.roof else VisualTheme.Colors.timberDark
	local styleColour = styleColours[profile.homeTheme] or styleColours.Meadow
	local frontZ = depth / 2

	shell:SetAttribute("TinyWorldHouseTier", tier)
	shell:SetAttribute("TinyWorldHouseWidth", width)
	shell:SetAttribute("TinyWorldHouseDepth", depth)
	shell:SetAttribute("TinyWorldHouseHeight", height)
	shell:SetAttribute("TinyWorldHouseTheme", profile.homeTheme)

	addFoundation(shell, anchor, width, depth)

	makePart(
		shell,
		"BackWall",
		Vector3.new(width, height, 1),
		anchor + Vector3.new(0, (height / 2) + 1, -depth / 2),
		wallColor,
		Enum.Material.Plaster,
		"home-wall"
	)
	makePart(
		shell,
		"LeftWall",
		Vector3.new(1, height, depth),
		anchor + Vector3.new(-width / 2, (height / 2) + 1, 0),
		wallColor,
		Enum.Material.Plaster,
		"home-wall"
	)
	makePart(
		shell,
		"RightWall",
		Vector3.new(1, height, depth),
		anchor + Vector3.new(width / 2, (height / 2) + 1, 0),
		wallColor,
		Enum.Material.Plaster,
		"home-wall"
	)

	local entryWidth = 6.5
	local frontSegment = (width - entryWidth) / 2
	makePart(
		shell,
		"FrontLeft",
		Vector3.new(frontSegment, height, 1),
		anchor + Vector3.new(-((entryWidth / 2) + (frontSegment / 2)), (height / 2) + 1, frontZ),
		wallColor,
		Enum.Material.Plaster,
		"home-facade-wall"
	)
	makePart(
		shell,
		"FrontRight",
		Vector3.new(frontSegment, height, 1),
		anchor + Vector3.new((entryWidth / 2) + (frontSegment / 2), (height / 2) + 1, frontZ),
		wallColor,
		Enum.Material.Plaster,
		"home-facade-wall"
	)

	local facade = makeDecoration(
		shell,
		"FacadeBand",
		Vector3.new(width - 5, 0.45, 0.5),
		anchor + Vector3.new(0, height - 0.2, frontZ + 0.65),
		styleColour,
		Enum.Material.Wood,
		"home-theme-facade-trim"
	)

	local gable = ArchitecturalDetailBuilder.addPitchedRoof(shell, {
		name = "MainPitchedRoof",
		role = "home-main-roof",
		width = width,
		depth = depth,
		center = anchor + Vector3.new(0, height + 1.3, 0),
		rise = 4.1 + (tier * 0.25),
		eave = 1.15,
		color = roofColor,
		ridgeColor = VisualTheme.Colors.roofLight,
		gableTrimColor = VisualTheme.Colors.creamDeep,
	})

	local porchModel = ArchitecturalDetailBuilder.addPorch(shell, {
		name = "FrontPorch",
		role = "home-porch",
		width = math.min(11.5, width * 0.55),
		depth = 4.8,
		cframe = CFrame.new(anchor + Vector3.new(0, 1.15, frontZ + 2.5)),
		deckColor = VisualTheme.Colors.timber,
		canopyColor = roofColor,
	})
	local porch = porchModel:FindFirstChild("Deck")

	local _, frontDoor = ArchitecturalDetailBuilder.addDoor(shell, {
		name = "FrontDoorAssembly",
		role = "home-front-door",
		width = 4.2,
		height = 6.4,
		cframe = CFrame.new(anchor + Vector3.new(0, 4.25, frontZ + 0.6)),
		color = VisualTheme.Colors.timberDark,
		frameColor = VisualTheme.Colors.woodLight,
	})
	frontDoor.Name = "FrontDoor"

	addFrontWindows(shell, anchor + Vector3.new(0, 1, 0), width, height, frontZ, styleColour)
	addSideWindow(shell, anchor + Vector3.new(0, 1, 0), width, depth, height)

	ArchitecturalDetailBuilder.addChimney(shell, {
		name = "CabinChimney",
		role = "home-chimney",
		cframe = CFrame.new(anchor + Vector3.new(width * 0.27, height + 3.2, -depth * 0.2)),
		height = 5.2,
	})
	ArchitecturalDetailBuilder.addLantern(shell, {
		name = "PorchLampFixture",
		role = "home-porch-lantern",
		cframe = CFrame.new(anchor + Vector3.new(-4.9, 5.7, frontZ + 1.05)),
		brightness = 0.55,
		range = 9,
	})

	makeDecoration(
		shell,
		"FacadeTrimLeft",
		Vector3.new(0.55, height - 1.2, 0.55),
		anchor + Vector3.new(-(width / 2) + 0.8, (height / 2) + 1, frontZ + 0.65),
		VisualTheme.Colors.woodLight,
		Enum.Material.Wood,
		"home-facade-trim"
	)
	makeDecoration(
		shell,
		"FacadeTrimRight",
		Vector3.new(0.55, height - 1.2, 0.55),
		anchor + Vector3.new((width / 2) - 0.8, (height / 2) + 1, frontZ + 0.65),
		VisualTheme.Colors.woodLight,
		Enum.Material.Wood,
		"home-facade-trim"
	)

	addTierDetails(shell, anchor + Vector3.new(0, 1, 0), tier, width, depth, height, wallColor, roofColor)

	makeDecoration(
		shell,
		"FrontPathInset",
		Vector3.new(7, 0.16, 9),
		anchor + Vector3.new(0, 0.75, frontZ + 7.4),
		VisualTheme.Colors.pathLight,
		Enum.Material.Cobblestone,
		"home-entry-path"
	)
	for _, side in { -1, 1 } do
		makeDecoration(
			shell,
			if side < 0 then "PorchPlanterLeft" else "PorchPlanterRight",
			Vector3.new(2.6, 1.1, 2.2),
			anchor + Vector3.new(side * 5.2, 1.35, frontZ + 3.2),
			VisualTheme.Colors.timber,
			Enum.Material.WoodPlanks,
			"home-porch-planter"
		)
		local foliage = makeDecoration(
			shell,
			if side < 0 then "PorchFoliageLeft" else "PorchFoliageRight",
			Vector3.new(2.2, 1.8, 2.2),
			anchor + Vector3.new(side * 5.2, 2.5, frontZ + 3.2),
			VisualTheme.Colors.leaf,
			Enum.Material.LeafyGrass,
			"home-porch-foliage"
		)
		foliage.Shape = Enum.PartType.Ball
	end

	if tier >= 2 then
		makeDecoration(
			shell,
			"SideGardenBed",
			Vector3.new(8, 0.65, 4.5),
			anchor + Vector3.new((width / 2) + 2.5, 0.7, 2),
			VisualTheme.Colors.timberDark,
			Enum.Material.Ground,
			"home-side-garden-bed"
		)
		for index = 1, 3 do
			local plant = makeDecoration(
				shell,
				"SideGardenPlant" .. index,
				Vector3.new(1.3, 1.5 + (index * 0.15), 1.3),
				anchor + Vector3.new((width / 2) + 0.5 + (index * 1.3), 1.5, 2),
				if index == 2 then styleColour else VisualTheme.Colors.leafLight,
				Enum.Material.LeafyGrass,
				"home-side-garden-plant"
			)
			plant.Shape = Enum.PartType.Ball
		end
	end

	local homeCharmDisplay = nil
	if profile.homeCharmApplied then
		homeCharmDisplay = makeDecoration(
			shell,
			"HomeCharmDisplay",
			Vector3.new(1.15, 1.15, 1.15),
			anchor + Vector3.new(0, 3.7, frontZ + 3.6),
			VisualTheme.Colors.flower,
			Enum.Material.Glass,
			"home-charm-display"
		)
		homeCharmDisplay.Shape = Enum.PartType.Ball
		homeCharmDisplay:SetAttribute("TinyWorldItem", "HomeCharm")
	end

	local namePost = makePart(
		shell,
		"HouseName",
		Vector3.new(7.5, 2.2, 0.55),
		anchor + Vector3.new(0, 8.1, frontZ + 1.05),
		roofColor,
		Enum.Material.Wood,
		"home-name-sign"
	)
	namePost.CanCollide = false
	makeSurfaceLabel(namePost, if house then house.name else "TinyWorld Home")

	local frontDoorAnchor = makeAnchor(
		shell,
		"HomeFrontDoorAnchor",
		Vector3.new(5, 7, 3),
		anchor + Vector3.new(0, 3.8, frontZ + 1.5),
		"home-front-door-anchor"
	)
	local porchAnchor = makeAnchor(
		shell,
		"HomePorchAnchor",
		Vector3.new(10, 4, 5),
		anchor + Vector3.new(0, 2.5, frontZ + 3),
		"home-porch-anchor"
	)
	local gardenAnchor = makeAnchor(
		shell,
		"HomeGardenAnchor",
		Vector3.new(8, 5, 6),
		anchor + Vector3.new((width / 2) + 4, 2.5, 2),
		"home-garden-anchor"
	)

	return {
		model = shell,
		facade = facade,
		gable = gable,
		frontDoor = frontDoor,
		frontDoorAnchor = frontDoorAnchor,
		porch = porch,
		porchAnchor = porchAnchor,
		gardenAnchor = gardenAnchor,
		homeCharmDisplay = homeCharmDisplay,
		namePost = namePost,
	}
end

return HomePrefabBuilder
