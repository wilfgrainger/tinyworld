local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local TraversalRules = require(shared:WaitForChild("TraversalRules"))
local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))
local BoatBuilder = require(script.Parent:WaitForChild("BoatBuilder"))

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

function BoatService:apply(player: Player, profile)
	local firstApply = self.sessionPrepared[player] ~= true
	if firstApply then
		self.sessionPrepared[player] = true
		profile.boatActive = false
	end

	if not profile.ownsTinyBoat then
		self:_destroyBoat(player)
		if firstApply then
			self.PlayerStateService.sync(player, profile)
		end
		return
	end

	local boat = self:_ensureBoat(player)
	if profile.boatActive then
		boat.model:PivotTo(self.world.boundary.coveBoatCFrame)
	else
		boat.model:PivotTo(self:_dockOrigin(player))
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
	local profile = self.ProfileStore.get(player)
	local boat = self.boats[player] or self:_ensureBoat(player)
	if profile == nil or boat == nil or player.Character == nil then
		return
	end
	local mounted, reason = TraversalRules.mountTinyBoat(profile)
	if not mounted then
		self.PlayerStateService.message(player, if reason == "not_owned" then "Buy the Tiny Boat first." else "You are already in Tidepool Cove.")
		return
	end
	boat.model:PivotTo(self.world.boundary.coveBoatCFrame)
	teleport(player, self.world.boundary.coveArrivalCFrame)
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
	boat.model:PivotTo(self:_dockOrigin(player))
	teleport(player, self.world.boundary.villageReturnCFrame)
	self:_setPromptState(player, false)
	self.PlayerStateService.sync(player, profile)
	self.PlayerStateService.message(player, "Returned to Sea Dock. Your Tiny Boat is parked.")
	self.ProfileStore.save(player)
end

function BoatService:_useShop(player: Player)
	local profile = self.ProfileStore.get(player)
	if profile == nil then
		return
	end
	if not profile.ownsTinyBoat then
		local bought, reason = TraversalRules.buyTinyBoat(profile)
		if not bought then
			self.PlayerStateService.message(player, if reason == "not_enough_coins" then "The Tiny Boat costs 600 coins." else "You already own the Tiny Boat.")
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
