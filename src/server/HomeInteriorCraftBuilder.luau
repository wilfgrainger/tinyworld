local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))

local HomeInteriorCraftBuilder = {}

local function decoration(parent, name, size, cframe, color, material, role)
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

local function warmLight(parent: BasePart, brightness: number, range: number)
	local light = parent:FindFirstChild("CraftedWarmLight")
	if not light or not light:IsA("PointLight") then
		if light then
			light:Destroy()
		end
		light = Instance.new("PointLight")
		light.Name = "CraftedWarmLight"
		light.Parent = parent
	end
	light.Brightness = brightness
	light.Range = range
	light.Color = VisualTheme.Colors.warmLight
	light.Shadows = false
	return light
end

local function craftBedsideLamp(container: Instance)
	local lamp = container:FindFirstChild("HomeFurniture_BedsideLamp", true)
	if not lamp or not lamp:IsA("Part") then
		return
	end
	lamp.Shape = Enum.PartType.Block
	lamp.Size = Vector3.new(0.55, 0.9, 0.55)
	lamp.Material = Enum.Material.Glass
	lamp.Color = VisualTheme.Colors.warmLight
	lamp.Transparency = 0.22
	lamp:SetAttribute("TinyWorldArtRole", "home-bedside-lamp-core")
	local light = warmLight(lamp, 0.55, 8)
	light.Enabled = false

	local parent = lamp.Parent
	if not parent then
		return
	end
	local oldShade = parent:FindFirstChild("HomeFurniture_BedsideLampShade")
	if oldShade then
		oldShade:Destroy()
	end
	decoration(
		parent,
		"HomeFurniture_BedsideLampShade",
		Vector3.new(1.9, 1.2, 1.9),
		lamp.CFrame * CFrame.new(0, 0.28, 0),
		VisualTheme.Colors.cream,
		Enum.Material.Fabric,
		"home-bedside-lamp-shade"
	)
	decoration(
		parent,
		"HomeFurniture_BedsideLampCap",
		Vector3.new(0.8, 0.18, 0.8),
		lamp.CFrame * CFrame.new(0, 0.95, 0),
		VisualTheme.Colors.timberDark,
		Enum.Material.Metal,
		"home-bedside-lamp-cap"
	)
end

local function addCeilingFixture(room: Instance, name: string, cframe: CFrame, accent: Color3)
	if room:FindFirstChild(name) then
		return
	end
	local mount = decoration(
		room,
		name,
		Vector3.new(2.2, 0.35, 2.2),
		cframe,
		VisualTheme.Colors.timberDark,
		Enum.Material.Metal,
		"home-ceiling-light-mount"
	)
	local glow = decoration(
		room,
		name .. "Glass",
		Vector3.new(1.55, 0.45, 1.55),
		cframe * CFrame.new(0, -0.3, 0),
		accent,
		Enum.Material.Glass,
		"home-ceiling-light-glass"
	)
	glow.Transparency = 0.25
	local light = warmLight(glow, 0.32, 7)
	light.Enabled = true
	mount:SetAttribute("TinyWorldInteriorCraft", true)
end

local function addLivingCluster(container: Instance, anchor: Vector3)
	local room = container:FindFirstChild("HomeRoom_Living")
	if not room then
		return
	end
	if not room:FindFirstChild("CraftedLivingCoffeeTable") then
		decoration(
			room,
			"CraftedLivingCoffeeTable",
			Vector3.new(4.2, 0.55, 2.4),
			CFrame.new(anchor + Vector3.new(-1.6, 2.45, 4.6)),
			VisualTheme.Colors.timber,
			Enum.Material.WoodPlanks,
			"home-living-coffee-table"
		)
		decoration(
			room,
			"CraftedLivingBookStack",
			Vector3.new(1.5, 0.42, 1),
			CFrame.new(anchor + Vector3.new(-1.5, 2.95, 4.5)),
			VisualTheme.Colors.berry,
			Enum.Material.Fabric,
			"home-living-book-stack"
		)
	end
	addCeilingFixture(room, "CraftedLivingCeilingLight", CFrame.new(anchor + Vector3.new(-2.5, 7.6, 4.7)), VisualTheme.Colors.warmLight)
end

local function addKitchenCluster(container: Instance, anchor: Vector3)
	local room = container:FindFirstChild("HomeRoom_Kitchen")
	if not room then
		return
	end
	if not room:FindFirstChild("CraftedKitchenBacksplash") then
		decoration(
			room,
			"CraftedKitchenBacksplash",
			Vector3.new(8, 2.1, 0.25),
			CFrame.new(anchor + Vector3.new(4.3, 5.9, -7.05)),
			VisualTheme.Colors.creamDeep,
			Enum.Material.CeramicTiles,
			"home-kitchen-backsplash"
		)
		decoration(
			room,
			"CraftedKitchenShelf",
			Vector3.new(5.5, 0.45, 1),
			CFrame.new(anchor + Vector3.new(4.3, 7, -6.6)),
			VisualTheme.Colors.timber,
			Enum.Material.WoodPlanks,
			"home-kitchen-shelf"
		)
	end
	addCeilingFixture(room, "CraftedKitchenCeilingLight", CFrame.new(anchor + Vector3.new(4.5, 7.6, -2.8)), VisualTheme.Colors.warmLight)
end

local function addBedroomCluster(container: Instance, anchor: Vector3)
	local room = container:FindFirstChild("HomeRoom_Bedroom")
	if not room then
		return
	end
	if not room:FindFirstChild("CraftedBedroomWallArt") then
		decoration(
			room,
			"CraftedBedroomWallArt",
			Vector3.new(3.5, 2.2, 0.22),
			CFrame.new(anchor + Vector3.new(-5, 6.2, -7.05)),
			VisualTheme.Colors.flower,
			Enum.Material.SmoothPlastic,
			"home-bedroom-wall-art"
		)
	end
end

function HomeInteriorCraftBuilder.apply(plot)
	local container = plot.houseContainer
	local anchor = plot.houseAnchor
	if not container or not anchor then
		return
	end
	craftBedsideLamp(container)
	addBedroomCluster(container, anchor)
	addKitchenCluster(container, anchor)
	addLivingCluster(container, anchor)
	container:SetAttribute("TinyWorldInteriorCraft", "v0.6.3")
end

return HomeInteriorCraftBuilder
