local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))

local HeroPortalBuilder = {}

local function decoration(
	parent: Instance,
	name: string,
	size: Vector3,
	cframe: CFrame,
	color: Color3,
	material: Enum.Material,
	role: string
): Part
	local part = Instance.new("Part")
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
	part:SetAttribute("TinyWorldArtRole", role)
	part:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	part.Parent = parent
	return part
end

local function wedge(
	parent: Instance,
	name: string,
	size: Vector3,
	cframe: CFrame,
	color: Color3,
	material: Enum.Material,
	role: string
): WedgePart
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
	part:SetAttribute("TinyWorldArtRole", role)
	part:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	part.Parent = parent
	return part
end

local function findPortalAnchor(model: Model): BasePart?
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") and descendant:GetAttribute("TinyWorldInteractionAnchor") == true then
			return descendant
		end
	end
	return nil
end

local function findPortalOrigin(model: Model, anchor: BasePart?): Vector3
	if anchor then
		return Vector3.new(anchor.Position.X, 0, anchor.Position.Z)
	end
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") and string.find(descendant.Name, "Platform", 1, true) then
			return Vector3.new(descendant.Position.X, 0, descendant.Position.Z)
		end
	end
	local pivot = model:GetPivot().Position
	return Vector3.new(pivot.X, 0, pivot.Z)
end

local function findAccent(model: Model, anchor: BasePart?): Color3
	if anchor then
		return anchor.Color
	end
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") and (descendant.Material == Enum.Material.Neon or descendant.Material == Enum.Material.Glass) then
			return descendant.Color
		end
	end
	return VisualTheme.Colors.portal
end

local function clearLegacyPortalGeometry(model: Model, anchor: BasePart?)
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

local function addPier(model: Model, origin: Vector3, x: number, accent: Color3, suffix: string)
	decoration(
		model,
		"PortalPierBase" .. suffix,
		Vector3.new(3.6, 0.9, 3.8),
		CFrame.new(origin + Vector3.new(x, 0.65, 0)),
		VisualTheme.Colors.pathEdge,
		Enum.Material.Cobblestone,
		"portal-pier-base"
	)
	decoration(
		model,
		"PortalPier" .. suffix,
		Vector3.new(2.35, 8.7, 2.6),
		CFrame.new(origin + Vector3.new(x, 5.25, 0)) * CFrame.Angles(0, 0, math.rad(if x < 0 then -2 else 2)),
		VisualTheme.Colors.creamDeep,
		Enum.Material.Brick,
		"portal-pier"
	)
	decoration(
		model,
		"PortalPierCap" .. suffix,
		Vector3.new(3.3, 0.65, 3.5),
		CFrame.new(origin + Vector3.new(x, 9.65, 0)),
		VisualTheme.Colors.timberDark,
		Enum.Material.Wood,
		"portal-pier-cap"
	)
	wedge(
		model,
		"PortalRuneFin" .. suffix,
		Vector3.new(1.35, 4.6, 0.6),
		CFrame.new(origin + Vector3.new(x + (if x < 0 then -1.65 else 1.65), 6.2, -0.2))
			* CFrame.Angles(0, math.rad(if x < 0 then 180 else 0), math.rad(if x < 0 then -8 else 8)),
		accent,
		Enum.Material.Glass,
		"portal-rune-fin"
	)
end

