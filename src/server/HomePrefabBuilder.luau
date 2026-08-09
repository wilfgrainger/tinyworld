local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))

local HomePrefabBuilder = {}

local function makePart(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material?, artRole: string): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Size = size
	part.Position = position
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part:SetAttribute("TinyWorldArtRole", artRole)
	part:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	part.Parent = parent
	return part
end

local function makeDecoration(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material?, artRole: string): Part
	local part = makePart(parent, name, size, position, color, material, artRole)
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	return part
end

local function makeWedge(parent: Instance, name: string, size: Vector3, cframe: CFrame, color: Color3, material: Enum.Material, artRole: string): WedgePart
	local part = Instance.new("WedgePart")
	part.Name = name
	part.Anchored = true
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part:SetAttribute("TinyWorldArtRole", artRole)
	part:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	part.Parent = parent
	return part
end

local function makeAnchor(parent: Instance, name: string, size: Vector3, position: Vector3, artRole: string): Part
	local anchor = makeDecoration(parent, name, size, position, VisualTheme.Colors.paper, Enum.Material.SmoothPlastic, artRole)
	anchor.Transparency = 1
	anchor.CanQuery = true
	anchor:SetAttribute("TinyWorldInteractionAnchor", true)
	return anchor
end

local function makeLabel(parent: BasePart, text: string)
	local gui = Instance.new("BillboardGui")
	gui.Name = "HouseLabel"
	gui.Size = UDim2.fromOffset(220, 55)
	gui.StudsOffset = Vector3.new(0, 3, 0)
	gui.AlwaysOnTop = true
	gui.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 0.04
	label.BackgroundColor3 = VisualTheme.Colors.inkSoft
	label.TextColor3 = VisualTheme.Colors.paper
	label.TextScaled = true
	label.TextWrapped = true
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = label
	local stroke = Instance.new("UIStroke")
	stroke.Color = VisualTheme.Colors.warmLight
	stroke.Transparency = 0.52
	stroke.Parent = label
	return label
end

