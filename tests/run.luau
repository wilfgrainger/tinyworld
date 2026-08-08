local specs = {
		require("./ProfileSchema.spec"),
		require("./OnboardingRules.spec"),
	require("./Progression.spec"),
	require("./HouseUpgrade.spec"),
	require("./Inventory.spec"),
	require("./GardenRules.spec"),
	require("./DailyReward.spec"),
	require("./Profession.spec"),
	require("./TransportRules.spec"),
	require("./PortalRules.spec"),
	require("./TradeRules.spec"),
}

for _, runSpec in specs do
	runSpec()
end

print(string.format("TinyWorld tests passed: %d specs", #specs))
