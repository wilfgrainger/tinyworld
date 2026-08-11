local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))
local ArchitecturalDetailBuilder = require(script.Parent:WaitForChild("ArchitecturalDetailBuilder"))

local CivicHeroRebuildBuilder = {}

local function decoration(
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

local function destroyNamed(model: Model, names: { string })
	for _, name in names do
		local item = model:FindFirstChild(name, true)
		if item then
			item:Destroy()
		end
	end
end

local function destroyPrefix(model: Model, prefixes: { string })
	for _, item in model:GetDescendants() do
		for _, prefix in prefixes do
			if string.sub(item.Name, 1, #prefix) == prefix then
				item:Destroy()
				break
			end
		end
	end
end

local function originFrom(model: Model, partName: string, yOffset: number): Vector3?
	local part = model:FindFirstChild(partName)
	if part and part:IsA("BasePart") then
		return part.Position - Vector3.new(0, yOffset, 0)
	end
	return nil
end

local function addFacadePilasters(
	model: Model,
	origin: Vector3,
	width: number,
	height: number,
	frontZ: number,
	role: string
)
	for _, x in { -(width / 2) + 1, (width / 2) - 1 } do
		decoration(
			model,
			role .. "Pilaster" .. tostring(x),
			Vector3.new(1.15, height, 1.15),
			CFrame.new(origin + Vector3.new(x, (height / 2) + 1, frontZ)),
			VisualTheme.Colors.creamDeep,
			Enum.Material.Brick,
			role .. "-facade-pilaster"
		)
	end
	decoration(
		model,
		role .. "Cornice",
		Vector3.new(width - 2, 0.65, 0.8),
		CFrame.new(origin + Vector3.new(0, height + 0.7, frontZ + 0.15)),
		VisualTheme.Colors.woodLight,
		Enum.Material.Wood,
		role .. "-cornice"
	)
end

local function rebuildTownHall(model: Model)
	local origin = originFrom(model, "TownHallFoundation", 0.5)
	if not origin then
		return
	end

	destroyNamed(model, {
		"TownHallRoofLeft",
		"TownHallRoofRight",
		"TownHallBell",
		"TownHallFinalRoof",
		"TownHallClockTowerRoof",
	})

	ArchitecturalDetailBuilder.addPitchedRoof(model, {
		name = "TownHallFinalRoof",
		role = "town-hall-final-roof",
		width = 26,
		depth = 20,
		center = origin + Vector3.new(0, 13.1, 0),
		rise = 5.1,
		eave = 0.9,
		color = VisualTheme.Colors.roof,
		ridgeColor = VisualTheme.Colors.roofLight,
		gableTrimColor = VisualTheme.Colors.creamDeep,
	})
	ArchitecturalDetailBuilder.addPitchedRoof(model, {
		name = "TownHallClockTowerRoof",
		role = "town-hall-clock-tower-roof",
		width = 9,
		depth = 9,
		center = origin + Vector3.new(0, 22.5, 0),
		rise = 3.4,
		eave = 0.7,
		color = VisualTheme.Colors.roofLight,
		ridgeColor = VisualTheme.Colors.gold,
		gableTrimColor = VisualTheme.Colors.creamDeep,
	})
	addFacadePilasters(model, origin, 26, 12, 10.55, "TownHallFinal")

	decoration(
		model,
		"TownHallClockTowerBand",
		Vector3.new(8.8, 0.65, 8.8),
		CFrame.new(origin + Vector3.new(0, 22.1, 0)),
		VisualTheme.Colors.woodLight,
		Enum.Material.Wood,
		"town-hall-clock-tower-band"
	)
	model:SetAttribute("TinyWorldFinalCivicCraft", "v0.6.3-studio-correction")
end

local function rebuildVillageShop(model: Model)
	local origin = originFrom(model, "VillageShopFloor", 0.5)
	if not origin then
		return
	end

	destroyNamed(model, {
		"VillageShopRoofLeft",
		"VillageShopRoofRight",
		"VillageShopFinalRoof",
		"VillageShopFinalPorch",
	})

	ArchitecturalDetailBuilder.addPitchedRoof(model, {
		name = "VillageShopFinalRoof",
		role = "village-shop-final-roof",
		width = 26,
		depth = 20,
		center = origin + Vector3.new(0, 12.6, 0),
		rise = 4.5,
		eave = 0.85,
		color = VisualTheme.Colors.roof,
		ridgeColor = VisualTheme.Colors.berry,
		gableTrimColor = VisualTheme.Colors.creamDeep,
	})
	ArchitecturalDetailBuilder.addPorch(model, {
		name = "VillageShopFinalPorch",
		role = "village-shop-front-porch",
		width = 15,
		depth = 4.2,
		cframe = CFrame.new(origin + Vector3.new(0, 1.15, 12)),
		deckColor = VisualTheme.Colors.timber,
		canopyColor = VisualTheme.Colors.berry,
	})
	addFacadePilasters(model, origin, 26, 11.5, 10.55, "VillageShopFinal")
	model:SetAttribute("TinyWorldFinalCivicCraft", "v0.6.3-studio-correction")
end

local function rebuildCourier(model: Model)
	local origin = originFrom(model, "CourierDepotFloor", 0.5)
	if not origin then
		return
	end

	destroyNamed(model, {
		"CourierDepotRoof",
		"CourierDepotPitchedRoof",
		"CourierDepotFinalRoof",
	})

	ArchitecturalDetailBuilder.addPitchedRoof(model, {
		name = "CourierDepotFinalRoof",
		role = "courier-depot-final-roof",
		width = 24,
		depth = 18,
		center = origin + Vector3.new(0, 11.55, -1),
		rise = 4.1,
		eave = 0.85,
		color = VisualTheme.Colors.roof,
		ridgeColor = VisualTheme.Colors.warmLight,
		gableTrimColor = VisualTheme.Colors.creamDeep,
	})

	local canopy = ArchitecturalDetailBuilder.addPorch(model, {
		name = "CourierLoadingPorch",
		role = "courier-loading-porch",
		width = 13,
		depth = 4.8,
		cframe = CFrame.new(origin + Vector3.new(-3.8, 1.1, 10.8)),
		deckColor = VisualTheme.Colors.pathEdge,
		canopyColor = VisualTheme.Colors.roofLight,
	})
	canopy:SetAttribute("TinyWorldDestinationCue", "parcel-loading")
	model:SetAttribute("TinyWorldFinalCivicCraft", "v0.6.3-studio-correction")
end

local function rebuildWorkshop(model: Model)
	local origin = originFrom(model, "WorkshopFloor", 0.5)
	if not origin then
		return
	end

	destroyNamed(model, {
		"WorkshopRoof",
		"WorkshopPitchedRoof",
		"WorkshopFinalRoof",
	})

	ArchitecturalDetailBuilder.addPitchedRoof(model, {
		name = "WorkshopFinalRoof",
		role = "workshop-final-roof",
		width = 27,
		depth = 21,
		center = origin + Vector3.new(0, 11.6, 0),
		rise = 4.2,
		eave = 0.8,
		color = VisualTheme.Colors.roof,
		ridgeColor = VisualTheme.Colors.inkSoft,
		gableTrimColor = VisualTheme.Colors.woodLight,
	})

	for _, x in { -11.5, 11.5 } do
		decoration(
			model,
			"WorkshopFinalFrontPost" .. tostring(x),
			Vector3.new(0.8, 8.5, 0.8),
			CFrame.new(origin + Vector3.new(x, 4.7, 10.5)),
			VisualTheme.Colors.timberDark,
			Enum.Material.Wood,
			"workshop-final-front-post"
		)
	end
	model:SetAttribute("TinyWorldFinalCivicCraft", "v0.6.3-studio-correction")
end

local function addMarketStall(
	model: Model,
	origin: Vector3,
	name: string,
	x: number,
	primary: Color3,
	secondary: Color3
)
	local stall = Instance.new("Model")
	stall.Name = name
	stall:SetAttribute("TinyWorldArtRole", "market-final-stall")
	stall:SetAttribute("TinyWorldVisualState", "authored-native")
	stall.Parent = model

	local base = CFrame.new(origin + Vector3.new(x, 0, 2))
	decoration(
		stall,
		"Counter",
		Vector3.new(8.5, 2, 3.8),
		base * CFrame.new(0, 2, 0),
		VisualTheme.Colors.timber,
		Enum.Material.WoodPlanks,
		"market-final-counter"
	)
	for _, dx in { -3.8, 3.8 } do
		for _, z in { -2.3, 2.3 } do
			decoration(
				stall,
				"Post" .. tostring(dx) .. tostring(z),
				Vector3.new(0.45, 6.8, 0.45),
				base * CFrame.new(dx, 3.6, z),
				VisualTheme.Colors.timberDark,
				Enum.Material.Wood,
				"market-final-post"
			)
		end
	end
	for index, dx in { -3.1, 0, 3.1 } do
		decoration(
			stall,
			"AwningStrip" .. index,
			Vector3.new(3.15, 0.22, 6.3),
			base * CFrame.new(dx, 7, 0) * CFrame.Angles(math.rad(5), 0, 0),
			if index == 2 then secondary else primary,
			Enum.Material.Fabric,
			"market-final-awning-strip"
		)
	end
	for index, dx in { -2.4, 0, 2.4 } do
		local basket = decoration(
			stall,
			"Basket" .. index,
			Vector3.new(1.7, 1.1, 1.7),
			base * CFrame.new(dx, 3.55, 0),
			VisualTheme.Colors.timber,
			Enum.Material.WoodPlanks,
			"market-final-basket"
		)
		basket:SetAttribute("TinyWorldDestinationCue", "market-stock")
	end
end

local function rebuildMarket(model: Model)
	local platform = model:FindFirstChild("MarketPlatform")
	if not platform or not platform:IsA("BasePart") then
		return
	end
	local origin = platform.Position

	destroyPrefix(model, { "MarketStallWest", "MarketStallEast", "MarketFinalStall" })
	destroyNamed(model, {
		"MarketTable",
		"MarketTableLeg1",
		"MarketTableLeg2",
		"MarketAwning",
		"MarketAwningPost1",
		"MarketAwningPost2",
	})

	platform.Size = Vector3.new(30, 0.45, 22)
	platform.Color = VisualTheme.Colors.pathLight
	platform.Material = Enum.Material.Cobblestone

	local statusSign = model:FindFirstChild("MarketStatusSign")
	if statusSign and statusSign:IsA("BasePart") then
		statusSign.Size = Vector3.new(10, 3.2, 0.55)
		statusSign.Position = origin + Vector3.new(0, 5.4, -9)
	end

	addMarketStall(model, origin, "MarketFinalStallWest", -7.8, VisualTheme.Colors.warmLight, VisualTheme.Colors.cream)
	addMarketStall(model, origin, "MarketFinalStallEast", 7.8, VisualTheme.Colors.flower, VisualTheme.Colors.paper)
	model:SetAttribute("TinyWorldFinalCivicCraft", "v0.6.3-studio-correction")
end

function CivicHeroRebuildBuilder.apply(root: Instance)
	local mappings = {
		TownHallPrefab = rebuildTownHall,
		VillageShopPrefab = rebuildVillageShop,
		CourierDepotPrefab = rebuildCourier,
		TransportWorkshopPrefab = rebuildWorkshop,
		VillageMarketPrefab = rebuildMarket,
	}

	for modelName, rebuild in mappings do
		local model = root:FindFirstChild(modelName)
		if model and model:IsA("Model") then
			rebuild(model)
		end
	end
end

return CivicHeroRebuildBuilder
