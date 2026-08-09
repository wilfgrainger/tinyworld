local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local WorldDefinitions = require(shared:WaitForChild("WorldDefinitions"))

local PortalKeepsakeDisplayBuilder = {}

local COLORS = {
	wood = Color3.fromRGB(128, 89, 58),
	woodDark = Color3.fromRGB(82, 57, 42),
	paper = Color3.fromRGB(242, 233, 208),
	gold = Color3.fromRGB(224, 179, 73),
	moon = Color3.fromRGB(154, 143, 219),
	sky = Color3.fromRGB(105, 177, 211),
	green = Color3.fromRGB(92, 146, 81),
	metal = Color3.fromRGB(127, 136, 145),
}

local function part(parent: Instance, name: string, size: Vector3, cframe: CFrame, color: Color3, material: Enum.Material?, shape: Enum.PartType?): Part
	local value = Instance.new("Part")
	value.Name = name
	value.Size = size
	value.CFrame = cframe
	value.Color = color
	value.Material = material or Enum.Material.SmoothPlastic
	value.Anchored = true
	value.CanCollide = false
	value.CanTouch = false
	value.CanQuery = false
	value.TopSurface = Enum.SurfaceType.Smooth
	value.BottomSurface = Enum.SurfaceType.Smooth
	if shape then
		value.Shape = shape
	end
	value:SetAttribute("TinyWorldArtRole", "portal-keepsake-home-display")
	value:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	value.Parent = parent
	return value
end

local function worldKeepsakeId(definition): string?
	if type(definition.keepsakeId) == "string" then
		return definition.keepsakeId
	end
	if type(definition.keepsake) == "string" then
		return definition.keepsake
	end
	return nil
end

local function buildWhisk(parent: Instance, base: CFrame)
	part(parent, "GiantKitchenHandle", Vector3.new(0.45, 2.8, 0.45), base * CFrame.new(0, 1.7, 0), COLORS.metal, Enum.Material.Metal)
	for angle = -45, 45, 30 do
		part(parent, "GiantKitchenLoop" .. tostring(angle), Vector3.new(0.18, 2, 0.18), base * CFrame.new(0, 3.25, 0) * CFrame.Angles(0, 0, math.rad(angle)), COLORS.metal, Enum.Material.Metal)
	end
end

local function buildMoonFlower(parent: Instance, base: CFrame)
	part(parent, "MoonStem", Vector3.new(0.32, 2, 0.32), base * CFrame.new(0, 1.1, 0), COLORS.green, Enum.Material.Grass)
	for index, offset in {
		Vector3.new(-0.55, 2.25, 0),
		Vector3.new(0.55, 2.25, 0),
		Vector3.new(0, 2.25, -0.55),
		Vector3.new(0, 2.25, 0.55),
		Vector3.new(0, 2.6, 0),
	} do
		part(parent, "MoonPetal" .. index, Vector3.new(0.9, 0.55, 0.9), base * CFrame.new(offset), COLORS.moon, Enum.Material.Glass, Enum.PartType.Ball)
	end
end

local function buildBreezeBottle(parent: Instance, base: CFrame)
	local bottle = part(parent, "BreezeBottle", Vector3.new(1.45, 2.3, 1.45), base * CFrame.new(0, 1.35, 0), COLORS.sky, Enum.Material.Glass)
	bottle.Transparency = 0.25
	part(parent, "BreezeBottleCork", Vector3.new(0.72, 0.55, 0.72), base * CFrame.new(0, 2.75, 0), COLORS.wood, Enum.Material.Wood)
	local light = Instance.new("PointLight")
	light.Name = "BottledBreezeGlow"
	light.Color = COLORS.sky
	light.Brightness = 0.7
	light.Range = 5
	light.Parent = bottle
end

local function buildClockworkKey(parent: Instance, base: CFrame)
	part(parent, "ClockworkKeyShaft", Vector3.new(0.35, 2.8, 0.35), base * CFrame.new(0, 1.65, 0) * CFrame.Angles(0, 0, math.rad(38)), COLORS.gold, Enum.Material.Metal)
	local ring = part(parent, "ClockworkKeyRing", Vector3.new(0.45, 1.35, 1.35), base * CFrame.new(-0.72, 2.35, 0) * CFrame.Angles(0, 0, math.rad(90)), COLORS.gold, Enum.Material.Metal, Enum.PartType.Cylinder)
	ring:SetAttribute("TinyWorldKeepsakeDetail", "key-ring")
	part(parent, "ClockworkKeyTooth", Vector3.new(0.8, 0.35, 0.35), base * CFrame.new(0.78, 0.73, 0) * CFrame.Angles(0, 0, math.rad(38)), COLORS.gold, Enum.Material.Metal)
end

local function buildKeepsake(parent: Instance, worldId: string, base: CFrame)
	if worldId == "GiantKitchen" then
		buildWhisk(parent, base)
	elseif worldId == "MoonlitMeadow" then
		buildMoonFlower(parent, base)
	elseif worldId == "CloudpostObservatory" then
		buildBreezeBottle(parent, base)
	elseif worldId == "ClockworkOrchard" then
		buildClockworkKey(parent, base)
	else
		part(parent, "MysteryKeepsake", Vector3.new(1.5, 1.5, 1.5), base * CFrame.new(0, 1, 0), COLORS.gold, Enum.Material.Glass, Enum.PartType.Ball)
	end
end

function PortalKeepsakeDisplayBuilder.refresh(houseContainer: Model, profile)
	local existing = houseContainer:FindFirstChild("PortalKeepsakeDisplay")
	if existing then
		existing:Destroy()
	end

	local collected = {}
	for _, definition in WorldDefinitions.all() do
		local keepsakeId = worldKeepsakeId(definition)
		local quantity = if keepsakeId and type(profile.keepsakes) == "table" then profile.keepsakes[keepsakeId] else nil
		if type(quantity) == "number" and quantity > 0 then
			table.insert(collected, definition)
		end
	end
	if #collected == 0 then
		return
	end

	local display = Instance.new("Model")
	display.Name = "PortalKeepsakeDisplay"
	display:SetAttribute("TinyWorldArtRole", "portal-keepsake-home-display")
	display:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	display.Parent = houseContainer

	local origin = houseContainer:GetPivot() * CFrame.new(8.5, 0.7, 6)
	part(display, "KeepsakeShelf", Vector3.new(10, 0.55, 2.4), origin * CFrame.new(0, 2.6, 0), COLORS.wood, Enum.Material.WoodPlanks)
	part(display, "KeepsakeShelfBack", Vector3.new(10, 4.8, 0.45), origin * CFrame.new(0, 4.7, 1), COLORS.woodDark, Enum.Material.WoodPlanks)
	part(display, "KeepsakeTitlePlaque", Vector3.new(5.5, 0.9, 0.3), origin * CFrame.new(0, 6.55, 0.72), COLORS.paper, Enum.Material.Wood)

	local start = -3.6
	for index, definition in collected do
		local slot = origin * CFrame.new(start + (index - 1) * 2.4, 2.9, 0)
		part(display, "KeepsakePlinth" .. index, Vector3.new(1.8, 0.35, 1.8), slot, COLORS.paper, Enum.Material.Marble)
		buildKeepsake(display, definition.id, slot)
	end
end

return PortalKeepsakeDisplayBuilder
