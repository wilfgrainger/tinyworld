local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local MermaidQuestRules = require(shared:WaitForChild("MermaidQuestRules"))
local MermaidLandBuilder = require(script.Parent:WaitForChild("MermaidLandBuilder"))

local MermaidLandService = {}
MermaidLandService.__index = MermaidLandService

local QUEST_COPY = {
	PearlTrail = "Pearl Trail complete. You followed the reef lights home.",
	CoralGarden = "Coral Garden complete. The reef is bright again.",
	LostParcel = "Lost Parcel complete. A mermaid delivery found its owner.",
	MoonShells = "Moon Shells complete. The tide-song collection is restored.",
	WhirlpoolPromise = "Whirlpool Promise complete. Mermaid Land trusts you with its secret.",
}

function MermaidLandService.new(world, ProfileStore, PlayerStateService)
	local self = setmetatable({}, MermaidLandService)
	self.world = world
	self.ProfileStore = ProfileStore
	self.PlayerStateService = PlayerStateService
	self.land = MermaidLandBuilder.build(world)

	if self.land.whirlpoolPrompt then
		self.land.whirlpoolPrompt.Triggered:Connect(function(player)
			self:_enter(player)
		end)
	end
	for questId, prompt in self.land.questPrompts do
		if prompt then
			prompt.Triggered:Connect(function(player)
				self:_completeQuest(player, questId)
			end)
		end
	end
	if self.land.returnPrompt then
		self.land.returnPrompt.Triggered:Connect(function(player)
			self:_return(player)
		end)
	end
	return self
end

function MermaidLandService:_inOuterSea(player: Player): boolean
	local character = player.Character
	local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
	if root == nil or not root:IsA("BasePart") then
		return false
	end
	local distance = math.max(math.abs(root.Position.X), math.abs(root.Position.Z))
	return distance > self.world.boundary.swimDistance
end

function MermaidLandService:_enter(player: Player)
	local profile = self.ProfileStore.get(player)
	if profile == nil then
		return
	end
	local allowed, reason = MermaidQuestRules.canEnter(profile, self:_inOuterSea(player))
	if not allowed then
		local message = if reason == "boat_required" or reason == "boat_not_active"
			then "The hidden current only opens while you are exploring the outer sea in your Tiny Boat."
			else "The current slips away. Explore beyond the swimming water first."
		self.PlayerStateService.message(player, message)
		return
	end
	local character = player.Character
	if character then
		character:PivotTo(self.land.entryCFrame)
		profile.discoveredWorlds.MermaidLand = true
		self.PlayerStateService.sync(player, profile)
		self.PlayerStateService.message(player, "You found Mermaid Land. Five reef promises are waiting, and the whirlpool remains your secret.")
		self.ProfileStore.save(player)
	end
end

function MermaidLandService:_completeQuest(player: Player, questId: string)
	local profile = self.ProfileStore.get(player)
	if profile == nil or profile.discoveredWorlds.MermaidLand ~= true then
		return
	end
	local completed, reason = MermaidQuestRules.complete(profile, questId)
	if not completed then
		if reason == "already_complete" then
			self.PlayerStateService.message(player, "That mermaid promise is already complete.")
		end
		return
	end
	self.PlayerStateService.sync(player, profile)
	local count = MermaidQuestRules.completedCount(profile)
	local suffix = if count == 5 then " All five promises are complete." else string.format(" %d of 5 complete.", count)
	self.PlayerStateService.message(player, QUEST_COPY[questId] .. suffix)
	self.ProfileStore.save(player)
end

function MermaidLandService:_return(player: Player)
	local character = player.Character
	if character then
		character:PivotTo(self.land.returnCFrame)
		self.PlayerStateService.message(player, "Back on the TinyWorld shore. Mermaid Land stays hidden until you return by boat.")
	end
end

function MermaidLandService:stop()
	if self.land and self.land.folder then
		self.land.folder:Destroy()
	end
end

return MermaidLandService
