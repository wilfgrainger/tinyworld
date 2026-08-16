local PublishedFallbackFactory = {}

local MATERIALS = {
	plaster = Enum.Material.SmoothPlastic,
	stone = Enum.Material.Cobblestone,
	marble = Enum.Material.Marble,
	slate = Enum.Material.Slate,
	wood = Enum.Material.Wood,
	woodPlanks = Enum.Material.WoodPlanks,
	brick = Enum.Material.Brick,
	metal = Enum.Material.Metal,
	glass = Enum.Material.Glass,
	fabric = Enum.Material.Fabric,
	foliage = Enum.Material.LeafyGrass,
	ground = Enum.Material.Ground,
	water = Enum.Material.Glass,
	paint = Enum.Material.SmoothPlastic,
	neon = Enum.Material.Neon,
}

local function componentCFrame(component): CFrame
	local position = component.position or { 0, 0, 0 }
	local rotation = component.rotation or { 0, 0, 0 }
	return CFrame.new(position[1], position[2], position[3])
		* CFrame.Angles(math.rad(rotation[1]), math.rad(rotation[2]), math.rad(rotation[3]))
end

local function partShape(shape: string): Enum.PartType
	if shape == "ellipsoid" then
		return Enum.PartType.Ball
	end
	if shape == "cylinder" then
		return Enum.PartType.Cylinder
	end
	return Enum.PartType.Block
end

function PublishedFallbackFactory.createComponent(parent: Instance, component, rootCFrame: CFrame, palette): BasePart
	local sizeArray = component.size or { 1, 1, 1 }
	local part = Instance.new("Part")
	part.Name = component.name or "PublishedFallback"
	part.Shape = partShape(component.shape or "beveledBox")
	part.Size = Vector3.new(sizeArray[1], sizeArray[2], sizeArray[3])
	part.CFrame = rootCFrame * componentCFrame(component)
	part.Color = palette.colors[component.color] or Color3.fromRGB(255, 255, 255)
	part.Material = MATERIALS[component.material] or Enum.Material.SmoothPlastic
	part.Transparency = component.transparency or 0
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = component.role ~= "fountain-water-arc" and component.role ~= "fountain-water"
	part:SetAttribute("TinyWorldArtRole", component.role or "published-safe-fallback")
	part:SetAttribute("TinyWorldVisualState", "published-safe-fallback-r5")
	part:SetAttribute("TinyWorldPublishedSafeFallback", true)
	part.Parent = parent

	if parent:IsA("Model") then
		parent:SetAttribute("TinyWorldVisualState", "published-safe-fallback-r5")
		parent:SetAttribute("TinyWorldPublishedSafeFallback", true)
	end

	if component.role == "lantern-glass" then
		local light = Instance.new("PointLight")
		light.Name = "ART_R5_PracticalLight"
		light.Brightness = 0.48
		light.Range = 10
		light.Color = palette.colors.warmLight or Color3.fromRGB(255, 224, 155)
		light.Shadows = true
		light.Parent = part
	end

	return part
end

return PublishedFallbackFactory
