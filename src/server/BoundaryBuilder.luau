local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))

local BoundaryBuilder = {}

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

local function makeLabel(parent: BasePart, text: string, width: number): TextLabel
	local gui = Instance.new("BillboardGui")
	gui.Name = "Label"
	gui.Size = UDim2.fromOffset(math.min(width, 280), 58)
	gui.StudsOffset = Vector3.new(0, 4.5, 0)
	gui.MaxDistance = 120
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
	local textConstraint = Instance.new("UITextSizeConstraint")
	textConstraint.MinTextSize = 12
	textConstraint.MaxTextSize = 22
	textConstraint.Parent = label
	return label
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

local function makeTree(parent: Instance, name: string, position: Vector3, scale: number)
	makeDecoration(parent, name .. "Trunk", Vector3.new(2 * scale, 6 * scale, 2 * scale), position + Vector3.new(0, 3 * scale, 0), VisualTheme.Colors.timberDark, Enum.Material.Wood)
	makeDecoration(parent, name .. "Canopy", Vector3.new(9 * scale, 9 * scale, 9 * scale), position + Vector3.new(0, 8 * scale, 0), VisualTheme.Colors.leaf, Enum.Material.LeafyGrass).Shape = Enum.PartType.Ball
	makeDecoration(parent, name .. "CanopyHighlight", Vector3.new(5 * scale, 5 * scale, 5 * scale), position + Vector3.new(2 * scale, 10 * scale, -2 * scale), VisualTheme.Colors.meadowDeep, Enum.Material.LeafyGrass).Shape = Enum.PartType.Ball
end

local function makeWoodlandShrub(parent: Instance, name: string, position: Vector3, scale: number)
	local shrub = makeDecoration(parent, name, Vector3.new(4 * scale, 3 * scale, 4 * scale), position + Vector3.new(0, 1.5 * scale, 0), VisualTheme.Colors.leaf, Enum.Material.LeafyGrass)
	shrub.Shape = Enum.PartType.Ball
end

local function makeWoodlandClearing(parent: Instance, name: string, position: Vector3)
	makeDecoration(parent, name, Vector3.new(20, 0.12, 14), position + Vector3.new(0, 0.06, 0), VisualTheme.Colors.meadowDeep, Enum.Material.Ground)
	for index, offset in {
		Vector3.new(-7, 0, -4),
		Vector3.new(7, 0, -4),
		Vector3.new(-7, 0, 4),
		Vector3.new(7, 0, 4),
	} do
		makeWoodlandShrub(parent, "WoodlandShrub" .. name .. index, position + offset, 0.8 + ((index % 2) * 0.15))
	end
end

local function makeSea(parent: Instance, name: string, size: Vector3, position: Vector3)
	local water = makeDecoration(parent, name, size, position, VisualTheme.Colors.water, Enum.Material.Water)
	water.Transparency = 0.12
	water.Reflectance = 0.05
	local foam = makeDecoration(parent, name .. "Foam", Vector3.new(size.X * 0.9, 0.08, size.Z * 0.9), position + Vector3.new(0, 1.05, 0), VisualTheme.Colors.paper, Enum.Material.Neon)
	foam.Transparency = 0.82
end

local function makeSandTransition(parent: Instance, name: string, size: Vector3, position: Vector3)
	makeDecoration(parent, name, size, position, VisualTheme.Colors.warmLight, Enum.Material.Sand)
end

local function makeRockCluster(parent: Instance, name: string, position: Vector3, scale: number)
	for index, offset in {
		Vector3.new(-3, 0, 0),
		Vector3.new(0, 0, 2),
		Vector3.new(3, 0, -1),
	} do
		local rock = makeDecoration(parent, name .. "Rock" .. index, Vector3.new(4 * scale, 3 * scale, 3 * scale), position + offset + Vector3.new(0, 1.5 * scale, 0), VisualTheme.Colors.path, Enum.Material.Rock)
		rock.Shape = Enum.PartType.Ball
		rock.Orientation = Vector3.new(0, index * 18, index * 4)
	end
end

