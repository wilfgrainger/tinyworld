local Workspace = game:GetService("Workspace")

local CoastBuilder = {}

local Terrain = Workspace.Terrain
local SEA_DEPTH = 18
local WATER_BELT = 180
local SWIM_DISTANCE = 36
local HILL_RISE = 3.4
local HILL_ANGLE = math.rad(14)

local function makePart(
	parent: Instance,
	name: string,
	size: Vector3,
	cframe: CFrame,
	color: Color3,
	material: Enum.Material
): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function fillWater(size: Vector3, position: Vector3)
	local waterSize = Vector3.new(size.X, SEA_DEPTH, size.Z)
	local waterCenter = Vector3.new(position.X, -(SEA_DEPTH / 2) + 0.5, position.Z)
	Terrain:FillBlock(CFrame.new(waterCenter), waterSize, Enum.Material.Water)
end

local function makeHillSlope(parent: Instance, name: string, position: Vector3, northSouth: boolean): Part
	local angleX = 0
	local angleZ = 0
	if northSouth then
		angleX = HILL_ANGLE * math.sign(position.Z)
	else
		angleZ = -HILL_ANGLE * math.sign(position.X)
	end

	local slope = makePart(
		parent,
		name .. "HillSlope",
		Vector3.new(30, 2, 30),
		CFrame.new(position + Vector3.new(0, HILL_RISE, 0)) * CFrame.Angles(angleX, 0, angleZ),
		Color3.fromRGB(100, 129, 87),
		Enum.Material.Ground
	)
	slope:SetAttribute("TinyWorldTraversalRole", "walkable-hill")
	return slope
end

function CoastBuilder.build(parent: Instance, layout)
	local coast = Instance.new("Model")
	coast.Name = "CoastRuntime"
	coast.Parent = parent

	local half = layout.perimeterHalfExtent
	local fullWaterExtent = (half * 2) + (WATER_BELT * 2)
	local waterCenter = half + (WATER_BELT / 2)

	fillWater(Vector3.new(fullWaterExtent, SEA_DEPTH, WATER_BELT), Vector3.new(0, 0, waterCenter))
	fillWater(Vector3.new(fullWaterExtent, SEA_DEPTH, WATER_BELT), Vector3.new(0, 0, -waterCenter))
	fillWater(Vector3.new(WATER_BELT, SEA_DEPTH, fullWaterExtent), Vector3.new(waterCenter, 0, 0))
	fillWater(Vector3.new(WATER_BELT, SEA_DEPTH, fullWaterExtent), Vector3.new(-waterCenter, 0, 0))

	local seaBed = makePart(
		coast,
		"SeaBed",
		Vector3.new(fullWaterExtent, 2, fullWaterExtent),
		CFrame.new(0, -SEA_DEPTH - 0.5, 0),
		Color3.fromRGB(197, 174, 131),
		Enum.Material.Sand
	)
	seaBed:SetAttribute("TinyWorldTraversalRole", "sea-bed")

	local slopeLine = half - 7
	makeHillSlope(coast, "North", Vector3.new(0, 0, -slopeLine), true)
	makeHillSlope(coast, "South", Vector3.new(0, 0, slopeLine), true)
	makeHillSlope(coast, "East", Vector3.new(slopeLine, 0, 0), false)
	makeHillSlope(coast, "West", Vector3.new(-slopeLine, 0, 0), false)

	coast:SetAttribute("TinyWorldSeaDepth", SEA_DEPTH)
	coast:SetAttribute("TinyWorldSwimDistance", SWIM_DISTANCE)
	coast:SetAttribute("TinyWorldWaterBelt", WATER_BELT)

	return {
		model = coast,
		shorelineDistance = half,
		swimDistance = SWIM_DISTANCE,
		waterBelt = WATER_BELT,
		safeShoreCFrame = CFrame.new(half - 24, 5, 0),
		worldRecoveryCFrame = CFrame.new(0, 6, 0),
	}
end

return CoastBuilder
