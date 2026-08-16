local VillageActivityLocations = require(script.Parent:WaitForChild("VillageActivityLocations"))
local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))

local R7ActivityPresentationBuilder = {}

local ROOT_NAME = "ART_R7_ActivityPresentation"

local function part(
	parent: Instance,
	name: string,
	size: Vector3,
	cframe: CFrame,
	color: Color3,
	material: Enum.Material,
	role: string,
	shape: Enum.PartType?
): Part
	local item = Instance.new("Part")
	item.Name = name
	item.Anchored = true
	item.CanCollide = false
	item.CanTouch = false
	item.CanQuery = false
	item.Size = size
	item.CFrame = cframe
	item.Color = color
	item.Material = material
	item.TopSurface = Enum.SurfaceType.Smooth
	item.BottomSurface = Enum.SurfaceType.Smooth
	if shape then
		item.Shape = shape
	end
	item:SetAttribute("TinyWorldR7Decorative", true)
	item:SetAttribute("TinyWorldArtRole", role)
	item.Parent = parent
	return item
end

local function ball(parent: Instance, name: string, cframe: CFrame, size: number, color: Color3, role: string)
	return part(
		parent,
		name,
		Vector3.new(size, size, size),
		cframe,
		color,
		Enum.Material.SmoothPlastic,
		role,
		Enum.PartType.Ball
	)
end

local function cylinder(
	parent: Instance,
	name: string,
	cframe: CFrame,
	diameter: number,
	height: number,
	color: Color3,
	material: Enum.Material,
	role: string
)
	local item = part(
		parent,
		name,
		Vector3.new(height, diameter, diameter),
		cframe * CFrame.Angles(0, 0, math.rad(90)),
		color,
		material,
		role,
		Enum.PartType.Cylinder
	)
	return item
end

local function zone(parent: Instance, name: string, marker: string): Model
	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("TinyWorldArtRole", marker)
	model:SetAttribute("TinyWorldVisualState", "premium-native-r7")
	model:SetAttribute("TinyWorldR7Decorative", true)
	model.Parent = parent
	return model
end

local function addCompactSign(parent: Instance, base: CFrame, text: string, accent: Color3)
	local board = part(
		parent,
		"CompactSign",
		Vector3.new(5.6, 2.1, 0.38),
		base,
		accent,
		Enum.Material.WoodPlanks,
		"r7-compact-diegetic-sign"
	)
	local gui = Instance.new("SurfaceGui")
	gui.Name = "SignSurface"
	gui.Face = Enum.NormalId.Front
	gui.AlwaysOnTop = false
	gui.LightInfluence = 0.8
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 34
	gui.Parent = board
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.TextColor3 = VisualTheme.Colors.paper
	label.Text = text
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = gui
	local constraint = Instance.new("UITextSizeConstraint")
	constraint.MinTextSize = 9
	constraint.MaxTextSize = 18
	constraint.Parent = label
end

local function addCanopy(parent: Instance, base: CFrame, accent: Color3)
	for _, data in
		{
			{ -3.3, accent },
			{ -1.1, VisualTheme.Colors.cream },
			{ 1.1, accent },
			{ 3.3, VisualTheme.Colors.cream },
		}
	do
		part(
			parent,
			"CanopyStripe" .. tostring(data[1]),
			Vector3.new(2.2, 0.35, 6.4),
			base * CFrame.new(data[1], 5.5, 0) * CFrame.Angles(math.rad(4), 0, 0),
			data[2],
			Enum.Material.Fabric,
			"market-display"
		)
	end
	for _, x in { -4.2, 4.2 } do
		part(
			parent,
			"CanopyPost" .. tostring(x),
			Vector3.new(0.42, 5.3, 0.42),
			base * CFrame.new(x, 2.65, 2.0),
			VisualTheme.Colors.timberDark,
			Enum.Material.Wood,
			"market-display"
		)
	end
end

local function addMara(parent: Instance, world)
	local model = zone(parent, "R7MaraActivityZone", "market-display")
	local base = VillageActivityLocations.station(world, "Trader")
	addCanopy(model, base, VisualTheme.Colors.pink)
	part(
		model,
		"MarketCounter",
		Vector3.new(8.5, 1.8, 3.1),
		base * CFrame.new(0, 1.05, -0.5),
		VisualTheme.Colors.woodLight,
		Enum.Material.WoodPlanks,
		"market-display"
	)
	for index, x in { -2.6, 0, 2.6 } do
		part(
			model,
			"GoodsCrate" .. index,
			Vector3.new(2.0, 1.25, 2.0),
			base * CFrame.new(x, 2.05, -0.7),
			VisualTheme.Colors.timber,
			Enum.Material.WoodPlanks,
			"market-display"
		)
		for fruitIndex, offset in { -0.45, 0, 0.45 } do
			ball(
				model,
				"MarketGood" .. index .. "_" .. fruitIndex,
				base * CFrame.new(x + offset, 2.95 + math.abs(offset) * 0.2, -0.72),
				0.68,
				if index == 1
					then VisualTheme.Colors.coral
					elseif index == 2 then VisualTheme.Colors.lemon
					else VisualTheme.Colors.mint,
				"market-display"
			)
		end
	end
	addCompactSign(model, base * CFrame.new(0, 4.0, 2.55), "MARA'S MARKET", VisualTheme.Colors.plum)
