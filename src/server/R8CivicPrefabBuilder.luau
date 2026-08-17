local R8AssetLibrary = require(script.Parent:WaitForChild("R8AssetLibrary"))
local R8DestinationBuilder = require(script.Parent:WaitForChild("R8DestinationBuilder"))

local R8CivicPrefabBuilder = {}

local PLACEMENTS = {
	{ destination = "Mara", prefab = "MarketHouse", name = "R8MarketHouse" },
	{ destination = "Pip", prefab = "GardenShed", name = "R8GardenShed" },
	{ destination = "Milo", prefab = "Workshop", name = "R8Workshop" },
	{ destination = "Skye", prefab = "HarbourHut", name = "R8HarbourHut" },
}

local function placementCFrame(point): CFrame
	return CFrame.new(point.x, point.y, point.z) * CFrame.Angles(0, math.rad(point.yaw or 0), 0)
end

local function prepareAnchors(model: Model)
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			local isAnchor = descendant.Name == "NpcAnchor"
				or descendant.Name == "PromptAnchor"
				or descendant.Name == "BoatSpawnAnchor"
			if isAnchor then
				descendant.Transparency = 1
				descendant.CanCollide = false
				descendant.CanTouch = false
				descendant.CanQuery = true
				descendant:SetAttribute("TinyWorldInteractionAnchor", true)
			end
		end
	end
end

function R8CivicPrefabBuilder.apply(world, layout): Model
	local previous = world.root:FindFirstChild("ART_R8_CivicPrefabs")
	if previous then
		previous:Destroy()
	end

	local root = Instance.new("Model")
	root.Name = "ART_R8_CivicPrefabs"
	root:SetAttribute("TinyWorldArtRevision", "ART R8.1")
	root:SetAttribute("TinyWorldVisualState", "authored-prefabs-r8")
	root.Parent = world.root

	local raw = layout.r8 or layout
	local placed = {}
	for _, definition in PLACEMENTS do
		local point = raw.destinations[definition.destination]
		if point == nil then
			error("R8 civic destination missing: " .. definition.destination)
		end

		local model = R8AssetLibrary.clonePrefab("Civic", definition.prefab)
		model.Name = definition.name
		model:SetAttribute("TinyWorldArtRevision", "ART R8.1")
		model:SetAttribute("TinyWorldDestination", definition.destination)
		model.Parent = root
		model:PivotTo(placementCFrame(point))
		prepareAnchors(model)
		placed[definition.destination] = model
	end

	world.r8CivicPrefabs = placed
	R8DestinationBuilder.apply(world, layout)
	return root
end

return R8CivicPrefabBuilder
