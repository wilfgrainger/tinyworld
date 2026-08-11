local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))
local ArchitecturalDetailBuilder = require(script.Parent:WaitForChild("ArchitecturalDetailBuilder"))

local CivicFacadePolishBuilder = {}

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

local function originFrom(model: Model, partName: string, yOffset: number): Vector3?
	local item = model:FindFirstChild(partName)
	if item and item:IsA("BasePart") then
		return item.Position - Vector3.new(0, yOffset, 0)
	end
	return nil
end

local function addSideWindows(
	model: Model,
	origin: Vector3,
	width: number,
	depth: number,
	y: number,
	role: string,
	glassColor: Color3
)
	for _, side in { -1, 1 } do
		for index, z in { -depth * 0.22, depth * 0.22 } do
			ArchitecturalDetailBuilder.addWindow(model, {
				name = role .. "SideWindow" .. tostring(side) .. tostring(index),
				role = role .. "-side-window",
				width = 4.3,
				height = 4.1,
				cframe = CFrame.new(origin + Vector3.new(side * ((width / 2) + 0.52), y, z))
					* CFrame.Angles(0, math.rad(if side < 0 then -90 else 90), 0),
				frameColor = VisualTheme.Colors.timberDark,
				sillColor = VisualTheme.Colors.woodLight,
				glassColor = glassColor,
				transparency = 0.38,
				warmLight = true,
			})
		end
	end
end

local function addStoneBaseCourse(model: Model, origin: Vector3, width: number, depth: number, role: string)
	local color = VisualTheme.Colors.pathEdge
	decoration(
		model,
		role .. "BaseFront",
		Vector3.new(width + 1, 1.4, 0.65),
		CFrame.new(origin + Vector3.new(0, 1.45, (depth / 2) + 0.42)),
		color,
		Enum.Material.Cobblestone,
		role .. "-base-course"
	)
	decoration(
		model,
		role .. "BaseBack",
		Vector3.new(width + 1, 1.4, 0.65),
		CFrame.new(origin + Vector3.new(0, 1.45, -(depth / 2) - 0.42)),
		color,
		Enum.Material.Cobblestone,
		role .. "-base-course"
	)
	for _, side in { -1, 1 } do
		decoration(
			model,
			role .. "BaseSide" .. tostring(side),
			Vector3.new(0.65, 1.4, depth),
			CFrame.new(origin + Vector3.new(side * ((width / 2) + 0.42), 1.45, 0)),
			color,
			Enum.Material.Cobblestone,
			role .. "-base-course"
		)
	end
end

local function addPlanter(model: Model, name: string, position: Vector3, flowerColor: Color3)
	decoration(
		model,
		name .. "Box",
		Vector3.new(4.2, 1.1, 2),
		CFrame.new(position),
		VisualTheme.Colors.timber,
		Enum.Material.WoodPlanks,
		"civic-planter-box"
	)
	for index, x in { -1.25, 0, 1.25 } do
		local foliage = decoration(
			model,
			name .. "Plant" .. index,
			Vector3.new(1.25, 1.45 + (index * 0.12), 1.25),
			CFrame.new(position + Vector3.new(x, 1.2, 0)),
			if index == 2 then flowerColor else VisualTheme.Colors.leafLight,
			Enum.Material.LeafyGrass,
			"civic-planter-foliage"
		)
		foliage.Shape = Enum.PartType.Ball
	end
end

local function polishTownHall(model: Model)
	local origin = originFrom(model, "TownHallFoundation", 0.5)
	if not origin then
		return
	end
	addStoneBaseCourse(model, origin, 26, 20, "TownHall")
	addSideWindows(model, origin, 26, 20, 7, "TownHall", VisualTheme.Colors.inkGlass)
	addPlanter(model, "TownHallPlanterLeft", origin + Vector3.new(-9, 1.2, 12.6), VisualTheme.Colors.flower)
	addPlanter(model, "TownHallPlanterRight", origin + Vector3.new(9, 1.2, 12.6), VisualTheme.Colors.warmLight)
	model:SetAttribute("TinyWorldPlayerHeightFacadePolish", true)
end

