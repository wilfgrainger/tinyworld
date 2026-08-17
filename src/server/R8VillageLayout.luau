local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local R8VillageLayoutRules = require(shared:WaitForChild("R8VillageLayoutRules"))
local WorldLayoutRules = require(shared:WaitForChild("WorldLayoutRules"))

local R8VillageLayout = {}

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

return R8VillageLayout
