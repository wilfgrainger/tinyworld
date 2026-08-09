local specs = {
	require("./ProfileSchema.spec"),
	require("./OnboardingRules.spec"),
	require("./GoalRules.spec"),
	require("./Progression.spec"),
	require("./HouseUpgrade.spec"),
	require("./Inventory.spec"),
	require("./PhysicalAffordanceRules.spec"),
	require("./LivingWorldRules.spec"),
	require("./GardenRules.spec"),
	require("./DailyReward.spec"),
	require("./Profession.spec"),
	require("./TransportRules.spec"),
	require("./TraversalRules.spec"),
	require("./PortalRules.spec"),
	require("./TradeRules.spec"),
	require("./WorldLayoutRules.spec"),
	require("./VillageComposition.spec"),
	require("./TerrainRules.spec"),
	require("./ExplorationRules.spec"),
	require("./VisualBudgetRules.spec"),
	require("./ProfileStoreRules.spec"),
	require("./RouteRules.spec"),
	require("./SocialRules.spec"),
	require("./HomeRules.spec"),
	require("./HomeExpressionRules.spec"),
	require("./AlphaOpsRules.spec"),
	require("./VisualQualityRules.spec"),
}

for _, runSpec in specs do
	runSpec()
end

print(string.format("TinyWorld tests passed: %d specs", #specs))
