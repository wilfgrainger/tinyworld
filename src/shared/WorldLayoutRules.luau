local WorldLayoutRules = {}

WorldLayoutRules.MIN_PLOTS = 4
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
}

local FIRST_PLOTS = {
	{ x = -75, z = -75 },
	{ x = 75, z = -75 },
	{ x = -75, z = 75 },
	{ x = 75, z = 75 },
}

local function safeMaxPlayers(maxPlayers: any): number
	if type(maxPlayers) ~= "number" or maxPlayers ~= maxPlayers or maxPlayers == math.huge or maxPlayers == -math.huge then
		return WorldLayoutRules.MIN_PLOTS
	end
	return math.max(WorldLayoutRules.MIN_PLOTS, math.floor(maxPlayers))
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
	}
end

return WorldLayoutRules
