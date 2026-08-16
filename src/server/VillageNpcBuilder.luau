local VillageNpcBuilder = {}

local COLORS = {
	skin = Color3.fromRGB(226, 181, 145),
	dark = Color3.fromRGB(48, 45, 52),
	cream = Color3.fromRGB(244, 231, 199),
	trader = Color3.fromRGB(164, 73, 91),
	gardener = Color3.fromRGB(77, 132, 83),
	fisherman = Color3.fromRGB(57, 108, 151),
	boatkeeper = Color3.fromRGB(58, 105, 124),
	builder = Color3.fromRGB(198, 128, 51),
	denim = Color3.fromRGB(71, 92, 122),
	water = Color3.fromRGB(83, 161, 196),
	red = Color3.fromRGB(198, 72, 68),
}

local ROLE_COLOR = {
	Trader = COLORS.trader,
	Gardener = COLORS.gardener,
	Fisherman = COLORS.fisherman,
	BoatKeeper = COLORS.boatkeeper,
	Builder = COLORS.builder,
}

local function makePart(
	parent: Instance,
	name: string,
	size: Vector3,
	cframe: CFrame,
	color: Color3,
	material: Enum.Material,
	shape: Enum.PartType?
): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	if shape then
		part.Shape = shape
	end
	part:SetAttribute("TinyWorldArtRole", "village-npc-native")
	part:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	part.Parent = parent
	return part
end

local function addFace(model: Model, origin: CFrame)
	for index, x in { -0.42, 0.42 } do
		makePart(
			model,
			"Eye" .. index,
			Vector3.new(0.28, 0.34, 0.18),
			origin * CFrame.new(x, 5.55, -1.08),
			COLORS.dark,
			Enum.Material.SmoothPlastic,
			Enum.PartType.Ball
		)
	end
	makePart(
		model,
		"Mouth",
		Vector3.new(0.72, 0.12, 0.14),
		origin * CFrame.new(0, 4.98, -1.13),
		COLORS.red,
		Enum.Material.SmoothPlastic
	)
end

local function addHat(model: Model, origin: CFrame, color: Color3, tall: boolean)
	makePart(
		model,
		"HatBrim",
		Vector3.new(2.8, 0.28, 2.65),
		origin * CFrame.new(0, 6.66, 0),
		color,
		Enum.Material.Fabric,
		Enum.PartType.Cylinder
	).CFrame *= CFrame.Angles(
		0,
		0,
		math.rad(90)
	)
	makePart(
		model,
		"HatCrown",
		Vector3.new(1.85, if tall then 1.2 else 0.72, 1.85),
		origin * CFrame.new(0, if tall then 7.1 else 6.92, 0),
		color,
		Enum.Material.Fabric,
		Enum.PartType.Cylinder
	).CFrame *= CFrame.Angles(
		0,
		0,
		math.rad(90)
	)
end

local function addRoleAccessory(model: Model, role: string, origin: CFrame, roleColor: Color3)
	if role == "Trader" then
		makePart(
			model,
			"Apron",
			Vector3.new(2.45, 2.5, 0.18),
			origin * CFrame.new(0, 2.85, -1.05),
			COLORS.cream,
			Enum.Material.Fabric
		)
		makePart(
			model,
			"Satchel",
			Vector3.new(1.25, 1.5, 0.65),
			origin * CFrame.new(2.05, 2.55, 0.1),
			COLORS.dark,
			Enum.Material.Fabric
		)
	elseif role == "Gardener" then
		addHat(model, origin, Color3.fromRGB(214, 183, 103), true)
		makePart(
			model,
			"WateringCan",
			Vector3.new(1.25, 1.15, 1.25),
			origin * CFrame.new(2.05, 1.55, -0.25),
			COLORS.water,
			Enum.Material.Metal,
			Enum.PartType.Ball
		)
		makePart(
			model,
			"WateringSpout",
			Vector3.new(1.45, 0.28, 0.28),
			origin * CFrame.new(2.8, 1.55, -0.6) * CFrame.Angles(0, math.rad(28), 0),
			COLORS.water,
			Enum.Material.Metal
		)
	elseif role == "Fisherman" then
		addHat(model, origin, roleColor, false)
		makePart(
			model,
			"FishingRod",
			Vector3.new(0.22, 6.8, 0.22),
			origin * CFrame.new(2.0, 3.25, 0) * CFrame.Angles(0, 0, math.rad(-18)),
			Color3.fromRGB(113, 78, 51),
			Enum.Material.Wood
		)
		makePart(
			model,
			"FishBucket",
			Vector3.new(1.45, 1.25, 1.45),
			origin * CFrame.new(-2.0, 0.7, -0.2),
			Color3.fromRGB(126, 142, 151),
			Enum.Material.Metal,
			Enum.PartType.Cylinder
		).CFrame *= CFrame.Angles(
			0,
			0,
			math.rad(90)
		)
	elseif role == "BoatKeeper" then
		addHat(model, origin, COLORS.dark, false)
		makePart(
			model,
			"LifeRing",
			Vector3.new(1.75, 1.75, 0.35),
			origin * CFrame.new(1.95, 2.7, -0.15),
			Color3.fromRGB(230, 117, 62),
			Enum.Material.SmoothPlastic,
			Enum.PartType.Cylinder
		).CFrame *= CFrame.Angles(
			0,
			math.rad(90),
			0
		)
		makePart(
			model,
			"HarbourRope",
			Vector3.new(0.42, 2.8, 0.42),
			origin * CFrame.new(-1.95, 2.3, 0),
			Color3.fromRGB(183, 155, 107),
			Enum.Material.Fabric
		)
	elseif role == "Builder" then
		addHat(model, origin, Color3.fromRGB(239, 184, 58), false)
		makePart(
			model,
			"HammerHandle",
			Vector3.new(0.28, 2.4, 0.28),
			origin * CFrame.new(2.0, 2.0, -0.2) * CFrame.Angles(0, 0, math.rad(-25)),
			Color3.fromRGB(118, 77, 50),
			Enum.Material.Wood
		)
		makePart(
			model,
			"HammerHead",
			Vector3.new(1.25, 0.55, 0.55),
			origin * CFrame.new(2.45, 3.0, -0.2) * CFrame.Angles(0, 0, math.rad(-25)),
			Color3.fromRGB(94, 99, 105),
			Enum.Material.Metal
		)
	end