end

local function addPip(parent: Instance, world)
	local model = zone(parent, "R7PipActivityZone", "garden-nook")
	local base = VillageActivityLocations.station(world, "Gardener")
	for index, z in { -2.4, 1.1 } do
		part(
			model,
			"RaisedBed" .. index,
			Vector3.new(7.5, 0.72, 2.4),
			base * CFrame.new(0, 0.45, z),
			VisualTheme.Colors.timber,
			Enum.Material.WoodPlanks,
			"garden-nook"
		)
		part(
			model,
			"BedSoil" .. index,
			Vector3.new(6.8, 0.25, 1.8),
			base * CFrame.new(0, 0.88, z),
			VisualTheme.Colors.timberDark,
			Enum.Material.Ground,
			"garden-nook"
		)
		for plantIndex, x in { -2.4, -0.8, 0.8, 2.4 } do
			ball(
				model,
				"GardenPlant" .. index .. "_" .. plantIndex,
				base * CFrame.new(x, 1.5 + (plantIndex % 2) * 0.18, z),
				1.05,
				if plantIndex % 2 == 0 then VisualTheme.Colors.mintDeep else VisualTheme.Colors.flower,
				"garden-nook"
			)
		end
	end
	part(
		model,
		"ToolTable",
		Vector3.new(4.0, 0.5, 2.2),
		base * CFrame.new(-4.8, 1.65, 0),
		VisualTheme.Colors.woodLight,
		Enum.Material.WoodPlanks,
		"garden-nook"
	)
	for _, x in { -5.9, -3.7 } do
		part(
			model,
			"ToolTableLeg" .. tostring(x),
			Vector3.new(0.35, 2.9, 0.35),
			base * CFrame.new(x, 0.2, 0),
			VisualTheme.Colors.timberDark,
			Enum.Material.Wood,
			"garden-nook"
		)
	end
	local can = cylinder(
		model,
		"WateringCan",
		base * CFrame.new(-4.8, 2.35, 0),
		1.35,
		1.25,
		VisualTheme.Colors.aqua,
		Enum.Material.Metal,
		"garden-nook"
	)
	can.CastShadow = true
	part(
		model,
		"WateringSpout",
		Vector3.new(1.7, 0.28, 0.28),
		base * CFrame.new(-3.8, 2.35, -0.15) * CFrame.Angles(0, math.rad(-18), 0),
		VisualTheme.Colors.aqua,
		Enum.Material.Metal,
		"garden-nook"
	)
	addCompactSign(model, base * CFrame.new(0, 3.7, 3.3), "PIP'S PATCH", VisualTheme.Colors.mintDeep)
end

local function addFinn(parent: Instance, world)
	local model = zone(parent, "R7FinnActivityZone", "fishing-nook")
	local station = VillageActivityLocations.station(world, "Fisherman")
	local dock = VillageActivityLocations.fishingDock(world)

	for index = -2, 2 do
		part(
			model,
			"DockPlank" .. index,
			Vector3.new(2.0, 0.32, 7.5),
			dock * CFrame.new(index * 1.75, -0.52, 0),
			if index % 2 == 0 then VisualTheme.Colors.woodLight else VisualTheme.Colors.timber,
			Enum.Material.WoodPlanks,
			"fishing-nook"
		)
	end
	for _, x in { -4.2, 4.2 } do
		part(
			model,
			"DockPost" .. tostring(x),
			Vector3.new(0.65, 3.4, 0.65),
			dock * CFrame.new(x, 0.6, 2.8),
			VisualTheme.Colors.timberDark,
			Enum.Material.Wood,
			"fishing-nook"
		)
	end
	local bucket = cylinder(
		model,
		"FishBucket",
		station * CFrame.new(-2.4, 0.8, -1.5),
		1.75,
		1.6,
		VisualTheme.Colors.metal,
		Enum.Material.Metal,
		"fishing-nook"
	)
	bucket.CastShadow = true
	part(
		model,
		"TackleBox",
		Vector3.new(2.6, 1.25, 1.8),
		station * CFrame.new(2.1, 0.78, -1.5),
		VisualTheme.Colors.aquaDeep,
		Enum.Material.SmoothPlastic,
		"fishing-nook"
	)
	for index, z in { -2.5, 0, 2.5 } do
		ball(
			model,
			"DecorativeBuoy" .. index,
			dock * CFrame.new(5.7, 0.2, z),
			1.15,
			if index % 2 == 0 then VisualTheme.Colors.coral else VisualTheme.Colors.lemon,
			"fishing-nook"
		)
	end
	part(
		model,
		"FishCrate",
		Vector3.new(3.2, 1.3, 2.2),
		station * CFrame.new(0, 0.8, 1.4),
		VisualTheme.Colors.timber,
		Enum.Material.WoodPlanks,
		"fishing-nook"
	)
	addCompactSign(model, station * CFrame.new(0, 3.8, 3.1), "FINN'S FISHING", VisualTheme.Colors.aquaDeep)
