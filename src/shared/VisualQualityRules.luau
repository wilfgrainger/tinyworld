local VisualQualityRules = {}

VisualQualityRules.MAX_RESIDENT_HOMES = 16
VisualQualityRules.TOAST_DURATION_SECONDS = 3
VisualQualityRules.NEIGHBOURHOOD_COUNT = 4
VisualQualityRules.MAX_ORDINARY_BILLBOARD_WIDTH = 0
VisualQualityRules.ALLOW_PRIMITIVE_CHARACTER_FALLBACK = false
VisualQualityRules.HERO_VISUAL_EVIDENCE_REQUIRED = true

function VisualQualityRules.isRecognizableObjectContract(contract: any): boolean
	return type(contract) == "table"
		and contract.silhouette == true
		and contract.scale == true
		and contract.material == true
		and contract.feedback == true
end

return VisualQualityRules