local function makeReedCluster(parent: Instance, name: string, position: Vector3)
	for index, offset in {
		Vector3.new(-2, 0, 0),
		Vector3.new(0, 0, 1),
		Vector3.new(2, 0, -1),
	} do
		local reed = makeDecoration(parent, name .. "Reed" .. index, Vector3.new(0.35, 3.5, 0.35), position + offset + Vector3.new(0, 1.75, 0), VisualTheme.Colors.leaf, Enum.Material.Grass)
		reed.Orientation = Vector3.new(0, index * 25, (index - 2) * 8)
	end
end

local function makeDockRail(parent: Instance, name: string, position: Vector3)
	makeDecoration(parent, name .. "Deck", Vector3.new(18, 0.35, 7), position + Vector3.new(0, 0.35, 0), VisualTheme.Colors.timber, Enum.Material.WoodPlanks)
	for _, x in {-7, 7} do
		makeDecoration(parent, name .. "Post" .. x, Vector3.new(0.6, 3, 0.6), position + Vector3.new(x, 1.5, 0), VisualTheme.Colors.timberDark, Enum.Material.Wood)
	end
	makeDecoration(parent, name .. "Rail", Vector3.new(15, 0.45, 0.45), position + Vector3.new(0, 2.7, 0), VisualTheme.Colors.timberDark, Enum.Material.Wood)
end

local function makeBoatDock(parent: Instance, half: number)
	local dockPosition = Vector3.new(half - 35, 0, 0)
	makeDecoration(parent, "TinyBoatDock", Vector3.new(20, 0.35, 10), dockPosition + Vector3.new(0, 0.35, 0), VisualTheme.Colors.timber, Enum.Material.WoodPlanks)
	for _, z in {-4, 4} do
		makeDecoration(parent, "TinyBoatDockPost" .. tostring(z), Vector3.new(0.7, 3.5, 0.7), dockPosition + Vector3.new(7, 1.75, z), VisualTheme.Colors.timberDark, Enum.Material.Wood)
	end
	local shop = makePart(parent, "TinyBoatShop", Vector3.new(6, 5, 6), dockPosition + Vector3.new(-2, 2.5, 9), VisualTheme.Colors.skyDeep, Enum.Material.WoodPlanks)
	makeLabel(shop, "TINY BOAT DOCK\n600 coins • Tidepool Cove", 320)
	local prompt = makePrompt(shop, "Buy Tiny Boat", "Sea Dock")
	return prompt, CFrame.new(dockPosition + Vector3.new(0, 1.6, 0)) * CFrame.Angles(0, math.rad(90), 0)
end

local function makeTidepoolCove(parent: Instance, half: number)
	local coveCenter = Vector3.new(half + 108, 0, 0)
	makePart(parent, "TidepoolCoveIsland", Vector3.new(56, 2, 44), coveCenter + Vector3.new(0, -0.2, 0), VisualTheme.Colors.warmLight, Enum.Material.Sand)
	makeDecoration(parent, "TidepoolCoveMeadow", Vector3.new(42, 0.2, 30), coveCenter + Vector3.new(0, 0.9, 0), VisualTheme.Colors.meadowDeep, Enum.Material.Grass)
	makeDockRail(parent, "TidepoolCoveDock", coveCenter + Vector3.new(-14, 0, 0))
	local beacon = makePart(parent, "TidepoolCoveBeacon", Vector3.new(3, 8, 3), coveCenter + Vector3.new(12, 4, 0), VisualTheme.Colors.gold, Enum.Material.Neon)
	makeLabel(beacon, "TIDEPOOL COVE\nA new edge of TinyWorld", 280)
	local storyStone = makePart(parent, "TidepoolCoveStoryStone", Vector3.new(6, 2.5, 3), coveCenter + Vector3.new(4, 1.25, 10), VisualTheme.Colors.path, Enum.Material.Rock)
	makeLabel(storyStone, "Tide pools remember every journey.", 260)
	makeReedCluster(parent, "TidepoolCoveReeds", coveCenter + Vector3.new(-16, 0, 12))
	makeRockCluster(parent, "TidepoolCoveRocks", coveCenter + Vector3.new(16, 0, -12), 0.65)

	return {
		boatCFrame = CFrame.new(coveCenter + Vector3.new(-14, 1.6, 0)) * CFrame.Angles(0, math.rad(90), 0),
		arrivalCFrame = CFrame.new(coveCenter + Vector3.new(-2, 4.5, -5)) * CFrame.Angles(0, math.rad(90), 0),
	}
