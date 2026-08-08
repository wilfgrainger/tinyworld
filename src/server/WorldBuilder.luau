local Workspace = game:GetService("Workspace")
local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))

local WorldBuilder = {}

local function makePart(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material?): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Size = size
	part.Position = position
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function makeDecoration(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material?): Part
	local part = makePart(parent, name, size, position, color, material)
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	return part
end

local function makeShapeDecoration(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material, shape: Enum.PartType): Part
	local part = makeDecoration(parent, name, size, position, color, material)
	part.Shape = shape
	return part
end

local function makeWindow(parent: Instance, name: string, position: Vector3, width: number, height: number)
	local frame = makeDecoration(parent, name .. "Frame", Vector3.new(width + 1, height + 1, 0.5), position, VisualTheme.Colors.timberDark, Enum.Material.Wood)
	local glass = makeDecoration(parent, name, Vector3.new(width, height, 0.55), position + Vector3.new(0, 0, 0.08), VisualTheme.Colors.sky, Enum.Material.Glass)
	glass.Reflectance = 0.1
	return frame
end

local function makeTree(parent: Instance, name: string, position: Vector3, scale: number)
	makeDecoration(parent, name .. "Trunk", Vector3.new(2 * scale, 6 * scale, 2 * scale), position + Vector3.new(0, 3 * scale, 0), VisualTheme.Colors.timberDark, Enum.Material.Wood)
	makeShapeDecoration(parent, name .. "Canopy", Vector3.new(9 * scale, 9 * scale, 9 * scale), position + Vector3.new(0, 8 * scale, 0), VisualTheme.Colors.leaf, Enum.Material.LeafyGrass, Enum.PartType.Ball)
	makeShapeDecoration(parent, name .. "CanopyHighlight", Vector3.new(5 * scale, 5 * scale, 5 * scale), position + Vector3.new(2 * scale, 10 * scale, -2 * scale), VisualTheme.Colors.meadowDeep, Enum.Material.LeafyGrass, Enum.PartType.Ball)
end

