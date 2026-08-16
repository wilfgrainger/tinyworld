local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local VillageNpcDefinitions = require(shared:WaitForChild("VillageNpcDefinitions"))
local VillageNpcBuilder = require(script.Parent:WaitForChild("VillageNpcBuilder"))

local VillageNpcService = {}
VillageNpcService.__index = VillageNpcService

local ACTION_TEXT = {
	Trader = "See village request",
	Gardener = "Start garden round",
	Fisherman = "Go fishing",
	BoatKeeper = "Take coastal delivery",
	Builder = "Take repair job",
}

local function anchorCFrame(world, anchorName: string, index: number): CFrame
	local found = world.root:FindFirstChild(anchorName, true)
	if found and found:IsA("BasePart") then
		return found.CFrame * CFrame.new(0, 2.8, -5)
	end
	local angle = (index - 1) * (math.pi * 2 / 5)
	return CFrame.new(math.cos(angle) * 36, 3, math.sin(angle) * 36)
end

function VillageNpcService.new(world, PlayerStateService, VillageActivityService)
	local self = setmetatable({}, VillageNpcService)
	self.world = world
	self.PlayerStateService = PlayerStateService
	self.VillageActivityService = VillageActivityService
	self.folder = Instance.new("Folder")
	self.folder.Name = "TinyWorldVillageNPCs"
	self.folder.Parent = world.root

	for index, definition in VillageNpcDefinitions.all() do
		VillageNpcBuilder.build(
			self.folder,
			definition,
			anchorCFrame(world, definition.anchor, index),
			ACTION_TEXT[definition.id] or "Talk",
			function(player)
				self.VillageActivityService:startForRole(player, definition.id)
			end
		)
	end
	return self
end

function VillageNpcService:stop()
	self.folder:Destroy()
end

return VillageNpcService
