local ProductionMeshFactory = require(script.Parent:WaitForChild("ProductionMeshFactory"))

local MermaidLandBuilder = {}

local PALETTE = {
	colors = {
		aqua = Color3.fromRGB(75, 207, 196),
		deepAqua = Color3.fromRGB(44, 132, 153),
		pearl = Color3.fromRGB(244, 231, 222),
		coral = Color3.fromRGB(238, 118, 127),
		sand = Color3.fromRGB(228, 199, 151),
		purple = Color3.fromRGB(147, 104, 181),
		skin = Color3.fromRGB(226, 181, 145),
	},
}

local function spec(name, shape, size, position, color, material, role, extra)
	local value = {
		name = name,
		shape = shape,
		size = size,
		position = position,
		color = color,
		material = material,
		role = role,
	}
	if extra then
		for key, child in extra do
			value[key] = child
		end
	end
	return value
end

local function promptOn(part: BasePart?, name: string, actionText: string, objectText: string)
	if part == nil then
		return nil
	end
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = name
	prompt.ActionText = actionText
	prompt.ObjectText = objectText
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = part
	return prompt
end

local function buildMermaid(parent: Instance, origin: CFrame, index: number)
	local model = Instance.new("Model")
	model.Name = "Mermaid_" .. tostring(index)
	model:SetAttribute("TinyWorldNpcRole", "Mermaid")
	model:SetAttribute("TinyWorldVisualState", "authored-custom-mesh")
	model.Parent = parent
	ProductionMeshFactory.createComponent(
		model,
		spec(
			"Tail",
			"frustum",
			{ 2.5, 4.8, 2.5 },
			{ 0, 2.4, 0 },
			if index % 2 == 0 then "purple" else "aqua",
			"fabric",
			"mermaid-tail",
			{ topScale = 0.55 }
		),
		origin,
		PALETTE
	)
	ProductionMeshFactory.createComponent(
		model,
		spec("Torso", "beveledBox", { 2.6, 2.8, 1.6 }, { 0, 5.8, 0 }, "pearl", "fabric", "mermaid-torso"),
		origin,
		PALETTE
	)
	ProductionMeshFactory.createComponent(
		model,
		spec("Head", "ellipsoid", { 2.1, 2.3, 2.0 }, { 0, 8.0, 0 }, "skin", "fabric", "mermaid-head"),
		origin,
		PALETTE
	)
end

function MermaidLandBuilder.build(world)
	local folder = Instance.new("Folder")
	folder.Name = "MermaidLand"
	folder.Parent = world.root

	local entryCFrame = CFrame.new(0, 10, 1400)
	local returnCFrame = world.boundary.safeShoreCFrame or CFrame.new(0, 6, 80)
	local whirlpoolDistance = (world.coast and world.coast.swimDistance or 120) + 55
	local whirlpoolOrigin = CFrame.new(0, 1, whirlpoolDistance)

	local whirlpoolModel = Instance.new("Model")
	whirlpoolModel.Name = "HiddenWhirlpool"
	whirlpoolModel.Parent = folder
	local whirlpool = ProductionMeshFactory.createComponent(
		whirlpoolModel,
		spec(
			"Whirlpool",
			"cylinder",
			{ 18, 0.7, 18 },
			{ 0, 0, 0 },
			"deepAqua",
			"water",
			"hidden-whirlpool",
			{ segments = 24, transparency = 0.28 }
		),
		whirlpoolOrigin,
		PALETTE
	)
	local whirlpoolPrompt = promptOn(whirlpool, "WhirlpoolPrompt", "Investigate", "A strange current")

	local island = Instance.new("Model")
	island.Name = "MermaidIsland"
	island.Parent = folder
	ProductionMeshFactory.createComponent(
		island,
		spec(
			"Island",
			"ellipsoid",
			{ 100, 10, 80 },
			{ 0, -3, 0 },
			"sand",
			"ground",
			"mermaid-land-island",
			{ segments = 20, rings = 8 }
		),
		entryCFrame,
		PALETTE
	)
	ProductionMeshFactory.createComponent(
		island,
		spec(
			"CoralArch",
			"archSegment",
			{ 18, 18, 4 },
			{ 0, 8, -22 },
			"coral",
			"stone",
			"mermaid-land-arch",
			{ segments = 16, thickness = 2.2 }
		),
		entryCFrame,
		PALETTE
	)

	for index, offset in { -14, 0, 14 } do
		buildMermaid(island, entryCFrame * CFrame.new(offset, 0, -8), index)
	end

	local questIds = { "PearlTrail", "CoralGarden", "LostParcel", "MoonShells", "WhirlpoolPromise" }
	local questPrompts = {}
	for index, questId in questIds do
		local angle = (index - 1) * (math.pi * 2 / #questIds)
		local pedestal = ProductionMeshFactory.createComponent(
			island,
			spec(
				"Quest_" .. questId,
				"beveledBox",
				{ 4, 2.2, 4 },
				{ math.cos(angle) * 25, 1.2, math.sin(angle) * 20 },
				"pearl",
				"stone",
				"mermaid-quest-pedestal"
			),
			entryCFrame,
			PALETTE
		)
		questPrompts[questId] = promptOn(pedestal, "QuestPrompt_" .. questId, "Help", questId)
	end

	local returnPart = ProductionMeshFactory.createComponent(
		island,
		spec("ReturnShell", "ellipsoid", { 6, 3, 6 }, { 0, 1.6, 26 }, "aqua", "marble", "mermaid-return-shell"),
		entryCFrame,
		PALETTE
	)
	local returnPrompt = promptOn(returnPart, "ReturnPrompt", "Return", "Back to TinyWorld")

	return {
		folder = folder,
		entryCFrame = entryCFrame * CFrame.new(0, 4, 0),
		returnCFrame = returnCFrame,
		whirlpoolPrompt = whirlpoolPrompt,
		questPrompts = questPrompts,
		returnPrompt = returnPrompt,
		whirlpoolPosition = whirlpoolOrigin.Position,
	}
end

return MermaidLandBuilder
