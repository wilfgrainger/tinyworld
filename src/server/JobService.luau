local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local Progression = require(shared:WaitForChild("Progression"))
local Profession = require(shared:WaitForChild("Profession"))
local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))

local JobService = {}
JobService.__index = JobService

local function removeParcel(player: Player)
	local character = player.Character
	if character then
		local old = character:FindFirstChild("TinyWorldCourierParcel")
		if old then
			old:Destroy()
		end
	end
end

local function attachParcel(player: Player)
	removeParcel(player)
	local character = player.Character
	if character == nil then
		return
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if root == nil then
		return
	end
	local parcel = Instance.new("Part")
	parcel.Name = "TinyWorldCourierParcel"
	parcel.Size = Vector3.new(2.5, 2.5, 2.5)
	parcel.Color = VisualTheme.Colors.timber
	parcel.Material = Enum.Material.Cardboard
	parcel.CanCollide = false
	parcel.Massless = true
	parcel.Anchored = false
	parcel.CFrame = root.CFrame * CFrame.new(0, 0, 2.3)
	parcel.Parent = character
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = parcel
	weld.Parent = parcel
end

function JobService.new(world, ProfileStore, PlayerStateService, RouteService)
	local self = setmetatable({}, JobService)
	self.ProfileStore = ProfileStore
	self.PlayerStateService = PlayerStateService
	self.RouteService = RouteService
	self.active = {}
	self.characterConnections = {}

	world.deliveryStartPrompt.Triggered:Connect(function(player)
		self:_start(player)
	end)
	world.deliveryEndPrompt.Triggered:Connect(function(player)
		self:_finish(player)
	end)
	return self
end

function JobService:trackPlayer(player: Player)
	if self.characterConnections[player] then
		self.characterConnections[player]:Disconnect()
	end
	self.characterConnections[player] = player.CharacterAdded:Connect(function()
		if self.active[player] then
			task.wait(0.2)
			attachParcel(player)
		end
	end)
end

function JobService:_start(player: Player)
	if self.ProfileStore.get(player) == nil then
		return
	end
	if self.active[player] then
		self.PlayerStateService.message(player, "You already have a parcel. Deliver it to the Village Shop.")
		return
	end
	self.active[player] = true
	player:SetAttribute("TinyWorldCarryingParcel", true)
	attachParcel(player)
	self.PlayerStateService.message(player, "Courier job started. Take the parcel to the Village Shop.")
end

function JobService:_finish(player: Player)
	if not self.active[player] then
		self.PlayerStateService.message(player, "Pick up a parcel from the Courier Depot first.")
		return
	end
	local profile = self.ProfileStore.get(player)
	if profile == nil then
		return
	end
	self.active[player] = nil
	player:SetAttribute("TinyWorldCarryingParcel", false)
	removeParcel(player)
	profile.coins += 150
	Progression.addXp(profile, 75)
	local professionLevels = Profession.addCourierXp(profile, 100)
	local _routeChanged, routeText = self.RouteService:record(player, "courier_delivery")
	self.PlayerStateService.sync(player, profile)
	self.PlayerStateService.message(player, string.format("Delivery complete: +150 coins, +75 XP, +100 Courier XP%s", if professionLevels > 0 then " — Courier level up!" else "."))
	if routeText ~= "" then
		self.PlayerStateService.message(player, routeText)
	end
	self.ProfileStore.save(player)
end

function JobService:removePlayer(player: Player)
	self.active[player] = nil
	removeParcel(player)
	local connection = self.characterConnections[player]
	if connection then
		connection:Disconnect()
		self.characterConnections[player] = nil
	end
end

return JobService
