local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local WorldLayoutRules = require(shared:WaitForChild("WorldLayoutRules"))
local VisualBudgetRules = require(shared:WaitForChild("VisualBudgetRules"))
local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))
local BoundaryBuilder = require(script.Parent:WaitForChild("BoundaryBuilder"))
local VillageSceneryBuilder = require(script.Parent:WaitForChild("VillageSceneryBuilder"))
local LivingWorldBuilder = require(script.Parent:WaitForChild("LivingWorldBuilder"))
local AuthoredPrefabBuilder = require(script.Parent:WaitForChild("AuthoredPrefabBuilder"))

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

local function makeStoneBorder(parent: Instance, name: string, origin: Vector3, width: number, depth: number)
	local stoneColor = VisualTheme.Colors.pathEdge
	makeDecoration(parent, name .. "North", Vector3.new(width, 0.5, 1.5), origin + Vector3.new(0, 0.25, -depth / 2), stoneColor, Enum.Material.Cobblestone)
	makeDecoration(parent, name .. "South", Vector3.new(width, 0.5, 1.5), origin + Vector3.new(0, 0.25, depth / 2), stoneColor, Enum.Material.Cobblestone)
	makeDecoration(parent, name .. "West", Vector3.new(1.5, 0.5, depth), origin + Vector3.new(-width / 2, 0.25, 0), stoneColor, Enum.Material.Cobblestone)
	makeDecoration(parent, name .. "East", Vector3.new(1.5, 0.5, depth), origin + Vector3.new(width / 2, 0.25, 0), stoneColor, Enum.Material.Cobblestone)
end

local function makePlotDressing(parent: Instance, origin: Vector3)
	local hedgeColor = VisualTheme.Colors.leaf
	for _, side in { { name = "North", z = -28 }, { name = "South", z = 28 } } do
		makeDecoration(parent, "PlotHedge" .. side.name, Vector3.new(50, 1.4, 1), origin + Vector3.new(0, 0.7, side.z), hedgeColor, Enum.Material.LeafyGrass)
	end
	for _, side in { { name = "West", x = -28 }, { name = "East", x = 28 } } do
		makeDecoration(parent, "PlotHedge" .. side.name, Vector3.new(1, 1.4, 50), origin + Vector3.new(side.x, 0.7, 0), hedgeColor, Enum.Material.LeafyGrass)
	end
	makeDecoration(parent, "GardenApproach", Vector3.new(6, 0.12, 18), origin + Vector3.new(0, 0.58, 22), VisualTheme.Colors.pathEdge, Enum.Material.Cobblestone)
	for index, x in {-18, -9, 9, 18} do
		makeDecoration(parent, "PlotFencePost" .. index, Vector3.new(0.7, 2.2, 0.7), origin + Vector3.new(x, 1.1, 20), VisualTheme.Colors.timberDark, Enum.Material.Wood)
	end
	makeDecoration(parent, "PlotFenceRail", Vector3.new(36, 0.45, 0.45), origin + Vector3.new(0, 1.7, 20), VisualTheme.Colors.timber, Enum.Material.WoodPlanks)
	makeDecoration(parent, "PlotMailbox", Vector3.new(2.5, 2, 2), origin + Vector3.new(18, 2, 26), VisualTheme.Colors.skyDeep, Enum.Material.Metal)
	makeDecoration(parent, "PlotMailboxPost", Vector3.new(0.45, 2.2, 0.45), origin + Vector3.new(18, 1.1, 26), VisualTheme.Colors.timberDark, Enum.Material.Wood)
	makeDecoration(parent, "GardenTrellisLeft", Vector3.new(0.5, 5, 0.5), origin + Vector3.new(-13, 2.5, 12), VisualTheme.Colors.timberDark, Enum.Material.Wood)
	makeDecoration(parent, "GardenTrellisRight", Vector3.new(0.5, 5, 0.5), origin + Vector3.new(13, 2.5, 12), VisualTheme.Colors.timberDark, Enum.Material.Wood)
	makeDecoration(parent, "GardenTrellisTop", Vector3.new(26, 0.5, 0.5), origin + Vector3.new(0, 5, 12), VisualTheme.Colors.timber, Enum.Material.WoodPlanks)
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
	for _, side in {{name = "West", value = -3.5}, {name = "East", value = 3.5}} do
		makeDecoration(parent, "PondRail" .. side.name, Vector3.new(0.5, 2.5, 16), origin + Vector3.new(side.value, 2, 0), VisualTheme.Colors.timberDark, Enum.Material.Wood)
	end
