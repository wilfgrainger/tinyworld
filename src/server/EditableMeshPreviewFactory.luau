local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local ProductionArtSpec = require(shared:WaitForChild("ProductionArtSpec"))
local ProductionMeshFactory = require(script.Parent:WaitForChild("ProductionMeshFactory"))

local EditableMeshPreviewFactory = {}

function EditableMeshPreviewFactory.build(role: string, parent: Instance, pivot: CFrame): Model?
	local asset = ProductionArtSpec.get(role)
	if asset == nil then
		warn("[TinyWorld ART R4] no product-art spec for role", role)
		return nil
	end

	local model = Instance.new("Model")
	model.Name = asset.displayName or ("TinyWorld_" .. role)
	model:SetAttribute("TinyWorldArtRole", role)
	model:SetAttribute("TinyWorldVisualState", "production-preview-r4")
	model:SetAttribute("TinyWorldProductionArtDegraded", false)
	model:SetAttribute("TinyWorldProductionSpecVersion", ProductionArtSpec.specVersion)
	model.Parent = parent

	local built = 0
	for _, component in asset.components do
		local meshPart = ProductionMeshFactory.createComponent(model, component, pivot, ProductionArtSpec.palette)
		if meshPart then
			built += 1
		end
	end

	if built == 0 then
		model:Destroy()
		warn("[TinyWorld ART R4] product-art preview produced no MeshParts for", role)
		return nil
	end

	model:SetAttribute("TinyWorldProductionMeshCount", built)
	return model
end

return EditableMeshPreviewFactory
