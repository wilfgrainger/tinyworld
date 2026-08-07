local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local TransportRules = require(shared:WaitForChild("TransportRules"))

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
	label.BackgroundColor3 = Color3.fromRGB(55, 137, 201)
	label.BackgroundTransparency = 0.1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Text = "TINY BIKE • ACTIVE"
	label.Parent = gui
end

function TransportService.new(world, ProfileStore, PlayerStateService)
	local self = setmetatable({}, TransportService)
	self.ProfileStore = ProfileStore
	self.PlayerStateService = PlayerStateService
	self.characterConnections = {}
	world.transportPrompt.Triggered:Connect(function(player)
		self:_useShop(player)
	end)
	return self
end

function TransportService:apply(player: Player, profile)
	local character = player.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = if profile.ownsTinyBike and profile.bikeActive then 24 else 16
		end
	end
	if profile.ownsTinyBike and profile.bikeActive then
		addBikeBadge(player)
	else
		removeBikeBadge(player)
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
			self:apply(player, profile)
		end
	end)
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
		profile.bikeActive = true
		self.PlayerStateService.message(player, "Tiny Bike purchased and activated. Movement speed increased.")
	else
		profile.bikeActive = not profile.bikeActive
		self.PlayerStateService.message(player, if profile.bikeActive then "Tiny Bike activated." else "Tiny Bike parked.")
	end

	self:apply(player, profile)
	self.PlayerStateService.sync(player, profile)
	self.ProfileStore.save(player)
end

function TransportService:removePlayer(player: Player)
	removeBikeBadge(player)
	local connection = self.characterConnections[player]
	if connection then
		connection:Disconnect()
		self.characterConnections[player] = nil
	end
end

return TransportService