end

local function makeCliffSegment(parent: Instance, name: string, size: Vector3, position: Vector3, height: number)
	makePart(parent, name .. "Rock", Vector3.new(size.X, height, size.Z), position + Vector3.new(0, height / 2, 0), VisualTheme.Colors.path, Enum.Material.Rock)
	makePart(parent, name .. "BasaltCap", Vector3.new(math.max(6, size.X - 4), 1.4, math.max(6, size.Z - 2)), position + Vector3.new(0, height + 0.7, 0), VisualTheme.Colors.inkSoft, Enum.Material.Basalt)
end

local function makeLandmark(parent: Instance, name: string, labelText: string, position: Vector3, color: Color3)
	local anchor = makePart(parent, name .. "Anchor", Vector3.new(8, 2, 8), position + Vector3.new(0, 1, 0), color, Enum.Material.Rock)
	makeDecoration(parent, name .. "Pillar", Vector3.new(3, 5, 3), position + Vector3.new(0, 4.5, 0), color, Enum.Material.Basalt)
	local beacon = makeDecoration(parent, name .. "Beacon", Vector3.new(2, 2, 2), position + Vector3.new(0, 8, 0), VisualTheme.Colors.gold, Enum.Material.Neon)
	beacon.Shape = Enum.PartType.Ball
	makeLabel(anchor, labelText, 250)
	local prompt = makePrompt(anchor, "Explore Landmark", "Boundary Explorer")
	return prompt
end

