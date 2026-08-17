local R8VillageLayoutRules = {}

local GROUND_Y = 0
local WATER_Y = -2.5
local SAFE_STANDING_Y = GROUND_Y + 5
local SHORELINE_DISTANCE = 210

local function point(x: number, z: number, yaw: number?)
	return {
		x = x,
		y = GROUND_Y,
		z = z,
		yaw = yaw or 0,
	}
end

local function plot(x: number, z: number, yaw: number)
	return {
		x = x,
		y = GROUND_Y,
		z = z,
		yaw = yaw,
	}
end

local function cluster(name: string, centerX: number, centerZ: number, plots)
	return {
		name = name,
		center = point(centerX, centerZ),
		plots = plots,
	}
end

function R8VillageLayoutRules.create()
	local destinations = {
		Mara = point(52, -30, -35),
		Pip = point(-52, -34, 35),
		Milo = point(-54, 44, 145),
		Finn = point(174, 50, -90),
		Skye = point(174, -55, -90),
	}

	local activitySites = {
		GardenBeds = point(-67, -45, 35),
		FishingDock = point(SHORELINE_DISTANCE - 10, 50, -90),
		RepairStation = point(-68, 57, 145),
		CoastalDelivery = point(SHORELINE_DISTANCE + 65, -20, -90),
	}

	local routes = {
		{ name = "MarketStreet", from = point(0, 0), to = destinations.Mara, width = 12 },
		{ name = "GardenLane", from = point(0, 0), to = destinations.Pip, width = 11 },
		{ name = "WorkshopLane", from = point(0, 0), to = destinations.Milo, width = 11 },
		{ name = "FishingWalk", from = point(38, 18), to = destinations.Finn, width = 10 },
		{ name = "HarbourRoad", from = point(38, -18), to = destinations.Skye, width = 12 },
		{ name = "WestResidentialLane", from = point(-38, -138), to = point(-38, 138), width = 10 },
		{ name = "EastResidentialLane", from = point(38, -138), to = point(38, 138), width = 10 },
		{ name = "NorthResidentialLane", from = point(-138, 38), to = point(138, 38), width = 10 },
		{ name = "SouthResidentialLane", from = point(-138, -38), to = point(138, -38), width = 10 },
	}

	return {
		artRevision = "ART R8",
		groundY = GROUND_Y,
		waterY = WATER_Y,
		shorelineDistance = SHORELINE_DISTANCE,
		waterBelt = 180,
		swimDistance = 36,
		worldHalfExtent = 210,
		plaza = point(0, 0),
		plazaRadius = 34,
		safeShore = {
			x = SHORELINE_DISTANCE - 24,
			y = SAFE_STANDING_Y,
			z = 0,
			yaw = -90,
		},
		worldRecovery = {
			x = 0,
			y = SAFE_STANDING_Y,
			z = 0,
			yaw = 0,
		},
		residentialClusters = {
			cluster("MeadowLane", -102, -102, {
				plot(-134, -134, 45),
				plot(-70, -134, -45),
				plot(-134, -70, 135),
				plot(-70, -70, -135),
			}),
			cluster("HarbourRow", 102, -102, {
				plot(70, -134, 45),
				plot(134, -134, -45),
				plot(70, -70, 135),
				plot(134, -70, -135),
			}),
			cluster("WoodlandRise", -102, 102, {
				plot(-134, 70, 45),
				plot(-70, 70, -45),
				plot(-134, 134, 135),
				plot(-70, 134, -135),
			}),
			cluster("OrchardEnd", 102, 102, {
				plot(70, 70, 45),
				plot(134, 70, -45),
				plot(70, 134, 135),
				plot(134, 134, -135),
			}),
		},
		destinations = destinations,
		activitySites = activitySites,
		routes = routes,
		routesByDestination = {
			Mara = true,
			Pip = true,
			Finn = true,
			Skye = true,
			Milo = true,
		},
	}
end

return R8VillageLayoutRules
