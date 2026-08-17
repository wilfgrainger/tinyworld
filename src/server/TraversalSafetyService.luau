local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local TraversalRules = require(shared:WaitForChild("TraversalRules"))
local TraversalSafetyRules = require(shared:WaitForChild("TraversalSafetyRules"))

local TraversalSafetyService = {}
TraversalSafetyService.__index = TraversalSafetyService

local CHECK_INTERVAL = 0.2
local OUTSIDE_COASTAL_BOUNDS_REASON = "outside_coastal_bounds"
local UNDER_WORLD_REASON = "under_world"

function TraversalSafetyService.new(world, ProfileStore, PlayerStateService, hasValidPortalSession)
	local self = setmetatable({}, TraversalSafetyService)
	self.world = world
	self.ProfileStore = ProfileStore
	self.PlayerStateService = PlayerStateService
	self.hasValidPortalSession = hasValidPortalSession or function(_player)
		return false
	end
	self.tracked = {}
	self.accumulator = 0
	self.connection = RunService.Heartbeat:Connect(function(dt)
		self.accumulator += dt
		if self.accumulator < CHECK_INTERVAL then
			return
		end
		self.accumulator = 0
		self:_checkPlayers()
	end)
	return self
end

function TraversalSafetyService:trackPlayer(player: Player)
	self.tracked[player] = true
end

function TraversalSafetyService:removePlayer(player: Player)
	self.tracked[player] = nil
end

function TraversalSafetyService:_recover(player: Player, target: CFrame, message: string?)
	local character = player.Character
	if character then
		character:PivotTo(target)
	end
	if message then
		self.PlayerStateService.message(player, message)
	end
end

function TraversalSafetyService:_checkPlayers()
	for player in pairs(self.tracked) do
		local character = player.Character
		local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
		local profile = self.ProfileStore.get(player)
		if root and root:IsA("BasePart") and profile then
			local distance = math.max(math.abs(root.Position.X), math.abs(root.Position.Z))
			local action = TraversalSafetyRules.decide({
				distance = distance,
				y = root.Position.Y,
				shorelineDistance = self.world.boundary.shorelineDistance,
				waterBelt = self.world.coast.waterBelt,
				portalWorld = player:GetAttribute("TinyWorldPortalWorld"),
				hasValidPortalSession = self.hasValidPortalSession(player) == true,
			})

			if action == TraversalSafetyRules.Action.PortalExempt then
				continue
			elseif action == TraversalSafetyRules.Action.RecoverWorld then
				player:SetAttribute("TinyWorldLastTraversalRecovery", UNDER_WORLD_REASON)
				self:_recover(player, self.world.boundary.worldRecoveryCFrame)
				continue
			elseif action == TraversalSafetyRules.Action.RecoverShore then
				player:SetAttribute("TinyWorldLastTraversalRecovery", OUTSIDE_COASTAL_BOUNDS_REASON)
				self:_recover(player, self.world.boundary.safeShoreCFrame, "The sea gets too rough beyond TinyWorld.")
				continue
			end

			local zone = TraversalRules.classifyDistanceFromVillage(
				distance,
				self.world.boundary.shorelineDistance,
				self.world.boundary.swimDistance
			)
			local allowed, reason = TraversalRules.canOccupyZone(profile, zone)
			if not allowed and reason == "tiny_boat_required" then
				self:_recover(player, self.world.boundary.safeShoreCFrame, "The outer sea needs your Tiny Boat.")
			end
		end
	end
end

function TraversalSafetyService:stop()
	if self.connection then
		self.connection:Disconnect()
		self.connection = nil
	end
	table.clear(self.tracked)
end

return TraversalSafetyService
