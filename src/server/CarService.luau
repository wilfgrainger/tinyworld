local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local TransportRules = require(shared:WaitForChild("TransportRules"))
local CarBuilder = require(script.Parent:WaitForChild("CarBuilder"))

local CarService = {}
CarService.__index = CarService

function CarService.new(world, ProfileStore, PlayerStateService)
	local self = setmetatable({}, CarService)
	self.world = world
	self.ProfileStore = ProfileStore
	self.PlayerStateService = PlayerStateService
	self.cars = {}
	self.active = {}
	self.connections = {}
	self.folder = Instance.new("Folder")
	self.folder.Name = "TinyWorldCars"
	self.folder.Parent = world.root
	return self
end

function CarService:_origin(): CFrame
	local workshop = self.world.root:FindFirstChild("Workshop", true)
	if workshop and workshop:IsA("BasePart") then
		return workshop.CFrame * CFrame.new(0, 0, -10)
	end
	return CFrame.new(12, 2, 26)
end

function CarService:_ensure(player: Player)
	if self.cars[player] then
		return self.cars[player]
	end
	local car = CarBuilder.build(self.folder, "TinyCar_" .. tostring(player.UserId), self:_origin())
	self.cars[player] = car
	if car.prompt then
		car.prompt.Triggered:Connect(function(triggeringPlayer)
			if triggeringPlayer ~= player then
				self.PlayerStateService.message(
					triggeringPlayer,
					"That Tiny Car belongs to another resident's session."
				)
				return
			end
			self:_toggle(player)
		end)
	end
	return car
end

function CarService:_stop(player: Player)
	self.active[player] = nil
	local connection = self.connections[player]
	if connection then
		connection:Disconnect()
		self.connections[player] = nil
	end
	player:SetAttribute("TinyWorldCarActive", false)
	local profile = self.ProfileStore.get(player)
	local character = player.Character
	local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
	if humanoid and profile then
		humanoid.WalkSpeed = TransportRules.movementSpeed(profile)
	end
end

function CarService:_start(player: Player)
	local car = self:_ensure(player)
	self.active[player] = true
	player:SetAttribute("TinyWorldCarActive", true)
	local character = player.Character
	local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
	if humanoid then
		humanoid.WalkSpeed = 30
	end
	self.connections[player] = RunService.Heartbeat:Connect(function()
		if not self.active[player] then
			return
		end
		local currentCharacter = player.Character
		local root = if currentCharacter then currentCharacter:FindFirstChild("HumanoidRootPart") else nil
		if root and car.model.Parent then
			car.model:PivotTo(root.CFrame * CFrame.new(0, -2.1, 0))
		end
	end)
end

function CarService:_toggle(player: Player)
	local profile = self.ProfileStore.get(player)
	if profile == nil then
		return
	end
	if not TransportRules.canUseTinyCar(profile) then
		self.PlayerStateService.message(player, "Tiny Car unlocks at level 8.")
		return
	end
	if self.active[player] then
		self:_stop(player)
		self.PlayerStateService.message(player, "Tiny Car parked.")
	else
		self:_start(player)
		self.PlayerStateService.message(player, "Tiny Car ready. Roads are the quickest way around the village.")
	end
end

function CarService:apply(player: Player, profile)
	if TransportRules.canUseTinyCar(profile) then
		self:_ensure(player)
	end
	player:SetAttribute("TinyWorldCarUnlocked", TransportRules.canUseTinyCar(profile))
	player:SetAttribute("TinyWorldCarActive", self.active[player] == true)
end

function CarService:trackPlayer(player: Player)
	player.CharacterAdded:Connect(function()
		self:_stop(player)
	end)
end

function CarService:removePlayer(player: Player)
	self:_stop(player)
	local car = self.cars[player]
	if car then
		car.model:Destroy()
		self.cars[player] = nil
	end
end

function CarService:stop()
	for player in self.cars do
		self:removePlayer(player)
	end
	self.folder:Destroy()
end

return CarService
