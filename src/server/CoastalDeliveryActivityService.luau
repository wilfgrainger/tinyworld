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

	local model = Instance.new("Model")
	model.Name = PARCEL_NAME
	model:SetAttribute("TinyWorldActivityRole", "CoastalDelivery")
	model.Parent = character

	local parcel = Instance.new("Part")
	parcel.Name = "ParcelBox"
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
	parcel.Parent = model

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
	band.Parent = model

	for _, part in { parcel, band } do
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = root
		weld.Part1 = part
		weld.Parent = part
	end
	model.PrimaryPart = parcel
	return true
end

function CoastalDeliveryActivityService.new(world, hooks)
	local self = setmetatable({}, CoastalDeliveryActivityService)
	self.hooks = hooks

	local registry = world.r8Destinations
	local destination = registry and registry.CoastalDelivery
	if destination == nil or destination.model == nil or destination.promptAnchor == nil then
		error("R8 CoastalDelivery destination is incomplete")
	end
	self.destination = destination.model
	self.destination:SetAttribute("TinyWorldActivityRole", "CoastalDelivery")
	self.destination:SetAttribute("TinyWorldBoatRouteTarget", true)

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "CoastalDeliveryPrompt"
	prompt.ActionText = "Deliver coastal parcel"
	prompt.ObjectText = "Outer coast buoy"
	prompt.HoldDuration = 0.15
	prompt.MaxActivationDistance = 14
	prompt.RequiresLineOfSight = false
	prompt.Parent = destination.promptAnchor
	prompt.Triggered:Connect(function(player)
		self:_deliver(player)
	end)
	self.prompt = prompt
	return self
end

function CoastalDeliveryActivityService:start(player: Player, state): (boolean, string?)
	local profile = self.hooks.profile(player)
	if profile == nil then
		return false, "Your saved TinyWorld profile is not ready yet. Try Skye again in a moment."
	end
	if profile.ownsTinyBoat ~= true then
		return false,
			"Skye only sends parcels beyond swimming range once you own the Tiny Boat. Unlock it at the Boat Dock first."
	end
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
	if self.prompt then
		self.prompt:Destroy()
	end
end

return CoastalDeliveryActivityService
