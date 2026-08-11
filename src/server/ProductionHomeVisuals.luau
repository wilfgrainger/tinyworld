local ProductionHomeVisuals = {}

local function hideLegacyHomeVisuals(container: Instance)
	for _, descendant in container:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Transparency = 1
			-- R3's later compatibility pass scans Part names for Foliage/Bloom/Canopy.
			-- Retire those visual-only names so it cannot recreate primitive art after ART R4 mounts.
			if
				descendant:IsA("Part")
				and descendant.Shape == Enum.PartType.Ball
				and descendant:GetAttribute("TinyWorldInteractionAnchor") ~= true
			then
				descendant.Name = "RetiredR4Primitive"
			end
			-- Interaction and collision policy remains owned by the existing gameplay builder.
		elseif descendant:IsA("SurfaceGui") or descendant:IsA("BillboardGui") then
			descendant.Enabled = false
		elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") then
			descendant.Enabled = false
		elseif descendant:IsA("Light") then
			-- Keep lights attached to explicit interaction anchors because gameplay may toggle them.
			local parent = descendant.Parent
			if not parent or not parent:GetAttribute("TinyWorldInteractionAnchor") then
				descendant.Enabled = false
			end
		end
	end
	container:SetAttribute("TinyWorldLegacyHomeVisualsHidden", true)
end

local function visualHolder(parent: Instance, name: string): Model
	local existing = parent:FindFirstChild(name)
	if existing then
		existing:Destroy()
	end
	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("TinyWorldArtRole", "art-r4-home-visual-holder")
	model.Parent = parent
	return model
end

function ProductionHomeVisuals.apply(plot, profile, house, productionVisualService)
	if productionVisualService == nil or plot == nil or plot.houseContainer == nil or plot.houseAnchor == nil then
		return
	end

	local container = plot.houseContainer
	hideLegacyHomeVisuals(container)

	local pivot = CFrame.new(plot.houseAnchor)
	local exteriorHolder = visualHolder(container, "ART_R4_HomeExterior")
	local exterior = productionVisualService:mount("starter-home", exteriorHolder, pivot)
	local interiorHolder = visualHolder(container, "ART_R4_HomeInterior")
	local interior = productionVisualService:mount("starter-interior-kit", interiorHolder, pivot)

	container:SetAttribute("TinyWorldProductionArtRevision", "ART R4")
	container:SetAttribute("TinyWorldHomeVisualArchitecture", "mesh-shell-plus-semantic-anchors")
	container:SetAttribute("TinyWorldHouseTier", profile and profile.houseTier or 1)
	container:SetAttribute("TinyWorldHouseName", house and house.name or "TinyWorld Home")
	container:SetAttribute("TinyWorldProductionArtDegraded", exterior == nil or interior == nil)
end

return ProductionHomeVisuals