end

local function makePrompt(parent: Instance, actionText: string, objectText: string): ProximityPrompt
	if parent:IsA("BasePart") then
		parent:SetAttribute("TinyWorldInteractionAnchor", true)
		parent.CanQuery = true
	end
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = actionText
	prompt.ObjectText = objectText
	prompt.HoldDuration = 0.2
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = parent
	return prompt
end

local function makeLabel(parent: BasePart, text: string, width: number?, maxDistance: number?): TextLabel
	local gui = Instance.new("BillboardGui")
	gui.Name = "Label"
	gui.Size = UDim2.fromOffset(math.min(width or 220, 260), 58)
	gui.StudsOffset = Vector3.new(0, 3.4, 0)
	gui.MaxDistance = maxDistance or 80
	gui.AlwaysOnTop = true
	gui.Parent = parent

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 0.03
	label.BackgroundColor3 = VisualTheme.Colors.inkSoft
	label.Size = UDim2.fromScale(1, 1)
	label.TextColor3 = VisualTheme.Colors.paper
	label.TextStrokeTransparency = 0.85
	label.TextWrapped = true
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.Parent = gui
	local textConstraint = Instance.new("UITextSizeConstraint")
	textConstraint.MinTextSize = 12
	textConstraint.MaxTextSize = 22
	textConstraint.Parent = label
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = label
	local stroke = Instance.new("UIStroke")
	stroke.Color = VisualTheme.Colors.warmLight
	stroke.Transparency = 0.52
	stroke.Thickness = 1
	stroke.Parent = label
	return label
end

local function makePlotPlacementCFrame(origin: Vector3, rotation: number, setback: number): CFrame
	return CFrame.new(origin) * CFrame.Angles(0, math.rad(rotation), 0) * CFrame.new(0, 0, -setback)
end

local function applyPlotPlacement(model: Model, origin: Vector3, placement: CFrame)
	local delta = placement * CFrame.new(-origin)
	model:PivotTo(delta * model:GetPivot())
end

