local HeroFountainBuilder = require(script.Parent:WaitForChild("HeroFountainBuilder"))
local VillageActivityLocations = require(script.Parent:WaitForChild("VillageActivityLocations"))
local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))

local R6CivicPresentationBuilder = {}

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
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part:SetAttribute("TinyWorldArtRole", role)
	part:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	part.Parent = parent
	return part
end

local function addStationBase(parent: Instance, name: string, cframe: CFrame, role: string, accent: Color3): Model
	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("TinyWorldArtRole", role)
	model:SetAttribute("TinyWorldVisualState", "authored-native-r6")
	model.Parent = parent

	decoration(
		model,
		"StationPad",
		Vector3.new(9, 0.45, 7),
		cframe * CFrame.new(0, 0.22, 0),
		VisualTheme.Colors.pathLight,
		Enum.Material.Cobblestone,
		role .. "-pad"
	)
	decoration(
		model,
		"StationPostLeft",
		Vector3.new(0.55, 4.8, 0.55),
		cframe * CFrame.new(-3.4, 2.4, 2.4),
		VisualTheme.Colors.timberDark,
		Enum.Material.Wood,
		role .. "-post"
	)
	decoration(
		model,
		"StationPostRight",
		Vector3.new(0.55, 4.8, 0.55),
		cframe * CFrame.new(3.4, 2.4, 2.4),
		VisualTheme.Colors.timberDark,
		Enum.Material.Wood,
		role .. "-post"
	)
	decoration(
		model,
		"StationHeader",
		Vector3.new(7.5, 1.0, 0.6),
		cframe * CFrame.new(0, 4.6, 2.4),
		accent,
		Enum.Material.WoodPlanks,
		role .. "-header"
	)
	return model
end

local function addTraderStation(parent: Instance, world)
	local origin = VillageActivityLocations.station(world, "Trader")
	local model = addStationBase(parent, "MaraTraderStation", origin, "trader-station", VisualTheme.Colors.berry)
	for index, offset in { Vector3.new(-2.3, 1.0, -1.4), Vector3.new(0, 1.0, -1.4), Vector3.new(2.3, 1.0, -1.4) } do
		decoration(
			model,
			"MarketCrate" .. index,
			Vector3.new(1.8, 1.8, 1.8),
			origin * CFrame.new(offset),
			VisualTheme.Colors.timber,
			Enum.Material.WoodPlanks,
			"trader-station-crate"
		)
	end
	decoration(
		model,
		"MarketCloth",
		Vector3.new(6.7, 0.2, 2.0),
		origin * CFrame.new(0, 2.0, -1.4),
		VisualTheme.Colors.warmLight,
		Enum.Material.Fabric,
		"trader-station-cloth"
	)
end

local function addGardenerStation(parent: Instance, world)
	local origin = VillageActivityLocations.station(world, "Gardener")
	local model = addStationBase(parent, "PipGardenerStation", origin, "gardener-station", VisualTheme.Colors.leaf)
	decoration(
		model,
		"SeedShelf",
		Vector3.new(5.5, 2.3, 1.5),
		origin * CFrame.new(0, 1.4, -1.9),
		VisualTheme.Colors.timber,
		Enum.Material.WoodPlanks,
		"gardener-station-seed-shelf"
	)
	for index, x in { -1.8, 0, 1.8 } do
		local pot = decoration(
			model,
			"PlantPot" .. index,
			Vector3.new(1.1, 1.1, 1.1),
			origin * CFrame.new(x, 2.9, -1.9),
			Color3.fromRGB(176, 101, 67),
			Enum.Material.SmoothPlastic,
			"gardener-station-pot"
		)
		pot.Shape = Enum.PartType.Cylinder
	end
end

