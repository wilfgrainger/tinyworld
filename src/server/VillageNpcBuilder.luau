local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))

local VillageNpcBuilder = {}

local COLORS = {
	skin = Color3.fromRGB(231, 187, 153),
	skinWarm = Color3.fromRGB(241, 199, 166),
	dark = VisualTheme.Colors.ink,
	denim = Color3.fromRGB(79, 106, 148),
	boot = Color3.fromRGB(72, 54, 51),
	hairBrown = Color3.fromRGB(104, 70, 52),
	hairDark = Color3.fromRGB(55, 47, 55),
}

local ROLE_STYLE = {
	Trader = {
		primary = VisualTheme.Colors.pink,
		secondary = VisualTheme.Colors.plum,
		accent = VisualTheme.Colors.lemon,
		pants = VisualTheme.Colors.plum,
		hair = COLORS.hairDark,
		headwear = nil,
	},
	Gardener = {
		primary = VisualTheme.Colors.mintDeep,
		secondary = VisualTheme.Colors.seafoam,
		accent = VisualTheme.Colors.lemon,
		pants = COLORS.denim,
		hair = COLORS.hairBrown,
		headwear = "sun",
	},
	Fisherman = {
		primary = VisualTheme.Colors.aquaDeep,
		secondary = VisualTheme.Colors.sky,
		accent = VisualTheme.Colors.creamDeep,
		pants = COLORS.denim,
		hair = COLORS.hairBrown,
		headwear = "cap",
	},
	BoatKeeper = {
		primary = VisualTheme.Colors.coral,
		secondary = VisualTheme.Colors.aqua,
		accent = VisualTheme.Colors.cream,
		pants = VisualTheme.Colors.plum,
		hair = COLORS.hairDark,
		headwear = "cap",
	},
	Builder = {
		primary = VisualTheme.Colors.peach,
		secondary = VisualTheme.Colors.timber,
		accent = VisualTheme.Colors.lemon,
		pants = VisualTheme.Colors.timberDark,
		hair = COLORS.hairBrown,
		headwear = "hardhat",
	},
}

local function makePart(
	parent: Instance,
	name: string,
	size: Vector3,
	cframe: CFrame,
	color: Color3,
	material: Enum.Material,
	artRole: string,
	shape: Enum.PartType?
): Part
	local item = Instance.new("Part")
	item.Name = name
	item.Anchored = true
	item.CanCollide = false
	item.CanTouch = false
	item.CanQuery = false
	item.Size = size
	item.CFrame = cframe
	item.Color = color
	item.Material = material
	item.TopSurface = Enum.SurfaceType.Smooth
	item.BottomSurface = Enum.SurfaceType.Smooth
	if shape then
		item.Shape = shape
	end
	item:SetAttribute("TinyWorldArtRole", artRole)
	item:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	item:SetAttribute("TinyWorldVisualState", "character-grade-native-r7")
	item.Parent = parent
	return item
end

local function ball(
	parent: Instance,
	name: string,
	cframe: CFrame,
	size: Vector3,
	color: Color3,
	artRole: string,
	material: Enum.Material?
): Part
	return makePart(
		parent,
		name,
		size,
		cframe,
		color,
		material or Enum.Material.SmoothPlastic,
		artRole,
		Enum.PartType.Ball
	)
end

local function verticalCylinder(
	parent: Instance,
	name: string,
	cframe: CFrame,
	length: number,
	diameter: number,
	color: Color3,
	material: Enum.Material,
	artRole: string
): Part
	return makePart(
		parent,
		name,
		Vector3.new(length, diameter, diameter),
		cframe * CFrame.Angles(0, 0, math.rad(90)),
		color,
		material,
		artRole,
		Enum.PartType.Cylinder
	)
end

local function makeGroup(parent: Instance, name: string, artRole: string): Model
	local group = Instance.new("Model")
	group.Name = name
	group:SetAttribute("TinyWorldArtRole", artRole)
	group:SetAttribute("TinyWorldVisualState", "character-grade-native-r7")
	group.Parent = parent
	return group
end

