local R8GroundBuilder = {}

local BASE_INSET_FROM_SHORE = 20
local BASE_THICKNESS = 2
local ROAD_HEIGHT = 0.5
local ROAD_LIFT = 0.25
local PLAZA_HEIGHT = 0.6
local PLAZA_LIFT = 0.3

local GRASS_COLOR = Color3.fromRGB(108, 176, 91)
local ROAD_COLOR = Color3.fromRGB(218, 201, 166)
local PLAZA_COLOR = Color3.fromRGB(232, 214, 181)
local COURTYARD_COLOR = Color3.fromRGB(224, 207, 174)

local function makePart(
	parent: Instance,
	name: string,
	size: Vector3,
	cframe: CFrame,
	color: Color3,
	material: Enum.Material,
	canCollide: boolean
): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material
	part.CanCollide = canCollide
	part.CanTouch = false
	part.CanQuery = canCollide
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function asVector(point): Vector3
	return Vector3.new(point.x, point.y or 0, point.z)
end

local function buildRoute(parent: Instance, route, groundY: number)
	local from = asVector(route.from)
	local to = asVector(route.to)
	local planarFrom = Vector3.new(from.X, groundY + ROAD_LIFT, from.Z)
	local planarTo = Vector3.new(to.X, groundY + ROAD_LIFT, to.Z)
	local delta = planarTo - planarFrom
	local length = delta.Magnitude
	if length <= 0.1 then
		return
	end

	local midpoint = planarFrom:Lerp(planarTo, 0.5)
	local routePart = makePart(
		parent,
		"Route_" .. route.name,
		Vector3.new(route.width, ROAD_HEIGHT, length),
		CFrame.lookAt(midpoint, planarTo),
		ROAD_COLOR,
		Enum.Material.Cobblestone,
		false
	)
	routePart:SetAttribute("TinyWorldRouteName", route.name)
	routePart:SetAttribute("TinyWorldR8VisualRole", "continuous-route")
end

function R8GroundBuilder.build(parent: Instance, layout)
	local prior = parent:FindFirstChild("R8Ground")
	if prior then
		prior:Destroy()
	end

	local legacyGround = parent:FindFirstChild("VillageGround")
	if legacyGround then
		legacyGround:Destroy()
	end

	local model = Instance.new("Model")
	model.Name = "R8Ground"
	model:SetAttribute("TinyWorldArtRevision", "ART R8")
	model:SetAttribute("TinyWorldGroundAuthority", true)
	model.Parent = parent

	local landHalfExtent = layout.shorelineDistance - BASE_INSET_FROM_SHORE
	local villageBase = makePart(
		model,
		"AuthoritativeVillageBase",
		Vector3.new(landHalfExtent * 2, BASE_THICKNESS, landHalfExtent * 2),
		CFrame.new(0, layout.groundY - (BASE_THICKNESS / 2), 0),
		GRASS_COLOR,
		Enum.Material.Grass,
		true
	)
	villageBase:SetAttribute("TinyWorldTraversalRole", "authoritative-ground")

	local plaza = makePart(
		model,
		"HeroPlaza",
		Vector3.new(layout.plazaRadius * 2, PLAZA_HEIGHT, layout.plazaRadius * 2),
		CFrame.new(layout.plaza.x, layout.groundY + PLAZA_LIFT, layout.plaza.z),
		PLAZA_COLOR,
		Enum.Material.Cobblestone,
		false
	)
	plaza:SetAttribute("TinyWorldR8VisualRole", "hero-plaza")

	for _, route in layout.routes do
		buildRoute(model, route, layout.groundY)
	end

	for _, cluster in layout.residentialClusters do
		local courtyard = makePart(
			model,
			"NeighbourhoodCourt_" .. cluster.name,
			Vector3.new(28, ROAD_HEIGHT, 28),
			CFrame.new(cluster.center.x, layout.groundY + ROAD_LIFT, cluster.center.z),
			COURTYARD_COLOR,
			Enum.Material.Cobblestone,
			false
		)
		courtyard:SetAttribute("TinyWorldNeighbourhood", cluster.name)
		courtyard:SetAttribute("TinyWorldR8VisualRole", "neighbourhood-court")
	end

	model:SetAttribute("TinyWorldLandHalfExtent", landHalfExtent)
	model:SetAttribute("TinyWorldGroundY", layout.groundY)
	return model
end

return R8GroundBuilder
