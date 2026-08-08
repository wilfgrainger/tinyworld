local TestUtil = require("./TestUtil")
local VisualBudgetRules = require("../src/shared/VisualBudgetRules")

return function()
	local four = VisualBudgetRules.forPlayers(4, 16)
	TestUtil.equal(four.perPlotDecorations, 24)
	TestUtil.isTrue(VisualBudgetRules.isWithinBudget(four))

	local sixty = VisualBudgetRules.forPlayers(60, 180)
	TestUtil.equal(sixty.perPlotDecorations, 24)
	TestUtil.isTrue(sixty.totalDecorations <= 4200)
	TestUtil.isTrue(sixty.boundaryDecorations <= 900)
	TestUtil.isTrue(VisualBudgetRules.isWithinBudget(sixty))

	local over = { totalDecorations = 4201, perPlotDecorations = 24, boundaryDecorations = 100, billboards = 10, interactionMarkers = 10 }
	TestUtil.isFalse(VisualBudgetRules.isWithinBudget(over))
end