local function addFace(parent: Model, origin: CFrame)
	local face = makeGroup(parent, "Face", "npc-face-r7")
	for index, x in { -0.36, 0.36 } do
		ball(
			face,
			"Eye" .. index,
			origin * CFrame.new(x, 6.33, -1.02),
			Vector3.new(0.22, 0.28, 0.18),
			COLORS.dark,
			"npc-face-eye"
		)
		ball(
			face,
			"EyeSpark" .. index,
			origin * CFrame.new(x - 0.045, 6.39, -1.115),
			Vector3.new(0.075, 0.075, 0.075),
			VisualTheme.Colors.white,
			"npc-face-eye-highlight"
		)
	end
	ball(
		face,
		"Nose",
		origin * CFrame.new(0, 6.05, -1.1),
		Vector3.new(0.16, 0.2, 0.14),
		COLORS.skinWarm,
		"npc-face-nose"
	)
	makePart(
		face,
		"Smile",
		Vector3.new(0.62, 0.12, 0.12),
		origin * CFrame.new(0, 5.82, -1.08) * CFrame.Angles(0, 0, math.rad(-3)),
		VisualTheme.Colors.coral,
		Enum.Material.SmoothPlastic,
		"npc-face-smile"
	)
end

local function addHair(parent: Model, origin: CFrame, color: Color3, longStyle: boolean)
	local hair = makeGroup(parent, "Hair", "npc-hair-r7")
	local offsets = {
		Vector3.new(0, 7.15, 0.12),
		Vector3.new(-0.62, 6.95, 0.18),
		Vector3.new(0.62, 6.95, 0.18),
	}
	if longStyle then
		table.insert(offsets, Vector3.new(-0.72, 6.45, 0.45))
		table.insert(offsets, Vector3.new(0.72, 6.45, 0.45))
	end
	for index, offset in offsets do
		ball(
			hair,
			"HairLock" .. index,
			origin * CFrame.new(offset),
			Vector3.new(1.05, 0.86, 1.0),
			color,
			"npc-hair-lock",
			Enum.Material.Fabric
		)
	end
end

local function addHat(parent: Model, origin: CFrame, color: Color3, style: string)
	local headwear = makeGroup(parent, "Headwear", "npc-headwear-r7")
	local brimDiameter = if style == "sun" then 3.0 elseif style == "hardhat" then 2.55 else 2.45
	local brim = verticalCylinder(
		headwear,
		"HatBrim",
		origin * CFrame.new(0, 7.18, 0),
		0.28,
		brimDiameter,
		color,
		Enum.Material.SmoothPlastic,
		"npc-headwear"
	)
	brim.CFrame *= CFrame.Angles(0, math.rad(4), 0)

	local crownHeight = if style == "sun" then 0.82 elseif style == "hardhat" then 0.68 else 0.62
	verticalCylinder(
		headwear,
		"HatCrown",
		origin * CFrame.new(0, 7.55, 0),
		crownHeight,
		if style == "sun" then 1.85 else 1.72,
		color,
		if style == "sun" then Enum.Material.Fabric else Enum.Material.SmoothPlastic,
		"npc-headwear"
	)
	if style == "hardhat" then
		makePart(
			headwear,
			"HardHatRidge",
			Vector3.new(0.22, 0.72, 1.65),
			origin * CFrame.new(0, 7.9, -0.05),
			VisualTheme.Colors.lemon,
			Enum.Material.SmoothPlastic,
			"npc-headwear"
		)
	end
end

