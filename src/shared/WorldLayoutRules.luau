local WorldLayoutRules = {}
local VisualBudgetRules = require("./VisualBudgetRules")
local TerrainRules = require("./TerrainRules")

WorldLayoutRules.MIN_PLOTS = 4
WorldLayoutRules.MAX_PLOTS = 16
WorldLayoutRules.MAX_SERVER_PLAYERS = WorldLayoutRules.MAX_PLOTS
WorldLayoutRules.PLOT_SIZE = 60
WorldLayoutRules.PLOT_SPACING = 72
WorldLayoutRules.CORE_HALF_EXTENT = 60
WorldLayoutRules.BOUNDARY_CLEARANCE = 48
WorldLayoutRules.LANDMARK_INSET = 24
WorldLayoutRules.ART_SEED = 2052
WorldLayoutRules.NEIGHBOURHOODS = {
	"MeadowLane",
	"HarbourRow",
	"WoodlandRise",
	"OrchardEnd",
}
WorldLayoutRules.NEIGHBOURHOOD_LABELS = {
	MeadowLane = "Meadow Lane",
	HarbourRow = "Harbour Row",
	WoodlandRise = "Woodland Rise",
	OrchardEnd = "Orchard End",
}

export type Position2D = { x: number, z: number }
export type PlotSlot = { x: number, z: number, neighbourhood: string, rotation: number, setback: number }
export type Layout = {
	plotSlots: { PlotSlot },
	neighbourhoods: { string },
	artSeed: number,
	plotSize: number,
	plotSpacing: number,
	coreHalfExtent: number,
	perimeterHalfExtent: number,
	landmarks: { [string]: Position2D },
	roads: { mainHalfLength: number, sideOffset: number, laneWidth: number },
	terrainBands: { any },
	civic: { fountain: Position2D, townHall: Position2D, market: Position2D, portal: Position2D },
	livingWorld: { cabinLaneZ: number, nursery: Position2D, pickupAnchors: { [string]: Position2D } },
	budgets: {
		plots: number,
		boundaryTrees: number,
		roadParts: number,
		totalDecorations: number,
		cabins: number,
		livingPickups: number,
		planters: number,
		visual: any,
	},
}

local PLOT_SLOTS = {
	{ x = -112, z = -112, neighbourhood = "MeadowLane", rotation = -38, setback = 2 },
	{ x = 112, z = -112, neighbourhood = "HarbourRow", rotation = 32, setback = 7 },
	{ x = -112, z = 112, neighbourhood = "WoodlandRise", rotation = -142, setback = 5 },
	{ x = 112, z = 112, neighbourhood = "OrchardEnd", rotation = 146, setback = 3 },
	{ x = -184, z = -112, neighbourhood = "MeadowLane", rotation = -24, setback = 6 },
	{ x = 184, z = -112, neighbourhood = "HarbourRow", rotation = 18, setback = 10 },
	{ x = -184, z = 112, neighbourhood = "WoodlandRise", rotation = -158, setback = 8 },
	{ x = 184, z = 112, neighbourhood = "OrchardEnd", rotation = 164, setback = 5 },
	{ x = -112, z = -184, neighbourhood = "MeadowLane", rotation = -52, setback = 4 },
	{ x = 112, z = -184, neighbourhood = "HarbourRow", rotation = 48, setback = 12 },
	{ x = -112, z = 184, neighbourhood = "WoodlandRise", rotation = -128, setback = 7 },
	{ x = 112, z = 184, neighbourhood = "OrchardEnd", rotation = 132, setback = 6 },
	{ x = -184, z = -184, neighbourhood = "MeadowLane", rotation = -34, setback = 8 },
	{ x = 184, z = -184, neighbourhood = "HarbourRow", rotation = 27, setback = 14 },
	{ x = -184, z = 184, neighbourhood = "WoodlandRise", rotation = -150, setback = 10 },
	{ x = 184, z = 184, neighbourhood = "OrchardEnd", rotation = 154, setback = 9 },
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

function WorldLayoutRules.canAdmitPlayer(currentAdmitted: any): boolean
	return type(currentAdmitted) == "number"
		and currentAdmitted == math.floor(currentAdmitted)
		and currentAdmitted >= 0
		and currentAdmitted < WorldLayoutRules.MAX_SERVER_PLAYERS
end

local function safeMaxPlayers(maxPlayers: any): number
	return WorldLayoutRules.safeCount(maxPlayers, WorldLayoutRules.MIN_PLOTS, WorldLayoutRules.MAX_PLOTS)
end

function WorldLayoutRules.boundsOverlap(first: Position2D, second: Position2D, size: number?, padding: number?): boolean
	local halfSize = (size or WorldLayoutRules.PLOT_SIZE) + (padding or 0)
	return math.abs(first.x - second.x) < halfSize and math.abs(first.z - second.z) < halfSize
end

function WorldLayoutRules.create(maxPlayers: any): Layout
	local target = safeMaxPlayers(maxPlayers)
	local slots = {}
	for index = 1, target do
		local slot = PLOT_SLOTS[index]
		table.insert(slots, {
			x = slot.x,
			z = slot.z,
			neighbourhood = slot.neighbourhood,
			rotation = slot.rotation,
			setback = slot.setback,
		})
	end

	local outerExtent = WorldLayoutRules.CORE_HALF_EXTENT
	for _, slot in slots do
		outerExtent = math.max(
			outerExtent,
			math.abs(slot.x) + (WorldLayoutRules.PLOT_SIZE / 2),
			math.abs(slot.z) + (WorldLayoutRules.PLOT_SIZE / 2)
		)
	end
	local perimeterHalfExtent = outerExtent + WorldLayoutRules.BOUNDARY_CLEARANCE
	local landmarkOffset = perimeterHalfExtent - WorldLayoutRules.LANDMARK_INSET
	local roadHalfLength = math.max(
		WorldLayoutRules.CORE_HALF_EXTENT,
		math.min(perimeterHalfExtent - WorldLayoutRules.BOUNDARY_CLEARANCE, 180)
	)
	local boundaryTrees = WorldLayoutRules.safeCount(math.floor((perimeterHalfExtent * 2) / 48) * 4, 16, 180)
	local roadParts = 17
	local cabinLaneZ = WorldLayoutRules.CORE_HALF_EXTENT + 16
	local pickupOffset = math.max(WorldLayoutRules.CORE_HALF_EXTENT + 8, landmarkOffset - 12)
	local visualBudget = VisualBudgetRules.forPlayers(target, boundaryTrees)

	return {
		plotSlots = slots,
		neighbourhoods = table.clone(WorldLayoutRules.NEIGHBOURHOODS),
		artSeed = WorldLayoutRules.ART_SEED,
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
		terrainBands = TerrainRules.allBands(),
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
			totalDecorations = visualBudget.totalDecorations,
			cabins = 3,
			livingPickups = 3,
			planters = 12,
			visual = visualBudget,
		},
	}
end

return WorldLayoutRules
