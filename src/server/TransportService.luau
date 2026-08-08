local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local TransportRules = require(shared:WaitForChild("TransportRules"))
local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))
local BikeBuilder = require(script.Parent:WaitForChild("BikeBuilder"))

local TransportService = {}
TransportService.__index = TransportService

local function removeBikeBadge(player: Player)
	local character = player.Character
	if character then
		local head = character:FindFirstChild("Head")
		if head then
			local badge = head:FindFirstChild("TinyWorldBikeBadge")
			if badge then
				badge:Destroy()
			end
		end
	end
end

local function addBikeBadge(player: Player)
	removeBikeBadge(player)
	local character = player.Character
	if character == nil then
		return
	end
	local head = character:FindFirstChild("Head")
	if head == nil then
		return
	end
	local gui = Instance.new("BillboardGui")
	gui.Name = "TinyWorldBikeBadge"
	gui.Size = UDim2.fromOffset(130, 32)
	gui.StudsOffset = Vector3.new(0, 2.5, 0)
	gui.AlwaysOnTop = true
	gui.Parent = head
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = VisualTheme.Colors.skyDeep
	label.BackgroundTransparency = 0.1
	label.TextColor3 = VisualTheme.Colors.white
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Text = "TINY BIKE - MOUNTED"
	label.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = label
	local stroke = Instance.new("UIStroke")
	stroke.Color = VisualTheme.Colors.paper
	stroke.Transparency = 0.7
	stroke.Parent = label
end

function TransportService.new(world, ProfileStore, PlayerStateService)
	local self = setmetatable({}, TransportService)
	self.world = world
	self.ProfileStore = ProfileStore
	self.PlayerStateService = PlayerStateService
	self.characterConnections = {}
	self.followConnections = {}
	self.bikes = {}
	self.sessionPrepared = {}
	self.bikeFolder = Instance.new("Folder")
	self.bikeFolder.Name = "TinyWorldBikes"
	self.bikeFolder.Parent = world.root
	world.transportPrompt.Triggered:Connect(function(player)
		self:_useShop(player)
	end)
	return self
end

function TransportService:_bikeOrigin(): CFrame
	local stand = self.world.transportPrompt.Parent
	return stand.CFrame * CFrame.new(0, 3, -8)
end

function TransportService:_ensureBike(player: Player)
	local existing = self.bikes[player]
	if existing then
		return existing
	end
	local bike = BikeBuilder.build(
		self.bikeFolder,
		"TinyBike_" .. tostring(player.UserId),
		self:_bikeOrigin(),
		VisualTheme.Colors.skyDeep
	)
	bike.mountPrompt.Triggered:Connect(function(triggeringPlayer)
		if triggeringPlayer == player then
			self:_mount(player)
		end
	end)
	bike.dismountPrompt.Triggered:Connect(function(triggeringPlayer)
		if triggeringPlayer == player then
			self:_dismount(player)
		end
	end)
	self.bikes[player] = bike
	return bike
end

function TransportService:_stopFollowing(player: Player)
	local connection = self.followConnections[player]
	if connection then
		connection:Disconnect()
		self.followConnections[player] = nil
	end
end

function TransportService:_startFollowing(player: Player)
	self:_stopFollowing(player)
	self.followConnections[player] = RunService.Heartbeat:Connect(function()
		local profile = self.ProfileStore.get(player)
		local bike = self.bikes[player]
		local character = player.Character
		local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
		if profile == nil or bike == nil or not profile.bikeActive or root == nil then
			return
		end
		bike.model:PivotTo(root.CFrame * CFrame.new(0, -2.4, 0))
	end)
end

function TransportService:_setPromptState(player: Player, mounted: boolean)
	local bike = self.bikes[player]
	if bike == nil then
		return
	end
	bike.mountPrompt.Enabled = not mounted
	bike.dismountPrompt.Enabled = mounted
end

