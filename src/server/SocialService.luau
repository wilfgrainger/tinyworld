local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local SocialRules = require(shared:WaitForChild("SocialRules"))

local SocialService = {}
SocialService.__index = SocialService

local function displayName(player: Player): string
	return player:GetAttribute("TinyWorldDisplayName") or player.DisplayName or player.Name
end

function SocialService.new(world, ProfileStore, PlayerStateService)
	local self = setmetatable({}, SocialService)
	self.world = world
	self.ProfileStore = ProfileStore
	self.PlayerStateService = PlayerStateService
	self.members = {}
	self.leader = nil
	self.sharedActivityCount = 0

	world.social.joinPrompt.Triggered:Connect(function(player)
		self:_join(player)
	end)
	world.social.leavePrompt.Triggered:Connect(function(player)
		self:_leave(player)
	end)
	self:_updateBoard()
	return self
end

function SocialService:_syncPlayer(player: Player)
	if player.Parent == nil then
		return
	end
	player:SetAttribute("TinyWorldPartyMember", self.members[player] == true)
	player:SetAttribute("TinyWorldPartySize", SocialRules.partySize(self.members))
	player:SetAttribute("TinyWorldPartyLeader", self.leader == player)
	player:SetAttribute("TinyWorldSharedActivityCount", self.sharedActivityCount)
	if player:GetAttribute("TinyWorldVisitingHome") == nil then
		player:SetAttribute("TinyWorldVisitingHome", "")
	end
end

function SocialService:_syncAll()
	for _, player in Players:GetPlayers() do
		self:_syncPlayer(player)
	end
end

function SocialService:_updateBoard()
	local size = SocialRules.partySize(self.members)
	local leaderText = if self.leader then displayName(self.leader) else "waiting for a leader"
	self.world.social.joinPrompt.ActionText = if size >= SocialRules.MAX_PARTY_SIZE then "Party Full" else "Join Village Walk"
	self.world.social.leavePrompt.ActionText = if size > 0 then "Leave Village Walk" else "No Party to Leave"
	self.world.social.statusLabel.Text = string.format("VILLAGE MEETUP\nVillage Walk %d/%d\nLeader: %s\nShared activities: %d", size, SocialRules.MAX_PARTY_SIZE, leaderText, self.sharedActivityCount)
end

function SocialService:setupPlayer(player: Player)
	self:_syncPlayer(player)
	self:_updateBoard()
end

function SocialService:_join(player: Player)
	if self.ProfileStore.get(player) == nil then
		return
	end
	local joined, reason = SocialRules.joinParty(self.members, player)
	if not joined then
		self.PlayerStateService.message(player, if reason == "already_member" then "You are already in the Village Walk party. Use Leave Village Walk to step out." else "The Village Walk party is full (4 players).")
		return
	end
	if self.leader == nil then
		self.leader = player
	end
	self:_syncAll()
	self:_updateBoard()
	self.PlayerStateService.message(player, string.format("Joined the Village Walk party: %d/%d. Visit a home or trade together for a shared activity.", SocialRules.partySize(self.members), SocialRules.MAX_PARTY_SIZE))
end

function SocialService:_leave(player: Player)
	local left, _reason = SocialRules.leaveParty(self.members, player)
	if not left then
		self.PlayerStateService.message(player, "You are not in the Village Walk party.")
		return
	end
	if self.leader == player then
		self.leader = nil
		for member, active in self.members do
			if active then
				self.leader = member
				break
			end
		end
	end
	if SocialRules.partySize(self.members) == 0 then
		self.sharedActivityCount = 0
	end
	self:_syncAll()
	self:_updateBoard()
	self.PlayerStateService.message(player, "You left the Village Walk party.")
end

function SocialService:recordVisit(visitor: Player, owner: Player, _plotIndex: number)
	if visitor == owner then
		return
	end
	visitor:SetAttribute("TinyWorldVisitingHome", displayName(owner))
	if SocialRules.canShareActivity(self.members, visitor) and self.members[owner] == true then
		self.sharedActivityCount += 1
		self:_syncAll()
		self:_updateBoard()
		local message = string.format("Shared activity %d: you visited %s's home with the Village Walk party.", self.sharedActivityCount, displayName(owner))
		self.PlayerStateService.message(visitor, message)
		self.PlayerStateService.message(owner, message)
	end
end

function SocialService:recordTrade(first: Player, second: Player)
	if self.members[first] ~= true or self.members[second] ~= true then
		return
	end
	self.sharedActivityCount += 1
	self:_syncAll()
	self:_updateBoard()
	local message = string.format("Shared activity %d: your party completed a safe trade.", self.sharedActivityCount)
	self.PlayerStateService.message(first, message)
	self.PlayerStateService.message(second, message)
end

function SocialService:removePlayer(player: Player)
	if self.members[player] then
		self:_leave(player)
	end
	player:SetAttribute("TinyWorldPartyMember", false)
	player:SetAttribute("TinyWorldPartySize", SocialRules.partySize(self.members))
	player:SetAttribute("TinyWorldPartyLeader", false)
	player:SetAttribute("TinyWorldSharedActivityCount", self.sharedActivityCount)
end

return SocialService
