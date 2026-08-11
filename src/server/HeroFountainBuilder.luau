local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))

local HeroFountainBuilder = {}

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

local function uprightDisc(
	parent: Instance,
	name: string,
	diameter: number,
	height: number,
	position: Vector3,
	color: Color3,
	material: Enum.Material,
	role: string
): Part
	local disc = decoration(
		parent,
		name,
		Vector3.new(height, diameter, diameter),
		CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90)),
		color,
		material,
		role
	)
	disc.Shape = Enum.PartType.Cylinder
	return disc
end

local function clearLegacyFountainGeometry(model: Model, anchor: BasePart)
	local remove = {}
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") and descendant ~= anchor then
			table.insert(remove, descendant)
		end
	end
	for _, item in remove do
		item:Destroy()
	end
end

local function addRimBlocks(model: Model, origin: Vector3, radius: number, y: number, count: number, prefix: string)
	for index = 1, count do
		local angle = ((index - 1) / count) * math.pi * 2
		local x = math.cos(angle) * radius
		local z = math.sin(angle) * radius
		decoration(
			model,
			prefix .. index,
			Vector3.new(4.15, 0.82, 1.05),
			CFrame.new(origin + Vector3.new(x, y, z)) * CFrame.Angles(0, -angle, 0),
			VisualTheme.Colors.creamDeep,
			Enum.Material.Marble,
			"fountain-rim-stone"
		)
	end
end

local function addWaterArc(model: Model, origin: Vector3, index: number, angle: number)
	local direction = Vector3.new(math.cos(angle), 0, math.sin(angle))
	local startPosition = origin + (direction * 1.8) + Vector3.new(0, 6.3, 0)
	local endPosition = origin + (direction * 5.3) + Vector3.new(0, 2.15, 0)

	local startPart = decoration(
		model,
		"FountainJetStart" .. index,
		Vector3.new(0.15, 0.15, 0.15),
		CFrame.new(startPosition),
		VisualTheme.Colors.waterHighlight,
		Enum.Material.Glass,
		"fountain-water-attachment"
	)
	startPart.Transparency = 1
	local endPart = decoration(
		model,
		"FountainJetEnd" .. index,
		Vector3.new(0.15, 0.15, 0.15),
		CFrame.new(endPosition),
		VisualTheme.Colors.waterHighlight,
		Enum.Material.Glass,
		"fountain-water-attachment"
	)
	endPart.Transparency = 1

	local startAttachment = Instance.new("Attachment")
	startAttachment.Name = "WaterStart"
	startAttachment.Axis = Vector3.new(0, 1, 0)
	startAttachment.Parent = startPart

	local endAttachment = Instance.new("Attachment")
	endAttachment.Name = "WaterEnd"
	endAttachment.Axis = Vector3.new(0, -1, 0)
	endAttachment.Parent = endPart

	local beam = Instance.new("Beam")
	beam.Name = "FountainWaterArc" .. index
	beam.Attachment0 = startAttachment
	beam.Attachment1 = endAttachment
	beam.Width0 = 0.32
	beam.Width1 = 0.18
	beam.CurveSize0 = 3.4
	beam.CurveSize1 = 2.6
	beam.Segments = 14
	beam.FaceCamera = true
	beam.LightEmission = 0.18
	beam.Color = ColorSequence.new(VisualTheme.Colors.waterHighlight, VisualTheme.Colors.water)
	beam.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.12),
		NumberSequenceKeypoint.new(1, 0.3),
	})
	beam:SetAttribute("TinyWorldArtRole", "fountain-curved-water-arc")
	beam.Parent = model
end

