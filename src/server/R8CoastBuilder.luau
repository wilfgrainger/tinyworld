local Workspace = game:GetService("Workspace")

local R8CoastBuilder = {}

local Terrain = Workspace.Terrain
local SEA_DEPTH = 18
local BANK_WIDTH = 8
local BEACH_WIDTH = 12
local LAND_INSET = BANK_WIDTH + BEACH_WIDTH

local BANK_COLOR = Color3.fromRGB(100, 148, 83)
local BEACH_COLOR = Color3.fromRGB(238, 218, 163)
local SEABED_COLOR = Color3.fromRGB(195, 169, 123)

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
	part.CanCollide = true
	part.CanTouch = false
	part.CanQuery = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function fillWater(size: Vector3, position: Vector3, waterY: number)
	local waterSize = Vector3.new(size.X, SEA_DEPTH, size.Z)
	local waterCenter = Vector3.new(position.X, waterY - (SEA_DEPTH / 2), position.Z)
	Terrain:FillBlock(CFrame.new(waterCenter), waterSize, Enum.Material.Water)
end

local function buildBands(parent: Instance, raw)
	local shore = raw.shorelineDistance
	local landHalf = shore - LAND_INSET
	local bankOuter = landHalf + BANK_WIDTH
	local bankCenter = landHalf + (BANK_WIDTH / 2)
	local beachCenter = bankOuter + (BEACH_WIDTH / 2)
	local bankY = raw.groundY - 1.1
	local beachY = raw.groundY - 2

	for _, side in {
		{ name = "North", x = 0, z = -bankCenter },
		{ name = "South", x = 0, z = bankCenter },
	} do
		makePart(
			parent,
			side.name .. "Bank",
			Vector3.new(bankOuter * 2, 1.2, BANK_WIDTH),
			CFrame.new(side.x, bankY, side.z),
			BANK_COLOR,
			Enum.Material.Ground
		)
	end
	for _, side in {
		{ name = "West", x = -bankCenter, z = 0 },
		{ name = "East", x = bankCenter, z = 0 },
	} do
		makePart(
			parent,
			side.name .. "Bank",
			Vector3.new(BANK_WIDTH, 1.2, landHalf * 2),
			CFrame.new(side.x, bankY, side.z),
			BANK_COLOR,
			Enum.Material.Ground
		)
	end

	for _, side in {
		{ name = "North", x = 0, z = -beachCenter },
		{ name = "South", x = 0, z = beachCenter },
	} do
		makePart(
			parent,
			side.name .. "Beach",
			Vector3.new(shore * 2, 1.2, BEACH_WIDTH),
			CFrame.new(side.x, beachY, side.z),
			BEACH_COLOR,
			Enum.Material.Sand
		)
	end
	for _, side in {
		{ name = "West", x = -beachCenter, z = 0 },
		{ name = "East", x = beachCenter, z = 0 },
	} do
		makePart(
			parent,
			side.name .. "Beach",
			Vector3.new(BEACH_WIDTH, 1.2, bankOuter * 2),
			CFrame.new(side.x, beachY, side.z),
			BEACH_COLOR,
			Enum.Material.Sand
		)
	end

	return landHalf
end

function R8CoastBuilder.build(parent: Instance, layout)
	local raw = layout.r8 or layout
	local previous = parent:FindFirstChild("R8Coast")
	if previous then
		previous:Destroy()
	end

	local coast = Instance.new("Model")
	coast.Name = "R8Coast"
	coast:SetAttribute("TinyWorldArtRevision", "ART R8")
	coast:SetAttribute("TinyWorldCoastAuthority", true)
	coast.Parent = parent

	local landHalf = buildBands(coast, raw)
	local shore = raw.shorelineDistance
	local waterBelt = raw.waterBelt
	local fullWaterExtent = (shore * 2) + (waterBelt * 2)
	local waterCenter = shore + (waterBelt / 2)

	fillWater(Vector3.new(fullWaterExtent, SEA_DEPTH, waterBelt), Vector3.new(0, 0, waterCenter), raw.waterY)
	fillWater(Vector3.new(fullWaterExtent, SEA_DEPTH, waterBelt), Vector3.new(0, 0, -waterCenter), raw.waterY)
	fillWater(Vector3.new(waterBelt, SEA_DEPTH, shore * 2), Vector3.new(waterCenter, 0, 0), raw.waterY)
	fillWater(Vector3.new(waterBelt, SEA_DEPTH, shore * 2), Vector3.new(-waterCenter, 0, 0), raw.waterY)

	local seaBed = makePart(
		coast,
		"SeaBed",
		Vector3.new(fullWaterExtent, 2, fullWaterExtent),
		CFrame.new(0, raw.waterY - SEA_DEPTH - 1, 0),
		SEABED_COLOR,
		Enum.Material.Sand
	)
	seaBed:SetAttribute("TinyWorldTraversalRole", "sea-bed")
	seaBed.CanQuery = false

	coast:SetAttribute("TinyWorldGroundY", raw.groundY)
	coast:SetAttribute("TinyWorldWaterY", raw.waterY)
	coast:SetAttribute("TinyWorldLandHalfExtent", landHalf)
	coast:SetAttribute("TinyWorldShorelineDistance", shore)
	coast:SetAttribute("TinyWorldSwimDistance", raw.swimDistance)
	coast:SetAttribute("TinyWorldWaterBelt", raw.waterBelt)

	return {
		model = coast,
		shorelineDistance = shore,
		swimDistance = raw.swimDistance,
		waterBelt = raw.waterBelt,
		safeShoreCFrame = layout.safeShoreCFrame,
		worldRecoveryCFrame = layout.worldRecoveryCFrame,
	}
end

return R8CoastBuilder