local function polishVillageShop(model: Model)
	local origin = originFrom(model, "VillageShopFloor", 0.5)
	if not origin then
		return
	end
	addStoneBaseCourse(model, origin, 26, 20, "VillageShop")
	addSideWindows(model, origin, 26, 20, 6.2, "VillageShop", VisualTheme.Colors.inkGlass)
	for _, side in { -1, 1 } do
		local awning = decoration(
			model,
			"VillageShopWindowAwning" .. tostring(side),
			Vector3.new(6.5, 0.42, 2.2),
			CFrame.new(origin + Vector3.new(side * 8, 9, 11.65)) * CFrame.Angles(math.rad(10), 0, 0),
			if side < 0 then VisualTheme.Colors.berry else VisualTheme.Colors.warmLight,
			Enum.Material.Fabric,
			"village-shop-window-awning"
		)
		awning:SetAttribute("TinyWorldDestinationCue", "shopfront")
	end
	addPlanter(model, "VillageShopPlanter", origin + Vector3.new(11, 1.2, 13), VisualTheme.Colors.flower)
	model:SetAttribute("TinyWorldPlayerHeightFacadePolish", true)
end

local function polishCourier(model: Model)
	local origin = originFrom(model, "CourierDepotFloor", 0.5)
	if not origin then
		return
	end
	addStoneBaseCourse(model, origin + Vector3.new(0, 0, -1), 24, 18, "Courier")
	addSideWindows(model, origin + Vector3.new(0, 0, -1), 24, 18, 6, "Courier", VisualTheme.Colors.inkGlass)
	for index, offset in {
		Vector3.new(6.5, 1.1, 11.5),
		Vector3.new(8.8, 1.4, 10.7),
		Vector3.new(7.6, 2.7, 10.9),
	} do
		local parcel = decoration(
			model,
			"CourierParcelStack" .. index,
			Vector3.new(2.1 + (index * 0.15), 1.7, 1.8),
			CFrame.new(origin + offset) * CFrame.Angles(0, math.rad((index - 2) * 6), 0),
			if index == 2 then VisualTheme.Colors.creamDeep else VisualTheme.Colors.timber,
			Enum.Material.WoodPlanks,
			"courier-visible-parcel"
		)
		parcel:SetAttribute("TinyWorldDestinationCue", "parcel")
	end
	model:SetAttribute("TinyWorldPlayerHeightFacadePolish", true)
end

local function polishWorkshop(model: Model)
	local origin = originFrom(model, "WorkshopFloor", 0.5)
	if not origin then
		return
	end
	addStoneBaseCourse(model, origin, 26, 20, "Workshop")
	addSideWindows(model, origin, 26, 20, 6.1, "Workshop", VisualTheme.Colors.inkGlass)

	-- Readable workshop clutter: tyre stack and a timber workbench, not anonymous coloured cubes.
	for index = 1, 3 do
		local tyre = decoration(
			model,
			"WorkshopTyre" .. index,
			Vector3.new(2.4, 0.8, 2.4),
			CFrame.new(origin + Vector3.new(9.2, 0.9 + ((index - 1) * 0.7), 12.4)) * CFrame.Angles(0, 0, math.rad(90)),
			VisualTheme.Colors.inkSoft,
			Enum.Material.Rubber,
			"workshop-tyre-stack"
		)
		tyre.Shape = Enum.PartType.Cylinder
	end
	decoration(
		model,
		"WorkshopExteriorBench",
		Vector3.new(7.2, 1, 2.4),
		CFrame.new(origin + Vector3.new(-7.5, 3.2, 12.2)),
		VisualTheme.Colors.timber,
		Enum.Material.WoodPlanks,
		"workshop-exterior-workbench"
	)
	for _, x in { -10, -5 } do
		decoration(
			model,
			"WorkshopExteriorBenchLeg" .. tostring(x),
			Vector3.new(0.65, 3, 0.65),
			CFrame.new(origin + Vector3.new(x, 1.6, 12.2)),
			VisualTheme.Colors.timberDark,
			Enum.Material.Wood,
			"workshop-exterior-workbench-leg"
		)
	end
	model:SetAttribute("TinyWorldPlayerHeightFacadePolish", true)
end

function CivicFacadePolishBuilder.apply(root: Instance)
	local mappings = {
		TownHallPrefab = polishTownHall,
		VillageShopPrefab = polishVillageShop,
		CourierDepotPrefab = polishCourier,
		TransportWorkshopPrefab = polishWorkshop,
	}
	for name, polish in mappings do
		local model = root:FindFirstChild(name)
		if model and model:IsA("Model") then
			polish(model)
		end
	end
end

return CivicFacadePolishBuilder
