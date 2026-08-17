local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local VillageActivityRules = require(shared:WaitForChild("VillageActivityRules"))
local VillageActivityLocations = require(script.Parent:WaitForChild("VillageActivityLocations"))
local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))

local FishingActivityService = {}
FishingActivityService.__index = FishingActivityService

local WAITING_COLOR = Color3.fromRGB(235, 85, 75)
local BITE_COLOR = Color3.fromRGB(255, 214, 72)

function FishingActivityService.new(world, hooks)
	local self = setmetatable({}, FishingActivityService)
	self.hooks = hooks
	self.streaks = {}
	self.owner = nil
	self.castNonce = 0

	local registry = world.r8Destinations
	local destination = registry and registry.Fisherman
	if destination == nil or destination.promptAnchor == nil or destination.fishingOrigin == nil then
		error("R8 Fisherman destination is incomplete")
	end

	local model = Instance.new("Model")
	model.Name = "R8FishingActivityState"
	model.Parent = world.root
	self.model = model

	local bobber = Instance.new("Part")
	bobber.Name = "FishingBobber"
	bobber.Anchored = true
	bobber.CanCollide = false
	bobber.CanTouch = false
	bobber.CanQuery = false
	bobber.Size = Vector3.new(1.2, 1.2, 1.2)
	bobber.CFrame = VillageActivityLocations.fishingBobber(world)
	bobber.Shape = Enum.PartType.Ball
	bobber.Color = WAITING_COLOR
	bobber.Material = Enum.Material.SmoothPlastic
	bobber:SetAttribute("TinyWorldActivityRole", "Fishing")
	bobber:SetAttribute("TinyWorldFishingState", "idle")
	bobber.Parent = model
	self.bobber = bobber

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "CatchPrompt"
	prompt.ActionText = "Pull fishing line"
	prompt.ObjectText = "Finn's fishing spot"
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = destination.promptAnchor
	prompt.Triggered:Connect(function(player)
		self:_pull(player)
	end)
	self.prompt = prompt
	return self
end

function FishingActivityService:_setBobber(state: string, color: Color3)
	self.bobber:SetAttribute("TinyWorldFishingState", state)
	self.bobber.Color = color
end

function FishingActivityService:start(player: Player, state): (boolean, string?)
	if self.owner ~= nil and self.owner ~= player then
		return false, "Finn already has a line in the water for another player. Try again in a moment."
	end
	self.owner = player
	self.castNonce += 1
	local nonce = self.castNonce
	local now = os.clock()
	local delay = 1.5 + ((math.abs(player.UserId) % 4) * 0.35)
	state.biteAt = now + delay
	state.idealAt = state.biteAt + 0.9
	state.castNonce = nonce
	self:_setBobber("waiting", WAITING_COLOR)
	self.hooks.message(player, "Finn has cast the line. Watch the bobber, then pull when it flashes gold.")

	task.delay(delay, function()
		local current = self.hooks.getState(player)
		if self.owner == player and current == state and current.castNonce == nonce and current.id == "Fishing" then
			self:_setBobber("bite", BITE_COLOR)
			self.hooks.message(player, "Bite! Pull the line now.")
		end
	end)
	return true, nil
end

function FishingActivityService:interact(player: Player, _state)
	self.hooks.message(player, "The line is cast at Finn's fishing dock. Pull when the bobber flashes gold.")
end

function FishingActivityService:_pull(player: Player)
	local state = self.hooks.getState(player)
	if state == nil or state.id ~= "Fishing" or self.owner ~= player then
		self.hooks.message(player, "Ask Finn to start a fishing attempt first.")
		return
	end
	local now = os.clock()
	if now < (state.biteAt or now) then
		self.hooks.message(player, "Not yet. Wait for the gold flash.")
		return
	end

	local offset = math.abs(now - (state.idealAt or now))
	local quality = VillageActivityRules.gradeTiming(offset, 2.5, 0.75)
	if quality == "normal" then
		self.streaks[player] = 0
	else
		self.streaks[player] = (self.streaks[player] or 0) + 1
	end
	self:_setBobber("landed", if quality == "perfect" then BITE_COLOR else VisualTheme.Colors.water)
	local streak = self.streaks[player] or 0
	local detail = string.format("Fish landed: %s catch%s", quality, if streak > 1 then " · streak " .. streak else "")
	self.owner = nil
	self.hooks.finish(player, "Fishing", quality, detail, 0)
	task.delay(2, function()
		if self.owner == nil then
			self:_setBobber("idle", WAITING_COLOR)
		end
	end)
end

function FishingActivityService:removePlayer(player: Player)
	self.streaks[player] = nil
	if self.owner == player then
		self.owner = nil
		self:_setBobber("idle", WAITING_COLOR)
	end
end

function FishingActivityService:stop()
	self.owner = nil
	if self.prompt then
		self.prompt:Destroy()
	end
	self.model:Destroy()
end

return FishingActivityService