local function buildPlot(parent: Instance, index: number, origin: Vector3, placement: CFrame)
	local model = Instance.new("Model")
	model.Name = string.format("Plot%d", index)
	model.Parent = parent

	makePart(model, "PlotBase", Vector3.new(WorldLayoutRules.PLOT_SIZE, 1, WorldLayoutRules.PLOT_SIZE), origin, VisualTheme.Colors.meadowDeep, Enum.Material.Ground)
	makeStoneBorder(model, "PlotBorder", origin + Vector3.new(0, 0.08, 0), WorldLayoutRules.PLOT_SIZE, WorldLayoutRules.PLOT_SIZE)
	makePlotDressing(model, origin)
	makeTree(model, "PlotTree", origin + Vector3.new(-24, 0, -21), 0.7)
	makeFlowerCluster(model, "PlotFlowers", origin + Vector3.new(20, 0, -20), VisualTheme.Colors.flower)

	local interactionRoot = Instance.new("Model")
	interactionRoot.Name = "PlotInteractionAffordances"
	interactionRoot.Parent = model
	makeDecoration(interactionRoot, "EstateSignPost", Vector3.new(1, 6, 1), origin + Vector3.new(18, 3, 27), VisualTheme.Colors.timberDark, Enum.Material.Wood)
	makeDecoration(interactionRoot, "EstateSignArm", Vector3.new(8, 0.8, 0.8), origin + Vector3.new(14.5, 5.5, 27), VisualTheme.Colors.timberDark, Enum.Material.Wood)
	local sign = makeDecoration(interactionRoot, "EstateSign", Vector3.new(10, 5, 0.8), origin + Vector3.new(12, 3.5, 27), VisualTheme.Colors.timber, Enum.Material.WoodPlanks)
	local ownerLabel = makeLabel(sign, "Available Plot", 180, 55)

	local upgradePrompt, privacyPrompt, visitPrompt, homeCharmPrompt = AuthoredPrefabBuilder.buildPlotAffordances(interactionRoot, origin)
	local itemChest = makePart(interactionRoot, "ItemChest", Vector3.new(6, 3, 4), origin + Vector3.new(20, 1.5, 20), VisualTheme.Colors.timber, Enum.Material.WoodPlanks)
	itemChest:SetAttribute("TinyWorldArtRole", "plot-item-chest")
	itemChest:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	local itemChestLid = makeDecoration(interactionRoot, "ItemChestLid", Vector3.new(6.3, 0.45, 4.3), origin + Vector3.new(20, 3.2, 20), VisualTheme.Colors.woodLight, Enum.Material.Wood)
	itemChestLid.Orientation = Vector3.new(-8, 0, 0)
	makeDecoration(interactionRoot, "ItemChestHandle", Vector3.new(2, 0.5, 0.6), origin + Vector3.new(20, 3.1, 22.2), VisualTheme.Colors.gold, Enum.Material.Metal)
	makeDecoration(interactionRoot, "ItemChestBandLeft", Vector3.new(0.5, 3.6, 4.3), origin + Vector3.new(18, 1.8, 20), VisualTheme.Colors.inkSoft, Enum.Material.Metal)
	makeDecoration(interactionRoot, "ItemChestBandRight", Vector3.new(0.5, 3.6, 4.3), origin + Vector3.new(22, 1.8, 20), VisualTheme.Colors.inkSoft, Enum.Material.Metal)
	local itemChestLabel = makeLabel(itemChest, "ITEM CHEST\nYour collected things", 190, 55)
	local itemChestPrompt = makePrompt(itemChest, "View Items", "Item Chest")
	local itemDisplay = Instance.new("Model")
	itemDisplay.Name = "InventoryDisplay"
	itemDisplay:SetAttribute("TinyWorldArtRole", "plot-inventory-display")
	itemDisplay:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	itemDisplay.Parent = interactionRoot

	local houseContainer = Instance.new("Model")
	houseContainer.Name = "House"
	houseContainer.Parent = model

	local gardenBeds = {}
	local gardenPrompts = {}
	for bedIndex, bedName in { "GardenBed1", "GardenBed2", "GardenBed3" } do
		local x = (bedIndex - 2) * 10
		local bed = makePart(interactionRoot, bedName, Vector3.new(8, 1, 10), origin + Vector3.new(x, 1, 16), VisualTheme.Colors.timberDark, Enum.Material.Ground)
		bed:SetAttribute("TinyWorldArtRole", "raised-garden-bed")
		bed:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
		makeDecoration(interactionRoot, bedName .. "NorthEdge", Vector3.new(9, 1.4, 0.7), origin + Vector3.new(x, 1.2, 11), VisualTheme.Colors.timber, Enum.Material.WoodPlanks)
		makeDecoration(interactionRoot, bedName .. "SouthEdge", Vector3.new(9, 1.4, 0.7), origin + Vector3.new(x, 1.2, 21), VisualTheme.Colors.timber, Enum.Material.WoodPlanks)
		makeDecoration(interactionRoot, bedName .. "WestEdge", Vector3.new(0.7, 1.4, 10), origin + Vector3.new(x - 4.2, 1.2, 16), VisualTheme.Colors.timber, Enum.Material.WoodPlanks)
		makeDecoration(interactionRoot, bedName .. "EastEdge", Vector3.new(0.7, 1.4, 10), origin + Vector3.new(x + 4.2, 1.2, 16), VisualTheme.Colors.timber, Enum.Material.WoodPlanks)
		gardenBeds[bedIndex] = bed
		gardenPrompts[bedIndex] = makePrompt(bed, "Plant Carrot", string.format("Garden Bed %d", bedIndex))
	end
	applyPlotPlacement(interactionRoot, origin, placement)
	local homeAnchorCFrame = placement * CFrame.new(0, 1, -8)

	return {
		index = index,
		model = model,
		origin = origin,
		placementCFrame = placement,
		houseAnchorCFrame = homeAnchorCFrame,
		houseAnchor = homeAnchorCFrame.Position,
		houseContainer = houseContainer,
		ownerLabel = ownerLabel,
		upgradePrompt = upgradePrompt,
		privacyPrompt = privacyPrompt,
		itemChest = itemChest,
		itemChestLabel = itemChestLabel,
		itemChestPrompt = itemChestPrompt,
		itemDisplay = itemDisplay,
		visitPrompt = visitPrompt,
		homeCharmPrompt = homeCharmPrompt,
		gardenBeds = gardenBeds,
		gardenPrompts = gardenPrompts,
		insideCFrame = placement * CFrame.new(0, 4, -8),
		outsideCFrame = placement * CFrame.new(0, 4, 20),
	}
