local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local TraversalRules = require(shared:WaitForChild("TraversalRules"))
local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))
local BoatBuilder = require(script.Parent:WaitForChild("BoatBuilder"))
local GameplayAccessService = require(script.Parent:WaitForChild("GameplayAccessService"))

local BoatService = {}
BoatService.__index = BoatService

local function teleport(player: Player, target: CFrame)
	local character = player.Character
	if character then
		character:PivotTo(target)
	end
end

function BoatService.new(world, ProfileStore, PlayerStateService)
	local self = setmetatable({}, BoatService)
	self.world = world
	self.ProfileStore = ProfileStore
	self.PlayerStateService = PlayerStateService
	self.boats = {}
	self.characterConnections = {}
	self.sessionPrepared = {}
	self.boatSlots = {}
	self.nextBoatSlot = 0
	self.boatFolder = Instance.new("Folder")
	self.boatFolder.Name = "TinyWorldBoats"
	self.boatFolder.Parent = world.boundary.model
	world.boundary.boatShopPrompt.Triggered:Connect(function(player)
		self:_useShop(player)
	end)
	return self
end

function BoatService:_dockOrigin(player: Player): CFrame
	local slot = self.boatSlots[player]
	if slot == nil then
		self.nextBoatSlot += 1
		slot = self.nextBoatSlot
		self.boatSlots[player] = slot
	end
	return self.world.boundary.boatDockCFrame * CFrame.new(0, 0, (slot - 1) * 9)
end

function BoatService:_destroyBoat(player: Player)
	local boat = self.boats[player]
	if boat == nil then
		return
	end
	for _, connection in boat.connections do
		connection:Disconnect()
	end
	boat.model:Destroy()
	self.boats[player] = nil
end

function BoatService:_ensureBoat(player: Player)
	local existing = self.boats[player]
	if existing then
		return existing
	end
	local boat = BoatBuilder.build(
		self.boatFolder,
		"TinyBoat_" .. tostring(player.UserId),
		self:_dockOrigin(player),
		VisualTheme.Colors.skyDeep
	)
	boat.model:SetAttribute("TinyWorldBoatOwnerUserId", player.UserId)
	boat.connections = {
		boat.mountPrompt.Triggered:Connect(function(triggeringPlayer)
			if triggeringPlayer == player then
				self:_mount(player)
			end
		end),
		boat.returnPrompt.Triggered:Connect(function(triggeringPlayer)
			if triggeringPlayer == player then
				self:_return(player)
			end
		end),
	}
	self.boats[player] = boat
	self:_captureFlagBaseline(player)
	return boat
end

function BoatService:_setPromptState(player: Player, active: boolean)
	local boat = self.boats[player]
	if boat == nil then
		return
	end
	boat.mountPrompt.Enabled = not active
	boat.returnPrompt.Enabled = active
end

function BoatService:_restorePlayerState(player: Player)
	local character = player.Character
	local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
	if humanoid == nil then
		return
	end
	humanoid.Sit = false
	if humanoid.Health > 0 and humanoid:GetState() == Enum.HumanoidStateType.Seated then
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end

function BoatService:_seatPlayer(player: Player, seat: Seat): boolean
	local character = player.Character
	local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
	if humanoid == nil or humanoid.Health <= 0 or seat.Parent == nil then
		return false
	end
	humanoid.Sit = false
	local seated = pcall(function()
		seat:Sit(humanoid)
	end)
	return seated
end

function BoatService:_captureFlagBaseline(player: Player)
	local boat = self.boats[player]
	if boat == nil then
		return
	end
	local flag = boat.model:FindFirstChild("BoatFlag", true)
	if flag and flag:IsA("BasePart") then
		if boat.flagBaseLocalCFrame ~= nil then
			return
		end
		boat.flagBaseLocalCFrame = boat.model:GetPivot():ToObjectSpace(flag.CFrame)
	end
end

function BoatService:_setMotionState(player: Player, state: string)
	local boat = self.boats[player]
	if boat == nil then
		return
	end
	boat.model:SetAttribute("TinyWorldMotionState", state)
	boat.model:SetAttribute("TinyWorldMotionPhase", if state == "sailing" then os.clock() else 0)
	local wake = boat.model:FindFirstChild("BoatWaterWake", true)
	if wake and wake:IsA("BasePart") then
		wake.Transparency = if state == "sailing" then 0.35 else 1
	end
	local flag = boat.model:FindFirstChild("BoatFlag", true)
	if flag and flag:IsA("BasePart") then
		self:_captureFlagBaseline(player)
		local flutter = if state == "sailing" then CFrame.Angles(0, 0, math.rad(-8)) else CFrame.identity
		flag.CFrame = boat.model:GetPivot() * boat.flagBaseLocalCFrame * flutter
	end
end

