local ReplicatedStorage = game:GetService("ReplicatedStorage")

local R8AssetLibrary = {}

local function root(): Instance
	return ReplicatedStorage:WaitForChild("TinyWorldAssets"):WaitForChild("R8")
end

function R8AssetLibrary.requirePrefab(category: string, name: string): Model
	local categoryFolder = root():FindFirstChild(category)
	if categoryFolder == nil then
		error("R8 required prefab missing: " .. category .. "/" .. name .. " (category missing)")
	end

	local prefab = categoryFolder:FindFirstChild(name)
	if prefab == nil or not prefab:IsA("Model") then
		error("R8 required prefab missing: " .. category .. "/" .. name)
	end

	return prefab
end

function R8AssetLibrary.clonePrefab(category: string, name: string): Model
	return R8AssetLibrary.requirePrefab(category, name):Clone()
end

return R8AssetLibrary
