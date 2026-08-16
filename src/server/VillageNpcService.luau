local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local VillageNpcDefinitions = require(shared:WaitForChild("VillageNpcDefinitions"))
local ProductionMeshFactory = require(script.Parent:WaitForChild("ProductionMeshFactory"))

local VillageNpcService = {}
VillageNpcService.__index = VillageNpcService

local PALETTE = {
	colors = {
		skin = Color3.fromRGB(226, 181, 145),
		trader = Color3.fromRGB(170, 83, 95),
		gardener = Color3.fromRGB(80, 132, 82),
		fisherman = Color3.fromRGB(61, 109, 151),
		boatkeeper = Color3.fromRGB(93, 86, 151),
		builder = Color3.fromRGB(177, 118, 53),
		dark = Color3.fromRGB(47, 45, 52),
	},
}

local ROLE_COLORS = {
	Trader = "trader",
	Gardener = "gardener",
	Fisherman = "fisherman",
	BoatKeeper = "boatkeeper",
	Builder = "builder",
}

local DIALOGUE = {
	Trader = "Fresh village finds, fairly priced.",
	Gardener = "Healthy gardens start with a little patience.",
	Fisherman = "The coast has more secrets than it shows.",
	BoatKeeper = "The Tiny Boat is the safe way beyond the swimming water.",
	Builder = "Every great home starts small and earns its skyline.",
}

local function anchorCFrame(world, anchorName: string, index: number): CFrame
	local found = world.root:FindFirstChild(anchorName, true)
	if found and found:IsA("BasePart") then
		return found.CFrame * CFrame.new(0, 2.8, -5)
	end
	local angle = (index - 1) * (math.pi * 2 / 5)
	return CFrame.new(math.cos(angle) * 36, 3, math.sin(angle) * 36)
end

local function makeComponent(name, shape, size, position, color, role)
	return {
		name = name,
		shape = shape,
		size = size,
		position = position,
		color = color,
		material = "fabric",
		role = role,
	}
end

local function buildNpc(parent: Instance, definition, origin: CFrame, onTalk)
	local model = Instance.new("Model")
	model.Name = "Npc_" .. definition.id
	model:SetAttribute("TinyWorldNpcRole", definition.id)
	model:SetAttribute("TinyWorldVisualState", "authored-custom-mesh")
	model.Parent = parent

	local color = ROLE_COLORS[definition.id] or "trader"
	local torso = ProductionMeshFactory.createComponent(
		model,
		makeComponent("Torso", "beveledBox", { 3.2, 4.2, 2.0 }, { 0, 2.3, 0 }, color, "village-npc-torso"),
		origin,
		PALETTE
	)
	ProductionMeshFactory.createComponent(
		model,
		makeComponent("Head", "ellipsoid", { 2.3, 2.5, 2.2 }, { 0, 5.4, 0 }, "skin", "village-npc-head"),
		origin,
		PALETTE
	)
	ProductionMeshFactory.createComponent(
		model,
		makeComponent("Satchel", "beveledBox", { 1.5, 1.8, 0.65 }, { 1.75, 2.2, 0 }, "dark", "village-npc-prop"),
		origin,
		PALETTE
	)

	if torso then
		local prompt = Instance.new("ProximityPrompt")
		prompt.Name = "TalkPrompt"
		prompt.ActionText = "Talk"
		prompt.ObjectText = definition.displayName .. " • " .. definition.id
		prompt.MaxActivationDistance = 10
		prompt.RequiresLineOfSight = false
		prompt.Parent = torso
		prompt.Triggered:Connect(onTalk)
	end
	return model
end

function VillageNpcService.new(world, PlayerStateService)
	local self = setmetatable({}, VillageNpcService)
	self.world = world
	self.PlayerStateService = PlayerStateService
	self.folder = Instance.new("Folder")
	self.folder.Name = "TinyWorldVillageNPCs"
	self.folder.Parent = world.root
	for index, definition in VillageNpcDefinitions.all() do
		buildNpc(self.folder, definition, anchorCFrame(world, definition.anchor, index), function(player)
			self.PlayerStateService.message(player, definition.displayName .. ": " .. DIALOGUE[definition.id])
		end)
	end
	return self
end

function VillageNpcService:stop()
	self.folder:Destroy()
end

return VillageNpcService
