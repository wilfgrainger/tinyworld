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
	local spawn = root:FindFirstChild("VillageSpawn", true)
	if not spawn or not spawn:IsA("SpawnLocation") then
		return
	end

	spawn.Transparency = 1
	spawn.CanCollide = false
	spawn.CanTouch = false
	spawn.CastShadow = false
	spawn.Duration = 0
	spawn.AllowTeamChangeOnTouch = false
	spawn:SetAttribute("TinyWorldArtRole", "invisible-spawn-anchor")
	spawn:SetAttribute("TinyWorldVisualState", "hidden-runtime-anchor")

	-- SpawnLocation can carry a visible top-face texture/decal independently of the base Part.
	-- Hide any present or future child presentation so Studio screenshots never show a dev spawn starburst.
	for _, descendant in spawn:GetDescendants() do
		if descendant:IsA("Decal") or descendant:IsA("Texture") then
			descendant.Transparency = 1
		end
	end
end

function ProductionArtCleanup.apply(root: Instance)
	hideSpawnPad(root)
	removePrimitiveAmbientCharacters(root)
	replaceLegacyPracticalLights(root)
end

return ProductionArtCleanup
