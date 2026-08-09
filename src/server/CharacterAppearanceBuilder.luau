local CharacterAppearanceBuilder = {}

local HAIR_COLORS = {
	Color3.fromRGB(67, 46, 35),
	Color3.fromRGB(111, 73, 43),
	Color3.fromRGB(42, 42, 47),
	Color3.fromRGB(183, 130, 68),
	Color3.fromRGB(125, 70, 65),
	Color3.fromRGB(88, 64, 102),
}

local SHOE_COLORS = {
	Color3.fromRGB(64, 72, 82),
	Color3.fromRGB(102, 68, 47),
	Color3.fromRGB(57, 89, 106),
	Color3.fromRGB(111, 62, 75),
}

local function stableIndex(text: string, count: number): number
	local sum = 0
	for index = 1, #text do
		sum += string.byte(text, index)
	end
	return (sum % count) + 1
end

local function weldedPart(
	parent: Instance,
	target: BasePart,
	name: string,
	size: Vector3,
	offset: CFrame,
	color: Color3
): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = target.CFrame * offset
	part.Color = color
	part.Material = Enum.Material.SmoothPlastic
	part.Anchored = false
	part.Massless = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part:SetAttribute("TinyWorldArtRole", "character-expression-fallback")
	part.Parent = parent

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = target
	weld.Part1 = part
	weld.Parent = part
	return part
end

local function buildHair(character: Model, hairId: string)
	local head = character:FindFirstChild("Head")
	if head == nil or not head:IsA("BasePart") then
		return
	end

	local style = stableIndex(hairId, 5)
	local color = HAIR_COLORS[stableIndex(hairId, #HAIR_COLORS)]
	local folder = Instance.new("Model")
	folder.Name = "TinyWorldHairFallback"
	folder:SetAttribute("TinyWorldHairStyle", hairId)
	folder.Parent = character

	weldedPart(folder, head, "HairCap", Vector3.new(1.9, 0.55, 1.8), CFrame.new(0, 0.72, 0), color)
	if style == 1 then
		weldedPart(
			folder,
			head,
			"SideSweep",
			Vector3.new(1.25, 0.42, 0.55),
			CFrame.new(0.32, 0.68, -0.72) * CFrame.Angles(0, 0, math.rad(-14)),
			color
		)
	elseif style == 2 then
		weldedPart(
			folder,
			head,
			"FringeLeft",
			Vector3.new(0.55, 0.7, 0.45),
			CFrame.new(-0.45, 0.55, -0.78) * CFrame.Angles(math.rad(12), 0, math.rad(12)),
			color
		)
		weldedPart(
			folder,
			head,
			"FringeRight",
			Vector3.new(0.55, 0.7, 0.45),
			CFrame.new(0.38, 0.55, -0.78) * CFrame.Angles(math.rad(-8), 0, math.rad(-10)),
			color
		)
	elseif style == 3 then
		weldedPart(folder, head, "PuffLeft", Vector3.new(0.75, 0.75, 0.75), CFrame.new(-0.82, 0.58, 0), color)
		weldedPart(folder, head, "PuffRight", Vector3.new(0.75, 0.75, 0.75), CFrame.new(0.82, 0.58, 0), color)
	elseif style == 4 then
		weldedPart(folder, head, "LongBack", Vector3.new(1.7, 1.75, 0.45), CFrame.new(0, 0.05, 0.84), color)
	else
		weldedPart(
			folder,
			head,
			"Tuft",
			Vector3.new(0.75, 0.95, 0.65),
			CFrame.new(0.18, 1.02, -0.08) * CFrame.Angles(0, 0, math.rad(-18)),
			color
		)
	end
end

local function legPart(character: Model, side: string): BasePart?
	local candidates = if side == "Left"
		then { "LeftFoot", "LeftLowerLeg", "Left Leg" }
		else { "RightFoot", "RightLowerLeg", "Right Leg" }
	for _, name in candidates do
		local part = character:FindFirstChild(name)
		if part and part:IsA("BasePart") then
			return part
		end
	end
	return nil
end

local function buildShoes(character: Model, outfitId: string)
	local color = SHOE_COLORS[stableIndex(outfitId, #SHOE_COLORS)]
	local folder = Instance.new("Model")
	folder.Name = "TinyWorldShoesFallback"
	folder:SetAttribute("TinyWorldOutfitStyle", outfitId)
	folder.Parent = character

	for _, side in { "Left", "Right" } do
		local target = legPart(character, side)
		if target then
			local height = math.clamp(target.Size.Y * 0.3, 0.35, 0.75)
			local yOffset = -(target.Size.Y / 2) + height / 2
			weldedPart(
				folder,
				target,
				side .. "Shoe",
				Vector3.new(target.Size.X + 0.12, height, target.Size.Z + 0.22),
				CFrame.new(0, yOffset, -0.06),
				color
			)
		end
	end
end

function CharacterAppearanceBuilder.apply(character: Model, hairId: string, outfitId: string)
	local oldHair = character:FindFirstChild("TinyWorldHairFallback")
	if oldHair then
		oldHair:Destroy()
	end
	local oldShoes = character:FindFirstChild("TinyWorldShoesFallback")
	if oldShoes then
		oldShoes:Destroy()
	end
	buildHair(character, hairId)
	buildShoes(character, outfitId)
end

return CharacterAppearanceBuilder