end

local function buildSocialBoard(parent: Instance, origin: Vector3)
	makePart(parent, "VillageMeetupBase", Vector3.new(30, 1, 18), origin, VisualTheme.Colors.warmLight, Enum.Material.WoodPlanks)
	local sign = makeDecoration(parent, "VillageMeetupSign", Vector3.new(22, 6, 1), origin + Vector3.new(0, 5, -7), VisualTheme.Colors.timberDark, Enum.Material.Wood)
	local statusLabel = makeLabel(sign, "VILLAGE MEETUP\nJoin a Village Walk\nVisit homes and trade safely together", 320, 32)
	local join = makePart(parent, "VillageWalkJoin", Vector3.new(7, 1, 7), origin + Vector3.new(-7, 1, 1), VisualTheme.Colors.leaf, Enum.Material.WoodPlanks)
	local leave = makePart(parent, "VillageWalkLeave", Vector3.new(7, 1, 7), origin + Vector3.new(7, 1, 1), VisualTheme.Colors.berry, Enum.Material.WoodPlanks)
	return {
		joinPrompt = makePrompt(join, "Join Village Walk", "Village Meetup"),
		leavePrompt = makePrompt(leave, "Leave Village Walk", "Village Meetup"),
		statusLabel = statusLabel,
	}
end

local function buildKitchen(parent: Instance, origin: Vector3)
	local kitchen = Instance.new("Model")
	kitchen.Name = "GiantKitchen"
	kitchen.Parent = parent

	makePart(kitchen, "KitchenFloor", Vector3.new(180, 1, 180), origin, VisualTheme.Colors.paper, Enum.Material.Concrete)
	AuthoredPrefabBuilder.buildPortalFrame(kitchen, "KitchenArrivalFrame", origin + Vector3.new(0, 0, -72))
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
		origin + Vector3.new(-30, 0, -35),
		origin + Vector3.new(35, 0, 45),
		origin + Vector3.new(15, 34, 10),
	}
	local crystalPrompts = {}
	for index, position in crystalPositions do
		local _crystal, prompt = AuthoredPrefabBuilder.buildSugarCrystal(kitchen, "SugarCrystal" .. index, position, string.format("Sugar Crystal %d/3", index))
		crystalPrompts[index] = prompt
	end

	local _exitPortal, returnPrompt = AuthoredPrefabBuilder.buildWorldPortal(
		kitchen,
		"KitchenExitPortal",
		origin + Vector3.new(0, 0, 75),
		VisualTheme.Colors.portal,
		"RETURN PORTAL",
		"Return to Village",
		"Portal"
	)

	return {
		arrivalCFrame = CFrame.new(origin + Vector3.new(0, 5, -72)),
		collectPrompts = crystalPrompts,
		crystalPrompts = crystalPrompts,
		returnPrompt = returnPrompt,
	}
end

