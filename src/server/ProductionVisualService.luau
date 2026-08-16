local AssetService = game:GetService("AssetService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local ProductionAssetRegistry = require(shared:WaitForChild("ProductionAssetRegistry"))
local EditableMeshPreviewFactory = require(script.Parent:WaitForChild("EditableMeshPreviewFactory"))

local ProductionVisualService = {}
ProductionVisualService.__index = ProductionVisualService

local function stripExecutableContent(root: Instance)
	for _, descendant in root:GetDescendants() do
		if descendant:IsA("LuaSourceContainer") then
			descendant:Destroy()
		end
	end
end

local function prepareVisualModel(model: Model, role: string)
	stripExecutableContent(model)
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
			descendant:SetAttribute("TinyWorldProductionMesh", true)
		end
	end
	model:SetAttribute("TinyWorldArtRole", role)
	model:SetAttribute("TinyWorldVisualState", "approved-production")
	model:SetAttribute("TinyWorldProductionArtDegraded", false)
end

local function hasVisiblePresentation(root: Instance): boolean
	for _, descendant in root:GetDescendants() do
		if descendant:IsA("BasePart") and descendant.Transparency < 1 then
			return true
		end
	end
	return false
end

function ProductionVisualService.new()
	local self = setmetatable({}, ProductionVisualService)
	self.templates = {}
	self.failures = {}
	return self
end

function ProductionVisualService:_canUseStudioPreview(): boolean
	return RunService:IsStudio()
end

function ProductionVisualService:_loadTemplate(role: string): Model?
	if self.templates[role] then
		return self.templates[role]
	end
	if self.failures[role] then
		return nil
	end

	local record = ProductionAssetRegistry.get(role)
	if record == nil or not record.devApproved then
		return nil
	end

	local loaded = nil
	local ok, errorMessage = pcall(function()
		loaded = AssetService:LoadAssetAsync(record.robloxAssetId)
	end)
	if not ok or loaded == nil or not loaded:IsA("Model") then
		self.failures[role] = true
		warn("[TinyWorld ART R5] failed to load approved production asset", role, errorMessage)
		return nil
	end

	prepareVisualModel(loaded, role)
	loaded.Name = "ART_R5_Template_" .. role
	loaded.Parent = nil
	self.templates[role] = loaded
	return loaded
end

function ProductionVisualService:mount(role: string, parent: Instance, pivot: CFrame): Model?
	local container = Instance.new("Model")
	container.Name = "ART_R4_VisualRoot"
	container:SetAttribute("TinyWorldArtRole", role)
	container:SetAttribute("TinyWorldProductionSpecVersion", ProductionAssetRegistry.specVersion)

	local template = self:_loadTemplate(role)
	if template then
		local clone = template:Clone()
		clone.Name = "ProductionAsset"
		clone.Parent = container
		clone:PivotTo(pivot)
		container:SetAttribute("TinyWorldVisualState", "approved-production")
		container:SetAttribute("TinyWorldProductionArtDegraded", false)
	elseif self:_canUseStudioPreview() then
		local preview = EditableMeshPreviewFactory.build(role, container, pivot)
		if preview then
			container:SetAttribute("TinyWorldVisualState", "studio-preview-r5")
			container:SetAttribute("TinyWorldProductionArtDegraded", false)
		end
	end

	if not hasVisiblePresentation(container) then
		container:Destroy()
		warn("[TinyWorld ART R5] no safe replacement available for role", role)
		return nil
	end

	local existing = parent:FindFirstChild("ART_R4_VisualRoot")
	if existing then
		existing:Destroy()
	end
	container.Parent = parent
	return container
end

return ProductionVisualService