end

local function addSkye(parent: Instance, world)
	local model = zone(parent, "R7SkyeActivityZone", "harbour-launch")
	local base = VillageActivityLocations.station(world, "BoatKeeper")
	for index = -2, 2 do
		part(
			model,
			"LaunchPlank" .. index,
			Vector3.new(1.8, 0.28, 8.5),
			base * CFrame.new(index * 1.55, 0.14, -1.6),
			if index % 2 == 0 then VisualTheme.Colors.woodLight else VisualTheme.Colors.timber,
			Enum.Material.WoodPlanks,
			"harbour-launch"
		)
	end
	for _, x in { -3.8, 3.8 } do
		part(
			model,
			"Bollard" .. tostring(x),
			Vector3.new(0.72, 2.2, 0.72),
			base * CFrame.new(x, 1.1, 2.0),
			VisualTheme.Colors.plum,
			Enum.Material.Metal,
			"harbour-launch"
		)
	end
	for index, offset in
		{
			Vector3.new(-2.2, 0.8, 2.8),
			Vector3.new(0, 0.8, 2.8),
			Vector3.new(2.2, 0.8, 2.8),
			Vector3.new(0, 2.1, 2.8),
		}
	do
		part(
			model,
			"DeliveryParcel" .. index,
			Vector3.new(1.8, 1.5, 1.6),
			base * CFrame.new(offset),
			if index == 4 then VisualTheme.Colors.peach else VisualTheme.Colors.creamDeep,
			Enum.Material.SmoothPlastic,
			"harbour-launch"
		)
	end
	addCompactSign(model, base * CFrame.new(0, 4.5, 3.0), "SKYE'S ROUTES", VisualTheme.Colors.aquaDeep)
	part(
		model,
		"RouteBoardPost",
		Vector3.new(0.4, 4.0, 0.4),
		base * CFrame.new(0, 2.0, 3.6),
		VisualTheme.Colors.timberDark,
		Enum.Material.Wood,
		"harbour-launch"
	)
end

local function addMilo(parent: Instance, world)
	local model = zone(parent, "R7MiloActivityZone", "builder-workshop")
	local base = VillageActivityLocations.station(world, "Builder")
	part(
		model,
		"WorkbenchTop",
		Vector3.new(7.2, 0.55, 3.0),
		base * CFrame.new(0, 2.3, -0.5),
		VisualTheme.Colors.woodLight,
		Enum.Material.WoodPlanks,
		"builder-workshop"
	)
	for _, x in { -2.8, 2.8 } do
		part(
			model,
			"WorkbenchLeg" .. tostring(x),
			Vector3.new(0.5, 3.8, 0.5),
			base * CFrame.new(x, 0.4, -0.5),
			VisualTheme.Colors.timberDark,
			Enum.Material.Wood,
			"builder-workshop"
		)
	end
	for index, y in { 0.55, 1.3, 2.05 } do
		part(
			model,
			"TimberStack" .. index,
			Vector3.new(5.4, 0.5, 0.75),
			base * CFrame.new(0, y, 2.5),
			if index % 2 == 0 then VisualTheme.Colors.timber else VisualTheme.Colors.woodLight,
			Enum.Material.WoodPlanks,
			"builder-workshop"
		)
	end
	part(
		model,
		"HammerHandle",
		Vector3.new(0.28, 2.2, 0.28),
		base * CFrame.new(-1.2, 3.5, -0.5) * CFrame.Angles(0, 0, math.rad(45)),
		VisualTheme.Colors.timberDark,
		Enum.Material.Wood,
		"builder-workshop"
	)
	part(
		model,
		"HammerHead",
		Vector3.new(1.15, 0.48, 0.55),
		base * CFrame.new(-0.45, 4.25, -0.5) * CFrame.Angles(0, 0, math.rad(45)),
		VisualTheme.Colors.metal,
		Enum.Material.Metal,
		"builder-workshop"
	)
	part(
		model,
		"ToolBox",
		Vector3.new(2.2, 1.25, 1.5),
		base * CFrame.new(2.0, 3.0, -0.5),
		VisualTheme.Colors.coral,
		Enum.Material.Metal,
		"builder-workshop"
	)
	addCompactSign(model, base * CFrame.new(0, 4.5, 3.0), "MILO'S WORKSHOP", VisualTheme.Colors.peach)
end

function R7ActivityPresentationBuilder.apply(world)
	local root = world.root
	local oldR6 = root:FindFirstChild("R6ActivityStations")
	if oldR6 then
		oldR6:Destroy()
	end
	local existing = root:FindFirstChild(ROOT_NAME)
	if existing then
		existing:Destroy()
	end
	local model = Instance.new("Model")
	model.Name = ROOT_NAME
	model:SetAttribute("TinyWorldVisualState", "premium-native-r7")
	model:SetAttribute("TinyWorldR7Decorative", true)
	model.Parent = root

	addMara(model, world)
	addPip(model, world)
	addFinn(model, world)
	addSkye(model, world)
	addMilo(model, world)
	return model
end

return R7ActivityPresentationBuilder
