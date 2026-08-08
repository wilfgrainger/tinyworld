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

local function amenity(parent: Instance, name: string, position: Vector3, text: string, color: Color3)
	local building = makePart(parent, name, Vector3.new(24, 12, 20), position + Vector3.new(0, 6, 0), color)
	makeLabel(building, text)
	return building
end

local function buildPlot(parent: Instance, index: number, origin: Vector3)
	local model = Instance.new("Model")
	model.Name = string.format("Plot%d", index)
	model.Parent = parent

	makePart(model, "PlotBase", Vector3.new(60, 1, 60), origin, VisualTheme.Colors.meadowDeep, Enum.Material.Grass)
	local sign = makeDecoration(model, "OwnerSign", Vector3.new(12, 5, 1), origin + Vector3.new(0, 3, 27), VisualTheme.Colors.timber, Enum.Material.Wood)
	local ownerLabel = makeLabel(sign, "Available Plot", 220)

	local upgradeKiosk = makePart(model, "UpgradeKiosk", Vector3.new(5, 4, 5), origin + Vector3.new(-12, 2, 24), VisualTheme.Colors.gold)
	local upgradePrompt = makePrompt(upgradeKiosk, "Upgrade Home", "Home Builder")

	local privacyKiosk = makePart(model, "PrivacyKiosk", Vector3.new(5, 4, 5), origin + Vector3.new(12, 2, 24), VisualTheme.Colors.sky)
	local privacyPrompt = makePrompt(privacyKiosk, "Change Privacy", "Home Access")

	local visitKiosk = makePart(model, "VisitKiosk", Vector3.new(5, 4, 5), origin + Vector3.new(0, 2, 24), VisualTheme.Colors.portal)
	local visitPrompt = makePrompt(visitKiosk, "Enter Home", "Front Gate")

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
		local crystal = makePart(kitchen, "SugarCrystal" .. index, Vector3.new(4, 8, 4), position, VisualTheme.Colors.crystal, Enum.Material.Neon)
		crystalPrompts[index] = makePrompt(crystal, "Collect Crystal", string.format("Sugar Crystal %d/3", index))
	end

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

	amenity(root, "TownHall", Vector3.new(-44, 0, 0), "TOWN HALL\nVillage Fund", VisualTheme.Colors.cream)
	local contribution = makePart(root, "ContributionKiosk", Vector3.new(6, 5, 6), Vector3.new(-29, 2.5, 0), VisualTheme.Colors.gold)
	local contributionPrompt = makePrompt(contribution, "Contribute 50 Coins", "Village Fund")
	local fundSign = makeDecoration(root, "FundSign", Vector3.new(8, 4, 1), Vector3.new(-29, 6, 0), VisualTheme.Colors.timberDark)
	local fundLabel = makeLabel(fundSign, "Village Fund: 0 coins", 250)

	amenity(root, "DeliveryDepot", Vector3.new(0, 0, -44), "COURIER DEPOT\nPick up deliveries", VisualTheme.Colors.warmLight)
	local deliveryStart = makePart(root, "DeliveryStart", Vector3.new(6, 4, 6), Vector3.new(0, 2, -30), VisualTheme.Colors.timber)
	local deliveryStartPrompt = makePrompt(deliveryStart, "Take Parcel", "Courier Job")

	amenity(root, "VillageShop", Vector3.new(44, 0, -44), "VILLAGE SHOP\nDelivery destination", VisualTheme.Colors.berry)
	local deliveryEnd = makePart(root, "DeliveryEnd", Vector3.new(6, 4, 6), Vector3.new(30, 2, -44), VisualTheme.Colors.timber)
	local deliveryEndPrompt = makePrompt(deliveryEnd, "Deliver Parcel", "Courier Job")

	amenity(root, "TransportShop", Vector3.new(44, 0, 0), "TRANSPORT\nTiny Bike: 300 coins", VisualTheme.Colors.sky)
	local transport = makePart(root, "TransportKiosk", Vector3.new(6, 4, 6), Vector3.new(30, 2, 0), VisualTheme.Colors.skyDeep)
	local transportPrompt = makePrompt(transport, "Buy / Toggle Bike", "Transport Shop")

	local trade = buildTradePost(root, Vector3.new(0, 0.5, 44))

	local portal = makePart(root, "VillagePortal", Vector3.new(12, 12, 2), Vector3.new(-44, 6, 44), VisualTheme.Colors.portal, Enum.Material.Neon)
	makeLabel(portal, "PORTAL\nThe Giant Kitchen", 300)
	local villagePortalPrompt = makePrompt(portal, "Enter Giant Kitchen", "World Portal")

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
