local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local Progression = require(shared:WaitForChild("Progression"))
local Profession = require(shared:WaitForChild("Profession"))
local AnalyticsEvents = require(shared:WaitForChild("AnalyticsEvents"))
local CourierRouteRules = require(shared:WaitForChild("CourierRouteRules"))
local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))
local TinyAnalyticsService = require(script.Parent:WaitForChild("AnalyticsService"))

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

local function parcelPart(model: Model, name: string, size: Vector3, cframe: CFrame, color: Color3, material: Enum.Material)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Massless = true
	part.Anchored = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part:SetAttribute("TinyWorldArtRole", "courier-parcel-detail")
	part:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	part.Parent = model
	return part
end

local function attachParcel(player: Player)
	removeParcel(player)
	local character = player.Character
	if character == nil then
		return
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if root == nil or not root:IsA("BasePart") then
		return
	end

	local model = Instance.new("Model")
	model.Name = "TinyWorldCourierParcel"
	model:SetAttribute("TinyWorldArtRole", "courier-parcel")
	model:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	model:SetAttribute("TinyWorldRecognizableSilhouette", true)
	model.Parent = character

	local boxCFrame = root.CFrame * CFrame.new(0, 0, 2.3)
	local box = parcelPart(
		model,
		"ParcelBox",
		Vector3.new(2.8, 2.2, 2.4),
		boxCFrame,
		VisualTheme.Colors.timber,
		Enum.Material.Cardboard
	)
	local tape = parcelPart(
		model,
		"ParcelTape",
		Vector3.new(0.45, 2.28, 2.48),
		boxCFrame,
		VisualTheme.Colors.warmLight,
		Enum.Material.Fabric
	)
	local seal = parcelPart(
		model,
		"ParcelSeal",
		Vector3.new(1.1, 0.12, 1.1),
		boxCFrame * CFrame.new(0.55, 1.14, 0),
		VisualTheme.Colors.berry,
		Enum.Material.SmoothPlastic
	)

	for _, part in { box, tape, seal } do
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = root
		weld.Part1 = part
		weld.Parent = part
	end
	model.PrimaryPart = box
end

local function deliveryPrompt(parent: Instance, destinationId: string): ProximityPrompt
	local name = "CourierDeliveryPrompt_" .. destinationId
	local existing = parent:FindFirstChild(name)
	local prompt
	if existing and existing:IsA("ProximityPrompt") then
		prompt = existing
	else
		if existing then
			existing:Destroy()
		end
		prompt = Instance.new("ProximityPrompt")
		prompt.Name = name
		prompt.Parent = parent
	end
	prompt.ActionText = "Deliver Parcel"
	prompt.ObjectText = CourierRouteRules.displayName(destinationId) or destinationId
	prompt.HoldDuration = 0.2
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	return prompt
end

function JobService.new(world, ProfileStore, PlayerStateService, RouteService)
	local self = setmetatable({}, JobService)
	self.ProfileStore = ProfileStore
	self.PlayerStateService = PlayerStateService
	self.RouteService = RouteService
	self.active = {}
	self.previousDestination = {}
	self.routeNonce = {}
	self.characterConnections = {}
	self.deliveryConnections = {}

	world.deliveryStartPrompt.Triggered:Connect(function(player)
		self:_start(player)
	end)

	local anchors = {
		VillageShop = world.deliveryEndPrompt.Parent,
		TownHall = world.contributionPrompt.Parent,
		HomeStore = world.homeSupplyPrompt.Parent,
		Workshop = world.transportPrompt.Parent,
	}
	for destinationId, anchor in anchors do
		local prompt
		if destinationId == "VillageShop" then
			prompt = world.deliveryEndPrompt
			prompt.ActionText = "Deliver Parcel"
			prompt.ObjectText = CourierRouteRules.displayName(destinationId) or destinationId
		else
			prompt = deliveryPrompt(anchor, destinationId)
		end
		table.insert(
			self.deliveryConnections,
			prompt.Triggered:Connect(function(player)
				self:_finish(player, destinationId)
			end)
		)
	end
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
		local activeDestination = CourierRouteRules.displayName(self.active[player].destinationId) or "your destination"
		self.PlayerStateService.message(player, "You already have a parcel. Take it to " .. activeDestination .. ".")
		return
	end

	local nonce = (self.routeNonce[player] or 0) + 1
	self.routeNonce[player] = nonce
	local destinationId = CourierRouteRules.nextDestination(self.previousDestination[player], nonce)
	self.previousDestination[player] = destinationId
	self.active[player] = { destinationId = destinationId }
	player:SetAttribute("TinyWorldCarryingParcel", true)
	player:SetAttribute("TinyWorldCourierDestination", destinationId)
	attachParcel(player)
	self.PlayerStateService.message(
		player,
		"Courier round started. Take this parcel to " .. (CourierRouteRules.displayName(destinationId) or destinationId) .. "."
	)
end

function JobService:_finish(player: Player, destinationId: string)
	local active = self.active[player]
	if not active then
		self.PlayerStateService.message(player, "Pick up a parcel from the Courier Depot first.")
		return
	end
	if active.destinationId ~= destinationId then
		local expected = CourierRouteRules.displayName(active.destinationId) or active.destinationId
		self.PlayerStateService.message(player, "This parcel is for " .. expected .. ".")
		return
	end

	local profile = self.ProfileStore.get(player)
	if profile == nil then
		return
	end
	self.active[player] = nil
	player:SetAttribute("TinyWorldCarryingParcel", false)
	player:SetAttribute("TinyWorldCourierDestination", "")
	removeParcel(player)
	profile.coins += 150
	Progression.addXp(profile, 75)
	local professionLevels = Profession.addCourierXp(profile, 100)
	local _routeChanged, routeText = self.RouteService:record(player, "courier_delivery")
	self.PlayerStateService.sync(player, profile)
	self.PlayerStateService.message(
		player,
		string.format(
			"Delivery complete at %s: +150 coins, +75 XP, +100 Courier XP%s",
			CourierRouteRules.displayName(destinationId) or destinationId,
			if professionLevels > 0 then " — Courier level up!" else "."
		)
	)
	if routeText ~= "" then
		self.PlayerStateService.message(player, routeText)
	end
	if self.ProfileStore.save(player) then
		TinyAnalyticsService.log(player, AnalyticsEvents.CurrencyEarned, 150)
		TinyAnalyticsService.log(player, AnalyticsEvents.CareerCompleted)
	end
end

function JobService:removePlayer(player: Player)
	self.active[player] = nil
	self.previousDestination[player] = nil
	self.routeNonce[player] = nil
	removeParcel(player)
	local connection = self.characterConnections[player]
	if connection then
		connection:Disconnect()
		self.characterConnections[player] = nil
	end
end

return JobService