local function addClothing(parent: Model, origin: CFrame, role: string, style)
	local clothing = makeGroup(parent, "Clothing", "npc-clothing-r7")
	makePart(
		clothing,
		"ShirtLayer",
		Vector3.new(2.68, 2.5, 1.48),
		origin * CFrame.new(0, 4.25, 0),
		style.primary,
		Enum.Material.Fabric,
		"npc-clothing-shirt"
	)
	for _, side in
		{
			{ name = "Left", x = -0.55, angle = -18 },
			{ name = "Right", x = 0.55, angle = 18 },
		}
	do
		makePart(
			clothing,
			"Collar" .. side.name,
			Vector3.new(0.88, 0.38, 0.18),
			origin * CFrame.new(side.x, 5.1, -0.82) * CFrame.Angles(0, 0, math.rad(side.angle)),
			style.secondary,
			Enum.Material.Fabric,
			"npc-clothing-collar"
		)
	end
	if role == "Trader" or role == "Gardener" then
		makePart(
			clothing,
			"ApronPanel",
			Vector3.new(2.05, 2.15, 0.16),
			origin * CFrame.new(0, 3.85, -0.84),
			if role == "Trader" then VisualTheme.Colors.cream else VisualTheme.Colors.butter,
			Enum.Material.Fabric,
			"npc-clothing-apron"
		)
	elseif role == "Fisherman" or role == "BoatKeeper" then
		for _, x in { -1.02, 1.02 } do
			makePart(
				clothing,
				"VestPanel" .. tostring(x),
				Vector3.new(0.6, 2.1, 0.18),
				origin * CFrame.new(x, 4.2, -0.84),
				style.secondary,
				Enum.Material.Fabric,
				"npc-clothing-vest"
			)
		end
	else
		makePart(
			clothing,
			"OverallBib",
			Vector3.new(1.7, 1.6, 0.18),
			origin * CFrame.new(0, 4.0, -0.84),
			style.secondary,
			Enum.Material.Fabric,
			"npc-clothing-overall"
		)
	end
end

local function addArms(parent: Model, origin: CFrame, style)
	for _, side in
		{
			{ name = "Left", x = -1.72, tilt = 8 },
			{ name = "Right", x = 1.72, tilt = -8 },
		}
	do
		verticalCylinder(
			parent,
			side.name .. "UpperArm",
			origin * CFrame.new(side.x, 4.43, 0) * CFrame.Angles(0, 0, math.rad(side.tilt)),
			1.55,
			0.68,
			style.primary,
			Enum.Material.Fabric,
			"npc-upper-arm"
		)
		ball(
			parent,
			side.name .. "Elbow",
			origin * CFrame.new(side.x + (side.tilt > 0 and 0.08 or -0.08), 3.57, 0),
			Vector3.new(0.72, 0.72, 0.72),
			style.primary,
			"npc-elbow",
			Enum.Material.Fabric
		)
		local lowerArmCFrame = origin
			* CFrame.new(side.x + (side.tilt > 0 and 0.15 or -0.15), 2.96, -0.04)
			* CFrame.Angles(0, 0, math.rad(-side.tilt * 0.55))
		verticalCylinder(
			parent,
			side.name .. "LowerArm",
			lowerArmCFrame,
			1.35,
			0.62,
			COLORS.skin,
			Enum.Material.SmoothPlastic,
			"npc-lower-arm"
		)
		ball(
			parent,
			side.name .. "Hand",
			origin * CFrame.new(side.x + (side.tilt > 0 and 0.08 or -0.08), 2.18, -0.08),
			Vector3.new(0.72, 0.72, 0.72),
			COLORS.skinWarm,
			"npc-hand"
		)
	end
end

local function addLegs(parent: Model, origin: CFrame, style)
	for _, side in { { name = "Left", x = -0.66 }, { name = "Right", x = 0.66 } } do
		verticalCylinder(
			parent,
			side.name .. "UpperLeg",
			origin * CFrame.new(side.x, 2.15, 0),
			1.55,
			0.88,
			style.pants,
			Enum.Material.Fabric,
			"npc-upper-leg"
		)
		ball(
			parent,
			side.name .. "Knee",
			origin * CFrame.new(side.x, 1.35, 0),
			Vector3.new(0.84, 0.78, 0.84),
			style.pants,
			"npc-knee",
			Enum.Material.Fabric
		)
		verticalCylinder(
			parent,
			side.name .. "LowerLeg",
			origin * CFrame.new(side.x, 0.83, 0),
			1.05,
			0.78,
			style.pants,
			Enum.Material.Fabric,
			"npc-lower-leg"
		)
		makePart(
			parent,
			side.name .. "Shoe",
			Vector3.new(1.05, 0.48, 1.45),
			origin * CFrame.new(side.x, 0.22, -0.2),
			COLORS.boot,
			Enum.Material.SmoothPlastic,
			"npc-shoe"
		)
	end
