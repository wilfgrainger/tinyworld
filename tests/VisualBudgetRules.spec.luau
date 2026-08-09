local TestUtil = require("./TestUtil")
local VisualBudgetRules = require("../src/shared/VisualBudgetRules")

return function()
	local minimumBudget = VisualBudgetRules.forPlayers(4, 16)
	local fullBudget = VisualBudgetRules.forPlayers(16, 40)
	local cappedBudget = VisualBudgetRules.forPlayers(60, 400)

	TestUtil.isTrue(VisualBudgetRules.isWithinBudget(minimumBudget))
	TestUtil.isTrue(VisualBudgetRules.isWithinBudget(fullBudget))
	TestUtil.isTrue(VisualBudgetRules.isWithinBudget(cappedBudget))
	TestUtil.isTrue(fullBudget.seededDressing > 0)
	TestUtil.isTrue(fullBudget.seededDressing <= VisualBudgetRules.MAX_SEEDED_DRESSING)
	TestUtil.isTrue(fullBudget.interactionMarkers <= VisualBudgetRules.MAX_INTERACTION_MARKERS)
	TestUtil.isFalse(fullBudget.seededDressing == fullBudget.interactionMarkers)
	TestUtil.equal(cappedBudget.totalDecorations, fullBudget.totalDecorations)
end