local function buildLandmark(model: Model, origin: Vector3, anchor: BasePart?, accent: Color3)
	local threshold = decoration(
		model,
		"PortalThreshold",
		Vector3.new(17, 0.55, 8),
		CFrame.new(origin + Vector3.new(0, 0.32, 0)),
		VisualTheme.Colors.pathEdge,
		Enum.Material.Cobblestone,
		"portal-threshold"
	)
	threshold.CanCollide = true

	decoration(
		model,
		"PortalThresholdInset",
		Vector3.new(11.5, 0.18, 5),
		CFrame.new(origin + Vector3.new(0, 0.68, 0.2)),
		VisualTheme.Colors.pathLight,
		Enum.Material.Pavement,
		"portal-threshold-inset"
	)

	addPier(model, origin, -6.5, accent, "Left")
	addPier(model, origin, 6.5, accent, "Right")

	decoration(
		model,
		"PortalArchBeamLeft",
		Vector3.new(8.6, 1.65, 2.5),
		CFrame.new(origin + Vector3.new(-3.35, 11.35, 0)) * CFrame.Angles(0, 0, math.rad(-25)),
		VisualTheme.Colors.roof,
		Enum.Material.Slate,
		"portal-arch-beam"
	)
	decoration(
		model,
		"PortalArchBeamRight",
		Vector3.new(8.6, 1.65, 2.5),
		CFrame.new(origin + Vector3.new(3.35, 11.35, 0)) * CFrame.Angles(0, 0, math.rad(25)),
		VisualTheme.Colors.roof,
		Enum.Material.Slate,
		"portal-arch-beam"
	)
	wedge(
		model,
		"PortalKeystone",
		Vector3.new(2.1, 2.8, 2.8),
		CFrame.new(origin + Vector3.new(0, 13.25, 0)) * CFrame.Angles(0, math.rad(90), 0),
		accent,
		Enum.Material.Glass,
		"portal-keystone"
	)

	for _, x in { -4.75, 4.75 } do
		local lightBar = decoration(
			model,
			"PortalLightRail" .. tostring(x),
			Vector3.new(0.28, 7.3, 0.35),
			CFrame.new(origin + Vector3.new(x, 6.15, -1.45)),
			accent,
			Enum.Material.Neon,
			"portal-light-rail"
		)
		lightBar.Transparency = 0.18
	end

	if anchor then
		anchor.Shape = Enum.PartType.Block
		anchor.Size = Vector3.new(8.8, 10.7, 0.48)
		anchor.CFrame = CFrame.new(origin + Vector3.new(0, 6.2, 0.55))
		anchor.Color = accent
		anchor.Material = Enum.Material.Glass
		anchor.Transparency = 0.82
		anchor.Reflectance = 0.04
		anchor.CanCollide = false
		anchor.CanTouch = false
		anchor.CanQuery = true
		anchor:SetAttribute("TinyWorldArtRole", "portal-interaction-plane-r3")
	else
		local preview = decoration(
			model,
			"PortalPreviewGlass",
			Vector3.new(8.8, 10.7, 0.32),
			CFrame.new(origin + Vector3.new(0, 6.2, 0.55)),
			accent,
			Enum.Material.Glass,
			"portal-preview-glass"
		)
		preview.Transparency = 0.88
	end

	for index, y in { 3.1, 6.2, 9.25 } do
		local ribbon = decoration(
			model,
			"PortalEnergyRibbon" .. index,
			Vector3.new(6.4 - (index * 0.45), 0.18, 0.25),
			CFrame.new(origin + Vector3.new(0, y, -0.15)) * CFrame.Angles(0, 0, math.rad(if index % 2 == 0 then -8 else 8)),
			accent,
			Enum.Material.Neon,
			"portal-energy-ribbon"
		)
		ribbon.Transparency = 0.28
	end

	model:SetAttribute("TinyWorldPortalLanguage", "landmark-arch-r3")
	model:SetAttribute("TinyWorldVisualState", "authored-native-r3")
end

function HeroPortalBuilder.apply(root: Instance)
	for _, descendant in root:GetDescendants() do
		if descendant:IsA("Model") then
			local role = descendant:GetAttribute("TinyWorldArtRole")
			if role == "world-portal" or role == "world-portal-frame" then
				local anchor = findPortalAnchor(descendant)
				local origin = findPortalOrigin(descendant, anchor)
				local accent = findAccent(descendant, anchor)
				clearLegacyPortalGeometry(descendant, anchor)
				buildLandmark(descendant, origin, anchor, accent)
			end
		end
	end
end

return HeroPortalBuilder