function BoatService:apply(player: Player, profile)
	local firstApply = self.sessionPrepared[player] ~= true
	if firstApply then
		self.sessionPrepared[player] = true
		profile.boatActive = false
	end

	if not profile.ownsTinyBoat then
		self:_restorePlayerState(player)
		self:_destroyBoat(player)
		if firstApply then
			self.PlayerStateService.sync(player, profile)
		end
		return
	end

	local boat = self:_ensureBoat(player)
	if profile.boatActive then
		boat.model:PivotTo(self.world.boundary.coveBoatCFrame)
		self:_setMotionState(player, "sailing")
	else
		boat.model:PivotTo(self:_dockOrigin(player))
		self:_setMotionState(player, "docked")
		self:_restorePlayerState(player)
	end
	self:_setPromptState(player, profile.boatActive)
	if firstApply then
		self.PlayerStateService.sync(player, profile)
	end
end

function BoatService:trackPlayer(player: Player)
	local old = self.characterConnections[player]
	if old then
		old:Disconnect()
	end
	self.characterConnections[player] = player.CharacterAdded:Connect(function()
		task.wait(0.25)
		local profile = self.ProfileStore.get(player)
		if profile then
			profile.boatActive = false
			self:apply(player, profile)
			self.PlayerStateService.sync(player, profile)
		end
	end)
end

function BoatService:_mount(player: Player)
	if not GameplayAccessService.requireAccess(player, self.ProfileStore, self.PlayerStateService) then
		return
	end
	local profile = self.ProfileStore.get(player)
	local boat = self.boats[player] or self:_ensureBoat(player)
	if profile == nil or boat == nil or player.Character == nil then
		return
	end
	local mounted, reason = TraversalRules.mountTinyBoat(profile)
	if not mounted then
		self.PlayerStateService.message(
			player,
			if reason == "not_owned" then "Buy the Tiny Boat first." else "You are already in Tidepool Cove."
		)
		return
	end
	boat.model:PivotTo(self.world.boundary.coveBoatCFrame)
	self:_setMotionState(player, "sailing")
	teleport(player, self.world.boundary.coveArrivalCFrame)
	if not self:_seatPlayer(player, boat.mountPart) then
		TraversalRules.returnTinyBoat(profile)
		self:_restorePlayerState(player)
		boat.model:PivotTo(self:_dockOrigin(player))
		self:_setMotionState(player, "docked")
		teleport(player, self.world.boundary.villageReturnCFrame)
		self:_setPromptState(player, false)
		self.PlayerStateService.sync(player, profile)
		self.PlayerStateService.message(player, "The Tiny Boat is not ready yet.")
		self.ProfileStore.save(player)
		return
	end
	self:_setPromptState(player, true)
	self.PlayerStateService.sync(player, profile)
	self.PlayerStateService.message(player, "Boarded Tiny Boat. Welcome to Tidepool Cove.")
	self.ProfileStore.save(player)
end

function BoatService:_return(player: Player)
	local profile = self.ProfileStore.get(player)
	local boat = self.boats[player]
	if profile == nil or boat == nil or not profile.boatActive then
		return
	end
	local returned = TraversalRules.returnTinyBoat(profile)
	if not returned then
		return
	end
	self:_restorePlayerState(player)
	boat.model:PivotTo(self:_dockOrigin(player))
	self:_setMotionState(player, "docked")
	teleport(player, self.world.boundary.villageReturnCFrame)
	self:_setPromptState(player, false)
	self.PlayerStateService.sync(player, profile)
	self.PlayerStateService.message(player, "Returned to Sea Dock. Your Tiny Boat is parked.")
	self.ProfileStore.save(player)
end

function BoatService:_useShop(player: Player)
	if not GameplayAccessService.requireAccess(player, self.ProfileStore, self.PlayerStateService) then
		return
	end
	local profile = self.ProfileStore.get(player)
	if profile == nil then
		return
	end
	if not profile.ownsTinyBoat then
		local bought, reason = TraversalRules.buyTinyBoat(profile)
		if not bought then
			self.PlayerStateService.message(
				player,
				if reason == "not_enough_coins"
					then "The Tiny Boat costs 600 coins."
					else "You already own the Tiny Boat."
			)
			return
		end
		self:_ensureBoat(player)
		self.PlayerStateService.sync(player, profile)
		self.PlayerStateService.message(player, "Tiny Boat purchased. Board it at the Sea Dock for Tidepool Cove.")
		self.ProfileStore.save(player)
		return
	end
	self:_ensureBoat(player)
	self.PlayerStateService.message(player, "Your Tiny Boat is waiting at the Sea Dock.")
end

function BoatService:removePlayer(player: Player)
	local profile = self.ProfileStore.get(player)
	if profile then
		profile.boatActive = false
	end
	self:_restorePlayerState(player)
	self:_destroyBoat(player)
	local connection = self.characterConnections[player]
	if connection then
		connection:Disconnect()
		self.characterConnections[player] = nil
	end
	self.boatSlots[player] = nil
	self.sessionPrepared[player] = nil
end

return BoatService
