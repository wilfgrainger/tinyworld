local FurniturePrefabBuilder = {}

local COLORS = {
	wood = Color3.fromRGB(137, 93, 61),
	woodDark = Color3.fromRGB(92, 62, 45),
	cream = Color3.fromRGB(244, 230, 196),
	green = Color3.fromRGB(111, 159, 94),
	leaf = Color3.fromRGB(73, 130, 72),
	blue = Color3.fromRGB(92, 148, 184),
	berry = Color3.fromRGB(174, 88, 112),
	gold = Color3.fromRGB(231, 183, 79),
	metal = Color3.fromRGB(145, 151, 157),
	ink = Color3.fromRGB(48, 55, 66),
	white = Color3.fromRGB(235, 238, 235),
	water = Color3.fromRGB(112, 193, 218),
}

local ACTION_TEXT = {
	rest = "Rest",
	dress = "Change Outfit",
	open = "Open / Close",
	store = "Store / Retrieve",
	read = "Read",
	cook = "Cook",
	use = "Use",
	sit = "Sit",
	wash = "Wash",
	craft = "Create",
	bathe = "Take a Bath",
	shower = "Use Shower",
	water = "Water",
	switch = "Switch On / Off",
	play = "Play",
	plant = "Plant",
	harvest = "Harvest",
}

local function part(model: Model, name: string, size: Vector3, offset: CFrame, color: Color3, material: Enum.Material?, collide: boolean?): Part
	local item = Instance.new("Part")
	item.Name = name
	item.Size = size
	item.CFrame = offset
	item.Color = color
	item.Material = material or Enum.Material.SmoothPlastic
	item.Anchored = true
	item.CanCollide = collide == true
	item.CanTouch = false
	item.CanQuery = false
	item.TopSurface = Enum.SurfaceType.Smooth
	item.BottomSurface = Enum.SurfaceType.Smooth
	item:SetAttribute("TinyWorldArtRole", "placed-furniture-detail")
	item:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	item.Parent = model
	return item
end

local function ball(model: Model, name: string, size: Vector3, offset: CFrame, color: Color3, material: Enum.Material?): Part
	local item = part(model, name, size, offset, color, material, false)
	item.Shape = Enum.PartType.Ball
	return item
end

local function cylinder(model: Model, name: string, size: Vector3, offset: CFrame, color: Color3, material: Enum.Material?): Part
	local item = part(model, name, size, offset, color, material, false)
	item.Shape = Enum.PartType.Cylinder
	return item
end

local function legs(model: Model, width: number, depth: number, height: number)
	for _, x in { -width / 2, width / 2 } do
		for _, z in { -depth / 2, depth / 2 } do
			part(model, "Leg", Vector3.new(0.35, height, 0.35), CFrame.new(x, height / 2, z), COLORS.woodDark, Enum.Material.Wood)
		end
	end
end

local function buildSeat(model: Model, role: string)
	local width = if role == "sofa" then 7 elseif role == "bench" then 5 else 3.4
	local depth = if role == "sofa" then 3.4 else 3
	part(model, "Seat", Vector3.new(width, 0.6, depth), CFrame.new(0, 1.7, 0), COLORS.cream, Enum.Material.Fabric, true)
	part(model, "Back", Vector3.new(width, 2.8, 0.55), CFrame.new(0, 3, depth / 2 - 0.25), COLORS.green, Enum.Material.Fabric)
	legs(model, width - 0.7, depth - 0.7, 1.4)
	if role == "sofa" then
		part(model, "ArmLeft", Vector3.new(0.55, 1.4, depth), CFrame.new(-width / 2 + 0.25, 2.2, 0), COLORS.green, Enum.Material.Fabric)
		part(model, "ArmRight", Vector3.new(0.55, 1.4, depth), CFrame.new(width / 2 - 0.25, 2.2, 0), COLORS.green, Enum.Material.Fabric)
	end
end

