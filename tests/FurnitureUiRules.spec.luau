local TestUtil = require("./TestUtil")
local FurnitureUiRules = require("../src/shared/FurnitureUiRules")

return function()
	TestUtil.equal(FurnitureUiRules.rejectionCopy("out_of_bounds"), "Keep the whole item inside your home.")
	TestUtil.equal(
		FurnitureUiRules.rejectionCopy("placement_budget"),
		"Your home has reached its furniture placement limit. Store an item before placing another."
	)
	TestUtil.equal(FurnitureUiRules.furnitureIdFromButtonName("Furniture_Sofa"), "Sofa")
	TestUtil.equal(FurnitureUiRules.furnitureIdFromButtonName("CloseButton"), nil)
	TestUtil.equal(FurnitureUiRules.preferredFurnitureId("Chair", { "Lamp", "Chair" }), "Chair")
	TestUtil.equal(FurnitureUiRules.preferredFurnitureId("Missing", { "Lamp", "Chair" }), "Lamp")
	TestUtil.equal(FurnitureUiRules.preferredFurnitureId(nil, {}), nil)
end
