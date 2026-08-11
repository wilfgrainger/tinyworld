local ProductionAssetRegistry = {}

local assets = {}

ProductionAssetRegistry.specVersion = "art-r4-v1"

function ProductionAssetRegistry.get(role: string)
	return assets[role]
end

function ProductionAssetRegistry.all()
	return assets
end

return ProductionAssetRegistry
