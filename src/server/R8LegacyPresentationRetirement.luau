local R8LegacyPresentationRetirement = {}

local DIRECT_LEGACY_NAMES = {
	VillageSquare = true,
	RoadNorth = true,
	RoadSouth = true,
	RoadEast = true,
	RoadWest = true,
}

local DIRECT_LEGACY_PREFIXES = {
	"Kerb",
	"Lantern",
	"SquareFlowers",
	"SquareBench",
	"MarketStall",
	"StreetCluster",
	"ART_R5_Tree_",
	"ART_R5_Hedge_",
	"ART_R5_Lantern",
	"ART_R5_Bench",
	"ART_R5_Planter",
}

local function hasPrefix(name: string, prefixes): boolean
	for _, prefix in prefixes do
		if string.sub(name, 1, #prefix) == prefix then
			return true
		end
	end
	return false
end

local function destroy(instance: Instance?)
	if instance and instance.Parent then
		instance:Destroy()
	end
end

local function retireBoundaryVisual(instance: Instance)
	if instance:IsA("BasePart") then
		instance.Transparency = 1
		instance.CanCollide = false
		instance.CanTouch = false
		instance.CastShadow = false
		instance:SetAttribute("TinyWorldVisualState", "hidden-runtime-anchor")
	elseif instance:IsA("SurfaceGui") or instance:IsA("BillboardGui") then
		instance.Enabled = false
	elseif instance:IsA("Light") then
		instance.Enabled = false
	elseif instance:IsA("ParticleEmitter") or instance:IsA("Trail") or instance:IsA("Beam") then
		instance.Enabled = false
	end
end

local function retireBoundary(world)
	local boundary = if world.boundary then world.boundary.model else nil
	if boundary == nil then
		boundary = world.root:FindFirstChild("VillageBoundary")
	end
	if boundary == nil then
		return
	end

	retireBoundaryVisual(boundary)
	for _, descendant in boundary:GetDescendants() do
		retireBoundaryVisual(descendant)
	end
	boundary:SetAttribute("TinyWorldVisualState", "hidden-runtime-anchors")
	boundary:SetAttribute("TinyWorldR8RetiredPresentation", true)
end

local function retireScenery(world)
	local scenery = world.scenery
	if scenery then
		if scenery.terrain then
			destroy(scenery.terrain.model)
		end
		for _, road in scenery.roads or {} do
			destroy(road)
		end
		if scenery.civic then
			destroy(scenery.civic.square)
			for _, stall in scenery.civic.marketStalls or {} do
				destroy(stall)
			end
		end
		for _, neighbourhood in scenery.neighbourhoods or {} do
			destroy(neighbourhood)
		end
	end

	if world.ambientLife then
		destroy(world.ambientLife.model)
	end

	for _, child in world.root:GetChildren() do
		if DIRECT_LEGACY_NAMES[child.Name] or hasPrefix(child.Name, DIRECT_LEGACY_PREFIXES) then
			destroy(child)
		end
	end
end

function R8LegacyPresentationRetirement.apply(world)
	retireScenery(world)
	retireBoundary(world)
	world.root:SetAttribute("TinyWorldLegacyPresentationRetired", true)
	world.root:SetAttribute("TinyWorldVisibleGroundAuthority", "R8Ground")
	world.root:SetAttribute("TinyWorldVisibleCoastAuthority", "R8TerrainCoast")
end

return R8LegacyPresentationRetirement
