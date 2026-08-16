local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local VillageActivityRules = require(shared:WaitForChild("VillageActivityRules"))
local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))

local CoastalDeliveryActivityService = {}
CoastalDeliveryActivityService.__index = CoastalDeliveryActivityService

local PARCEL_NAME = "TinyWorldCoastalParcel"

local function removeParcel(player: Player)
	local character = player.Character
	if character then
		local old = character:FindFirstChild(PARCEL_NAME)
		if old then
			old:Destroy()
		end
	end
end

local function attachParcel(player: Player): boolean
	removeParcel(player)
	local character = player.Character
	if character == nil then
		return false
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if root == nil or not root:IsA("BasePart") then
		return false
	end

	local parcel = Instance.new("Part")
	parcel.Name = PARCEL_NAME
	parcel.Size = Vector3.new(2.4, 1.8, 1.8)
	parcel.CFrame = root.CFrame * CFrame.new(0, 0.2, 2.0)
	parcel.Color = VisualTheme.Colors.timber
	parcel.Material = Enum.Material.SmoothPlastic
	parcel.CanCollide = false
	parcel.CanTouch = false
	parcel.CanQuery = false
	parcel.Massless = true
	parcel.Anchored = false
	parcel:SetAttribute("TinyWorldActivityRole", "CoastalDelivery")
	parcel.Parent = character

	local band = Instance.new("Part")
	band.Name = "ParcelBand"
	band.Size = Vector3.new(0.45, 1.9, 1.9)
	band.CFrame = parcel.CFrame
	band.Color = VisualTheme.Colors.warmLight
	band.Material = Enum.Material.Fabric
	band.CanCollide = false
	band.CanTouch = false
	band.CanQuery = false
	band.Massless = true
	band.Anchored = false
	band.Parent = character

	for _, part in { parcel, band } do
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = root
		weld.Part1 = part
		weld.Parent = part
	end
	return true
end

function CoastalDeliveryActivityService.new(world, hooks)
	local self = setmetatable({}, CoastalDeliveryActivityService)
	self.hooks = hooks
	self.model = Instance.new("Model")
	self.model.Name = "R6CoastalDeliveryActivity"
	self.model.Parent = world.root

	local shoreline = if world.coast then world.coast.shorelineDistance else 120
	local destination = Instance.new("Part")
	destination.Name = "OuterCoastDeliveryBuoy"
	destination.Anchored = true
	destination.CanCollide = false
	destination.Size = Vector3.new(4, 7, 4)
	destination.CFrame = CFrame.new(shoreline + 65, 3.5, -20)
	destination.Color = Color3.fromRGB(235, 132, 62)
	destination.Material = Enum.Material.SmoothPlastic
	destination.Shape = Enum.PartType.Cylinder
	destination:SetAttribute("TinyWorldActivityRole", "CoastalDelivery")
	destination:SetAttribute("TinyWorldBoatRouteTarget", true)
	destination.Parent = self.model
	self.destination = destination

	local beacon = Instance.new("Part")
	beacon.Name = "BuoyBeacon"
	beacon.Anchored = true
	beacon.CanCollide = false
	beacon.Size = Vector3.new(1.7, 1.7, 1.7)
	beacon.CFrame = CFrame.new(shoreline + 65, 7.5, -20)
	beacon.Color = VisualTheme.Colors.gold
	beacon.Material = Enum.Material.Neon
	beacon.Shape = Enum.PartType.Ball
	beacon.Parent = self.model

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "CoastalDeliveryPrompt"
	prompt.ActionText = "Deliver coastal parcel"
	prompt.ObjectText = "Outer coast buoy"
	prompt.HoldDuration = 0.15
	prompt.MaxActivationDistance = 14
	prompt.RequiresLineOfSight = false
	prompt.Parent = destination
	prompt.Triggered:Connect(function(player)
		self:_deliver(player)
	end)
	return self
end

function CoastalDeliveryActivityService:start(player: Player, state): (boolean, string?)
	if not attachParcel(player) then
		return false, "Your character is not ready for a parcel yet. Try Skye again in a moment."
	end
	state.startedAt = os.clock()
	state.target = "OuterCoastDeliveryBuoy"
	player:SetAttribute("TinyWorldCoastalDelivery", true)
	self.hooks.message(
		player,
		"Skye's parcel goes to the orange buoy beyond swimming range. Take the Tiny Boat and deliver it safely."
	)
	return true, nil
end

function CoastalDeliveryActivityService:interact(player: Player, _state)
	self.hooks.message(
		player,
		"Your coastal parcel is for the orange outer-coast buoy. The Tiny Boat is the safe way there."
	)
end

function CoastalDeliveryActivityService:_deliver(player: Player)
	local state = self.hooks.getState(player)
	if state == nil or state.id ~= "CoastalDelivery" then
		self.hooks.message(player, "Ask Skye for a coastal delivery first.")
		return
	end
	local elapsed = math.max(0, os.clock() - (state.startedAt or os.clock()))
	local quality = VillageActivityRules.gradeTiming(elapsed, 90, 55)
	removeParcel(player)
	player:SetAttribute("TinyWorldCoastalDelivery", false)
	self.hooks.finish(
		player,
		"CoastalDelivery",
		quality,
		string.format("Coastal parcel delivered in %.0f seconds.", elapsed),
		0
	)
end

function CoastalDeliveryActivityService:removePlayer(player: Player)
	removeParcel(player)
	player:SetAttribute("TinyWorldCoastalDelivery", false)
end

function CoastalDeliveryActivityService:stop()
	self.model:Destroy()
end

return CoastalDeliveryActivityService
