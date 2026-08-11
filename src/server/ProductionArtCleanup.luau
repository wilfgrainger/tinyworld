local ArchitecturalDetailBuilder = require(script.Parent:WaitForChild("ArchitecturalDetailBuilder"))

local ProductionArtCleanup = {}

local function looksLikePracticalLamp(part: BasePart): boolean
	if part.Material ~= Enum.Material.Neon or part.Shape ~= Enum.PartType.Ball then
		return false
	end
	local lowerName = string.lower(part.Name)
	local role = string.lower(tostring(part:GetAttribute("TinyWorldArtRole") or ""))
	return string.find(lowerName, "lamp", 1, true) ~= nil
		or string.find(lowerName, "lantern", 1, true) ~= nil
		or string.find(role, "lamp", 1, true) ~= nil
		or string.find(role, "lantern", 1, true) ~= nil
end

local function removePrimitiveAmbientCharacters(root: Instance)
	local toDestroy = {}
	for _, descendant in root:GetDescendants() do
		if descendant:IsA("Model") then
			local name = descendant.Name
			if string.find(name, "BirdAmbient", 1, true) or string.find(name, "ButterflyAmbient", 1, true) then
				table.insert(toDestroy, descendant)
			end
		end
	end
	for _, item in toDestroy do
		if item.Parent then
			item:Destroy()
		end
	end
end

local function replaceLegacyPracticalLights(root: Instance)
	local legacy = {}
	for _, descendant in root:GetDescendants() do
		if descendant:IsA("BasePart") and looksLikePracticalLamp(descendant) then
			table.insert(legacy, descendant)
		end
	end
	for index, bulb in legacy do
		if bulb.Parent then
			local parent = bulb.Parent
			ArchitecturalDetailBuilder.addLantern(parent, {
				name = "CraftedPracticalLantern" .. index,
				role = "replacement-practical-lantern",
				cframe = bulb.CFrame,
				brightness = 0.42,
				range = 8,
			})
			bulb:Destroy()
		end
	end
end

local function hideSpawnPad(root: Instance)
	local spawn = root:FindFirstChild("VillageSpawn")
	if spawn and spawn:IsA("SpawnLocation") then
		spawn.Transparency = 1
		spawn.CanCollide = false
		spawn.CanTouch = true
		spawn.CastShadow = false
		spawn:SetAttribute("TinyWorldArtRole", "invisible-spawn-anchor")
	end
end

function ProductionArtCleanup.apply(root: Instance)
	hideSpawnPad(root)
	removePrimitiveAmbientCharacters(root)
	replaceLegacyPracticalLights(root)
end

return ProductionArtCleanup
