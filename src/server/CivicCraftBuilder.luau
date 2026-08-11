local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))
local ArchitecturalDetailBuilder = require(script.Parent:WaitForChild("ArchitecturalDetailBuilder"))

local CivicCraftBuilder = {}

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
	part:SetAttribute("TinyWorldArtRole", role)
	part:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	part.Parent = parent
	return part
end

local function originFrom(model: Model, partName: string, yOffset: number): Vector3?
	local part = model:FindFirstChild(partName)
	if part and part:IsA("BasePart") then
		return part.Position - Vector3.new(0, yOffset, 0)
	end
	return nil
end

local function addTownHallCraft(model: Model)
	local origin = originFrom(model, "TownHallFoundation", 0.5)
	if not origin then
		return
	end
	ArchitecturalDetailBuilder.addPorch(model, {
		name = "TownHallPortico",
		role = "town-hall-portico",
		width = 12,
		depth = 4.8,
		cframe = CFrame.new(origin + Vector3.new(0, 1.25, 11.8)),
		deckColor = VisualTheme.Colors.pathEdge,
		canopyColor = VisualTheme.Colors.roof,
	})
	for index, x in { -7, 7 } do
		ArchitecturalDetailBuilder.addWindow(model, {
			name = "TownHallCraftWindow" .. index,
			role = "town-hall-window-crafted",
			width = 4.7,
			height = 4.5,
			cframe = CFrame.new(origin + Vector3.new(x, 7, 10.65)),
			glassColor = VisualTheme.Colors.inkGlass,
			frameColor = VisualTheme.Colors.timberDark,
			transparency = 0.42,
			warmLight = true,
		})
		ArchitecturalDetailBuilder.addLantern(model, {
			name = "TownHallLantern" .. index,
			role = "town-hall-practical-lantern",
			cframe = CFrame.new(origin + Vector3.new(x * 0.65, 7.3, 11.15)),
			brightness = 0.48,
			range = 9,
		})
	end
end

local function addCourierCraft(model: Model)
	local origin = originFrom(model, "CourierDepotFloor", 0.5)
	if not origin then
		return
	end
	local oldRoof = model:FindFirstChild("CourierDepotRoof")
	if oldRoof then
		oldRoof:Destroy()
	end
	ArchitecturalDetailBuilder.addPitchedRoof(model, {
		name = "CourierDepotPitchedRoof",
		role = "courier-depot-crafted-roof",
		width = 24,
		depth = 18,
		center = origin + Vector3.new(0, 12, -1),
		rise = 4.2,
		eave = 1.2,
		color = VisualTheme.Colors.roof,
		gableTrimColor = VisualTheme.Colors.creamDeep,
	})
	for index, x in { -7.5, 7.5 } do
		ArchitecturalDetailBuilder.addLantern(model, {
			name = "CourierLantern" .. index,
			role = "courier-practical-lantern",
			cframe = CFrame.new(origin + Vector3.new(x, 7.2, 10.6)),
			brightness = 0.44,
			range = 8,
		})
	end
	decoration(
		model,
		"CourierRouteBoardFrame",
		Vector3.new(8.5, 5.5, 0.4),
		CFrame.new(origin + Vector3.new(8.5, 4.6, 9.7)),
		VisualTheme.Colors.timberDark,
		Enum.Material.Wood,
		"courier-route-board-frame"
	)
end

local function addShopCraft(model: Model)
	local origin = originFrom(model, "VillageShopFloor", 0.5)
	if not origin then
		return
	end
	for _, name in
		{
			"HomeSupplyCounter",
			"DecoratorCatalogue",
			"FurnishingShowroomTable",
			"FurnishingShowroomLamp",
		}
	do
		local old = model:FindFirstChild(name)
		if old then
			old:Destroy()
		end
	end
	ArchitecturalDetailBuilder.addDoor(model, {
		name = "VillageShopEntry",
		role = "village-shop-entry",
		width = 4.5,
		height = 6.8,
		cframe = CFrame.new(origin + Vector3.new(0, 4.2, 10.7)),
		color = VisualTheme.Colors.timberDark,
		frameColor = VisualTheme.Colors.woodLight,
	})
	for index, x in { -8, 8 } do
		ArchitecturalDetailBuilder.addWindow(model, {
			name = "VillageShopCraftWindow" .. index,
			role = "village-shop-display-window",
			width = 5.2,
			height = 4.5,
			cframe = CFrame.new(origin + Vector3.new(x, 6, 10.65)),
			glassColor = VisualTheme.Colors.inkGlass,
			frameColor = VisualTheme.Colors.timberDark,
			transparency = 0.42,
			warmLight = true,
		})
		ArchitecturalDetailBuilder.addLantern(model, {
			name = "VillageShopLantern" .. index,
			role = "village-shop-practical-lantern",
			cframe = CFrame.new(origin + Vector3.new(x * 0.55, 7.2, 11.2)),
			brightness = 0.42,
			range = 8,
		})
	end
	for index, x in { -9, 9 } do
		decoration(
			model,
			"ShopfrontCrate" .. index,
			Vector3.new(4.2, 2.2, 3.2),
			CFrame.new(origin + Vector3.new(x, 1.5, 13.5)) * CFrame.Angles(0, math.rad(index * 5), 0),
			VisualTheme.Colors.timber,
			Enum.Material.WoodPlanks,
			"village-shop-stock-crate"
		)
	end
