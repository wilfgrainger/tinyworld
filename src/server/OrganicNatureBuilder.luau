local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))

local OrganicNatureBuilder = {}

local function part(
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

local function wedge(
	parent: Instance,
	name: string,
	size: Vector3,
	cframe: CFrame,
	color: Color3,
	material: Enum.Material,
	role: string
): WedgePart
	local item = Instance.new("WedgePart")
	item.Name = name
	item.Anchored = true
	item.Size = size
	item.CFrame = cframe
	item.Color = color
	item.Material = material
	item.CanCollide = false
	item.CanTouch = false
	item.CanQuery = false
	item:SetAttribute("TinyWorldArtRole", role)
	item:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	item.Parent = parent
	return item
end

local function layeredCanopy(source: BasePart)
	local parent = source.Parent
	if not parent then
		return
	end
	local center = source.Position
	local size = source.Size
	local baseColor = source.Color
	local name = source.Name
	local material = Enum.Material.LeafyGrass

	local model = Instance.new("Model")
	model.Name = name .. "R3"
	model:SetAttribute("TinyWorldArtRole", "organic-layered-canopy")
	model:SetAttribute("TinyWorldNatureLanguage", "layered-lowpoly-r3")
	model.Parent = parent

	local widths = {
		Vector3.new(size.X * 0.66, size.Y * 0.52, size.Z * 0.62),
		Vector3.new(size.X * 0.58, size.Y * 0.58, size.Z * 0.56),
		Vector3.new(size.X * 0.54, size.Y * 0.48, size.Z * 0.64),
		Vector3.new(size.X * 0.48, size.Y * 0.44, size.Z * 0.5),
	}
	local offsets = {
		Vector3.new(-size.X * 0.18, 0, 0),
		Vector3.new(size.X * 0.17, size.Y * 0.08, size.Z * 0.08),
		Vector3.new(0, size.Y * 0.2, -size.Z * 0.18),
		Vector3.new(size.X * 0.04, -size.Y * 0.14, size.Z * 0.2),
	}
	local yaws = { -18, 22, 48, -42 }

	for index = 1, 4 do
		local color = if index % 2 == 0 then VisualTheme.Colors.leafLight else baseColor
		wedge(
			model,
			"LeafMass" .. index,
			widths[index],
			CFrame.new(center + offsets[index]) * CFrame.Angles(0, math.rad(yaws[index]), math.rad((index - 2) * 4)),
			color,
			material,
			"organic-canopy-mass"
		)
	end

	part(
		model,
		"CanopyCore",
		Vector3.new(size.X * 0.44, size.Y * 0.38, size.Z * 0.44),
		CFrame.new(center + Vector3.new(0, size.Y * 0.05, 0)) * CFrame.Angles(0, math.rad(28), math.rad(6)),
		VisualTheme.Colors.leaf,
		material,
		"organic-canopy-core"
	)

	source:Destroy()
end

local function petalBloom(source: BasePart)
	local parent = source.Parent
	if not parent then
		return
	end
	local center = source.Position
	local diameter = math.max(0.55, math.min(source.Size.X, source.Size.Z))
	local color = source.Color
	local name = source.Name

	local model = Instance.new("Model")
	model.Name = name .. "R3"
	model:SetAttribute("TinyWorldArtRole", "organic-petal-bloom")
	model:SetAttribute("TinyWorldNatureLanguage", "layered-lowpoly-r3")
	model.Parent = parent

	for index, yaw in { 0, 90, 180, 270 } do
		local radians = math.rad(yaw)
		local offset = Vector3.new(math.cos(radians) * diameter * 0.28, 0, math.sin(radians) * diameter * 0.28)
		local petal = wedge(
			model,
			"Petal" .. index,
			Vector3.new(diameter * 0.58, diameter * 0.18, diameter * 0.42),
			CFrame.new(center + offset) * CFrame.Angles(0, radians, math.rad(if index % 2 == 0 then 8 else -8)),
			color,
			Enum.Material.SmoothPlastic,
			"organic-flower-petal"
		)
		petal.Transparency = math.min(source.Transparency, 0.12)
	end

	local centre = part(
		model,
		"FlowerCentre",
		Vector3.new(diameter * 0.32, diameter * 0.22, diameter * 0.32),
		CFrame.new(center),
		VisualTheme.Colors.gold,
		Enum.Material.SmoothPlastic,
		"organic-flower-centre"
	)
	centre.Shape = Enum.PartType.Cylinder
	centre.CFrame = CFrame.new(center) * CFrame.Angles(0, 0, math.rad(90))

	source:Destroy()
end

local function replacePrimitiveTrees(root: Instance)
	local candidates = {}
	for _, descendant in root:GetDescendants() do
		if descendant:IsA("BasePart") and descendant.Shape == Enum.PartType.Ball then
			local name = descendant.Name
			if string.find(name, "Canopy", 1, true) or string.find(name, "Foliage", 1, true) then
				table.insert(candidates, descendant)
			end
		end
	end
	for _, source in candidates do
		if source.Parent then
			layeredCanopy(source)
		end
	end
end

local function replacePrimitiveFlowers(root: Instance)
	local candidates = {}
	for _, descendant in root:GetDescendants() do
		if descendant:IsA("BasePart") and descendant.Shape == Enum.PartType.Ball then
			local name = descendant.Name
			if string.find(name, "Bloom", 1, true) or string.sub(name, 1, 6) == "Flower" then
				table.insert(candidates, descendant)
			end
		end
	end
	for _, source in candidates do
		if source.Parent then
			petalBloom(source)
		end
	end
end

function OrganicNatureBuilder.apply(root: Instance)
	replacePrimitiveTrees(root)
	replacePrimitiveFlowers(root)
	root:SetAttribute("TinyWorldNatureLanguage", "layered-lowpoly-r3")
end

return OrganicNatureBuilder
