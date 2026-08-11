local ProductionVillageVisuals = {}

local function hideLegacyVisuals(root: Instance)
	for _, descendant in root:GetDescendants() do
		if descendant.Name == "ART_R4_VisualRoot" then
			continue
		end
		if descendant:IsA("BasePart") then
			descendant.Transparency = 1
			-- Preserve gameplay collision/query exactly as authored. ART R4 is presentation only.
		elseif descendant:IsA("SurfaceGui") or descendant:IsA("BillboardGui") then
			descendant.Enabled = false
		elseif descendant:IsA("Light") then
			descendant.Enabled = false
		elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") then
			descendant.Enabled = false
		end
	end
	root:SetAttribute("TinyWorldLegacyVisualsHidden", true)
end

local function findModel(root: Instance, name: string): Model?
	local found = root:FindFirstChild(name, true)
	if found and found:IsA("Model") then
		return found
	end
	return nil
end

local function mountFixed(root: Instance, productionVisualService, modelName: string, role: string, pivot: CFrame)
	local model = findModel(root, modelName)
	if not model then
		warn("[TinyWorld ART R4] semantic model not found", modelName, role)
		return nil
	end
	hideLegacyVisuals(model)
	return productionVisualService:mount(role, model, pivot)
end

local function mountSupporting(root: Instance, productionVisualService, role: string, name: string, pivot: CFrame)
	local container = Instance.new("Model")
	container.Name = name
	container:SetAttribute("TinyWorldArtRole", "art-r4-supporting")
	container.Parent = root
	return productionVisualService:mount(role, container, pivot)
end

local function hideLandscapeTree(model: Model)
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Transparency = 1
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
		end
	end
end

