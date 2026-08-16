local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local VillageActivityRules = require(shared:WaitForChild("VillageActivityRules"))
local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))

local FishingActivityService = {}
FishingActivityService.__index = FishingActivityService

function FishingActivityService.new(world, hooks)
	local self = setmetatable({}, FishingActivityService)
	self.hooks = hooks
	self.streaks = {}

	local model = Instance.new("Model")
	model.Name = "R6FishingActivity"
	model.Parent = world.root
	self.model = model

	local shoreline = if world.coast then world.coast.shorelineDistance else 120
	local dock = Instance.new("Part")
	dock.Name = "FishingDock"
	dock.Anchored = true
	dock.Size = Vector3.new(8, 0.7, 12)
	dock.CFrame = CFrame.new(shoreline - 8, 1.0, 18)
	dock.Color = VisualTheme.Colors.timber
	dock.Material = Enum.Material.WoodPlanks
	dock:SetAttribute("TinyWorldActivityRole", "Fishing")
	dock.Parent = model

	local bobber = Instance.new("Part")
	bobber.Name = "FishingBobber"
	bobber.Anchored = true
	bobber.CanCollide = false
	bobber.Size = Vector3.new(1.2, 1.2, 1.2)
	bobber.CFrame = CFrame.new(shoreline + 4, 0.8, 18)
	bobber.Shape = Enum.PartType.Ball
	bobber.Color = Color3.fromRGB(235, 85, 75)
	bobber.Material = Enum.Material.SmoothPlastic
	bobber:SetAttribute("TinyWorldActivityRole", "Fishing")
	bobber.Parent = model
	self.bobber = bobber

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "CatchPrompt"
	prompt.ActionText = "Pull fishing line"
	prompt.ObjectText = "Finn's fishing spot"
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = dock
	prompt.Triggered:Connect(function(player)
		self:_pull(player)
	end)
	return self
end

function FishingActivityService:start(player: Player, state): (boolean, string?)
	local now = os.clock()
	local delay = 1.5 + ((math.abs(player.UserId) % 4) * 0.35)
	state.biteAt = now + delay
	state.idealAt = state.biteAt + 0.9
	self.bobber.Color = Color3.fromRGB(235, 85, 75)
	self.hooks.message(player, "Finn has cast the line. Watch the bobber, then pull when the fish bites.")
	return true, nil
end

function FishingActivityService:interact(player: Player, _state)
	self.hooks.message(player, "The line is cast at Finn's fishing dock. Use the dock prompt when the bobber bites.")
end

function FishingActivityService:_pull(player: Player)
	local state = self.hooks.getState(player)
	if state == nil or state.id ~= "Fishing" then
		self.hooks.message(player, "Ask Finn to start a fishing attempt first.")
		return
	end
	local now = os.clock()
	if now < (state.biteAt or now) then
		self.hooks.message(player, "Not yet. Wait for the bite.")
		return
	end

	local offset = math.abs(now - (state.idealAt or now))
	local quality = VillageActivityRules.gradeTiming(offset, 2.5, 0.75)
	if quality == "normal" then
		self.streaks[player] = 0
	else
		self.streaks[player] = (self.streaks[player] or 0) + 1
	end
	self.bobber.Color = if quality == "perfect" then Color3.fromRGB(255, 214, 72) else VisualTheme.Colors.water
	local streak = self.streaks[player] or 0
	local detail = string.format("Fish landed: %s catch%s", quality, if streak > 1 then " · streak " .. streak else "")
	self.hooks.finish(player, "Fishing", quality, detail, 0)
end

function FishingActivityService:removePlayer(player: Player)
	self.streaks[player] = nil
end

function FishingActivityService:stop()
	self.model:Destroy()
end

return FishingActivityService
