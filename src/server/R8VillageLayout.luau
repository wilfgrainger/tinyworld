local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local R8VillageLayoutRules = require(shared:WaitForChild("R8VillageLayoutRules"))
local WorldLayoutRules = require(shared:WaitForChild("WorldLayoutRules"))

local R8VillageLayout = {}

local function placementForSlot(slot)
	return CFrame.new(slot.x, 0, slot.z) * CFrame.Angles(0, math.rad(slot.rotation or 0), 0)
end

function R8VillageLayout.create(maxPlayers: number?)
	local raw = R8VillageLayoutRules.create()
	local compatible = WorldLayoutRules.create(maxPlayers)
	local targetPlotCount = #compatible.plotSlots
	local plotSlots = {}

	for _, cluster in raw.residentialClusters do
		for _, sourcePlot in cluster.plots do
			if #plotSlots >= targetPlotCount then
				break
			end
			table.insert(plotSlots, {
				x = sourcePlot.x,
				z = sourcePlot.z,
				neighbourhood = cluster.name,
				rotation = sourcePlot.yaw,
				setback = 0,
			})
		end
	end

	compatible.plotSlots = plotSlots
	compatible.perimeterHalfExtent = raw.worldHalfExtent
	compatible.r8 = raw
	compatible.groundY = raw.groundY
	compatible.waterY = raw.waterY
	compatible.shorelineDistance = raw.shorelineDistance
	compatible.safeShoreCFrame = CFrame.new(raw.safeShore.x, raw.safeShore.y, raw.safeShore.z)
		* CFrame.Angles(0, math.rad(raw.safeShore.yaw), 0)
	compatible.worldRecoveryCFrame = CFrame.new(
		raw.worldRecovery.x,
		raw.worldRecovery.y,
		raw.worldRecovery.z
	)

	return compatible
end

function R8VillageLayout.applyToWorld(world, layout)
	for index, plot in world.plots do
		local slot = layout.plotSlots[index]
		if slot == nil then
			break
		end

		local targetPlacement = placementForSlot(slot)
		local currentPlacement = plot.placementCFrame or CFrame.new(plot.origin)
		local delta = targetPlacement * currentPlacement:Inverse()
		plot.model:PivotTo(delta * plot.model:GetPivot())

		plot.origin = Vector3.new(slot.x, layout.groundY, slot.z)
		plot.placementCFrame = targetPlacement
		plot.houseAnchorCFrame = targetPlacement * CFrame.new(0, 1, -8)
		plot.houseAnchor = plot.houseAnchorCFrame.Position
		plot.insideCFrame = targetPlacement * CFrame.new(0, 4, -8)
		plot.outsideCFrame = targetPlacement * CFrame.new(0, 4, 20)
		plot.model:SetAttribute("TinyWorldNeighbourhood", slot.neighbourhood)
		plot.model:SetAttribute("TinyWorldArtRevision", "ART R8")
	end

	world.layout = layout
	world.root:SetAttribute("TinyWorldArtRevision", "ART R8")
	world.root:SetAttribute("TinyWorldLayoutAuthority", "R8VillageLayout")
	return world
end

return R8VillageLayout
