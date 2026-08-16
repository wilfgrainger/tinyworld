local VillageActivityLocations = require(script.Parent:WaitForChild("VillageActivityLocations"))
local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))

local R7BuildingPolishBuilder = {}

local ROOT_NAME = "ART_R7_BuildingPolish"

local function decoration(
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

local function addFlowerPot(parent: Instance, base: CFrame, name: string, accent: Color3)
	local pot = decoration(
		parent,
		name .. "Pot",
		Vector3.new(1.6, 1.0, 1.6),
		base * CFrame.new(0, 0.55, 0),
		VisualTheme.Colors.peach,
		Enum.Material.SmoothPlastic,
		"lived-in-detail",
		Enum.PartType.Cylinder
	)
	pot.CFrame *= CFrame.Angles(0, 0, math.rad(90))
	for index, offset in { -0.45, 0.15, 0.48 } do
		decoration(
			parent,
			name .. "Bloom" .. index,
			Vector3.new(0.72, 0.72, 0.72),
			base * CFrame.new(offset, 1.45 + math.abs(offset) * 0.25, 0),
			if index % 2 == 0 then accent else VisualTheme.Colors.lemon,
			Enum.Material.SmoothPlastic,
			"lived-in-detail",
			Enum.PartType.Ball
		)
	end
end

local function addFramedWindow(parent: Instance, base: CFrame, name: string, accent: Color3)
	decoration(
		parent,
		name .. "Glass",
		Vector3.new(4.1, 3.5, 0.18),
		base,
		VisualTheme.Colors.sky,
		Enum.Material.Glass,
		"framed-window"
	).Transparency = 0.24
	for _, data in {
		{ Vector3.new(4.7, 0.32, 0.32), Vector3.new(0, 1.92, -0.02) },
		{ Vector3.new(4.7, 0.32, 0.32), Vector3.new(0, -1.92, -0.02) },
		{ Vector3.new(0.32, 4.15, 0.32), Vector3.new(-2.22, 0, -0.02) },
		{ Vector3.new(0.32, 4.15, 0.32), Vector3.new(2.22, 0, -0.02) },
		{ Vector3.new(0.26, 3.55, 0.3), Vector3.new(0, 0, -0.04) },
	} do
		decoration(
			parent,
			name .. "Frame",
			data[1],
			base * CFrame.new(data[2]),
			accent,
			Enum.Material.Wood,
			"framed-window"
		)
	end
end

local function addRoof(parent: Instance, base: CFrame, width: number, depth: number, accent: Color3)
	local rise = 1.55
	local run = width / 4
	local angle = math.atan2(rise, run)
	local slopeLength = math.sqrt(run * run + rise * rise) * 2
	for side, sign in { { "Left", -1 }, { "Right", 1 } } do
		decoration(
			parent,
			"Roof" .. side,
			Vector3.new(slopeLength + 1.6, 0.6, depth + 2.2),
			base
				* CFrame.new(sign * width * 0.25, 0.7, 0)
				* CFrame.Angles(0, 0, sign * angle),
			accent,
			Enum.Material.SmoothPlastic,
			"roof-overhang"
		)
	end
	decoration(
		parent,
		"RoofRidge",
		Vector3.new(0.65, 0.65, depth + 2.4),
		base * CFrame.new(0, rise + 0.55, 0),
		VisualTheme.Colors.creamDeep,
		Enum.Material.SmoothPlastic,
		"roof-overhang"
	)
end

local function addAwning(parent: Instance, base: CFrame, width: number, accent: Color3)
	local canopy = decoration(
		parent,
		"SoftAwning",
		Vector3.new(width, 0.45, 3.4),
		base * CFrame.new(0, 0, -1.45) * CFrame.Angles(math.rad(7), 0, 0),
		accent,
		Enum.Material.Fabric,
		"awning-detail"
	)
	canopy.CastShadow = true
	for index, x in { -width * 0.35, 0, width * 0.35 } do
		decoration(
			parent,
			"AwningScallop" .. index,
			Vector3.new(width / 3.6, 0.6, 0.35),
			base * CFrame.new(x, -0.18, -3.0),
			if index % 2 == 0 then accent else VisualTheme.Colors.cream,
			Enum.Material.Fabric,
			"awning-detail"
		)
	end
end

local function addPorch(parent: Instance, base: CFrame, width: number, accent: Color3)
	decoration(
		parent,
		"PorchStep",
		Vector3.new(width, 0.5, 3.5),
		base * CFrame.new(0, 0.25, -1.4),
		VisualTheme.Colors.softStone,
		Enum.Material.Cobblestone,
		"porch-detail"
	)
	for _, x in { -width * 0.44, width * 0.44 } do
		decoration(
			parent,
			"PorchPost" .. tostring(x),
			Vector3.new(0.42, 3.4, 0.42),
			base * CFrame.new(x, 1.95, -0.55),
			VisualTheme.Colors.woodLight,
			Enum.Material.Wood,
			"porch-detail"
		)
	end
	addFlowerPot(parent, base * CFrame.new(-width * 0.32, 0.5, -2.55), "PorchPotLeft", accent)
	addFlowerPot(parent, base * CFrame.new(width * 0.32, 0.5, -2.55), "PorchPotRight", accent)
end

local function addFacade(
	parent: Instance,
	name: string,
	base: CFrame,
	buildingRole: string,
	accent: Color3,
	wall: Color3,
	width: number
)
	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("TinyWorldBuildingRole", buildingRole)
	model:SetAttribute("TinyWorldVisualState", "premium-native-r7")
	model:SetAttribute("TinyWorldR7Decorative", true)
	model.Parent = parent

	decoration(
		model,
		"Facade",
		Vector3.new(width, 7.8, 1.0),
		base * CFrame.new(0, 4.0, 1.4),
		wall,
		Enum.Material.Plaster,
		buildingRole
	)
	decoration(
		model,
		"FacadeTrim",
		Vector3.new(width - 1.2, 0.52, 0.46),
		base * CFrame.new(0, 6.75, 0.82),
		accent,
		Enum.Material.Wood,
		"lived-in-detail"
	)
	addRoof(model, base * CFrame.new(0, 7.9, 1.4), width, 5.5, accent)
	addFramedWindow(model, base * CFrame.new(-width * 0.25, 4.3, 0.82), "WindowLeft", accent)
	addFramedWindow(model, base * CFrame.new(width * 0.25, 4.3, 0.82), "WindowRight", accent)
	addAwning(model, base * CFrame.new(0, 6.15, 0.5), width * 0.6, accent)
	addPorch(model, base * CFrame.new(0, 0.35, 0), width * 0.62, accent)
	return model
end

function R7BuildingPolishBuilder.decorateHomeShell(shell: Model)
	if shell:FindFirstChild("R7HomeCharmLayer") then
		return
	end
	local reference = shell:FindFirstChild("FrontDoor")
	if not reference or not reference:IsA("BasePart") then
		return
	end
	local model = Instance.new("Model")
	model.Name = "R7HomeCharmLayer"
	model:SetAttribute("TinyWorldBuildingRole", "building-residential")
	model:SetAttribute("TinyWorldVisualState", "premium-native-r7")
	model.Parent = shell
	local base = reference.CFrame * CFrame.new(0, -reference.Size.Y * 0.5, -0.8)
	addFlowerPot(model, base * CFrame.new(-3.5, 0, -1.0), "HomeFlowerPotLeft", VisualTheme.Colors.pink)
	addFlowerPot(model, base * CFrame.new(3.5, 0, -1.0), "HomeFlowerPotRight", VisualTheme.Colors.aqua)
	decoration(
		model,
		"HomeDoorHalo",
		Vector3.new(reference.Size.X + 1.0, 0.42, 0.38),
		reference.CFrame * CFrame.new(0, reference.Size.Y * 0.5 + 0.35, -0.25),
		VisualTheme.Colors.creamDeep,
		Enum.Material.Wood,
		"lived-in-detail"
	)
end

function R7BuildingPolishBuilder.apply(world)
	local root = world.root
	local existing = root:FindFirstChild(ROOT_NAME)
	if existing then
		existing:Destroy()
	end
	local model = Instance.new("Model")
	model.Name = ROOT_NAME
	model:SetAttribute("TinyWorldVisualState", "premium-native-r7")
	model.Parent = root

	local market = VillageActivityLocations.npc(world, "Trader") * CFrame.new(0, 0, 13)
	local garden = VillageActivityLocations.npc(world, "Gardener") * CFrame.new(0, 0, 14)
	local workshop = VillageActivityLocations.npc(world, "Builder") * CFrame.new(0, 0, 14)
	local harbour = VillageActivityLocations.npc(world, "BoatKeeper") * CFrame.new(0, 0, 14)
	local residential = CFrame.new(-70, 0, -72) * CFrame.Angles(0, math.rad(45), 0)

	addFacade(
		model,
		"ResidentialCottageIdentity",
		residential,
		"building-residential",
		VisualTheme.Colors.pink,
		VisualTheme.Colors.cream,
		14
	)
	addFacade(
		model,
		"MarketHouseIdentity",
		market,
		"building-market",
		VisualTheme.Colors.pink,
		VisualTheme.Colors.butter,
		15
	)
	addFacade(
		model,
		"GardenHouseIdentity",
		garden,
		"building-garden",
		VisualTheme.Colors.mintDeep,
		VisualTheme.Colors.seafoam,
		14
	)
	addFacade(
		model,
		"WorkshopHouseIdentity",
		workshop,
		"building-workshop",
		VisualTheme.Colors.peach,
		VisualTheme.Colors.cream,
		15
	)
	addFacade(
		model,
		"HarbourHouseIdentity",
		harbour,
		"building-harbour",
		VisualTheme.Colors.aquaDeep,
		VisualTheme.Colors.paper,
		14
	)

	return model
end

return R7BuildingPolishBuilder