end

local function addNameplate(model: Model, head: BasePart, displayName: string, role: string)
	local gui = Instance.new("BillboardGui")
	gui.Name = "NpcNameplate"
	gui.Size = UDim2.fromOffset(170, 42)
	gui.StudsOffset = Vector3.new(0, 2.3, 0)
	gui.AlwaysOnTop = false
	gui.Parent = head

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 0.22
	label.BackgroundColor3 = Color3.fromRGB(38, 43, 52)
	label.TextColor3 = Color3.fromRGB(255, 248, 225)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Text = displayName .. " · " .. role
	label.Size = UDim2.fromScale(1, 1)
	label.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = label
end

function VillageNpcBuilder.build(parent: Instance, definition, origin: CFrame, actionText: string, onInteract): Model
	local model = Instance.new("Model")
	model.Name = "Npc_" .. definition.id
	model:SetAttribute("TinyWorldNpcRole", definition.id)
	model:SetAttribute("TinyWorldVisualState", "native-character-r6")
	model:SetAttribute("TinyWorldRecognizableSilhouette", true)
	model.Parent = parent

	local roleColor = ROLE_COLOR[definition.id] or COLORS.trader
	local torso = makePart(
		model,
		"Torso",
		Vector3.new(3.0, 3.5, 2.0),
		origin * CFrame.new(0, 3.0, 0),
		roleColor,
		Enum.Material.Fabric
	)
	local head = makePart(
		model,
		"Head",
		Vector3.new(2.3, 2.3, 2.15),
		origin * CFrame.new(0, 5.45, 0),
		COLORS.skin,
		Enum.Material.SmoothPlastic,
		Enum.PartType.Ball
	)
	makePart(
		model,
		"LeftArm",
		Vector3.new(0.85, 3.2, 0.85),
		origin * CFrame.new(-1.9, 3.05, 0),
		roleColor,
		Enum.Material.Fabric
	)
	makePart(
		model,
		"RightArm",
		Vector3.new(0.85, 3.2, 0.85),
		origin * CFrame.new(1.9, 3.05, 0),
		roleColor,
		Enum.Material.Fabric
	)
	makePart(
		model,
		"LeftLeg",
		Vector3.new(1.05, 2.7, 1.05),
		origin * CFrame.new(-0.72, 0.55, 0),
		COLORS.denim,
		Enum.Material.Fabric
	)
	makePart(
		model,
		"RightLeg",
		Vector3.new(1.05, 2.7, 1.05),
		origin * CFrame.new(0.72, 0.55, 0),
		COLORS.denim,
		Enum.Material.Fabric
	)

	addFace(model, origin)
	addRoleAccessory(model, definition.id, origin, roleColor)
	addNameplate(model, head, definition.displayName, definition.id)

	local humanoid = Instance.new("Humanoid")
	humanoid.Name = "Humanoid"
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.Parent = model

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "ActivityPrompt"
	prompt.ActionText = actionText
	prompt.ObjectText = definition.displayName .. " · " .. definition.id
	prompt.HoldDuration = 0.1
	prompt.MaxActivationDistance = 11
	prompt.RequiresLineOfSight = false
	prompt.Parent = torso
	prompt.Triggered:Connect(onInteract)

	model.PrimaryPart = torso
	return model
end

return VillageNpcBuilder