local function buildMoonlitMeadow(parent: Instance, origin: Vector3)
	local meadow = Instance.new("Model")
	meadow.Name = "MoonlitMeadow"
	meadow.Parent = parent

	makePart(meadow, "MoonlitMeadowFloor", Vector3.new(180, 1, 180), origin, VisualTheme.Colors.meadow, Enum.Material.Ground)
	AuthoredPrefabBuilder.buildPortalFrame(meadow, "MeadowArrivalFrame", origin + Vector3.new(0, 0, -72))
	local sign = makeDecoration(meadow, "MeadowSign", Vector3.new(30, 7, 1), origin + Vector3.new(0, 7, -60), VisualTheme.Colors.ink, Enum.Material.Wood)
	makeLabel(sign, "MOONLIT MEADOW\nFind 3 Moonlit Seeds", 340)

	makePond(meadow, origin + Vector3.new(28, 0, 8))
	for index, position in {
		Vector3.new(-60, 0, -32),
		Vector3.new(62, 0, -28),
		Vector3.new(-58, 0, 48),
		Vector3.new(62, 0, 50),
	} do
		makeTree(meadow, "MeadowTree" .. index, origin + position, if index % 2 == 0 then 0.85 else 0.65)
	end
	for index, position in {
		Vector3.new(-34, 0, -42),
		Vector3.new(48, 0, -42),
		Vector3.new(-42, 0, 42),
		Vector3.new(52, 0, 42),
	} do
		makeFlowerCluster(meadow, "MeadowFlowers" .. index, origin + position, if index % 2 == 0 then VisualTheme.Colors.flower else VisualTheme.Colors.warmLight)
	end

	local seedPositions = {
		origin + Vector3.new(-34, 0, -18),
		origin + Vector3.new(48, 0, 20),
		origin + Vector3.new(8, 0, 42),
	}
	local collectPrompts = {}
	for index, position in seedPositions do
		local _seed, prompt = AuthoredPrefabBuilder.buildMoonlitSeed(meadow, "MoonlitSeed" .. index, position, string.format("Moonlit Seed %d/3", index))
		collectPrompts[index] = prompt
	end

	local _exitPortal, returnPrompt = AuthoredPrefabBuilder.buildWorldPortal(
		meadow,
		"MeadowExitPortal",
		origin + Vector3.new(0, 0, 75),
		VisualTheme.Colors.portal,
		"RETURN PORTAL",
		"Return to Village",
		"Portal"
	)

	return {
		arrivalCFrame = CFrame.new(origin + Vector3.new(0, 5, -72)),
		collectPrompts = collectPrompts,
		returnPrompt = returnPrompt,
	}
end

