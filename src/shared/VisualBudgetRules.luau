local VisualBudgetRules = {
	MAX_TOTAL_DECORATIONS = 1200,
	MAX_PER_PLOT_DECORATIONS = 24,
	MAX_BOUNDARY_DECORATIONS = 120,
	MAX_BILLBOARDS = 48,
	MAX_INTERACTION_MARKERS = 48,
	MAX_SEEDED_DRESSING = 352,
}

function VisualBudgetRules.forPlayers(plotCount: number, boundaryTrees: number)
	local safePlots = math.max(4, math.min(16, math.floor(plotCount)))
	local safeTrees = math.max(4, math.min(40, math.floor(boundaryTrees)))
	local boundaryDecorations = safeTrees * 3
	local seededDressing = math.min(VisualBudgetRules.MAX_SEEDED_DRESSING, 160 + (safePlots * 12))
	return {
		totalDecorations = (safePlots * VisualBudgetRules.MAX_PER_PLOT_DECORATIONS)
			+ boundaryDecorations
			+ 220
			+ seededDressing,
		perPlotDecorations = VisualBudgetRules.MAX_PER_PLOT_DECORATIONS,
		boundaryDecorations = boundaryDecorations,
		seededDressing = seededDressing,
		billboards = math.min(VisualBudgetRules.MAX_BILLBOARDS, safePlots + 20),
		interactionMarkers = math.min(VisualBudgetRules.MAX_INTERACTION_MARKERS, safePlots * 3),
	}
end

function VisualBudgetRules.isWithinBudget(budget): boolean
	local seededDressing = budget.seededDressing or 0
	return budget.totalDecorations <= VisualBudgetRules.MAX_TOTAL_DECORATIONS
		and budget.perPlotDecorations <= VisualBudgetRules.MAX_PER_PLOT_DECORATIONS
		and budget.boundaryDecorations <= VisualBudgetRules.MAX_BOUNDARY_DECORATIONS
		and seededDressing <= VisualBudgetRules.MAX_SEEDED_DRESSING
		and budget.billboards <= VisualBudgetRules.MAX_BILLBOARDS
		and budget.interactionMarkers <= VisualBudgetRules.MAX_INTERACTION_MARKERS
end

return VisualBudgetRules