end

local function addWorkshopCraft(model: Model)
	local origin = originFrom(model, "WorkshopFloor", 0.5)
	if not origin then
		return
	end
	local oldRoof = model:FindFirstChild("WorkshopRoof")
	if oldRoof then
		oldRoof:Destroy()
	end
	ArchitecturalDetailBuilder.addPitchedRoof(model, {
		name = "WorkshopPitchedRoof",
		role = "workshop-crafted-roof",
		width = 26,
		depth = 20,
		center = origin + Vector3.new(0, 12, 0),
		rise = 4.4,
		eave = 1.1,
		color = VisualTheme.Colors.roof,
		ridgeColor = VisualTheme.Colors.inkSoft,
	})
	ArchitecturalDetailBuilder.addLantern(model, {
		name = "WorkshopLantern",
		role = "workshop-practical-lantern",
		cframe = CFrame.new(origin + Vector3.new(-10, 7.2, 10.7)),
		brightness = 0.5,
		range = 9,
	})
	decoration(
		model,
		"WorkshopGarageHeaderCraft",
		Vector3.new(20, 1, 1),
		CFrame.new(origin + Vector3.new(0, 10.2, 10.65)),
		VisualTheme.Colors.woodLight,
		Enum.Material.Wood,
		"workshop-garage-header"
	)
end

local function marketStall(model: Model, origin: Vector3, name: string, x: number, color: Color3)
	local base = CFrame.new(origin + Vector3.new(x, 0, 2))
	decoration(
		model,
		name .. "Counter",
		Vector3.new(11, 2.2, 5),
		base * CFrame.new(0, 2.2, 0),
		VisualTheme.Colors.timber,
		Enum.Material.WoodPlanks,
		"market-crafted-counter"
	)
	for _, dx in { -4.8, 4.8 } do
		decoration(
			model,
			name .. "Post" .. tostring(dx),
			Vector3.new(0.55, 8, 0.55),
			base * CFrame.new(dx, 4.2, 0),
			VisualTheme.Colors.timberDark,
			Enum.Material.Wood,
			"market-crafted-post"
		)
	end
	decoration(
		model,
		name .. "Canopy",
		Vector3.new(12.5, 0.55, 7),
		base * CFrame.new(0, 8, 0) * CFrame.Angles(0, 0, math.rad(if x < 0 then 3 else -3)),
		color,
		Enum.Material.Fabric,
		"market-crafted-canopy"
	)
	for index, dx in { -3, 0, 3 } do
		decoration(
			model,
			name .. "Basket" .. index,
			Vector3.new(2.3, 1.2, 2),
			base * CFrame.new(dx, 3.9, 0),
			if index == 2 then VisualTheme.Colors.flower else VisualTheme.Colors.gold,
			Enum.Material.Fabric,
			"market-crafted-stock"
		)
	end
end

local function addMarketCraft(model: Model)
	local platform = model:FindFirstChild("MarketPlatform")
	if not platform or not platform:IsA("BasePart") then
		return
	end
	local origin = platform.Position
	for _, name in
		{ "MarketTable", "MarketTableLeg1", "MarketTableLeg2", "MarketAwning", "MarketAwningPost1", "MarketAwningPost2" }
	do
		local old = model:FindFirstChild(name)
		if old then
			old:Destroy()
		end
	end
	platform.Size = Vector3.new(34, 0.55, 24)
	platform.Color = VisualTheme.Colors.pathLight
	marketStall(model, origin, "MarketStallWest", -8.5, VisualTheme.Colors.warmLight)
	marketStall(model, origin, "MarketStallEast", 8.5, VisualTheme.Colors.flower)
	for index, x in { -15, 15 } do
		ArchitecturalDetailBuilder.addLantern(model, {
			name = "MarketLantern" .. index,
			role = "market-practical-lantern",
			cframe = CFrame.new(origin + Vector3.new(x, 7, -7)),
			postHeight = 5.7,
			brightness = 0.44,
			range = 9,
		})
	end
end

function CivicCraftBuilder.apply(root: Instance)
	local mappings = {
		TownHallPrefab = addTownHallCraft,
		CourierDepotPrefab = addCourierCraft,
		VillageShopPrefab = addShopCraft,
		TransportWorkshopPrefab = addWorkshopCraft,
		VillageMarketPrefab = addMarketCraft,
	}
	for name, apply in mappings do
		local model = root:FindFirstChild(name)
		if model and model:IsA("Model") then
			apply(model)
		end
	end
end

return CivicCraftBuilder
