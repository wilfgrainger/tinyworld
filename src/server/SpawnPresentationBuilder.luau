local SpawnPresentationBuilder = {}

function SpawnPresentationBuilder.apply(root: Instance)
	local spawn = root:FindFirstChild("VillageSpawn")
	if not spawn or not spawn:IsA("SpawnLocation") then
		return
	end

	spawn.Position = Vector3.new(spawn.Position.X, -3, spawn.Position.Z)
	spawn.Size = Vector3.new(6, 1, 6)
	spawn.Transparency = 1
	spawn.CanCollide = false
	spawn.CanTouch = false
	spawn.CastShadow = false
	spawn:SetAttribute("TinyWorldSpawnPresentation", "buried-r3")
	spawn:SetAttribute("TinyWorldArtRole", "invisible-spawn-anchor")

	for _, descendant in spawn:GetDescendants() do
		if descendant:IsA("Decal") or descendant:IsA("Texture") then
			descendant.Transparency = 1
		end
	end
end

return SpawnPresentationBuilder
