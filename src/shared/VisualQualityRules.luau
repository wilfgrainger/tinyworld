local VisualQualityRules = {}

VisualQualityRules.MAX_RESIDENT_HOMES = 16
VisualQualityRules.TOAST_DURATION_SECONDS = 3
VisualQualityRules.NEIGHBOURHOOD_COUNT = 4

function VisualQualityRules.isRecognizableObjectContract(contract: any): boolean
	return type(contract) == "table"
		and contract.silhouette == true
		and contract.scale == true
		and contract.material == true
		and contract.feedback == true
end

return VisualQualityRules