function TransportService:apply(player: Player, profile)
	local firstApply = self.sessionPrepared[player] ~= true
	if firstApply then
		self.sessionPrepared[player] = true
		profile.bikeActive = false
	end
	if profile.ownsTinyBike then
		self:_ensureBike(player)
	end

	local character = player.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = TransportRules.movementSpeed(profile)
		end
	end
	if profile.ownsTinyBike and profile.bikeActive then
		addBikeBadge(player)
		self:_setPromptState(player, true)
		self:_startFollowing(player)
	else
		removeBikeBadge(player)
		self:_setPromptState(player, false)
		self:_stopFollowing(player)
	end
	if firstApply then
		self.PlayerStateService.sync(player, profile)
	end
end

function TransportService:trackPlayer(player: Player)
	local old = self.characterConnections[player]
	if old then
		old:Disconnect()
	end
	self.characterConnections[player] = player.CharacterAdded:Connect(function()
		task.wait(0.25)
		local profile = self.ProfileStore.get(player)
		if profile then
			self:_stopFollowing(player)
			profile.bikeActive = false
			self:apply(player, profile)
			self.PlayerStateService.sync(player, profile)
		end
	end)
end

function TransportService:_mount(player: Player)
	local profile = self.ProfileStore.get(player)
	local bike = self.bikes[player] or self:_ensureBike(player)
	local character = player.Character
	if profile == nil or bike == nil or character == nil then
		return
	end
	local mounted, reason = TransportRules.mountTinyBike(profile)
	if not mounted then
		self.PlayerStateService.message(player, if reason == "not_owned" then "Buy the Tiny Bike first." else "You are already riding your Tiny Bike.")
		return
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if root then
		bike.model:PivotTo(root.CFrame * CFrame.new(0, -2.4, 0))
	end
	self:_setPromptState(player, true)
	self:_startFollowing(player)
	self:apply(player, profile)
	self.PlayerStateService.sync(player, profile)
	self.PlayerStateService.message(player, "Mounted Tiny Bike. Move faster and press E again to park it.")
	self.ProfileStore.save(player)
end

function TransportService:_dismount(player: Player)
	local profile = self.ProfileStore.get(player)
	local bike = self.bikes[player]
	if profile == nil or bike == nil or not profile.bikeActive then
		return
	end
	TransportRules.dismountTinyBike(profile)
	self:_stopFollowing(player)
	local character = player.Character
	local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
	if root then
		bike.model:PivotTo(root.CFrame * CFrame.new(0, -2.4, -5))
	end
	self:_setPromptState(player, false)
	self:apply(player, profile)
	self.PlayerStateService.sync(player, profile)
	self.PlayerStateService.message(player, "Tiny Bike parked.")
	self.ProfileStore.save(player)
end

function TransportService:_useShop(player: Player)
	local profile = self.ProfileStore.get(player)
	if profile == nil then
		return
	end

	if not profile.ownsTinyBike then
		local bought, reason = TransportRules.buyTinyBike(profile)
		if not bought then
			self.PlayerStateService.message(player, if reason == "not_enough_coins" then "The Tiny Bike costs 300 coins." else "You already own the Tiny Bike.")
			return
		end
		self:_ensureBike(player)
		self.PlayerStateService.message(player, "Tiny Bike purchased. Mount it at the transport stand.")
		self:apply(player, profile)
		self.PlayerStateService.sync(player, profile)
		self.ProfileStore.save(player)
		return
	end

	if profile.bikeActive then
		self:_dismount(player)
	else
		self:_mount(player)
	end
end

function TransportService:removePlayer(player: Player)
	local profile = self.ProfileStore.get(player)
	if profile then
		profile.bikeActive = false
	end
	removeBikeBadge(player)
	self:_stopFollowing(player)
	local connection = self.characterConnections[player]
	if connection then
		connection:Disconnect()
		self.characterConnections[player] = nil
	end
	local bike = self.bikes[player]
	if bike then
		bike.model:Destroy()
		self.bikes[player] = nil
	end
	self.sessionPrepared[player] = nil
end

return TransportService
