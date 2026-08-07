local Workspace = game:GetService("Workspace")

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
	label.BackgroundTransparency = 0.15
	label.BackgroundColor3 = Color3.fromRGB(24, 30, 42)
	label.Size = UDim2.fromScale(1, 1)
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0.7
	label.TextWrapped = true
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.Parent = gui
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

	makePart(model, "PlotBase", Vector3.new(60, 1, 60), origin, Color3.fromRGB(105, 177, 90), Enum.Material.Grass)
	local sign = makePart(model, "OwnerSign", Vector3.new(12, 5, 1), origin + Vector3.new(0, 3, 27), Color3.fromRGB(107, 78, 54), Enum.Material.Wood)
	local ownerLabel = makeLabel(sign, "Available Plot", 220)

	local upgradeKiosk = makePart(model, "UpgradeKiosk", Vector3.new(5, 4, 5), origin + Vector3.new(-12, 2, 24), Color3.fromRGB(247, 194, 74))
	local upgradePrompt = makePrompt(upgradeKiosk, "Upgrade Home", "Home Builder")

	local privacyKiosk = makePart(model, "PrivacyKiosk", Vector3.new(5, 4, 5), origin + Vector3.new(12, 2, 24), Color3.fromRGB(139, 189, 255))
	local privacyPrompt = makePrompt(privacyKiosk, "Change Privacy", "Home Access")

	local visitKiosk = makePart(model, "VisitKiosk", Vector3.new(5, 4, 5), origin + Vector3.new(0, 2, 24), Color3.fromRGB(183, 132, 240))
	local visitPrompt = makePrompt(visitKiosk, "Enter Home", "Front Gate")

	local houseContainer = Instance.new("Model")
	houseContainer.Name = "House"
	houseContainer.Parent = model

	local gardenBeds = {}
	local gardenPrompts = {}
	for bedIndex = 1, 3 do
		local x = (bedIndex - 2) * 10
		local bed = makePart(model, string.format("GardenBed%d", bedIndex), Vector3.new(8, 1, 10), origin + Vector3.new(x, 1, 16), Color3.fromRGB(104, 72, 48), Enum.Material.Ground)
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
	makePart(parent, "TradePostBase", Vector3.new(36, 1, 24), origin, Color3.fromRGB(193, 171, 128), Enum.Material.WoodPlanks)
	local sign = makePart(parent, "TradePostSign", Vector3.new(16, 5, 1), origin + Vector3.new(0, 4, -10), Color3.fromRGB(79, 59, 45), Enum.Material.Wood)
	local statusLabel = makeLabel(sign, "TRADING POST\nTwo players: join → choose item → confirm", 340)

	local sides = {}
	for side = 1, 2 do
		local x = if side == 1 then -9 else 9
		local name = if side == 1 then "A" else "B"
		local join = makePart(parent, "TradeJoin" .. name, Vector3.new(6, 1, 6), origin + Vector3.new(x, 1, -2), Color3.fromRGB(88, 164, 218))
		local offer = makePart(parent, "TradeOffer" .. name, Vector3.new(6, 1, 6), origin + Vector3.new(x, 1, 5), Color3.fromRGB(225, 164, 70))
		local confirm = makePart(parent, "TradeConfirm" .. name, Vector3.new(6, 1, 6), origin + Vector3.new(x, 1, 12), Color3.fromRGB(86, 181, 111))
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

	makePart(kitchen, "KitchenFloor", Vector3.new(180, 1, 180), origin, Color3.fromRGB(230, 222, 205), Enum.Material.Tile)
	local tableTop = makePart(kitchen, "GiantTableTop", Vector3.new(100, 4, 70), origin + Vector3.new(0, 30, 10), Color3.fromRGB(148, 99, 61), Enum.Material.WoodPlanks)
	makeLabel(tableTop, "THE GIANT KITCHEN\nCollect all 3 Sugar Crystals", 380)
	for _, offset in {
		Vector3.new(-42, 14, -22),
		Vector3.new(42, 14, -22),
		Vector3.new(-42, 14, 42),
		Vector3.new(42, 14, 42),
	} do
		makePart(kitchen, "TableLeg", Vector3.new(8, 28, 8), origin + offset, Color3.fromRGB(119, 77, 48), Enum.Material.Wood)
	end

	makePart(kitchen, "GiantPlate", Vector3.new(50, 2, 36), origin + Vector3.new(12, 34, 10), Color3.fromRGB(244, 244, 238), Enum.Material.SmoothPlastic)
	makePart(kitchen, "ForkHandle", Vector3.new(7, 2, 48), origin + Vector3.new(-30, 35, 10), Color3.fromRGB(185, 190, 196), Enum.Material.Metal)
	for tine = 1, 4 do
		makePart(kitchen, "ForkTine", Vector3.new(3, 2, 18), origin + Vector3.new(-37 + tine * 4, 35, 40), Color3.fromRGB(185, 190, 196), Enum.Material.Metal)
	end

	for step = 1, 10 do
		makePart(kitchen, "TableStep" .. step, Vector3.new(10, 3, 8), origin + Vector3.new(-58 + (step * 5), 1.5 + (step * 3), -25), Color3.fromRGB(222, 178, 107), Enum.Material.WoodPlanks)
	end

	local crystalPositions = {
		origin + Vector3.new(-30, 3, -35),
		origin + Vector3.new(35, 3, 45),
		origin + Vector3.new(15, 37, 10),
	}
	local crystalPrompts = {}
	for index, position in crystalPositions do
		local crystal = makePart(kitchen, "SugarCrystal" .. index, Vector3.new(4, 8, 4), position, Color3.fromRGB(94, 239, 255), Enum.Material.Neon)
		crystalPrompts[index] = makePrompt(crystal, "Collect Crystal", string.format("Sugar Crystal %d/3", index))
	end

	local exit = makePart(kitchen, "KitchenExitPortal", Vector3.new(12, 12, 2), origin + Vector3.new(0, 6, 75), Color3.fromRGB(184, 100, 255), Enum.Material.Neon)
	makeLabel(exit, "RETURN PORTAL")
	local returnPrompt = makePrompt(exit, "Return to Village", "Portal")

	return {
		arrivalCFrame = CFrame.new(origin + Vector3.new(0, 5, -72)),
		crystalPrompts = crystalPrompts,
		returnPrompt = returnPrompt,
	}
