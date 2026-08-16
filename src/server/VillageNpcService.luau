local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local VillageNpcDefinitions = require(shared:WaitForChild("VillageNpcDefinitions"))
local VillageActivityLocations = require(script.Parent:WaitForChild("VillageActivityLocations"))
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

function VillageNpcService.new(world, PlayerStateService, VillageActivityService)
	local self = setmetatable({}, VillageNpcService)
	self.world = world
	self.PlayerStateService = PlayerStateService
	self.VillageActivityService = VillageActivityService
	self.folder = Instance.new("Folder")
	self.folder.Name = "TinyWorldVillageNPCs"
	self.folder.Parent = world.root

	for _, definition in VillageNpcDefinitions.all() do
		VillageNpcBuilder.build(
			self.folder,
			definition,
			VillageActivityLocations.npc(world, definition.id),
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
