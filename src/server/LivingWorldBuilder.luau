local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))

local LivingWorldBuilder = {}

local function makePart(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Size = size
	part.Position = position
	part.Color = color
	part.Material = material
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function makeDecoration(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material): Part
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

local function makeLabel(parent: BasePart, text: string, width: number?): TextLabel
	local gui = Instance.new("BillboardGui")
	gui.Name = "Label"
	gui.Size = UDim2.fromOffset(math.min(width or 180, 180), 48)
	gui.StudsOffset = Vector3.new(0, 3.2, 0)
	gui.MaxDistance = 70
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
	local constraint = Instance.new("UITextSizeConstraint")
	constraint.MinTextSize = 12
	constraint.MaxTextSize = 20
	constraint.Parent = label
	return label
end

local function makePrompt(parent: Instance, name: string, actionText: string, objectText: string): ProximityPrompt
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = name
	prompt.ActionText = actionText
	prompt.ObjectText = objectText
	prompt.HoldDuration = 0.2
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = parent
	return prompt
end

local function makeWindow(parent: Instance, name: string, position: Vector3)
	makeDecoration(parent, name .. "Frame", Vector3.new(4.8, 3.8, 0.5), position, VisualTheme.Colors.timberDark, Enum.Material.Wood)
	local glass = makeDecoration(parent, name, Vector3.new(3.9, 3, 0.55), position + Vector3.new(0, 0, 0.08), VisualTheme.Colors.sky, Enum.Material.Glass)
	glass.Reflectance = 0.1
	makeDecoration(parent, name .. "Sill", Vector3.new(5.4, 0.6, 1.2), position + Vector3.new(0, -2, 0.4), VisualTheme.Colors.timber, Enum.Material.WoodPlanks)
end

local function makeFlowerPatch(parent: Instance, name: string, position: Vector3, color: Color3)
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
	makeDecoration(parent, name .. "Post", Vector3.new(0.5, 4, 0.5), position + Vector3.new(0, 2, 0), VisualTheme.Colors.timberDark, Enum.Material.Wood)
	makeShapeDecoration(parent, name .. "Lamp", Vector3.new(1.8, 1.8, 1.8), position + Vector3.new(0, 4.3, 0), VisualTheme.Colors.gold, Enum.Material.Neon, Enum.PartType.Ball)
end

local function makePlanter(parent: Instance, name: string, position: Vector3, color: Color3)
	makePart(parent, name, Vector3.new(4, 1.2, 2.4), position + Vector3.new(0, 0.6, 0), VisualTheme.Colors.timber, Enum.Material.WoodPlanks)
	makeDecoration(parent, name .. "Soil", Vector3.new(3.3, 0.2, 1.8), position + Vector3.new(0, 1.25, 0), VisualTheme.Colors.timberDark, Enum.Material.Ground)
	makeFlowerPatch(parent, name .. "Flowers", position + Vector3.new(0, 1.3, 0), color)
end

local function makeCabin(parent: Instance, index: number, position: Vector3, wallColor: Color3): Model
	local cabin = Instance.new("Model")
	cabin.Name = "Cabin" .. index
	cabin.Parent = parent

	makePart(cabin, "CabinFloor", Vector3.new(20, 1, 16), position + Vector3.new(0, 0.5, 0), VisualTheme.Colors.timber, Enum.Material.WoodPlanks)
	makePart(cabin, "CabinBackWall", Vector3.new(20, 8, 1), position + Vector3.new(0, 4.5, -7.5), wallColor, Enum.Material.WoodPlanks)
	makePart(cabin, "CabinLeftWall", Vector3.new(1, 8, 16), position + Vector3.new(-9.5, 4.5, 0), wallColor, Enum.Material.WoodPlanks)
	makePart(cabin, "CabinRightWall", Vector3.new(1, 8, 16), position + Vector3.new(9.5, 4.5, 0), wallColor, Enum.Material.WoodPlanks)
	makePart(cabin, "CabinFrontLeft", Vector3.new(6, 8, 1), position + Vector3.new(-6.5, 4.5, 7.5), wallColor, Enum.Material.WoodPlanks)
	makePart(cabin, "CabinFrontRight", Vector3.new(6, 8, 1), position + Vector3.new(6.5, 4.5, 7.5), wallColor, Enum.Material.WoodPlanks)
	local roof = makePart(cabin, "CabinRoof", Vector3.new(23, 2.4, 19), position + Vector3.new(0, 10, 0), VisualTheme.Colors.roof, Enum.Material.Slate)
	roof.Shape = Enum.PartType.Wedge
	makeDecoration(cabin, "CabinRoofTrim", Vector3.new(24, 0.5, 1), position + Vector3.new(0, 11.4, 8.3), VisualTheme.Colors.gold, Enum.Material.Wood)
	makeDecoration(cabin, "CabinDoor", Vector3.new(4, 6, 0.5), position + Vector3.new(0, 3.5, 8.1), VisualTheme.Colors.timberDark, Enum.Material.Wood)
	makeWindow(cabin, "CabinWindowLeft", position + Vector3.new(-5.5, 5.3, 8.05))
	makeWindow(cabin, "CabinWindowRight", position + Vector3.new(5.5, 5.3, 8.05))
	makeDecoration(cabin, "CabinPorch", Vector3.new(10, 0.6, 4), position + Vector3.new(0, 0.9, 10), VisualTheme.Colors.timber, Enum.Material.WoodPlanks)
	makeDecoration(cabin, "CabinStep", Vector3.new(8, 0.5, 2), position + Vector3.new(0, 0.35, 12.5), VisualTheme.Colors.pathEdge, Enum.Material.Cobblestone)
	makePart(cabin, "CabinChimney", Vector3.new(3, 5, 3), position + Vector3.new(5.5, 12, -3), VisualTheme.Colors.path, Enum.Material.Brick)
	makeLantern(cabin, "CabinLantern", position + Vector3.new(-6, 1, 9))
	makePlanter(cabin, "CabinPlanter", position + Vector3.new(-6, 0, -9), if index % 2 == 0 then VisualTheme.Colors.flower else VisualTheme.Colors.warmLight)
	makeDecoration(cabin, "CabinFenceLeft", Vector3.new(1, 2, 12), position + Vector3.new(-13, 1, -1), VisualTheme.Colors.timberDark, Enum.Material.Wood)
	makeDecoration(cabin, "CabinFenceRight", Vector3.new(1, 2, 12), position + Vector3.new(13, 1, -1), VisualTheme.Colors.timberDark, Enum.Material.Wood)
	local sign = makeDecoration(cabin, "CabinSign", Vector3.new(8, 3, 0.8), position + Vector3.new(0, 4, 13), VisualTheme.Colors.timberDark, Enum.Material.Wood)
	makeLabel(sign, "CABIN " .. tostring(index), 120)
	return cabin
end

local function makeNursery(parent: Instance, position: Vector3): BasePart
	local nursery = Instance.new("Model")
	nursery.Name = "Nursery"
	nursery.Parent = parent
	makePart(nursery, "NurseryCounter", Vector3.new(18, 3, 5), position + Vector3.new(0, 1.5, 0), VisualTheme.Colors.timber, Enum.Material.WoodPlanks)
	makePart(nursery, "NurseryRoof", Vector3.new(21, 1.2, 8), position + Vector3.new(0, 7, 0), VisualTheme.Colors.warmLight, Enum.Material.WoodPlanks)
	makeDecoration(nursery, "NurseryPostLeft", Vector3.new(0.8, 7, 0.8), position + Vector3.new(-8, 3.5, 0), VisualTheme.Colors.timberDark, Enum.Material.Wood)
	makeDecoration(nursery, "NurseryPostRight", Vector3.new(0.8, 7, 0.8), position + Vector3.new(8, 3.5, 0), VisualTheme.Colors.timberDark, Enum.Material.Wood)
	makePlanter(nursery, "NurseryPlanter", position + Vector3.new(-5, 3, 3), VisualTheme.Colors.flower)
	makePlanter(nursery, "NurseryPlanter2", position + Vector3.new(0, 3, 3), VisualTheme.Colors.warmLight)
	makePlanter(nursery, "NurseryPlanter3", position + Vector3.new(5, 3, 3), VisualTheme.Colors.flower)
	makeFlowerPatch(nursery, "NurseryFlowerPatch", position + Vector3.new(0, 0, -5), VisualTheme.Colors.flower)
	local sign = makeDecoration(nursery, "NurserySign", Vector3.new(16, 4, 0.8), position + Vector3.new(0, 5, 3.5), VisualTheme.Colors.ink, Enum.Material.Wood)
	makeLabel(sign, "VILLAGE NURSERY\nCollect a Meadow Seed", 180)
	return nursery:FindFirstChild("NurseryCounter") :: BasePart
end

local function makePickup(parent: Instance, itemName: string, position: Vector3, color: Color3, labelText: string): ProximityPrompt
	local pickup = makePart(parent, itemName .. "Pickup", Vector3.new(5, 1, 5), position + Vector3.new(0, 0.5, 0), VisualTheme.Colors.timber, Enum.Material.WoodPlanks)
	local item = makeShapeDecoration(parent, itemName .. "Object", Vector3.new(2.4, 2.4, 2.4), position + Vector3.new(0, 2.1, 0), color, Enum.Material.Neon, Enum.PartType.Ball)
	item:SetAttribute("TinyWorldItem", itemName)
	makeLabel(pickup, labelText, 180)
	return makePrompt(pickup, "PickupPrompt", "Collect " .. itemName, "Village Find")
end

local function makeBikeShowcase(parent: Instance, position: Vector3)
	makePart(parent, "BikeShowcaseRack", Vector3.new(14, 2, 2), position + Vector3.new(0, 1, 0), VisualTheme.Colors.timberDark, Enum.Material.Wood)
	for index, x in {-5, 0, 5} do
		makeDecoration(parent, "BikeShowcaseHook" .. index, Vector3.new(0.6, 3, 0.6), position + Vector3.new(x, 2.5, 0), VisualTheme.Colors.metal, Enum.Material.Metal)
	end
	local sign = makeDecoration(parent, "BikeShowcaseSign", Vector3.new(14, 3, 0.8), position + Vector3.new(0, 5, 0), VisualTheme.Colors.skyDeep, Enum.Material.Wood)
	makeLabel(sign, "BIKE STAND\nRide to the boundary", 160)
end

function LivingWorldBuilder.build(parent: Instance, layout)
	local model = Instance.new("Model")
	model.Name = "TinyWorldLivingWorld"
	model.Parent = parent

	local nurseryAnchor = makeNursery(model, Vector3.new(layout.livingWorld.nursery.x, 0, layout.livingWorld.nursery.z))
	makeBikeShowcase(model, Vector3.new(30, 0, 10))

	local pickupPrompts = {}
	local pickupAnchors = layout.livingWorld.pickupAnchors
	pickupPrompts.MeadowSeed = makePickup(model, "MeadowSeed", Vector3.new(pickupAnchors.MeadowSeed.x, 0, pickupAnchors.MeadowSeed.z + 8), VisualTheme.Colors.flower, "MEADOW SEED\nGrow something lovely")
	pickupPrompts.Seashell = makePickup(model, "Seashell", Vector3.new(pickupAnchors.Seashell.x - 8, 0, pickupAnchors.Seashell.z + 8), VisualTheme.Colors.paper, "SEASHELL\nA gift from the sea")
	pickupPrompts.WoodToken = makePickup(model, "WoodToken", Vector3.new(pickupAnchors.WoodToken.x + 8, 0, pickupAnchors.WoodToken.z + 8), VisualTheme.Colors.gold, "WOOD TOKEN\nFound in the woods")

	local cabins = {}
	for index, x in {-24, 0, 24} do
		cabins[index] = makeCabin(model, index, Vector3.new(x, 0, layout.livingWorld.cabinLaneZ), if index == 2 then VisualTheme.Colors.cream else VisualTheme.Colors.warmLight)
	end

	for index, x in {-40, -20, 20, 40} do
		makeFlowerPatch(model, "VillageFlowerPatch" .. index, Vector3.new(x, 0, 60), if index % 2 == 0 then VisualTheme.Colors.flower else VisualTheme.Colors.warmLight)
	end

	return {
		model = model,
		pickupPrompts = pickupPrompts,
		nurseryAnchor = nurseryAnchor,
		cabins = cabins,
	}
end

return LivingWorldBuilder