local function buildBed(model: Model)
	part(model, "Frame", Vector3.new(6.8, 0.7, 4.8), CFrame.new(0, 1, 0), COLORS.wood, Enum.Material.Wood, true)
	part(model, "Mattress", Vector3.new(6.4, 0.8, 4.4), CFrame.new(0, 1.7, 0), COLORS.cream, Enum.Material.Fabric)
	part(model, "Quilt", Vector3.new(4.3, 0.35, 4.45), CFrame.new(-0.9, 2.25, 0), COLORS.blue, Enum.Material.Fabric)
	part(model, "Pillow", Vector3.new(1.4, 0.45, 3.3), CFrame.new(2.1, 2.25, 0), COLORS.white, Enum.Material.Fabric)
	part(model, "Headboard", Vector3.new(0.55, 3.8, 5), CFrame.new(3.15, 2.1, 0), COLORS.woodDark, Enum.Material.Wood)
end

local function buildTable(model: Model, role: string)
	local width = if role == "picnic-table" then 7 else 5.4
	local depth = if role == "desk" then 2.8 elseif role == "side-table" then 2.6 else 4.2
	part(model, "Top", Vector3.new(width, 0.55, depth), CFrame.new(0, 3, 0), COLORS.wood, Enum.Material.Wood, true)
	legs(model, width - 0.8, depth - 0.8, 2.75)
	if role == "desk" then
		part(model, "Drawer", Vector3.new(2, 0.8, 2.5), CFrame.new(1.4, 2.45, 0), COLORS.woodDark, Enum.Material.Wood)
	elseif role == "picnic-table" then
		part(model, "BenchLeft", Vector3.new(6.2, 0.45, 1.1), CFrame.new(0, 1.7, -3), COLORS.wood, Enum.Material.Wood, true)
		part(model, "BenchRight", Vector3.new(6.2, 0.45, 1.1), CFrame.new(0, 1.7, 3), COLORS.wood, Enum.Material.Wood, true)
	end
end

local function buildStorage(model: Model, role: string)
	local width = if role == "wardrobe" or role == "bookcase" or role == "display-cabinet" then 4.6 else 4.2
	local height = if role == "wardrobe" or role == "bookcase" or role == "display-cabinet" or role == "fridge" or role == "locker" then 6.4 else 3.2
	local depth = if role == "chest" or role == "basket" then 3.2 else 2.2
	part(model, "Body", Vector3.new(width, height, depth), CFrame.new(0, height / 2, 0), if role == "fridge" then COLORS.white else COLORS.wood, if role == "fridge" or role == "locker" then Enum.Material.Metal else Enum.Material.Wood, true)
	if role == "bookcase" or role == "shelf" or role == "display-cabinet" or role == "rack" then
		for y = 1.2, height - 0.8, 1.4 do
			part(model, "Shelf", Vector3.new(width - 0.4, 0.18, depth + 0.2), CFrame.new(0, y, 0), COLORS.cream, Enum.Material.Wood)
		end
	else
		part(model, "Door", Vector3.new(width - 0.4, height - 0.5, 0.18), CFrame.new(0, height / 2, -depth / 2 - 0.1), COLORS.cream, Enum.Material.Wood)
		ball(model, "Handle", Vector3.new(0.28, 0.28, 0.28), CFrame.new(width * 0.22, height / 2, -depth / 2 - 0.25), COLORS.gold, Enum.Material.Metal)
	end
end

local function buildLamp(model: Model, role: string)
	local height = if role == "floor-lamp" then 5.5 elseif role == "ceiling-light" then 4 else 3
	cylinder(model, "Base", Vector3.new(0.45, 2.2, 2.2), CFrame.new(0, 0.3, 0) * CFrame.Angles(0, 0, math.rad(90)), COLORS.metal, Enum.Material.Metal)
	part(model, "Stem", Vector3.new(0.3, height - 0.7, 0.3), CFrame.new(0, height / 2, 0), COLORS.metal, Enum.Material.Metal)
	local shade = cylinder(model, "Shade", Vector3.new(1.6, 2.3, 2.3), CFrame.new(0, height, 0) * CFrame.Angles(0, 0, math.rad(90)), COLORS.gold, Enum.Material.Fabric)
	shade:SetAttribute("TinyWorldLightSurface", true)
end