end

function WorldBuilder.build()
	local old = Workspace:FindFirstChild("TinyWorldGenerated")
	if old then
		old:Destroy()
	end

	local root = Instance.new("Model")
	root.Name = "TinyWorldGenerated"
	root.Parent = Workspace

	makePart(root, "VillageGround", Vector3.new(230, 2, 230), Vector3.new(0, -1, 0), Color3.fromRGB(112, 184, 92), Enum.Material.Grass)
	makePart(root, "RoadNS", Vector3.new(20, 1, 220), Vector3.new(0, 0.1, 0), Color3.fromRGB(73, 78, 82), Enum.Material.Asphalt)
	makePart(root, "RoadEW", Vector3.new(220, 1, 20), Vector3.new(0, 0.12, 0), Color3.fromRGB(73, 78, 82), Enum.Material.Asphalt)

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "VillageSpawn"
	spawn.Size = Vector3.new(12, 1, 12)
	spawn.Position = Vector3.new(0, 1, 0)
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Color = Color3.fromRGB(243, 222, 112)
	spawn.Parent = root

	local fountain = makePart(root, "DailyFountain", Vector3.new(8, 5, 8), Vector3.new(0, 2.5, 16), Color3.fromRGB(102, 182, 226), Enum.Material.Marble)
	makeLabel(fountain, "DAILY FOUNTAIN\n200 coins • 50 XP • 1 Carrot", 320)
	local dailyPrompt = makePrompt(fountain, "Claim Daily Reward", "Village Fountain")

	amenity(root, "TownHall", Vector3.new(-44, 0, 0), "TOWN HALL\nVillage Fund", Color3.fromRGB(230, 197, 133))
	local contribution = makePart(root, "ContributionKiosk", Vector3.new(6, 5, 6), Vector3.new(-29, 2.5, 0), Color3.fromRGB(237, 204, 91))
	local contributionPrompt = makePrompt(contribution, "Contribute 50 Coins", "Village Fund")
	local fundSign = makePart(root, "FundSign", Vector3.new(8, 4, 1), Vector3.new(-29, 6, 0), Color3.fromRGB(93, 74, 48))
	local fundLabel = makeLabel(fundSign, "Village Fund: 0 coins", 250)

	amenity(root, "DeliveryDepot", Vector3.new(0, 0, -44), "COURIER DEPOT\nPick up deliveries", Color3.fromRGB(222, 164, 103))
	local deliveryStart = makePart(root, "DeliveryStart", Vector3.new(6, 4, 6), Vector3.new(0, 2, -30), Color3.fromRGB(205, 133, 76))
	local deliveryStartPrompt = makePrompt(deliveryStart, "Take Parcel", "Courier Job")

	amenity(root, "VillageShop", Vector3.new(44, 0, -44), "VILLAGE SHOP\nDelivery destination", Color3.fromRGB(207, 137, 164))
	local deliveryEnd = makePart(root, "DeliveryEnd", Vector3.new(6, 4, 6), Vector3.new(30, 2, -44), Color3.fromRGB(205, 133, 76))
	local deliveryEndPrompt = makePrompt(deliveryEnd, "Deliver Parcel", "Courier Job")

	amenity(root, "TransportShop", Vector3.new(44, 0, 0), "TRANSPORT\nTiny Bike: 300 coins", Color3.fromRGB(101, 172, 214))
	local transport = makePart(root, "TransportKiosk", Vector3.new(6, 4, 6), Vector3.new(30, 2, 0), Color3.fromRGB(68, 142, 190))
	local transportPrompt = makePrompt(transport, "Buy / Toggle Bike", "Transport Shop")

	local trade = buildTradePost(root, Vector3.new(0, 0.5, 44))

	local portal = makePart(root, "VillagePortal", Vector3.new(12, 12, 2), Vector3.new(-44, 6, 44), Color3.fromRGB(184, 100, 255), Enum.Material.Neon)
	makeLabel(portal, "PORTAL\nThe Giant Kitchen", 300)
	local villagePortalPrompt = makePrompt(portal, "Enter Giant Kitchen", "World Portal")

	local premiumSign = makePart(root, "PremiumPreview", Vector3.new(16, 6, 1), Vector3.new(44, 4, 44), Color3.fromRGB(56, 45, 75))
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