end

local function addRoleProp(parent: Model, origin: CFrame, role: string, style)
	local props = makeGroup(parent, "RoleProp", "npc-role-prop-r7")
	props:SetAttribute("TinyWorldNpcRole", role)
	if role == "Trader" then
		makePart(
			props,
			"TraderSatchel",
			Vector3.new(1.1, 1.35, 0.6),
			origin * CFrame.new(1.65, 3.1, 0.1),
			style.secondary,
			Enum.Material.Fabric,
			"npc-role-prop-trader"
		)
		ball(
			props,
			"TraderCoin",
			origin * CFrame.new(1.67, 3.15, -0.35),
			Vector3.new(0.48, 0.48, 0.22),
			VisualTheme.Colors.gold,
			"npc-role-prop-trader"
		)
	elseif role == "Gardener" then
		local can = verticalCylinder(
			props,
			"GardenerWateringCan",
			origin * CFrame.new(1.7, 2.0, -0.1),
			1.0,
			1.15,
			VisualTheme.Colors.aqua,
			Enum.Material.Metal,
			"npc-role-prop-gardener"
		)
		can.CastShadow = true
		makePart(
			props,
			"GardenerSpout",
			Vector3.new(1.3, 0.24, 0.24),
			origin * CFrame.new(2.35, 2.0, -0.25) * CFrame.Angles(0, math.rad(-20), 0),
			VisualTheme.Colors.aqua,
			Enum.Material.Metal,
			"npc-role-prop-gardener"
		)
		ball(
			props,
			"GardenerFlower",
			origin * CFrame.new(-0.92, 5.0, -0.9),
			Vector3.new(0.48, 0.48, 0.48),
			VisualTheme.Colors.pink,
			"npc-role-prop-gardener"
		)
	elseif role == "Fisherman" then
		makePart(
			props,
			"FishermanRod",
			Vector3.new(0.22, 5.7, 0.22),
			origin * CFrame.new(1.85, 3.5, 0.1) * CFrame.Angles(0, 0, math.rad(-16)),
			VisualTheme.Colors.timberDark,
			Enum.Material.Wood,
			"npc-role-prop-fisherman"
		)
		makePart(
			props,
			"FishermanTackleBag",
			Vector3.new(1.15, 0.95, 0.58),
			origin * CFrame.new(-1.45, 2.35, 0.15),
			VisualTheme.Colors.creamDeep,
			Enum.Material.Fabric,
			"npc-role-prop-fisherman"
		)
	elseif role == "BoatKeeper" then
		makePart(
			props,
			"BoatKeeperScarf",
			Vector3.new(2.1, 0.42, 0.32),
			origin * CFrame.new(0, 5.28, -0.78) * CFrame.Angles(0, 0, math.rad(-8)),
			style.secondary,
			Enum.Material.Fabric,
			"npc-role-prop-boatkeeper"
		)
		local ring = verticalCylinder(
			props,
			"BoatKeeperLifeRing",
			origin * CFrame.new(1.55, 3.05, 0.1),
			0.34,
			1.55,
			VisualTheme.Colors.coral,
			Enum.Material.SmoothPlastic,
			"npc-role-prop-boatkeeper"
		)
		ring.CFrame *= CFrame.Angles(0, math.rad(90), 0)
		ball(
			props,
			"RouteBadge",
			origin * CFrame.new(-0.78, 4.3, -0.9),
			Vector3.new(0.48, 0.48, 0.22),
			VisualTheme.Colors.aqua,
			"npc-role-prop-boatkeeper"
		)
	else
		makePart(
			props,
			"BuilderToolBelt",
			Vector3.new(2.55, 0.42, 1.35),
			origin * CFrame.new(0, 2.78, 0),
			VisualTheme.Colors.timberDark,
			Enum.Material.Fabric,
			"npc-role-prop-builder"
		)
		makePart(
			props,
			"BuilderHammerHandle",
			Vector3.new(0.25, 2.0, 0.25),
			origin * CFrame.new(1.65, 2.45, -0.1) * CFrame.Angles(0, 0, math.rad(-30)),
			VisualTheme.Colors.timberDark,
			Enum.Material.Wood,
			"npc-role-prop-builder"
		)
		makePart(
			props,
			"BuilderHammerHead",
			Vector3.new(1.0, 0.45, 0.5),
			origin * CFrame.new(2.12, 3.22, -0.1) * CFrame.Angles(0, 0, math.rad(-30)),
			VisualTheme.Colors.metal,
			Enum.Material.Metal,
			"npc-role-prop-builder"
		)
	end