local function replaceLandscapeTrees(root: Instance, productionVisualService)
	local treeModels = {}
	for _, descendant in root:GetDescendants() do
		if descendant:IsA("Model") and descendant:GetAttribute("TinyWorldArtRole") == "village-cluster-tree" then
			table.insert(treeModels, descendant)
		end
	end

	local roles = { "tree-a", "tree-b", "tree-c" }
	for index, treeModel in treeModels do
		local trunk = treeModel:FindFirstChild("Trunk")
		if trunk and trunk:IsA("BasePart") then
			local base = trunk.Position - Vector3.new(0, trunk.Size.Y / 2, 0)
			hideLandscapeTree(treeModel)
			productionVisualService:mount(roles[((index - 1) % #roles) + 1], treeModel, CFrame.new(base))
		end
	end
end

local function replaceUngroupedTrees(root: Instance, productionVisualService)
	local candidates = {}
	for _, descendant in root:GetDescendants() do
		if descendant:IsA("Part") and string.find(descendant.Name, "Canopy", 1, true) then
			local parent = descendant.Parent
			if parent and not parent:IsA("Model") then
				continue
		end
			local prefix = string.gsub(descendant.Name, "CanopyHighlight$", "")
			prefix = string.gsub(prefix, "Canopy$", "")
			local trunk = if parent then parent:FindFirstChild(prefix .. "Trunk") else nil
			if trunk and trunk:IsA("BasePart") and not candidates[trunk] then
				candidates[trunk] = true
			end
		end
	end

	local index = 0
	for trunk in candidates do
		index += 1
		local parent = trunk.Parent
		if not parent then
			continue
		end
		local prefix = string.gsub(trunk.Name, "Trunk$", "")
		for _, child in parent:GetChildren() do
			if child:IsA("BasePart") and string.sub(child.Name, 1, #prefix) == prefix then
				child.Transparency = 1
				child.CanCollide = false
				child.CanTouch = false
				child.CanQuery = false
			end
		end
		local base = trunk.Position - Vector3.new(0, trunk.Size.Y / 2, 0)
		local holder = Instance.new("Model")
		holder.Name = "ART_R4_Tree_" .. prefix
		holder.Parent = parent
		productionVisualService:mount(({ "tree-a", "tree-b", "tree-c" })[((index - 1) % 3) + 1], holder, CFrame.new(base))
	end
end

local function replaceFlowerBeds(root: Instance, productionVisualService)
	local flowerBeds = {}
	for _, descendant in root:GetDescendants() do
		if descendant:IsA("Model") and descendant:GetAttribute("TinyWorldArtRole") == "village-flower-bed" then
			table.insert(flowerBeds, descendant)
		end
	end
	for index, bed in flowerBeds do
		local soil = bed:FindFirstChild("Soil")
		if soil and soil:IsA("BasePart") then
			for _, child in bed:GetDescendants() do
				if child:IsA("BasePart") and child ~= soil then
					child.Transparency = 1
					child.CanCollide = false
					child.CanTouch = false
					child.CanQuery = false
				end
			end
			-- A few larger authored planters read better than a carpet of ball-on-stick flowers.
			if index % 2 == 1 then
				productionVisualService:mount("planter", bed, CFrame.new(soil.Position + Vector3.new(0, 0.2, 0)))
			end
		end
	end
end

local function replaceHedges(root: Instance, productionVisualService)
	local hedges = {}
	for _, descendant in root:GetDescendants() do
		if descendant:IsA("BasePart") and descendant:GetAttribute("TinyWorldArtRole") == "village-hedge" then
			table.insert(hedges, descendant)
		end
	end
	for index, hedge in hedges do
		local pivot = hedge.CFrame
		local parent = hedge.Parent
		hedge.Transparency = 1
		hedge.CanCollide = false
		hedge.CanTouch = false
		hedge.CanQuery = false
		if parent and index <= 28 then
			local holder = Instance.new("Model")
			holder.Name = "ART_R4_Hedge_" .. index
			holder.Parent = parent
			productionVisualService:mount("hedge", holder, pivot)
		end
	end
end

local function replaceWorldPortals(root: Instance, productionVisualService)
	local portalModels = {}
	for _, descendant in root:GetDescendants() do
		if descendant:IsA("Model") then
			local role = descendant:GetAttribute("TinyWorldArtRole")
			if role == "world-portal" then
				table.insert(portalModels, descendant)
			end
		end
	end
	for _, portal in portalModels do
		local prompt = portal:FindFirstChildWhichIsA("ProximityPrompt", true)
		local anchor = if prompt and prompt.Parent and prompt.Parent:IsA("BasePart") then prompt.Parent else nil
		if anchor then
			local pivot = CFrame.new(anchor.Position.X, math.max(0, anchor.Position.Y - 6), anchor.Position.Z)
			hideLegacyVisuals(portal)
			productionVisualService:mount("portal-clockwork", portal, pivot)
		end
	end
end

local function addCivicSupportingArt(root: Instance, productionVisualService)
	local placements = {
		{ role = "lantern", name = "ART_R4_LanternNW", cf = CFrame.new(-13, 0, 7) },
		{ role = "lantern", name = "ART_R4_LanternNE", cf = CFrame.new(13, 0, 7) },
		{ role = "lantern", name = "ART_R4_LanternSW", cf = CFrame.new(-13, 0, 26) },
		{ role = "lantern", name = "ART_R4_LanternSE", cf = CFrame.new(13, 0, 26) },
		{ role = "bench", name = "ART_R4_BenchWest", cf = CFrame.new(-17, 0, 17) * CFrame.Angles(0, math.rad(90), 0) },
		{ role = "bench", name = "ART_R4_BenchEast", cf = CFrame.new(17, 0, 17) * CFrame.Angles(0, math.rad(-90), 0) },
		{ role = "planter", name = "ART_R4_PlanterNW", cf = CFrame.new(-10, 0, 10) },
		{ role = "planter", name = "ART_R4_PlanterNE", cf = CFrame.new(10, 0, 10) },
	}
	for _, placement in placements do
		mountSupporting(root, productionVisualService, placement.role, placement.name, placement.cf)
	end
end

function ProductionVillageVisuals.apply(world, productionVisualService)
	local root = world.root

	mountFixed(root, productionVisualService, "TownHallPrefab", "town-hall", CFrame.new(-44, 0, 0))
	mountFixed(root, productionVisualService, "CourierDepotPrefab", "courier-depot", CFrame.new(0, 0, -44))
	mountFixed(root, productionVisualService, "VillageShopPrefab", "village-shop", CFrame.new(44, 0, -44))
	mountFixed(root, productionVisualService, "HomeStoreDestination", "home-store", CFrame.new(-44, 0, -44))
	mountFixed(root, productionVisualService, "TransportWorkshopPrefab", "workshop", CFrame.new(44, 0, 0))
	mountFixed(root, productionVisualService, "DailyFountainPrefab", "fountain", CFrame.new(0, 0, 16))

	local market = findModel(root, "VillageMarketPrefab")
	if market then
		hideLegacyVisuals(market)
		productionVisualService:mount("market-stall-a", market, CFrame.new(-7, 0.5, 44))
		local stallB = Instance.new("Model")
		stallB.Name = "ART_R4_MarketStallB"
		stallB.Parent = market
		productionVisualService:mount("market-stall-b", stallB, CFrame.new(7, 0.5, 44))
	end

	local courier = findModel(root, "CourierDepotPrefab")
	if courier then
		local crates = Instance.new("Model")
		crates.Name = "ART_R4_ParcelCrates"
		crates.Parent = courier
		productionVisualService:mount("parcel-crates", crates, CFrame.new(8, 0, -31))
	end

	replaceWorldPortals(root, productionVisualService)
	replaceLandscapeTrees(root, productionVisualService)
	replaceUngroupedTrees(root, productionVisualService)
	replaceFlowerBeds(root, productionVisualService)
	replaceHedges(root, productionVisualService)
	addCivicSupportingArt(root, productionVisualService)

	root:SetAttribute("TinyWorldProductionArtRevision", "ART R4")
	root:SetAttribute("TinyWorldProductionVisualArchitecture", "semantic-roots-plus-mesh-assets")
end

return ProductionVillageVisuals