local function addFishermanStation(parent: Instance, world)
	local origin = VillageActivityLocations.station(world, "Fisherman")
	local model =
		addStationBase(parent, "FinnFishermanStation", origin, "fisherman-station", VisualTheme.Colors.skyDeep)
	local bucket = decoration(
		model,
		"FishBucket",
		Vector3.new(2.1, 2.1, 2.1),
		origin * CFrame.new(-2.1, 1.2, -1.4),
		VisualTheme.Colors.metal,
		Enum.Material.Metal,
		"fisherman-station-bucket"
	)
	bucket.Shape = Enum.PartType.Cylinder
	decoration(
		model,
		"RodRack",
		Vector3.new(0.45, 6.3, 0.45),
		origin * CFrame.new(2.2, 3.2, -1.4) * CFrame.Angles(0, 0, math.rad(-12)),
		VisualTheme.Colors.timberDark,
		Enum.Material.Wood,
		"fisherman-station-rod"
	)
end

local function addBoatKeeperStation(parent: Instance, world)
	local origin = VillageActivityLocations.station(world, "BoatKeeper")
	local model = addStationBase(parent, "SkyeBoatKeeperStation", origin, "boatkeeper-station", VisualTheme.Colors.sky)
	local ring = decoration(
		model,
		"LifeRing",
		Vector3.new(3.0, 0.55, 3.0),
		origin * CFrame.new(-2.0, 2.2, -1.3) * CFrame.Angles(math.rad(90), 0, 0),
		Color3.fromRGB(230, 117, 62),
		Enum.Material.SmoothPlastic,
		"boatkeeper-station-life-ring"
	)
	ring.Shape = Enum.PartType.Cylinder
	decoration(
		model,
		"RopeCoil",
		Vector3.new(2.4, 0.65, 2.4),
		origin * CFrame.new(2.2, 0.75, -1.3),
		Color3.fromRGB(181, 151, 104),
		Enum.Material.Fabric,
		"boatkeeper-station-rope"
	).Shape =
		Enum.PartType.Cylinder
end

local function addBuilderStation(parent: Instance, world)
	local origin = VillageActivityLocations.station(world, "Builder")
	local model = addStationBase(parent, "MiloBuilderStation", origin, "builder-station", VisualTheme.Colors.gold)
	for index, y in { 0.8, 1.8, 2.8 } do
		decoration(
			model,
			"Lumber" .. index,
			Vector3.new(6.0, 0.7, 0.8),
			origin * CFrame.new(0, y, -1.7),
			VisualTheme.Colors.timber,
			Enum.Material.WoodPlanks,
			"builder-station-lumber"
		)
	end
	decoration(
		model,
		"ToolBench",
		Vector3.new(4.5, 1.1, 2.2),
		origin * CFrame.new(0, 1.0, 1.1),
		VisualTheme.Colors.timberDark,
		Enum.Material.Wood,
		"builder-station-tool-bench"
	)
end

local function tameMarketSign(root: Instance)
	local sign = root:FindFirstChild("MarketStatusSign", true)
	if not sign or not sign:IsA("BasePart") then
		return
	end
	sign.Size = Vector3.new(12, 3.5, 0.65)
	sign:SetAttribute("TinyWorldArtRole", "market-status-sign-r6")
	sign:SetAttribute("TinyWorldVisualState", "compact-contextual-r6")
	local surface = sign:FindFirstChild("SignSurface")
	if surface and surface:IsA("SurfaceGui") then
		surface.PixelsPerStud = 34
		local label = surface:FindFirstChildWhichIsA("TextLabel")
		if label then
			label.TextScaled = true
			local constraint = label:FindFirstChildWhichIsA("UITextSizeConstraint")
			if constraint then
				constraint.MaxTextSize = 18
			end
		end
	end
end

function R6CivicPresentationBuilder.apply(world)
	local root = world.root
	HeroFountainBuilder.apply(root)
	tameMarketSign(root)

	local old = root:FindFirstChild("R6ActivityStations")
	if old then
		old:Destroy()
	end
	local stations = Instance.new("Model")
	stations.Name = "R6ActivityStations"
	stations:SetAttribute("TinyWorldArtRole", "r6-village-activity-stations")
	stations:SetAttribute("TinyWorldVisualState", "authored-native-r6")
	stations.Parent = root

	addTraderStation(stations, world)
	addGardenerStation(stations, world)
	addFishermanStation(stations, world)
	addBoatKeeperStation(stations, world)
	addBuilderStation(stations, world)
end

return R6CivicPresentationBuilder