end

local function addNameplate(parent: Model, head: BasePart, displayName: string)
	local gui = Instance.new("BillboardGui")
	gui.Name = "NpcNameplate"
	gui.Size = UDim2.fromOffset(118, 28)
	gui.StudsOffset = Vector3.new(0, 1.65, 0)
	gui.AlwaysOnTop = false
	gui.MaxDistance = 32
	gui.Parent = head

	local label = Instance.new("TextLabel")
	label.Name = "Name"
	label.BackgroundTransparency = 0.32
	label.BackgroundColor3 = VisualTheme.Colors.ink
	label.TextColor3 = VisualTheme.Colors.paper
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Text = displayName
	label.Size = UDim2.fromScale(1, 1)
	label.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = label
	local constraint = Instance.new("UITextSizeConstraint")
	constraint.MinTextSize = 10
	constraint.MaxTextSize = 15
	constraint.Parent = label
end

function VillageNpcBuilder.build(parent: Instance, definition, origin: CFrame, actionText: string, onInteract): Model
	local npc = Instance.new("Model")
	npc.Name = "Npc_" .. definition.id
	npc:SetAttribute("TinyWorldNpcRole", definition.id)
	npc:SetAttribute("TinyWorldVisualState", "character-grade-native-r7")
	npc:SetAttribute("TinyWorldRecognizableSilhouette", true)
	npc:SetAttribute("TinyWorldArtRevision", "ART R7")
	npc.Parent = parent

	local style = ROLE_STYLE[definition.id] or ROLE_STYLE.Trader
	local torso = makePart(
		npc,
		"Torso",
		Vector3.new(2.8, 2.8, 1.5),
		origin * CFrame.new(0, 4.25, 0),
		style.primary,
		Enum.Material.Fabric,
		"npc-torso"
	)
	makePart(
		npc,
		"Waist",
		Vector3.new(2.25, 0.72, 1.35),
		origin * CFrame.new(0, 2.75, 0),
		style.secondary,
		Enum.Material.Fabric,
		"npc-waist"
	)
	local head = ball(
		npc,
		"Head",
		origin * CFrame.new(0, 6.22, 0),
		Vector3.new(2.05, 2.12, 1.95),
		COLORS.skin,
		"npc-head"
	)

	addArms(npc, origin, style)
	addLegs(npc, origin, style)
	addClothing(npc, origin, definition.id, style)
	addFace(npc, origin)
	addHair(npc, origin, style.hair, definition.id == "Trader" or definition.id == "BoatKeeper")
	if style.headwear then
		addHat(npc, origin, style.accent, style.headwear)
	end
	addRoleProp(npc, origin, definition.id, style)
	addNameplate(npc, head, definition.displayName)

	local humanoid = Instance.new("Humanoid")
	humanoid.Name = "Humanoid"
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.Parent = npc

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "ActivityPrompt"
	prompt.ActionText = actionText
	prompt.ObjectText = definition.displayName .. " · " .. definition.id
	prompt.HoldDuration = 0.1
	prompt.MaxActivationDistance = 11
	prompt.RequiresLineOfSight = false
	prompt.Parent = torso
	prompt.Triggered:Connect(onInteract)

	npc.PrimaryPart = torso
	return npc
end

return VillageNpcBuilder
