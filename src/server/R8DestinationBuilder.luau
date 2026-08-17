local R8AssetLibrary = require(script.Parent:WaitForChild("R8AssetLibrary"))

local R8DestinationBuilder = {}

local function placementCFrame(point): CFrame
	return CFrame.new(point.x, point.y, point.z) * CFrame.Angles(0, math.rad(point.yaw or 0), 0)
end

local function requiredPart(model: Model, name: string): BasePart
	local value = model:FindFirstChild(name, true)
	if value == nil or not value:IsA("BasePart") then
		error("R8 destination anchor missing: " .. model.Name .. "/" .. name)
	end
	return value
end

local function prepareAnchor(part: BasePart)
	part.Transparency = 1
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = true
	part:SetAttribute("TinyWorldInteractionAnchor", true)
end

local function placeActivity(parent: Instance, name: string, point): Model
	local model = R8AssetLibrary.clonePrefab("Activities", name)
	model.Name = "R8" .. name
	model:SetAttribute("TinyWorldArtRevision", "ART R8.1")
	model:SetAttribute("TinyWorldVisualAuthority", "authored-prefab")
	model.Parent = parent
	model:PivotTo(placementCFrame(point))
	return model
end

function R8DestinationBuilder.apply(world, compatibleLayout)
	local previous = world.root:FindFirstChild("ART_R8_ActivityDestinations")
	if previous then
		previous:Destroy()
	end

	local civic = world.r8CivicPrefabs
	if civic == nil then
		error("R8 civic prefab registry missing before destination composition")
	end

	local layout = compatibleLayout.r8 or compatibleLayout
	local sites = layout.activitySites
	if sites == nil then
		error("R8 canonical activity sites missing")
	end

	local root = Instance.new("Model")
	root.Name = "ART_R8_ActivityDestinations"
	root:SetAttribute("TinyWorldArtRevision", "ART R8.1")
	root:SetAttribute("TinyWorldVisualAuthority", "authored-prefabs")
	root.Parent = world.root

	local gardenBedsModel = placeActivity(root, "GardenBeds", sites.GardenBeds)
	local fishingDock = placeActivity(root, "FishingDock", sites.FishingDock)
	local repairStation = placeActivity(root, "RepairStation", sites.RepairStation)
	local deliveryBuoy = placeActivity(root, "DeliveryBuoy", sites.CoastalDelivery)

	local market = civic.Mara
	local gardenShed = civic.Pip
	local workshop = civic.Milo
	local harbour = civic.Skye
	if market == nil or gardenShed == nil or workshop == nil or harbour == nil then
		error("R8 required civic prefab missing from registry")
	end

	local marketNpc = requiredPart(market, "NpcAnchor")
	local marketPrompt = requiredPart(market, "PromptAnchor")
	local gardenNpc = requiredPart(gardenShed, "NpcAnchor")
	local gardenPrompt = requiredPart(gardenShed, "PromptAnchor")
	local workshopNpc = requiredPart(workshop, "NpcAnchor")
	local workshopPrompt = requiredPart(workshop, "PromptAnchor")
	local harbourNpc = requiredPart(harbour, "NpcAnchor")
	local harbourPrompt = requiredPart(harbour, "PromptAnchor")
	local boatSpawn = requiredPart(harbour, "BoatSpawnAnchor")

	local gardenPromptAnchor = requiredPart(gardenBedsModel, "PromptAnchor")
	local fishingNpc = requiredPart(fishingDock, "NpcAnchor")
	local fishingPrompt = requiredPart(fishingDock, "PromptAnchor")
	local fishingOrigin = requiredPart(fishingDock, "FishingOrigin")
	local repairPrompt = requiredPart(repairStation, "PromptAnchor")
	local deliveryPrompt = requiredPart(deliveryBuoy, "PromptAnchor")

	for _, anchor in {
		marketNpc,
		marketPrompt,
		gardenNpc,
		gardenPrompt,
		workshopNpc,
		workshopPrompt,
		harbourNpc,
		harbourPrompt,
		boatSpawn,
		gardenPromptAnchor,
		fishingNpc,
		fishingPrompt,
		fishingOrigin,
		repairPrompt,
		deliveryPrompt,
	} do
		prepareAnchor(anchor)
	end

	local gardenBeds = {
		requiredPart(gardenBedsModel, "GardenBed1"),
		requiredPart(gardenBedsModel, "GardenBed2"),
		requiredPart(gardenBedsModel, "GardenBed3"),
	}
	local repairBoards = {
		requiredPart(repairStation, "RepairBoard1"),
		requiredPart(repairStation, "RepairBoard2"),
		requiredPart(repairStation, "RepairBoard3"),
	}

	local registry = {
		Trader = {
			model = market,
			npcAnchor = marketNpc,
			promptAnchor = marketPrompt,
		},
		Gardener = {
			model = gardenShed,
			activityModel = gardenBedsModel,
			npcAnchor = gardenNpc,
			promptAnchor = gardenPrompt,
			activityOrigin = gardenPromptAnchor,
			gardenBeds = gardenBeds,
		},
		Fisherman = {
			model = fishingDock,
			npcAnchor = fishingNpc,
			promptAnchor = fishingPrompt,
			fishingOrigin = fishingOrigin,
		},
		BoatKeeper = {
			model = harbour,
			npcAnchor = harbourNpc,
			promptAnchor = harbourPrompt,
			boatSpawnAnchor = boatSpawn,
		},
		Builder = {
			model = workshop,
			activityModel = repairStation,
			npcAnchor = workshopNpc,
			promptAnchor = workshopPrompt,
			activityOrigin = repairPrompt,
			repairBoards = repairBoards,
		},
		CoastalDelivery = {
			model = deliveryBuoy,
			promptAnchor = deliveryPrompt,
		},
	}

	world.r8Destinations = registry
	return registry
end

return R8DestinationBuilder
