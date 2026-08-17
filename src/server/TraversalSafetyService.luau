local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local TraversalRules = require(shared:WaitForChild("TraversalRules"))

local TraversalSafetyService = {}
TraversalSafetyService.__index = TraversalSafetyService

local CHECK_INTERVAL = 0.2
local RECOVERY_Y = -20
local COASTAL_RECOVERY_BUFFER = 120
local OUTSIDE_COASTAL_BOUNDS_REASON = "outside_coastal_bounds"

function TraversalSafetyService.new(world, ProfileStore, PlayerStateService)
	local self = setmetatable({}, TraversalSafetyService)
	self.world = world
	self.ProfileStore = ProfileStore
	self.PlayerStateService = PlayerStateService
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

local function isInVillageTraversalSpace(player: Player): boolean
	local portalWorld = player:GetAttribute("TinyWorldPortalWorld")
	return type(portalWorld) ~= "string" or portalWorld == "" or portalWorld == "Village"
end

function TraversalSafetyService:_checkPlayers()
	for player in pairs(self.tracked) do
		local character = player.Character
		local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
		local profile = self.ProfileStore.get(player)
		if root and root:IsA("BasePart") and profile then
			if not isInVillageTraversalSpace(player) then
				continue
			end

			if root.Position.Y < RECOVERY_Y then
				self:_recover(player, self.world.boundary.worldRecoveryCFrame)
				continue
			end

			local distance = math.max(math.abs(root.Position.X), math.abs(root.Position.Z))
			if
				not TraversalRules.isWithinCoastalBounds(
					distance,
					self.world.boundary.shorelineDistance,
					self.world.coast.waterBelt
				)
			then
				local recoveryEdge = self.world.boundary.shorelineDistance
					+ self.world.coast.waterBelt
					+ COASTAL_RECOVERY_BUFFER
				if distance <= recoveryEdge then
					player:SetAttribute("TinyWorldLastTraversalRecovery", OUTSIDE_COASTAL_BOUNDS_REASON)
					self:_recover(player, self.world.boundary.safeShoreCFrame, "The sea gets too rough beyond TinyWorld.")
				end
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
