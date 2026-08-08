local VisualBudgetRules = {
	MAX_TOTAL_DECORATIONS = 4200,
	MAX_PER_PLOT_DECORATIONS = 24,
	MAX_BOUNDARY_DECORATIONS = 900,
	MAX_BILLBOARDS = 180,
	MAX_INTERACTION_MARKERS = 180,
}

function VisualBudgetRules.forPlayers(plotCount: number, boundaryTrees: number)
	local safePlots = math.max(4, math.floor(plotCount))
	local safeTrees = math.max(4, math.floor(boundaryTrees))
	return {
		totalDecorations = (safePlots * VisualBudgetRules.MAX_PER_PLOT_DECORATIONS) + (safeTrees * 3) + 360,
		perPlotDecorations = VisualBudgetRules.MAX_PER_PLOT_DECORATIONS,
		boundaryDecorations = safeTrees * 3,
		billboards = math.min(VisualBudgetRules.MAX_BILLBOARDS, safePlots + 60),
		interactionMarkers = math.min(VisualBudgetRules.MAX_INTERACTION_MARKERS, safePlots * 3),
	}
end

function VisualBudgetRules.isWithinBudget(budget): boolean
	return budget.totalDecorations <= VisualBudgetRules.MAX_TOTAL_DECORATIONS
		and budget.perPlotDecorations <= VisualBudgetRules.MAX_PER_PLOT_DECORATIONS
		and budget.boundaryDecorations <= VisualBudgetRules.MAX_BOUNDARY_DECORATIONS
		and budget.billboards <= VisualBudgetRules.MAX_BILLBOARDS
		and budget.interactionMarkers <= VisualBudgetRules.MAX_INTERACTION_MARKERS
end

return VisualBudgetRules
