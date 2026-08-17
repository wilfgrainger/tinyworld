local TestUtil = require("./TestUtil")
local R8VillageLayoutRules = require("../src/shared/R8VillageLayoutRules")

local function distance2D(point)
	return math.sqrt((point.x * point.x) + (point.z * point.z))
end

return function()
	local layout = R8VillageLayoutRules.create()
	TestUtil.equal(layout.artRevision, "ART R8")
	TestUtil.equal(layout.groundY, 0)
	TestUtil.isTrue(layout.waterY < layout.groundY)
	TestUtil.isTrue(layout.shorelineDistance >= 180)
	TestUtil.isTrue(layout.shorelineDistance <= 220)

	TestUtil.equal(#layout.residentialClusters, 4)
	local plotCount = 0
	for _, cluster in layout.residentialClusters do
		TestUtil.equal(#cluster.plots, 4)
		for _, plot in cluster.plots do
			plotCount += 1
			TestUtil.isTrue(math.abs(plot.x) <= 140)
			TestUtil.isTrue(math.abs(plot.z) <= 140)
		end
	end
	TestUtil.equal(plotCount, 16)

	for _, role in { "Mara", "Pip", "Finn", "Skye", "Milo" } do
		local destination = layout.destinations[role]
		TestUtil.isTrue(destination ~= nil)
		TestUtil.isTrue(distance2D(destination) < layout.shorelineDistance)
		TestUtil.isTrue(layout.routesByDestination[role] == true)
	end

	TestUtil.isTrue(layout.safeShore.y >= layout.groundY + 4)
	TestUtil.isTrue(layout.worldRecovery.y >= layout.groundY + 4)
	TestUtil.equal(layout.safeShore.y, layout.worldRecovery.y)
	TestUtil.isTrue(distance2D(layout.plaza) < 1)
end