local function buildPlanter(model: Model, role: string)
	if role == "garden-arch" then
		part(model, "PostLeft", Vector3.new(0.5, 6, 0.5), CFrame.new(-3, 3, 0), COLORS.wood, Enum.Material.Wood)
		part(model, "PostRight", Vector3.new(0.5, 6, 0.5), CFrame.new(3, 3, 0), COLORS.wood, Enum.Material.Wood)
		part(model, "Top", Vector3.new(6.5, 0.5, 0.5), CFrame.new(0, 5.8, 0), COLORS.wood, Enum.Material.Wood)
		for _, x in { -2.5, -1, 1, 2.5 } do
			ball(model, "Flower", Vector3.new(0.8, 0.8, 0.8), CFrame.new(x, 5.6, 0), COLORS.berry, Enum.Material.SmoothPlastic)
		end
		return
	end
	part(model, "Planter", Vector3.new(4, 1.4, 3.2), CFrame.new(0, 0.7, 0), COLORS.wood, Enum.Material.Wood, true)
	for _, x in { -1.1, 0, 1.1 } do
		part(model, "Stem", Vector3.new(0.22, 1.8, 0.22), CFrame.new(x, 2, 0), COLORS.leaf, Enum.Material.Grass)
		ball(model, "Bloom", Vector3.new(0.9, 0.9, 0.9), CFrame.new(x, 3, 0), if role == "crop-patch" then COLORS.gold else COLORS.berry, Enum.Material.SmoothPlastic)
	end
end

local function buildKitchenOrBath(model: Model, role: string)
	if role == "bath" then
		part(model, "Tub", Vector3.new(6.5, 2.3, 3.6), CFrame.new(0, 1.15, 0), COLORS.white, Enum.Material.SmoothPlastic, true)
		part(model, "Water", Vector3.new(5.5, 0.25, 2.7), CFrame.new(0, 2.2, 0), COLORS.water, Enum.Material.Glass)
		return
	elseif role == "shower" then
		part(model, "Tray", Vector3.new(4.2, 0.35, 4.2), CFrame.new(0, 0.2, 0), COLORS.white, Enum.Material.SmoothPlastic, true)
		part(model, "Back", Vector3.new(4.2, 6.4, 0.3), CFrame.new(0, 3.2, 2), COLORS.blue, Enum.Material.Glass)
		part(model, "Pipe", Vector3.new(0.25, 4.8, 0.25), CFrame.new(0, 3.5, 1.6), COLORS.metal, Enum.Material.Metal)
		ball(model, "Head", Vector3.new(0.8, 0.8, 0.8), CFrame.new(0, 5.8, 1.2), COLORS.metal, Enum.Material.Metal)
		return
	end
	part(model, "Cabinet", Vector3.new(5.2, 2.8, 2.6), CFrame.new(0, 1.4, 0), COLORS.wood, Enum.Material.Wood, true)
	part(model, "Worktop", Vector3.new(5.5, 0.35, 2.9), CFrame.new(0, 2.95, 0), COLORS.cream, Enum.Material.Slate)
	if role == "sink" then
		part(model, "Basin", Vector3.new(2.5, 0.35, 1.8), CFrame.new(0, 3.15, 0), COLORS.water, Enum.Material.Glass)
		part(model, "Tap", Vector3.new(0.25, 1.3, 0.25), CFrame.new(0, 3.85, 0.5), COLORS.metal, Enum.Material.Metal)
	elseif role == "cooker" then
		for _, x in { -1.3, 1.3 } do
			cylinder(model, "Hob", Vector3.new(0.18, 0.9, 0.9), CFrame.new(x, 3.2, 0) * CFrame.Angles(0, 0, math.rad(90)), COLORS.ink, Enum.Material.Metal)
		end
	end
end