local function rebuild(model: Model, anchor: BasePart)
	local origin = Vector3.new(anchor.Position.X, 0, anchor.Position.Z)
	clearLegacyFountainGeometry(model, anchor)

	anchor.Shape = Enum.PartType.Block
	anchor.Size = Vector3.new(10, 5, 10)
	anchor.CFrame = CFrame.new(origin + Vector3.new(0, 2.5, 0))
	anchor.Transparency = 1
	anchor.CanCollide = false
	anchor.CanTouch = false
	anchor.CanQuery = true
	anchor:SetAttribute("TinyWorldArtRole", "fountain-reward-anchor-r3")

	uprightDisc(
		model,
		"FountainOuterBasin",
		15.5,
		1.25,
		origin + Vector3.new(0, 0.85, 0),
		VisualTheme.Colors.creamDeep,
		Enum.Material.Marble,
		"fountain-outer-basin"
	)
	uprightDisc(
		model,
		"FountainWaterSurface",
		12.7,
		0.22,
		origin + Vector3.new(0, 1.52, 0),
		VisualTheme.Colors.water,
		Enum.Material.Glass,
		"fountain-water-surface"
	).Transparency = 0.2
	addRimBlocks(model, origin, 6.6, 1.7, 10, "FountainOuterRim")

	decoration(
		model,
		"FountainPedestalPlinth",
		Vector3.new(4.2, 0.8, 4.2),
		CFrame.new(origin + Vector3.new(0, 2, 0)) * CFrame.Angles(0, math.rad(45), 0),
		VisualTheme.Colors.pathEdge,
		Enum.Material.Marble,
		"fountain-pedestal-plinth"
	)
	decoration(
		model,
		"FountainPedestal",
		Vector3.new(2.2, 4, 2.2),
		CFrame.new(origin + Vector3.new(0, 4.1, 0)) * CFrame.Angles(0, math.rad(45), 0),
		VisualTheme.Colors.cream,
		Enum.Material.Marble,
		"fountain-pedestal"
	)
	decoration(
		model,
		"FountainPedestalBand",
		Vector3.new(3, 0.55, 3),
		CFrame.new(origin + Vector3.new(0, 5.65, 0)) * CFrame.Angles(0, math.rad(45), 0),
		VisualTheme.Colors.creamDeep,
		Enum.Material.Marble,
		"fountain-pedestal-band"
	)

	uprightDisc(
		model,
		"FountainUpperBowl",
		6.3,
		0.72,
		origin + Vector3.new(0, 6.15, 0),
		VisualTheme.Colors.creamDeep,
		Enum.Material.Marble,
		"fountain-upper-bowl"
	)
	uprightDisc(
		model,
		"FountainUpperWater",
		4.9,
		0.14,
		origin + Vector3.new(0, 6.55, 0),
		VisualTheme.Colors.waterHighlight,
		Enum.Material.Glass,
		"fountain-upper-water"
	).Transparency = 0.22
	addRimBlocks(model, origin, 2.7, 6.55, 6, "FountainUpperRim")

	decoration(
		model,
		"FountainFinialStem",
		Vector3.new(0.8, 2.2, 0.8),
		CFrame.new(origin + Vector3.new(0, 7.55, 0)) * CFrame.Angles(0, math.rad(45), 0),
		VisualTheme.Colors.gold,
		Enum.Material.Metal,
		"fountain-finial-stem"
	)
	local finial = decoration(
		model,
		"FountainFinial",
		Vector3.new(1.2, 1.8, 1.2),
		CFrame.new(origin + Vector3.new(0, 9.1, 0)) * CFrame.Angles(math.rad(45), math.rad(45), 0),
		VisualTheme.Colors.gold,
		Enum.Material.Metal,
		"fountain-finial"
	)
	finial.Shape = Enum.PartType.Block

	for index = 1, 4 do
		addWaterArc(model, origin, index, ((index - 1) / 4) * math.pi * 2)
	end

	model:SetAttribute("TinyWorldFountainLanguage", "civic-hero-r3")
	model:SetAttribute("TinyWorldVisualState", "authored-native-r3")
end

function HeroFountainBuilder.apply(root: Instance)
	local model = root:FindFirstChild("DailyFountainPrefab")
	if not model or not model:IsA("Model") then
		return
	end
	local anchor = model:FindFirstChild("DailyFountain")
	if not anchor or not anchor:IsA("BasePart") then
		return
	end
	rebuild(model, anchor)
end

return HeroFountainBuilder
