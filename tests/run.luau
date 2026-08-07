local specs = {
	require("./ProfileSchema.spec"),
	require("./Progression.spec"),
	require("./HouseUpgrade.spec"),
}

for _, runSpec in specs do
	runSpec()
end

print(string.format("TinyWorld tests passed: %d specs", #specs))