function BoundaryBuilder.build(parent: Instance, layout)
	local boundary = Instance.new("Model")
	boundary.Name = "VillageBoundary"
	boundary.Parent = parent

	local half = layout.perimeterHalfExtent
	local waterBelt = 72
	local fullWaterExtent = (half * 2) + (waterBelt * 2)
	local waterCenter = half + (waterBelt / 2)
	makeSea(boundary, "SeaNorth", Vector3.new(fullWaterExtent, 2, waterBelt), Vector3.new(0, -0.6, waterCenter))
	makeSea(boundary, "SeaSouth", Vector3.new(fullWaterExtent, 2, waterBelt), Vector3.new(0, -0.6, -waterCenter))
	makeSea(boundary, "SeaEast", Vector3.new(waterBelt, 2, fullWaterExtent), Vector3.new(waterCenter, -0.6, 0))
	makeSea(boundary, "SeaWest", Vector3.new(waterBelt, 2, fullWaterExtent), Vector3.new(-waterCenter, -0.6, 0))

	local sandBand = 18
	local sandCenter = half - (sandBand / 2)
	makeSandTransition(boundary, "SandNorth", Vector3.new(half * 2, 0.2, sandBand), Vector3.new(0, 0.12, -sandCenter))
	makeSandTransition(boundary, "SandSouth", Vector3.new(half * 2, 0.2, sandBand), Vector3.new(0, 0.12, sandCenter))
	makeSandTransition(boundary, "SandEast", Vector3.new(sandBand, 0.2, half * 2), Vector3.new(sandCenter, 0.12, 0))
	makeSandTransition(boundary, "SandWest", Vector3.new(sandBand, 0.2, half * 2), Vector3.new(-sandCenter, 0.12, 0))

	local segmentCount = math.max(4, math.floor((half * 2) / 72))
	local segmentWidth = math.max(20, math.min(42, ((half * 2) / segmentCount) - 8))
	local cliffLine = half - 8
	for index = 1, segmentCount do
		local ratio = (index - 0.5) / segmentCount
		local offset = (-half) + (ratio * half * 2)
		local height = 5 + ((index % 3) * 2)
		local centerIndex = math.ceil(segmentCount / 2)
		if index ~= centerIndex then
			makeCliffSegment(boundary, "NorthCliff" .. index, Vector3.new(segmentWidth, 1, 10), Vector3.new(offset, 0, -cliffLine), height)
			makeCliffSegment(boundary, "EastCliff" .. index, Vector3.new(10, 1, segmentWidth), Vector3.new(cliffLine, 0, offset), height)
			makeCliffSegment(boundary, "WestCliff" .. index, Vector3.new(10, 1, segmentWidth), Vector3.new(-cliffLine, 0, offset), height)
		end
		makeCliffSegment(boundary, "SouthCliff" .. index, Vector3.new(segmentWidth, 1, 10), Vector3.new(offset, 0, cliffLine), height)
	end

	local forestLine = half - 24
	local budgetedTrees = if layout.budgets then layout.budgets.boundaryTrees else 16
	local treeCount = math.max(4, math.floor(budgetedTrees / 4))
	for index = 1, treeCount do
		local ratio = (index - 0.5) / treeCount
		local offset = (-half) + (ratio * half * 2)
		local centerDistance = math.abs(offset) / math.max(1, half)
		local skipCenter = centerDistance < 0.18
		if not skipCenter then
			makeTree(boundary, "NorthWood" .. index, Vector3.new(offset, 0, -forestLine), 0.9 + ((index % 2) * 0.12))
			makeTree(boundary, "EastWood" .. index, Vector3.new(forestLine, 0, offset), 0.9 + ((index % 2) * 0.12))
			makeTree(boundary, "WestWood" .. index, Vector3.new(-forestLine, 0, offset), 0.9 + ((index % 2) * 0.12))
			makeTree(boundary, "SouthWood" .. index, Vector3.new(offset, 0, forestLine), 0.9 + ((index % 2) * 0.12))
		end
	end

	makeWoodlandClearing(boundary, "WoodlandClearingWest", Vector3.new(-forestLine + 18, 0, 0))
	makeWoodlandClearing(boundary, "WoodlandClearingEast", Vector3.new(forestLine - 18, 0, 0))
	makeRockCluster(boundary, "CliffRockCluster", Vector3.new(0, 0, -cliffLine + 10), 0.9)
	makeReedCluster(boundary, "SeaReeds", Vector3.new(half - 22, 0, 9))
	makeDockRail(boundary, "SeaDock", Vector3.new(half - 35, 0, 0))
	local boatShopPrompt, boatDockCFrame = makeBoatDock(boundary, half)
	local tidepool = makeTidepoolCove(boundary, half)

	local landmarkPrompts = {
		woodlandTrail = makeLandmark(boundary, "WoodlandTrail", "WOODLAND TRAIL\nVisit the village woods", Vector3.new(layout.landmarks.woodlandTrail.x, 0, layout.landmarks.woodlandTrail.z), VisualTheme.Colors.leaf),
		cliffLookout = makeLandmark(boundary, "CliffLookout", "CLIFF LOOKOUT\nSee the edge of TinyWorld", Vector3.new(layout.landmarks.cliffLookout.x, 0, layout.landmarks.cliffLookout.z), VisualTheme.Colors.pathEdge),
		seaDock = makeLandmark(boundary, "SeaDock", "SEA DOCK\nThe village meets the sea", Vector3.new(layout.landmarks.seaDock.x, 0, layout.landmarks.seaDock.z), VisualTheme.Colors.skyDeep),
	}

	local board = makePart(boundary, "BoundaryExplorerBoard", Vector3.new(12, 5, 2), Vector3.new(0, 2.5, 28), VisualTheme.Colors.timberDark, Enum.Material.WoodPlanks)
	makeLabel(board, "BOUNDARY EXPLORER\nVisit woods, cliffs, and sea", 300)
	local explorerPrompt = makePrompt(board, "Claim Explorer Reward", "Boundary Explorer Board")

	return {
		model = boundary,
		landmarkPrompts = landmarkPrompts,
		explorerPrompt = explorerPrompt,
		boatShopPrompt = boatShopPrompt,
		boatDockCFrame = boatDockCFrame,
		coveBoatCFrame = tidepool.boatCFrame,
		coveArrivalCFrame = tidepool.arrivalCFrame,
		villageReturnCFrame = CFrame.new(layout.landmarks.seaDock.x - 8, 4.5, 0),
	}
end

return BoundaryBuilder