local function makeFlowerCluster(parent: Instance, name: string, position: Vector3, color: Color3)
	for index, offset in {
		Vector3.new(-2, 0, 0),
		Vector3.new(0, 0, 2),
		Vector3.new(2, 0, -1),
	} do
		makeDecoration(parent, name .. "Stem" .. index, Vector3.new(0.3, 1.2, 0.3), position + offset + Vector3.new(0, 0.6, 0), VisualTheme.Colors.leaf, Enum.Material.Grass)
		makeShapeDecoration(parent, name .. "Bloom" .. index, Vector3.new(1.4, 1.4, 1.4), position + offset + Vector3.new(0, 1.4, 0), color, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	end
end

local function makeLantern(parent: Instance, name: string, position: Vector3)
	makeDecoration(parent, name .. "Post", Vector3.new(0.6, 5, 0.6), position + Vector3.new(0, 2.5, 0), VisualTheme.Colors.timberDark, Enum.Material.Wood)
	local lamp = makeShapeDecoration(parent, name .. "Lamp", Vector3.new(2, 2, 2), position + Vector3.new(0, 5.5, 0), VisualTheme.Colors.gold, Enum.Material.Neon, Enum.PartType.Ball)
	lamp.Transparency = 0.05
end

local function makeInteractionMarker(parent: Instance, name: string, position: Vector3, color: Color3)
	local marker = makeShapeDecoration(parent, name, Vector3.new(8, 0.25, 8), position + Vector3.new(0, 0.75, 0), color, Enum.Material.Neon, Enum.PartType.Cylinder)
	marker.Transparency = 0.25
	local highlight = Instance.new("Highlight")
	highlight.Name = name .. "Highlight"
	highlight.Adornee = marker
	highlight.FillColor = color
	highlight.FillTransparency = 0.85
	highlight.OutlineColor = color
	highlight.OutlineTransparency = 0.3
	highlight.Parent = marker
	return marker
end

local function makePortalFrame(parent: Instance, name: string, position: Vector3)
	makeDecoration(parent, name .. "Platform", Vector3.new(26, 0.6, 20), position + Vector3.new(0, 0.3, 0), VisualTheme.Colors.pathEdge, Enum.Material.Cobblestone)
	makeDecoration(parent, name .. "LeftPillar", Vector3.new(3, 16, 3), position + Vector3.new(-8, 8, 0), VisualTheme.Colors.portal, Enum.Material.Neon)
	makeDecoration(parent, name .. "RightPillar", Vector3.new(3, 16, 3), position + Vector3.new(8, 8, 0), VisualTheme.Colors.portal, Enum.Material.Neon)
	makeDecoration(parent, name .. "TopBeam", Vector3.new(19, 3, 3), position + Vector3.new(0, 16, 0), VisualTheme.Colors.portal, Enum.Material.Neon)
	makeDecoration(parent, name .. "TopTrim", Vector3.new(23, 1.5, 4), position + Vector3.new(0, 18, 0), VisualTheme.Colors.roof, Enum.Material.Slate)
	for index, x in {-5, 0, 5} do
		makeShapeDecoration(parent, name .. "Crystal" .. index, Vector3.new(2.4, 2.4, 2.4), position + Vector3.new(x, 19.8, 0), VisualTheme.Colors.crystal, Enum.Material.Neon, Enum.PartType.Ball)
	end
end

local function makeCrystalPedestal(parent: Instance, name: string, position: Vector3)
	local basePosition = position - Vector3.new(0, 2, 0)
	makeShapeDecoration(parent, name .. "Base", Vector3.new(8, 1, 8), basePosition, VisualTheme.Colors.pathEdge, Enum.Material.Marble, Enum.PartType.Cylinder)
	local ring = makeShapeDecoration(parent, name .. "Ring", Vector3.new(10, 0.18, 10), basePosition + Vector3.new(0, 0.6, 0), VisualTheme.Colors.crystal, Enum.Material.Neon, Enum.PartType.Cylinder)
	ring.Transparency = 0.35
end

local function makeStoneBorder(parent: Instance, name: string, origin: Vector3, width: number, depth: number)
	local stoneColor = VisualTheme.Colors.pathEdge
	makeDecoration(parent, name .. "North", Vector3.new(width, 0.5, 1.5), origin + Vector3.new(0, 0.25, -depth / 2), stoneColor, Enum.Material.Cobblestone)
	makeDecoration(parent, name .. "South", Vector3.new(width, 0.5, 1.5), origin + Vector3.new(0, 0.25, depth / 2), stoneColor, Enum.Material.Cobblestone)
	makeDecoration(parent, name .. "West", Vector3.new(1.5, 0.5, depth), origin + Vector3.new(-width / 2, 0.25, 0), stoneColor, Enum.Material.Cobblestone)
	makeDecoration(parent, name .. "East", Vector3.new(1.5, 0.5, depth), origin + Vector3.new(width / 2, 0.25, 0), stoneColor, Enum.Material.Cobblestone)
end

local function makePond(parent: Instance, origin: Vector3)
	makeDecoration(parent, "VillagePondWater", Vector3.new(32, 0.25, 16), origin + Vector3.new(0, 0.15, 0), VisualTheme.Colors.water, Enum.Material.Glass)
	makeDecoration(parent, "PondNorthEdge", Vector3.new(34, 0.5, 1.5), origin + Vector3.new(0, 0.25, -8), VisualTheme.Colors.pathEdge, Enum.Material.Cobblestone)
	makeDecoration(parent, "PondSouthEdge", Vector3.new(34, 0.5, 1.5), origin + Vector3.new(0, 0.25, 8), VisualTheme.Colors.pathEdge, Enum.Material.Cobblestone)
	makeDecoration(parent, "PondWestEdge", Vector3.new(1.5, 0.5, 16), origin + Vector3.new(-16, 0.25, 0), VisualTheme.Colors.pathEdge, Enum.Material.Cobblestone)
	makeDecoration(parent, "PondEastEdge", Vector3.new(1.5, 0.5, 16), origin + Vector3.new(16, 0.25, 0), VisualTheme.Colors.pathEdge, Enum.Material.Cobblestone)
	makeShapeDecoration(parent, "PondLilyWest", Vector3.new(3, 0.18, 3), origin + Vector3.new(-9, 0.35, -3), VisualTheme.Colors.leaf, Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
	makeShapeDecoration(parent, "PondLilyEast", Vector3.new(3, 0.18, 3), origin + Vector3.new(9, 0.35, 3), VisualTheme.Colors.leaf, Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
	makePart(parent, "PondBridge", Vector3.new(8, 0.6, 20), origin + Vector3.new(0, 0.55, 0), VisualTheme.Colors.timber, Enum.Material.WoodPlanks)
	for side, x in {{name = "West", value = -3.5}, {name = "East", value = 3.5}} do
		makeDecoration(parent, "PondRail" .. x.name, Vector3.new(0.5, 2.5, 16), origin + Vector3.new(x.value, 2, 0), VisualTheme.Colors.timberDark, Enum.Material.Wood)
	end
end

local function makePrompt(parent: Instance, actionText: string, objectText: string): ProximityPrompt
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = actionText
	prompt.ObjectText = objectText
	prompt.HoldDuration = 0.2
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = parent
	return prompt
end

local function makeLabel(parent: BasePart, text: string, width: number?): TextLabel
	local gui = Instance.new("BillboardGui")
	gui.Name = "Label"
	gui.Size = UDim2.fromOffset(width or 250, 70)
	gui.StudsOffset = Vector3.new(0, 4, 0)
	gui.AlwaysOnTop = true
	gui.Parent = parent

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 0.08
	label.BackgroundColor3 = VisualTheme.Colors.ink
	label.Size = UDim2.fromScale(1, 1)
	label.TextColor3 = VisualTheme.Colors.paper
	label.TextStrokeTransparency = 0.85
	label.TextWrapped = true
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = label
	local stroke = Instance.new("UIStroke")
	stroke.Color = VisualTheme.Colors.paper
	stroke.Transparency = 0.78
	stroke.Thickness = 1
	stroke.Parent = label
	return label
end

local function makeCourierShowcase(parent: Instance)
	makeDecoration(parent, "CourierParcelCounter", Vector3.new(14, 2, 3), Vector3.new(-8, 1.5, -34), VisualTheme.Colors.timber, Enum.Material.WoodPlanks)
	for index, x in {-11, -7, -3} do
		local parcel = makeDecoration(parent, "DepotParcel" .. index, Vector3.new(3, 3, 3), Vector3.new(x, 4, -34), VisualTheme.Colors.timber, Enum.Material.Cardboard)
		parcel.Orientation = Vector3.new(0, index * 6, 0)
	end
	local pickupSign = makeDecoration(parent, "CourierPickupSign", Vector3.new(12, 4, 1), Vector3.new(-8, 6, -34), VisualTheme.Colors.ink, Enum.Material.Wood)
	makeLabel(pickupSign, "PICK UP PARCEL", 220)

	makeDecoration(parent, "DeliveryDropCounter", Vector3.new(12, 1.5, 4), Vector3.new(30, 1.25, -37), VisualTheme.Colors.timber, Enum.Material.WoodPlanks)
	local dropSign = makeDecoration(parent, "DeliveryDropSign", Vector3.new(14, 4, 1), Vector3.new(30, 5.5, -37), VisualTheme.Colors.ink, Enum.Material.Wood)
	makeLabel(dropSign, "DELIVERY DROP", 230)
end

local function amenity(parent: Instance, name: string, position: Vector3, text: string, color: Color3)
	local building = makePart(parent, name, Vector3.new(24, 12, 20), position + Vector3.new(0, 6, 0), color)
	makeShapeDecoration(parent, name .. "Roof", Vector3.new(28, 4, 24), position + Vector3.new(0, 14, 0), VisualTheme.Colors.roof, Enum.Material.Slate, Enum.PartType.Wedge)
	makeDecoration(parent, name .. "Door", Vector3.new(5, 7, 0.6), position + Vector3.new(0, 3.5, 10.3), VisualTheme.Colors.timberDark, Enum.Material.Wood)
	makeDecoration(parent, name .. "Awning", Vector3.new(9, 1, 3), position + Vector3.new(0, 8, 11), VisualTheme.Colors.warmLight, Enum.Material.Fabric)
	makeWindow(parent, name .. "WindowLeft", position + Vector3.new(-7, 6, 10.25), 4, 3)
	makeWindow(parent, name .. "WindowRight", position + Vector3.new(7, 6, 10.25), 4, 3)
	makeDecoration(parent, name .. "Trim", Vector3.new(26, 0.6, 21), position + Vector3.new(0, 12.2, 0), VisualTheme.Colors.cream, Enum.Material.WoodPlanks)
	makeLabel(building, text)
	return building
end

local function buildPlot(parent: Instance, index: number, origin: Vector3)
	local model = Instance.new("Model")
	model.Name = string.format("Plot%d", index)
	model.Parent = parent

	makePart(model, "PlotBase", Vector3.new(60, 1, 60), origin, VisualTheme.Colors.meadowDeep, Enum.Material.Grass)
	makeStoneBorder(model, "PlotBorder", origin, 60, 60)
	makeTree(model, "PlotTree", origin + Vector3.new(-24, 0, -21), 0.7)
	makeFlowerCluster(model, "PlotFlowers", origin + Vector3.new(20, 0, -20), VisualTheme.Colors.flower)
	local sign = makeDecoration(model, "OwnerSign", Vector3.new(12, 5, 1), origin + Vector3.new(0, 3, 27), VisualTheme.Colors.timber, Enum.Material.Wood)
	local ownerLabel = makeLabel(sign, "Available Plot", 220)

	local upgradeKiosk = makePart(model, "UpgradeKiosk", Vector3.new(5, 4, 5), origin + Vector3.new(-12, 2, 24), VisualTheme.Colors.gold)
	local upgradePrompt = makePrompt(upgradeKiosk, "Upgrade Home", "Home Builder")
	makeInteractionMarker(model, "UpgradeMarker", origin + Vector3.new(-12, 0, 24), VisualTheme.Colors.gold)

	local privacyKiosk = makePart(model, "PrivacyKiosk", Vector3.new(5, 4, 5), origin + Vector3.new(12, 2, 24), VisualTheme.Colors.sky)
	local privacyPrompt = makePrompt(privacyKiosk, "Change Privacy", "Home Access")
	makeInteractionMarker(model, "PrivacyMarker", origin + Vector3.new(12, 0, 24), VisualTheme.Colors.sky)

	local visitKiosk = makePart(model, "VisitKiosk", Vector3.new(5, 4, 5), origin + Vector3.new(0, 2, 24), VisualTheme.Colors.portal)
	local visitPrompt = makePrompt(visitKiosk, "Enter Home", "Front Gate")
	makeInteractionMarker(model, "VisitMarker", origin + Vector3.new(0, 0, 24), VisualTheme.Colors.portal)

	local houseContainer = Instance.new("Model")
	houseContainer.Name = "House"
	houseContainer.Parent = model

	local gardenBeds = {}
	local gardenPrompts = {}
	for bedIndex = 1, 3 do
		local x = (bedIndex - 2) * 10
		local bed = makePart(model, string.format("GardenBed%d", bedIndex), Vector3.new(8, 1, 10), origin + Vector3.new(x, 1, 16), VisualTheme.Colors.timberDark, Enum.Material.Ground)
		gardenBeds[bedIndex] = bed
		gardenPrompts[bedIndex] = makePrompt(bed, "Plant Carrot", string.format("Garden Bed %d", bedIndex))
	end

	return {
		index = index,
		model = model,
		origin = origin,
		houseAnchor = origin + Vector3.new(0, 1, -8),
		houseContainer = houseContainer,
		ownerLabel = ownerLabel,
		upgradePrompt = upgradePrompt,
		privacyPrompt = privacyPrompt,
		visitPrompt = visitPrompt,
		gardenBeds = gardenBeds,
		gardenPrompts = gardenPrompts,
		insideCFrame = CFrame.new(origin + Vector3.new(0, 4, -8)),
		outsideCFrame = CFrame.new(origin + Vector3.new(0, 4, 20)),
	}
end

local function buildTradePost(parent: Instance, origin: Vector3)
	makePart(parent, "TradePostBase", Vector3.new(36, 1, 24), origin, VisualTheme.Colors.warmLight, Enum.Material.WoodPlanks)
	local sign = makeDecoration(parent, "TradePostSign", Vector3.new(16, 5, 1), origin + Vector3.new(0, 4, -10), VisualTheme.Colors.timberDark, Enum.Material.Wood)
	local statusLabel = makeLabel(sign, "TRADING POST\nTwo players: join → choose item → confirm", 340)

	local sides = {}
	for side = 1, 2 do
		local x = if side == 1 then -9 else 9
		local name = if side == 1 then "A" else "B"
		local join = makePart(parent, "TradeJoin" .. name, Vector3.new(6, 1, 6), origin + Vector3.new(x, 1, -2), VisualTheme.Colors.skyDeep)
		local offer = makePart(parent, "TradeOffer" .. name, Vector3.new(6, 1, 6), origin + Vector3.new(x, 1, 5), VisualTheme.Colors.gold)
		local confirm = makePart(parent, "TradeConfirm" .. name, Vector3.new(6, 1, 6), origin + Vector3.new(x, 1, 12), VisualTheme.Colors.leaf)
		makeInteractionMarker(parent, "TradeJoinMarker" .. name, origin + Vector3.new(x, 1, -2), VisualTheme.Colors.skyDeep)
		makeInteractionMarker(parent, "TradeOfferMarker" .. name, origin + Vector3.new(x, 1, 5), VisualTheme.Colors.gold)
		makeInteractionMarker(parent, "TradeConfirmMarker" .. name, origin + Vector3.new(x, 1, 12), VisualTheme.Colors.leaf)
		sides[side] = {
			joinPrompt = makePrompt(join, "Join Trade " .. name, "Trading Post"),
			offerPrompt = makePrompt(offer, "Choose Offer", "Trading Post"),
			confirmPrompt = makePrompt(confirm, "Confirm Trade", "Trading Post"),
		}
	end

	return { sides = sides, statusLabel = statusLabel }
end

local function buildKitchen(parent: Instance, origin: Vector3)
	local kitchen = Instance.new("Model")
	kitchen.Name = "GiantKitchen"
	kitchen.Parent = parent

	makePart(kitchen, "KitchenFloor", Vector3.new(180, 1, 180), origin, VisualTheme.Colors.paper, Enum.Material.Concrete)
	makePortalFrame(kitchen, "KitchenArrivalFrame", origin + Vector3.new(0, 0, -72))
	local tableTop = makePart(kitchen, "GiantTableTop", Vector3.new(100, 4, 70), origin + Vector3.new(0, 30, 10), VisualTheme.Colors.timber, Enum.Material.WoodPlanks)
	makeLabel(tableTop, "THE GIANT KITCHEN\nCollect all 3 Sugar Crystals", 380)
	for _, offset in {
		Vector3.new(-42, 14, -22),
		Vector3.new(42, 14, -22),
		Vector3.new(-42, 14, 42),
		Vector3.new(42, 14, 42),
	} do
		makePart(kitchen, "TableLeg", Vector3.new(8, 28, 8), origin + offset, VisualTheme.Colors.timberDark, Enum.Material.Wood)
	end

	makeDecoration(kitchen, "GiantPlate", Vector3.new(50, 2, 36), origin + Vector3.new(12, 34, 10), VisualTheme.Colors.paper, Enum.Material.SmoothPlastic)
	makeDecoration(kitchen, "ForkHandle", Vector3.new(7, 2, 48), origin + Vector3.new(-30, 35, 10), VisualTheme.Colors.metal, Enum.Material.Metal)
	for tine = 1, 4 do
		makeDecoration(kitchen, "ForkTine", Vector3.new(3, 2, 18), origin + Vector3.new(-37 + tine * 4, 35, 40), VisualTheme.Colors.metal, Enum.Material.Metal)
	end

	for step = 1, 10 do
		makePart(kitchen, "TableStep" .. step, Vector3.new(10, 3, 8), origin + Vector3.new(-58 + (step * 5), 1.5 + (step * 3), -25), VisualTheme.Colors.warmLight, Enum.Material.WoodPlanks)
	end

	local crystalPositions = {
		origin + Vector3.new(-30, 3, -35),
		origin + Vector3.new(35, 3, 45),
		origin + Vector3.new(15, 37, 10),
	}
	local crystalPrompts = {}
	for index, position in crystalPositions do
		makeCrystalPedestal(kitchen, "CrystalPedestal" .. index, position)
		local crystal = makePart(kitchen, "SugarCrystal" .. index, Vector3.new(4, 8, 4), position, VisualTheme.Colors.crystal, Enum.Material.Neon)
		crystalPrompts[index] = makePrompt(crystal, "Collect Crystal", string.format("Sugar Crystal %d/3", index))
	end

	makePortalFrame(kitchen, "KitchenExitFrame", origin + Vector3.new(0, 0, 75))
	local exit = makePart(kitchen, "KitchenExitPortal", Vector3.new(12, 12, 2), origin + Vector3.new(0, 6, 75), VisualTheme.Colors.portal, Enum.Material.Neon)
	makeLabel(exit, "RETURN PORTAL")
	local returnPrompt = makePrompt(exit, "Return to Village", "Portal")

	return {
		arrivalCFrame = CFrame.new(origin + Vector3.new(0, 5, -72)),
		crystalPrompts = crystalPrompts,
		returnPrompt = returnPrompt,
	}
end

function WorldBuilder.build()
	VisualTheme.configureLighting()

	local old = Workspace:FindFirstChild("TinyWorldGenerated")
	if old then
		old:Destroy()
	end

	local root = Instance.new("Model")
	root.Name = "TinyWorldGenerated"
	root.Parent = Workspace

	makePart(root, "VillageGround", Vector3.new(230, 2, 230), Vector3.new(0, -1, 0), VisualTheme.Colors.meadow, Enum.Material.Grass)
	makePart(root, "RoadNS", Vector3.new(20, 1, 220), Vector3.new(0, 0.1, 0), VisualTheme.Colors.path, Enum.Material.Asphalt)
	makePart(root, "RoadEW", Vector3.new(220, 1, 20), Vector3.new(0, 0.12, 0), VisualTheme.Colors.path, Enum.Material.Asphalt)
	makeDecoration(root, "PlazaDeck", Vector3.new(50, 0.35, 50), Vector3.new(0, 0.68, 8), VisualTheme.Colors.pathEdge, Enum.Material.Cobblestone)
	makeShapeDecoration(root, "PlazaInlay", Vector3.new(42, 0.12, 42), Vector3.new(0, 0.9, 8), VisualTheme.Colors.paper, Enum.Material.Pebble, Enum.PartType.Cylinder)
	makeStoneBorder(root, "PlazaBorder", Vector3.new(0, 0.9, 8), 50, 50)
	makeTree(root, "TreeNorthWest", Vector3.new(-102, 0, -24), 1.1)
	makeTree(root, "TreeNorthEast", Vector3.new(102, 0, -24), 1.1)
	makeTree(root, "TreeSouthWest", Vector3.new(-102, 0, 24), 1.1)
	makeTree(root, "TreeSouthEast", Vector3.new(102, 0, 24), 1.1)
	makeFlowerCluster(root, "FlowersWest", Vector3.new(-28, 0, 30), VisualTheme.Colors.flower)
	makeFlowerCluster(root, "FlowersEast", Vector3.new(28, 0, 30), VisualTheme.Colors.warmLight)
	makeLantern(root, "PlazaLanternNorthWest", Vector3.new(-22, 0, 16))
	makeLantern(root, "PlazaLanternNorthEast", Vector3.new(22, 0, 16))
	makeLantern(root, "PlazaLanternSouthWest", Vector3.new(-22, 0, -16))
	makeLantern(root, "PlazaLanternSouthEast", Vector3.new(22, 0, -16))
	makePond(root, Vector3.new(0, 0, 68))
	makeDecoration(root, "RoadEdgeNorth", Vector3.new(2, 0.35, 220), Vector3.new(-11, 0.65, 0), VisualTheme.Colors.pathEdge, Enum.Material.Cobblestone)
	makeDecoration(root, "RoadEdgeSouth", Vector3.new(2, 0.35, 220), Vector3.new(11, 0.65, 0), VisualTheme.Colors.pathEdge, Enum.Material.Cobblestone)
	makeDecoration(root, "RoadEdgeWest", Vector3.new(220, 0.35, 2), Vector3.new(0, 0.67, -11), VisualTheme.Colors.pathEdge, Enum.Material.Cobblestone)
	makeDecoration(root, "RoadEdgeEast", Vector3.new(220, 0.35, 2), Vector3.new(0, 0.67, 11), VisualTheme.Colors.pathEdge, Enum.Material.Cobblestone)

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "VillageSpawn"
	spawn.Size = Vector3.new(12, 1, 12)
	spawn.Position = Vector3.new(0, 1, 0)
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Color = VisualTheme.Colors.gold
	spawn.Parent = root

	local fountain = makePart(root, "DailyFountain", Vector3.new(8, 5, 8), Vector3.new(0, 2.5, 16), VisualTheme.Colors.water, Enum.Material.Marble)
	makeLabel(fountain, "DAILY FOUNTAIN\n200 coins • 50 XP • 1 Carrot", 320)
	local dailyPrompt = makePrompt(fountain, "Claim Daily Reward", "Village Fountain")
	makeShapeDecoration(root, "FountainBase", Vector3.new(16, 1, 16), Vector3.new(0, 1, 16), VisualTheme.Colors.pathEdge, Enum.Material.Marble, Enum.PartType.Cylinder)
	makeInteractionMarker(root, "FountainMarker", Vector3.new(0, 0, 16), VisualTheme.Colors.water)

	amenity(root, "TownHall", Vector3.new(-44, 0, 0), "TOWN HALL\nVillage Fund", VisualTheme.Colors.cream)
	local contribution = makePart(root, "ContributionKiosk", Vector3.new(6, 5, 6), Vector3.new(-29, 2.5, 0), VisualTheme.Colors.gold)
	local contributionPrompt = makePrompt(contribution, "Contribute 50 Coins", "Village Fund")
	makeInteractionMarker(root, "ContributionMarker", Vector3.new(-29, 0, 0), VisualTheme.Colors.gold)
	local fundSign = makeDecoration(root, "FundSign", Vector3.new(8, 4, 1), Vector3.new(-29, 6, 0), VisualTheme.Colors.timberDark)
	local fundLabel = makeLabel(fundSign, "Village Fund: 0 coins", 250)

	amenity(root, "DeliveryDepot", Vector3.new(0, 0, -44), "COURIER DEPOT\nPick up deliveries", VisualTheme.Colors.warmLight)
	local deliveryStart = makePart(root, "DeliveryStart", Vector3.new(6, 4, 6), Vector3.new(0, 2, -30), VisualTheme.Colors.timber)
	local deliveryStartPrompt = makePrompt(deliveryStart, "Take Parcel", "Courier Job")
	makeInteractionMarker(root, "DeliveryStartMarker", Vector3.new(0, 0, -30), VisualTheme.Colors.warmLight)

	amenity(root, "VillageShop", Vector3.new(44, 0, -44), "VILLAGE SHOP\nDelivery destination", VisualTheme.Colors.berry)
	local deliveryEnd = makePart(root, "DeliveryEnd", Vector3.new(6, 4, 6), Vector3.new(30, 2, -44), VisualTheme.Colors.timber)
	local deliveryEndPrompt = makePrompt(deliveryEnd, "Deliver Parcel", "Courier Job")
	makeInteractionMarker(root, "DeliveryEndMarker", Vector3.new(30, 0, -44), VisualTheme.Colors.berry)
	makeCourierShowcase(root)

	amenity(root, "TransportShop", Vector3.new(44, 0, 0), "TRANSPORT\nTiny Bike: 300 coins", VisualTheme.Colors.sky)
	local transport = makePart(root, "TransportKiosk", Vector3.new(6, 4, 6), Vector3.new(30, 2, 0), VisualTheme.Colors.skyDeep)
	local transportPrompt = makePrompt(transport, "Buy / Toggle Bike", "Transport Shop")
	makeInteractionMarker(root, "TransportMarker", Vector3.new(30, 0, 0), VisualTheme.Colors.sky)

	local trade = buildTradePost(root, Vector3.new(0, 0.5, 44))

	local portal = makePart(root, "VillagePortal", Vector3.new(12, 12, 2), Vector3.new(-44, 6, 44), VisualTheme.Colors.portal, Enum.Material.Neon)
	makeLabel(portal, "PORTAL\nThe Giant Kitchen", 300)
	local villagePortalPrompt = makePrompt(portal, "Enter Giant Kitchen", "World Portal")
	makePortalFrame(root, "VillagePortalFrame", Vector3.new(-44, 0, 44))
	makeInteractionMarker(root, "VillagePortalMarker", Vector3.new(-44, 0, 44), VisualTheme.Colors.portal)

	local premiumSign = makeDecoration(root, "PremiumPreview", Vector3.new(16, 6, 1), Vector3.new(44, 4, 44), VisualTheme.Colors.ink)
	makeLabel(premiumSign, "PREMIUM PREVIEW\nStyle & convenience only\nNo pay-to-win", 340)

	local plotOrigins = {
		Vector3.new(-75, 0, -75),
		Vector3.new(75, 0, -75),
		Vector3.new(-75, 0, 75),
		Vector3.new(75, 0, 75),
	}
	local plots = {}
	for index, origin in plotOrigins do
		plots[index] = buildPlot(root, index, origin)
	end

	local kitchen = buildKitchen(root, Vector3.new(0, 0, 1000))

	return {
		root = root,
		spawn = spawn,
		dailyPrompt = dailyPrompt,
		contributionPrompt = contributionPrompt,
		fundLabel = fundLabel,
		deliveryStartPrompt = deliveryStartPrompt,
		deliveryEndPrompt = deliveryEndPrompt,
		transportPrompt = transportPrompt,
		trade = trade,
		villagePortalPrompt = villagePortalPrompt,
		plots = plots,
		kitchen = kitchen,
		villageReturnCFrame = CFrame.new(0, 5, 8),
	}
end

return WorldBuilder