local function buildDecoration(model: Model, role: string)
	if role == "rug" then
		part(model, "Rug", Vector3.new(6, 0.12, 4.5), CFrame.new(0, 0.08, 0), COLORS.berry, Enum.Material.Fabric)
	elseif role == "painting" or role == "mirror" or role == "wall-clock" then
		part(model, "Frame", Vector3.new(4.6, 3.6, 0.25), CFrame.new(0, 2.4, 0), COLORS.woodDark, Enum.Material.Wood)
		part(model, "Face", Vector3.new(4, 3, 0.18), CFrame.new(0, 2.4, -0.22), if role == "mirror" then COLORS.blue else COLORS.cream, if role == "mirror" then Enum.Material.Glass else Enum.Material.SmoothPlastic)
	elseif role == "globe" then
		ball(model, "World", Vector3.new(2.8, 2.8, 2.8), CFrame.new(0, 2.5, 0), COLORS.blue, Enum.Material.SmoothPlastic)
		part(model, "Stand", Vector3.new(0.4, 2, 0.4), CFrame.new(0, 1, 0), COLORS.woodDark, Enum.Material.Wood)
	elseif role == "record-player" then
		part(model, "Case", Vector3.new(4, 1, 3), CFrame.new(0, 1, 0), COLORS.wood, Enum.Material.Wood, true)
		cylinder(model, "Record", Vector3.new(0.15, 2.3, 2.3), CFrame.new(0, 1.55, 0) * CFrame.Angles(0, 0, math.rad(90)), COLORS.ink, Enum.Material.SmoothPlastic)
	else
		part(model, "DisplayBase", Vector3.new(3.2, 0.8, 3.2), CFrame.new(0, 0.4, 0), COLORS.wood, Enum.Material.Wood, true)
		ball(model, "DisplayObject", Vector3.new(1.8, 1.8, 1.8), CFrame.new(0, 1.8, 0), COLORS.gold, Enum.Material.SmoothPlastic)
	end
end

local function buildByRole(model: Model, definition: any)
	local role = definition.prefabRole
	if role == "chair" or role == "bench" or role == "sofa" or role == "cushions" then
		buildSeat(model, role)
	elseif role == "bed" then
		buildBed(model)
	elseif role == "table" or role == "desk" or role == "picnic-table" or role == "side-table" then
		buildTable(model, role)
	elseif role == "wardrobe" or role == "cabinet" or role == "chest" or role == "shelf" or role == "bookcase" or role == "rack" or role == "locker" or role == "fridge" or role == "display-cabinet" or role == "basket" or role == "wall-hooks" then
		buildStorage(model, role)
	elseif role == "floor-lamp" or role == "table-lamp" or role == "lantern" or role == "ceiling-light" or role == "nightlight" or role == "string-lights" then
		buildLamp(model, role)
	elseif role == "planter" or role == "crop-patch" or role == "plant-stand" or role == "potting-bench" or role == "garden-arch" or role == "watering-stand" or role == "bird-bath" then
		buildPlanter(model, role)
	elseif role == "counter" or role == "sink" or role == "cooker" or role == "bath" or role == "shower" then
		buildKitchenOrBath(model, role)
	else
		buildDecoration(model, role)
	end
end

function FurniturePrefabBuilder.build(parent: Instance, definition: any, cframe: CFrame, placementId: string): Model
	local model = Instance.new("Model")
	model.Name = "PlacedFurniture_" .. definition.id .. "_" .. placementId
	model:SetAttribute("TinyWorldArtRole", "placed-furniture")
	model:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	model:SetAttribute("TinyWorldFurnitureId", definition.id)
	model:SetAttribute("TinyWorldPlacementId", placementId)
	model.Parent = parent

	local root = part(model, "PlacementRoot", Vector3.new(0.2, 0.2, 0.2), CFrame.new(), COLORS.cream, Enum.Material.SmoothPlastic, false)
	root.Transparency = 1
	model.PrimaryPart = root
	buildByRole(model, definition)

	local anchor = part(
		model,
		"InteractionAnchor",
		Vector3.new(math.max(2, definition.footprintX), 4, math.max(2, definition.footprintZ)),
		CFrame.new(0, 2, 0),
		COLORS.cream,
		Enum.Material.SmoothPlastic,
		false
	)
	anchor.Transparency = 1
	anchor.CanQuery = true
	anchor:SetAttribute("TinyWorldInteractionAnchor", true)
	anchor:SetAttribute("TinyWorldFurnitureId", definition.id)
	anchor:SetAttribute("TinyWorldPlacementId", placementId)
	if definition.interaction ~= "display" then
		local prompt = Instance.new("ProximityPrompt")
		prompt.Name = "FurnitureInteractionPrompt"
		prompt.ActionText = ACTION_TEXT[definition.interaction] or "Use"
		prompt.ObjectText = definition.displayName
		prompt.HoldDuration = 0.15
		prompt.MaxActivationDistance = 9
		prompt.RequiresLineOfSight = false
		prompt.Parent = anchor
	end

	model:PivotTo(cframe)
	return model
end

return FurniturePrefabBuilder