function WorldBuilder.build(maxPlayers: number?)
	VisualTheme.configureLighting()
	local layout = WorldLayoutRules.create(maxPlayers)

	local old = Workspace:FindFirstChild("TinyWorldGenerated")
	if old then
		old:Destroy()
	end

	local baseplate = Workspace:FindFirstChild("Baseplate")
	if baseplate then
		baseplate:Destroy()
	end

	local root = Instance.new("Model")
	root.Name = "TinyWorldGenerated"
	root.Parent = Workspace

	local villageExtent = layout.perimeterHalfExtent * 2
	makePart(root, "VillageGround", Vector3.new(villageExtent, 2, villageExtent), Vector3.new(0, -1, 0), VisualTheme.Colors.meadow, Enum.Material.Ground)
	local scenery = VillageSceneryBuilder.build(root, layout)
	local livingWorld = LivingWorldBuilder.build(root, layout)

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "VillageSpawn"
	spawn.Size = Vector3.new(12, 1, 12)
	spawn.Position = Vector3.new(0, 1, 0)
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Color = VisualTheme.Colors.gold
	spawn.Parent = root

	local _dailyFountain, dailyPrompt = AuthoredPrefabBuilder.buildDailyFountain(root, Vector3.new(0, 0, 16))

	local _townHall, contributionAnchor, noticeboard = AuthoredPrefabBuilder.buildTownHall(root, Vector3.new(-44, 0, 0))
	local contributionPrompt = makePrompt(contributionAnchor, "Contribute 50 Coins", "Village Fund")
	local fundLabel = makeLabel(contributionAnchor, "Village Fund: 0 coins", 250)
	makeLabel(noticeboard, "PROFESSION BOARD\nCourier • Farmer • Designer", 330)
	local professionPrompt = makePrompt(noticeboard, "View Professions", "Profession Board")

	local _courierDepot, courierPickupAnchor, _courierDeliveryAnchor = AuthoredPrefabBuilder.buildCourierDepot(root, Vector3.new(0, 0, -44))
	local deliveryStartPrompt = makePrompt(courierPickupAnchor, "Take Parcel", "Courier Job")

	local _villageShop, shopDeliveryAnchor, supplyAnchor, styleAnchor, galleryAnchor = AuthoredPrefabBuilder.buildVillageShop(root, Vector3.new(44, 0, -44))
	local deliveryEndPrompt = makePrompt(shopDeliveryAnchor, "Deliver Parcel", "Courier Job")
	local homeSupplyLabel = makeLabel(supplyAnchor, "HOME SUPPLY\nFurniture and essentials", 340)
	local homeSupplyPrompt = makePrompt(supplyAnchor, "Buy Next Essential", "Home Supply")
	local homeStyleLabel = makeLabel(styleAnchor, "HOME STYLE\nMeadow • Harbor • Sunset", 340)
	local homeStylePrompt = makePrompt(styleAnchor, "Change Home Style", "Home Style")
	local homeDecorLabel = makeLabel(galleryAnchor, "HOME GALLERY\nSix authored pieces", 340)
	local homeDecorPrompt = makePrompt(galleryAnchor, "Collect Next Decor", "Home Gallery")

	local _transportWorkshop, transportAnchor = AuthoredPrefabBuilder.buildTransportWorkshop(root, Vector3.new(44, 0, 0))
	local transportPrompt = makePrompt(transportAnchor, "Buy / Toggle Bike", "Transport Shop")

	local _market, tradeSides, tradeStatusLabel = AuthoredPrefabBuilder.buildMarket(root, Vector3.new(0, 0.5, 44))
	local trade = { sides = tradeSides, statusLabel = tradeStatusLabel }
	local social = buildSocialBoard(root, Vector3.new(44, 0.5, 28))

	local _villagePortal, villagePortalPrompt = AuthoredPrefabBuilder.buildWorldPortal(
		root,
		"VillagePortal",
		Vector3.new(-44, 0, 44),
		VisualTheme.Colors.portal,
		"PORTAL\nThe Giant Kitchen",
		"Enter Giant Kitchen",
		"World Portal"
	)

	local _moonlitPortal, moonlitPortalPrompt = AuthoredPrefabBuilder.buildWorldPortal(
		root,
		"MoonlitMeadowPortal",
		Vector3.new(-8, 0, 44),
		VisualTheme.Colors.flower,
		"PORTAL\nMoonlit Meadow",
		"Enter Moonlit Meadow",
		"World Portal"
	)

	local plots = {}
	for index, slot in layout.plotSlots do
		local origin = Vector3.new(slot.x, 0, slot.z)
		local placement = makePlotPlacementCFrame(origin, slot.rotation, slot.setback)
		plots[index] = buildPlot(root, index, origin, placement)
	end
	local ambientLife = VillageSceneryBuilder.buildAmbientLife(root, layout, {
		_townHall,
		_villageShop,
	})
	root:SetAttribute("TinyWorldPlotCapacity", #layout.plotSlots)
	root:SetAttribute("TinyWorldVisualBudget", layout.budgets.visual.totalDecorations)
	root:SetAttribute("TinyWorldBuiltPlotCount", #plots)
	root:SetAttribute("TinyWorldAmbientEffectCount", ambientLife.effectCount)
	root:SetAttribute("TinyWorldScaleBudgetStatus", if VisualBudgetRules.isWithinBudget(layout.budgets.visual) then "within-budget" else "over-budget")

	local boundary = BoundaryBuilder.build(root, layout)

	local kitchen = buildKitchen(root, Vector3.new(0, 0, 1000))
	local moonlitMeadow = buildMoonlitMeadow(root, Vector3.new(260, 0, 1000))

	return {
		root = root,
		layout = layout,
		scenery = scenery,
		ambientLife = ambientLife,
		livingWorld = livingWorld,
		boundary = boundary,
		spawn = spawn,
		dailyPrompt = dailyPrompt,
		contributionPrompt = contributionPrompt,
		fundLabel = fundLabel,
		professionPrompt = professionPrompt,
		deliveryStartPrompt = deliveryStartPrompt,
		deliveryEndPrompt = deliveryEndPrompt,
		homeSupplyPrompt = homeSupplyPrompt,
		homeSupplyLabel = homeSupplyLabel,
		homeStylePrompt = homeStylePrompt,
		homeStyleLabel = homeStyleLabel,
		homeDecorPrompt = homeDecorPrompt,
		homeDecorLabel = homeDecorLabel,
		transportPrompt = transportPrompt,
		trade = trade,
		social = social,
		villagePortalPrompt = villagePortalPrompt,
		moonlitPortalPrompt = moonlitPortalPrompt,
		plots = plots,
		kitchen = kitchen,
		moonlitMeadow = moonlitMeadow,
		villageReturnCFrame = CFrame.new(0, 5, 8),
	}
end

return WorldBuilder
