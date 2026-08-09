local TestUtil = require("./TestUtil")
local VisualQualityRules = require("../src/shared/VisualQualityRules")

return function()
	TestUtil.equal(VisualQualityRules.MAX_RESIDENT_HOMES, 16)
	TestUtil.equal(VisualQualityRules.TOAST_DURATION_SECONDS, 3)
	TestUtil.equal(VisualQualityRules.NEIGHBOURHOOD_COUNT, 4)
	TestUtil.isTrue(VisualQualityRules.isRecognizableObjectContract({
		silhouette = true,
		scale = true,
		material = true,
		feedback = true,
	}))
	TestUtil.isFalse(VisualQualityRules.isRecognizableObjectContract({
		silhouette = false,
		scale = true,
		material = true,
		feedback = true,
	}))
end
