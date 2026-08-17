local R8AssetLibrary = require(script.Parent:WaitForChild("R8AssetLibrary"))

local R8VillageCompositionBuilder = {}

local function makeDecorationSafe(model: Model)
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
		end
	end
end

local function place(
	parent: Instance,
	category: string,
	name: string,
	instanceName: string,
	cframe: CFrame
): Model
	local model = R8AssetLibrary.clonePrefab(category, name)
	model.Name = instanceName
	model.Parent = parent
	model:PivotTo(cframe)
	makeDecorationSafe(model)
	model:SetAttribute("TinyWorldArtRevision", "ART R8")
	return model
end

local function buildPlazaRing(parent: Instance, layout)
	local group = Instance.new("Model")
	group.Name = "PlazaRing"
	group.Parent = parent

	for index, angleDegrees in { 0, 45, 90, 135, 180, 225, 270, 315 } do
		local angle = math.rad(angleDegrees)
		local radius = layout.plazaRadius + 8
		local x = math.cos(angle) * radius
		local z = math.sin(angle) * radius
		place(group, "StreetKit", "Lamp", "PlazaLamp" .. index, CFrame.new(x, layout.groundY, z))
	end

	for index, entry in {
		{ x = -22, z = -26, yaw = 35 },
		{ x = 22, z = -26, yaw = -35 },
		{ x = -22, z = 26, yaw = 145 },
		{ x = 22, z = 26, yaw = -145 },
	} do
		place(
			group,
			"StreetKit",
			"Bench",
			"PlazaBench" .. index,
			CFrame.new(entry.x, layout.groundY, entry.z) * CFrame.Angles(0, math.rad(entry.yaw), 0)
		)
	end

	for index, entry in {
		{ x = -30, z = 0 },
		{ x = 30, z = 0 },
		{ x = 0, z = -30 },
		{ x = 0, z = 30 },
	} do
		place(group, "StreetKit", "Planter", "PlazaPlanter" .. index, CFrame.new(entry.x, layout.groundY, entry.z))
	end
end

local function buildResidentialEdges(parent: Instance, layout)
	local group = Instance.new("Model")
	group.Name = "ResidentialEdges"
	group.Parent = parent

	for clusterIndex, cluster in layout.residentialClusters do
		local cx = cluster.center.x
		local cz = cluster.center.z
		place(group, "Nature", "TreeLarge", "ClusterTree" .. clusterIndex, CFrame.new(cx + 24, layout.groundY, cz + 24))
		place(group, "Nature", "TreeSmall", "ClusterTreeSmall" .. clusterIndex, CFrame.new(cx - 26, layout.groundY, cz - 22))
		place(group, "Nature", "HedgeSection", "ClusterHedgeA" .. clusterIndex, CFrame.new(cx, layout.groundY, cz - 34))
		place(
			group,
			"Nature",
			"HedgeSection",
			"ClusterHedgeB" .. clusterIndex,
			CFrame.new(cx - 34, layout.groundY, cz) * CFrame.Angles(0, math.rad(90), 0)
		)

		for plotIndex, plot in cluster.plots do
			place(
				group,
				"StreetKit",
				"Mailbox",
				string.format("Mailbox_%d_%d", clusterIndex, plotIndex),
				CFrame.new(plot.x + 9, layout.groundY, plot.z + 9)
			)
		end
	end
end

local function buildRouteLandmarks(parent: Instance, layout)
	local group = Instance.new("Model")
	group.Name = "RouteLandmarks"
	group.Parent = parent

	for index, route in layout.routes do
		if index <= 5 then
			local x = (route.from.x + route.to.x) / 2
			local z = (route.from.z + route.to.z) / 2
			place(group, "StreetKit", "Lamp", "RouteLamp" .. index, CFrame.new(x + 5, layout.groundY, z + 5))
			place(group, "StreetKit", "Planter", "RoutePlanter" .. index, CFrame.new(x - 6, layout.groundY, z - 5))
		end
	end
end

local function buildHarbourApproach(parent: Instance, layout)
	local group = Instance.new("Model")
	group.Name = "HarbourApproach"
	group.Parent = parent

	for index, z in { -82, -55, -25, 20, 52 } do
		place(group, "StreetKit", "Lamp", "HarbourLamp" .. index, CFrame.new(158, layout.groundY, z))
	end
	place(group, "StreetKit", "Bench", "HarbourLookoutBench", CFrame.new(165, layout.groundY, 8) * CFrame.Angles(0, math.rad(-90), 0))
	place(group, "Nature", "TreeSmall", "HarbourTreeNorth", CFrame.new(145, layout.groundY, 70))
	place(group, "Nature", "TreeSmall", "HarbourTreeSouth", CFrame.new(145, layout.groundY, -88))
end

function R8VillageCompositionBuilder.apply(parent: Instance, compatibleLayout)
	local previous = parent:FindFirstChild("R8VillageComposition")
	if previous then
		previous:Destroy()
	end

	local layout = compatibleLayout.r8 or compatibleLayout
	local model = Instance.new("Model")
	model.Name = "R8VillageComposition"
	model:SetAttribute("TinyWorldArtRevision", "ART R8")
	model:SetAttribute("TinyWorldVisualAuthority", "authored-prefabs")
	model.Parent = parent

	buildPlazaRing(model, layout)
	buildResidentialEdges(model, layout)
	buildRouteLandmarks(model, layout)
	buildHarbourApproach(model, layout)
	return model
end

return R8VillageCompositionBuilder
