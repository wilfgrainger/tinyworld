local WorldLayoutRules = {}

WorldLayoutRules.MIN_PLOTS = 4
WorldLayoutRules.MAX_PLOTS = 60
WorldLayoutRules.PLOT_SIZE = 60
WorldLayoutRules.PLOT_SPACING = 72
WorldLayoutRules.CORE_HALF_EXTENT = 60
WorldLayoutRules.BOUNDARY_CLEARANCE = 48
WorldLayoutRules.LANDMARK_INSET = 24

export type PlotSlot = { x: number, z: number }
export type Layout = {
	plotSlots: { PlotSlot },
	plotSize: number,
	plotSpacing: number,
	coreHalfExtent: number,
	perimeterHalfExtent: number,
	landmarks: { [string]: PlotSlot },
	roads: { mainHalfLength: number, sideOffset: number, laneWidth: number },
	civic: { fountain: PlotSlot, townHall: PlotSlot, market: PlotSlot, portal: PlotSlot },
	livingWorld: { cabinLaneZ: number, nursery: PlotSlot, pickupAnchors: { [string]: PlotSlot } },
	budgets: { plots: number, boundaryTrees: number, roadParts: number, totalDecorations: number, cabins: number, livingPickups: number, planters: number },
}

local FIRST_PLOTS = {
	{ x = -75, z = -75 },
	{ x = 75, z = -75 },
	{ x = -75, z = 75 },
	{ x = 75, z = 75 },
}

function WorldLayoutRules.safeCount(value: any, minimum: number, maximum: number): number
	if type(value) ~= "number" or value ~= value then
		return minimum
	end
	if value == math.huge then
		return maximum
	end
	if value == -math.huge then
		return minimum
	end
	return math.max(minimum, math.min(maximum, math.floor(value)))
end

local function safeMaxPlayers(maxPlayers: any): number
	if type(maxPlayers) ~= "number" or maxPlayers ~= maxPlayers or maxPlayers == math.huge or maxPlayers == -math.huge then
		return WorldLayoutRules.MIN_PLOTS
	end
	return WorldLayoutRules.safeCount(maxPlayers, WorldLayoutRules.MIN_PLOTS, WorldLayoutRules.MAX_PLOTS)
end

function WorldLayoutRules.boundsOverlap(first: PlotSlot, second: PlotSlot, size: number?, padding: number?): boolean
	local halfSize = (size or WorldLayoutRules.PLOT_SIZE) + (padding or 0)
	return math.abs(first.x - second.x) < halfSize and math.abs(first.z - second.z) < halfSize
end

local function appendIfClear(slots: { PlotSlot }, candidate: PlotSlot)
	for _, existing in slots do
		if WorldLayoutRules.boundsOverlap(existing, candidate, WorldLayoutRules.PLOT_SIZE, 4) then
			return
		end
	end
	table.insert(slots, candidate)
end

function WorldLayoutRules.create(maxPlayers: any): Layout
	local target = safeMaxPlayers(maxPlayers)
	local slots = {}
	for _, firstPlot in FIRST_PLOTS do
		table.insert(slots, { x = firstPlot.x, z = firstPlot.z })
	end

	local ring = 1
	while #slots < target do
		local edge = ring * WorldLayoutRules.PLOT_SPACING * 2
		local candidates = {
			{ x = -edge, z = -edge },
			{ x = edge, z = -edge },
			{ x = -edge, z = edge },
			{ x = edge, z = edge },
		}
		local coordinate = -edge + WorldLayoutRules.PLOT_SPACING
		while coordinate < edge do
			table.insert(candidates, { x = -edge, z = coordinate })
			table.insert(candidates, { x = edge, z = coordinate })
			table.insert(candidates, { x = coordinate, z = -edge })
			table.insert(candidates, { x = coordinate, z = edge })
			coordinate += WorldLayoutRules.PLOT_SPACING
		end
		for _, candidate in candidates do
			if #slots >= target then
				break
			end
			appendIfClear(slots, candidate)
		end
		ring += 1
	end

	local outerExtent = WorldLayoutRules.CORE_HALF_EXTENT
	for _, slot in slots do
		outerExtent = math.max(outerExtent, math.abs(slot.x) + (WorldLayoutRules.PLOT_SIZE / 2), math.abs(slot.z) + (WorldLayoutRules.PLOT_SIZE / 2))
	end
	local perimeterHalfExtent = outerExtent + WorldLayoutRules.BOUNDARY_CLEARANCE
	local landmarkOffset = perimeterHalfExtent - WorldLayoutRules.LANDMARK_INSET
	local roadHalfLength = math.max(WorldLayoutRules.CORE_HALF_EXTENT, math.min(perimeterHalfExtent - WorldLayoutRules.BOUNDARY_CLEARANCE, 180))
	local boundaryTrees = WorldLayoutRules.safeCount(math.floor((perimeterHalfExtent * 2) / 48) * 4, 16, 180)
	local roadParts = 12
	local cabinLaneZ = WorldLayoutRules.CORE_HALF_EXTENT + 16
	local pickupOffset = math.max(WorldLayoutRules.CORE_HALF_EXTENT + 8, landmarkOffset - 12)

	return {
		plotSlots = slots,
		plotSize = WorldLayoutRules.PLOT_SIZE,
		plotSpacing = WorldLayoutRules.PLOT_SPACING,
		coreHalfExtent = WorldLayoutRules.CORE_HALF_EXTENT,
		perimeterHalfExtent = perimeterHalfExtent,
		landmarks = {
			woodlandTrail = { x = -landmarkOffset, z = 0 },
			cliffLookout = { x = 0, z = -landmarkOffset },
			seaDock = { x = landmarkOffset, z = 0 },
		},
		roads = {
			mainHalfLength = roadHalfLength,
			sideOffset = 28,
			laneWidth = 18,
		},
		civic = {
			fountain = { x = 0, z = 0 },
			townHall = { x = -44, z = 0 },
			market = { x = 44, z = -44 },
			portal = { x = -44, z = 44 },
		},
		livingWorld = {
			cabinLaneZ = cabinLaneZ,
			nursery = { x = -28, z = 26 },
			pickupAnchors = {
				MeadowSeed = { x = -28, z = 26 },
				Seashell = { x = pickupOffset, z = 0 },
				WoodToken = { x = -pickupOffset, z = 0 },
			},
		},
		budgets = {
			plots = target,
			boundaryTrees = boundaryTrees,
			roadParts = roadParts,
			totalDecorations = (target * 20) + (boundaryTrees * 3) + 360,
			cabins = 3,
			livingPickups = 3,
			planters = 12,
		},
	}
end

return WorldLayoutRules