function HomePrefabBuilder.buildShell(parent: Instance, anchor: Vector3, profile, house)
	local shell = Instance.new("Model")
	shell.Name = "ResidentialShell"
	shell:SetAttribute("TinyWorldArtRole", "hero-home-shell")
	shell:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	shell:SetAttribute("TinyWorldRecognizableSilhouette", true)
	shell.Parent = parent

	local tier = profile.houseTier
	local width = 18 + ((tier - 1) * 5)
	local depth = 16 + ((tier - 1) * 4)
	local height = 9 + ((tier - 1) * 2)
	local wallColors = {
		VisualTheme.Colors.cream,
		VisualTheme.Colors.warmLight,
		VisualTheme.Colors.paper,
		VisualTheme.Colors.berry,
		VisualTheme.Colors.cream,
	}
	local wallColor = wallColors[tier] or VisualTheme.Colors.cream
	local roofColor = if tier >= 3 then VisualTheme.Colors.roof else VisualTheme.Colors.timberDark
	local frontZ = depth / 2
	local styleColours = {
		Meadow = VisualTheme.Colors.flower,
		Harbor = VisualTheme.Colors.sky,
		Sunset = VisualTheme.Colors.berry,
	}
	local styleColour = styleColours[profile.homeTheme] or styleColours.Meadow
	shell:SetAttribute("TinyWorldHouseTier", tier)
	shell:SetAttribute("TinyWorldHouseWidth", width)
	shell:SetAttribute("TinyWorldHouseDepth", depth)
	shell:SetAttribute("TinyWorldHouseHeight", height)
	shell:SetAttribute("TinyWorldHouseTheme", profile.homeTheme)

	makePart(shell, "Floor", Vector3.new(width, 1, depth), anchor, VisualTheme.Colors.timber, Enum.Material.WoodPlanks, "home-floor")
	makePart(shell, "BackWall", Vector3.new(width, height, 1), anchor + Vector3.new(0, height / 2, -depth / 2), wallColor, nil, "home-wall")
	makePart(shell, "LeftWall", Vector3.new(1, height, depth), anchor + Vector3.new(-width / 2, height / 2, 0), wallColor, nil, "home-wall")
	makePart(shell, "RightWall", Vector3.new(1, height, depth), anchor + Vector3.new(width / 2, height / 2, 0), wallColor, nil, "home-wall")
	local frontSegment = math.max(4, (width - 7) / 2)
	makePart(shell, "FrontLeft", Vector3.new(frontSegment, height, 1), anchor + Vector3.new(-(width - frontSegment) / 2, height / 2, depth / 2), wallColor, nil, "home-facade-wall")
	makePart(shell, "FrontRight", Vector3.new(frontSegment, height, 1), anchor + Vector3.new((width - frontSegment) / 2, height / 2, depth / 2), wallColor, nil, "home-facade-wall")
	makeDecoration(shell, "Roof", Vector3.new(width + 2, 1, depth + 2), anchor + Vector3.new(0, height + 0.6, 0), roofColor, Enum.Material.Slate, "home-roof-base")
	makeWedge(shell, "GableRoofLeft", Vector3.new((width / 2) + 1, 3.5, depth + 2), CFrame.new(anchor + Vector3.new(-(width / 4), height + 2, 0)), roofColor, Enum.Material.Slate, "home-gable-roof")
	makeWedge(shell, "GableRoofRight", Vector3.new((width / 2) + 1, 3.5, depth + 2), CFrame.new(anchor + Vector3.new(width / 4, height + 2, 0)) * CFrame.Angles(0, math.rad(180), 0), roofColor, Enum.Material.Slate, "home-gable-roof")
	makeDecoration(shell, "RoofTrim", Vector3.new(width + 4, 0.5, 1), anchor + Vector3.new(0, height + 2.2, frontZ), VisualTheme.Colors.gold, Enum.Material.Wood, "home-roof-trim")
	makeDecoration(shell, "HomeStyleAccent", Vector3.new(width - 8, 0.45, 0.5), anchor + Vector3.new(0, height - 1.2, frontZ + 0.75), styleColour, Enum.Material.Fabric, "home-theme-accent")
	makeDecoration(shell, "RoofRidge", Vector3.new(1.2, 0.6, depth + 2), anchor + Vector3.new(0, height + 3.8, 0), VisualTheme.Colors.roofLight, Enum.Material.Slate, "home-roof-ridge")
	local gable = makeDecoration(shell, "GableAccent", Vector3.new(width * 0.62, 0.45, 0.45), anchor + Vector3.new(0, height + 2.7, frontZ - 1), VisualTheme.Colors.creamDeep, Enum.Material.Wood, "home-gable-accent")
	local facade = makeDecoration(shell, "HouseFacade", Vector3.new(width - 6, 0.7, 0.6), anchor + Vector3.new(0, height - 0.8, frontZ + 0.65), roofColor, Enum.Material.WoodPlanks, "home-facade")
	local porch = makePart(shell, "Porch", Vector3.new(10, 0.6, 4), anchor + Vector3.new(0, 0.8, frontZ + 2), VisualTheme.Colors.timber, Enum.Material.WoodPlanks, "home-porch")
	makePart(shell, "PorchStep", Vector3.new(8, 0.5, 2), anchor + Vector3.new(0, 0.35, frontZ + 4.5), VisualTheme.Colors.pathEdge, Enum.Material.Cobblestone, "home-porch-step")
	local frontDoor = makeDecoration(shell, "FrontDoor", Vector3.new(4, 6, 0.5), anchor + Vector3.new(0, 3.2, frontZ + 0.6), VisualTheme.Colors.timberDark, Enum.Material.Wood, "home-front-door")
	makeDecoration(shell, "DoorKnob", Vector3.new(0.45, 0.45, 0.45), anchor + Vector3.new(1.1, 3.2, frontZ + 0.95), VisualTheme.Colors.gold, Enum.Material.Metal, "home-door-handle")
	for index, x in {-width * 0.3, width * 0.3} do
		local window = makeDecoration(shell, "HouseWindow" .. index, Vector3.new(4, 3, 0.45), anchor + Vector3.new(x, 5.8, frontZ + 0.58), VisualTheme.Colors.sky, Enum.Material.Glass, "home-window")
		window.Reflectance = 0.1
		makeDecoration(shell, "WindowBox" .. index, Vector3.new(5, 0.8, 1.2), anchor + Vector3.new(x, 3.8, frontZ + 1.2), VisualTheme.Colors.timber, Enum.Material.WoodPlanks, "home-window-box")
		makeDecoration(shell, "HouseFlowerBox" .. index, Vector3.new(4.5, 0.5, 1), anchor + Vector3.new(x, 4.5, frontZ + 1.45), if tier % 2 == 0 then VisualTheme.Colors.flower else VisualTheme.Colors.warmLight, Enum.Material.Fabric, "home-window-flowers")
		makeDecoration(shell, "HouseWindowGlow" .. index, Vector3.new(2.2, 1.2, 0.2), anchor + Vector3.new(x, 5.8, frontZ + 0.9), VisualTheme.Colors.warmLight, Enum.Material.Neon, "home-window-glow")
		makeDecoration(shell, "HouseShutterLeft" .. index, Vector3.new(0.8, 3.4, 0.35), anchor + Vector3.new(x - 2.6, 5.8, frontZ + 0.9), VisualTheme.Colors.woodLight, Enum.Material.Wood, "home-window-shutter")
		makeDecoration(shell, "HouseShutterRight" .. index, Vector3.new(0.8, 3.4, 0.35), anchor + Vector3.new(x + 2.6, 5.8, frontZ + 0.9), VisualTheme.Colors.woodLight, Enum.Material.Wood, "home-window-shutter")
	end
	local porchLamp = makeDecoration(shell, "PorchLamp", Vector3.new(0.7, 1.6, 0.7), anchor + Vector3.new(-6, 5.5, frontZ + 0.7), VisualTheme.Colors.gold, Enum.Material.Neon, "home-porch-lamp")
	porchLamp.Shape = Enum.PartType.Ball

	if tier >= 3 then
		makePart(shell, "UpperFeature", Vector3.new(width * 0.55, 5 + tier, depth * 0.5), anchor + Vector3.new(0, height + 4, -2), wallColor, nil, "home-upper-storey")
		makeDecoration(shell, "UpperRoof", Vector3.new((width * 0.55) + 2, 2, (depth * 0.5) + 2), anchor + Vector3.new(0, height + 8 + (tier / 2), -2), roofColor, Enum.Material.Slate, "home-upper-roof")
		makeDecoration(shell, "UpperWindow", Vector3.new(5, 3, 0.5), anchor + Vector3.new(0, height + 5, depth * 0.25), VisualTheme.Colors.sky, Enum.Material.Glass, "home-upper-window")
	end
	makePart(shell, "CabinChimney", Vector3.new(3, 5, 3), anchor + Vector3.new(width / 3, height + 3, -depth / 4), VisualTheme.Colors.path, Enum.Material.Brick, "home-chimney")
	makeDecoration(shell, "CabinChimneyCap", Vector3.new(3.5, 0.5, 3.5), anchor + Vector3.new(width / 3, height + 5.7, -depth / 4), VisualTheme.Colors.inkSoft, Enum.Material.Slate, "home-chimney-cap")
	if tier >= 2 then
		makeDecoration(shell, "SideGardenBed", Vector3.new(7, 0.7, 4), anchor + Vector3.new((width / 2) + 2, 0.7, 2), VisualTheme.Colors.timberDark, Enum.Material.Ground, "home-side-garden-bed")
		makeDecoration(shell, "SideGardenBloom", Vector3.new(3, 1.8, 2), anchor + Vector3.new((width / 2) + 2, 1.8, 2), VisualTheme.Colors.flower, Enum.Material.SmoothPlastic, "home-side-garden-bloom")
	end
	if tier == 5 then
		makePart(shell, "VillaTower", Vector3.new(7, 14, 7), anchor + Vector3.new((width / 2) - 5, height + 6, 0), wallColor, nil, "home-villa-tower")
		makeDecoration(shell, "VillaTowerWindow", Vector3.new(3, 5, 0.5), anchor + Vector3.new((width / 2) - 5, height + 7, 3.6), VisualTheme.Colors.sky, Enum.Material.Glass, "home-villa-tower-window")
	end

	local homeCharmDisplay = nil
	if profile.homeCharmApplied then
		makeDecoration(shell, "HomePlanter", Vector3.new(7, 1, 2.4), anchor + Vector3.new(0, 1.5, frontZ + 3.5), VisualTheme.Colors.timber, Enum.Material.WoodPlanks, "home-charm-planter")
		makeDecoration(shell, "HomeFlowerCluster", Vector3.new(5, 2, 2), anchor + Vector3.new(0, 2.8, frontZ + 3.7), VisualTheme.Colors.flower, Enum.Material.Fabric, "home-charm-flowers")
		homeCharmDisplay = makeDecoration(shell, "HomeCharmDisplay", Vector3.new(1.8, 1.8, 1.8), anchor + Vector3.new(0, 4.2, frontZ + 3.7), VisualTheme.Colors.flower, Enum.Material.Neon, "home-charm-display")
		homeCharmDisplay.Shape = Enum.PartType.Ball
		homeCharmDisplay:SetAttribute("TinyWorldItem", "HomeCharm")
		makeLabel(homeCharmDisplay, "HOME CHARM")
		local homeLantern = makeDecoration(shell, "HomeLantern", Vector3.new(1.2, 1.8, 1.2), anchor + Vector3.new(7, 4.6, frontZ + 1.2), VisualTheme.Colors.gold, Enum.Material.Neon, "home-charm-lantern")
		homeLantern.Shape = Enum.PartType.Ball
	end

	local namePost = makePart(shell, "HouseName", Vector3.new(8, 3, 1), anchor + Vector3.new(0, 3, frontZ + 2), roofColor, nil, "home-name-sign")
	makeLabel(namePost, if house then house.name else "TinyWorld Home")
	local frontDoorAnchor = makeAnchor(shell, "HomeFrontDoorAnchor", Vector3.new(5, 7, 3), anchor + Vector3.new(0, 3.5, frontZ + 1.5), "home-front-door-anchor")
	local porchAnchor = makeAnchor(shell, "HomePorchAnchor", Vector3.new(10, 4, 5), anchor + Vector3.new(0, 2.5, frontZ + 3), "home-porch-anchor")
	local gardenAnchor = makeAnchor(shell, "HomeGardenAnchor", Vector3.new(8, 5, 6), anchor + Vector3.new((width / 2) + 4, 2.5, 2), "home-garden-anchor")

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
