local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local Profession = require(shared:WaitForChild("Profession"))
local ActivityLeaseRules = require(shared:WaitForChild("ActivityLeaseRules"))
local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))

local VillageGardenActivityService = {}
VillageGardenActivityService.__index = VillageGardenActivityService

function VillageGardenActivityService.new(world, hooks)
	local self = setmetatable({}, VillageGardenActivityService)
	self.hooks = hooks
	self.lease = nil
	self.prompts = {}

	local registry = world.r8Destinations
	local destination = registry and registry.Gardener
	if destination == nil or destination.gardenBeds == nil or #destination.gardenBeds ~= 3 then
		error("R8 Gardener destination must expose exactly three authored garden beds")
	end
	self.beds = destination.gardenBeds

	for index, bed in self.beds do
		bed:SetAttribute("TinyWorldActivityRole", "VillageGarden")
		bed:SetAttribute("TinyWorldGardenState", "dry")

		local prompt = Instance.new("ProximityPrompt")
		prompt.Name = "TendPrompt"
		prompt.ActionText = "Tend garden bed"
		prompt.ObjectText = "Pip's village garden"
		prompt.HoldDuration = 0.15
		prompt.MaxActivationDistance = 10
		prompt.RequiresLineOfSight = false
		prompt.Parent = bed
		prompt.Triggered:Connect(function(player)
			self:_tend(player, index)
		end)
		self.prompts[index] = prompt
	end

	self:_resetBeds()
	return self
end

function VillageGardenActivityService:_setBed(index: number, tended: boolean)
	local bed = self.beds[index]
	if not bed then
		return
	end
	bed:SetAttribute("TinyWorldGardenState", if tended then "tended" else "dry")
	bed.Color = if tended then VisualTheme.Colors.leafLight else VisualTheme.Colors.timberDark
	bed.Material = Enum.Material.Ground
end

function VillageGardenActivityService:_resetBeds()
	for index = 1, #self.beds do
		self:_setBed(index, false)
	end
end

function VillageGardenActivityService:isActive(player: Player): boolean
	return ActivityLeaseRules.isOwnedBy(self.lease, player.UserId, os.clock())
end

function VillageGardenActivityService:start(player: Player, state): (boolean, string?)
	local now = os.clock()
	if not ActivityLeaseRules.canAcquire(self.lease, player.UserId, now) then
		return false, "Pip is helping another gardener right now. Try again in a moment."
	end
	self.lease = ActivityLeaseRules.new(player.UserId, now)
	state.tended = {}
	state.nextExpected = 1
	self:_resetBeds()
	self.hooks.message(player, "Pip has three dry village beds. Tend all three to finish the garden round.")
	return true, nil
end

function VillageGardenActivityService:interact(player: Player, state)
	local count = 0
	for _ in state.tended or {} do
		count += 1
	end
	self.hooks.message(player, string.format("Pip's garden round: %d of 3 beds tended.", count))
end

function VillageGardenActivityService:_tend(player: Player, index: number)
	local state = self.hooks.getState(player)
	if state == nil or state.id ~= "VillageGarden" or not self:isActive(player) then
		self.hooks.message(player, "Ask Pip to start a village garden round first.")
		return
	end
	state.tended = state.tended or {}
	if state.tended[index] then
		self.hooks.message(player, "That bed is already tended. Find another dry bed.")
		return
	end

	ActivityLeaseRules.refresh(self.lease, player.UserId, os.clock())
	state.orderPerfect = if state.orderPerfect == nil then true else state.orderPerfect
	if index ~= (state.nextExpected or 1) then
		state.orderPerfect = false
	end
	state.nextExpected = (state.nextExpected or 1) + 1
	state.tended[index] = true
	self:_setBed(index, true)

	local count = 0
	for _ in state.tended do
		count += 1
	end
	if count < 3 then
		self.hooks.message(player, string.format("Garden bed tended. %d of 3 complete.", count))
		return
	end

	local profile = self.hooks.profile(player)
	if profile then
		Profession.addXp(profile, "Farmer", 50)
	end
	local quality = if state.orderPerfect then "perfect" else "normal"
	self.lease = nil
	self.hooks.finish(player, "VillageGarden", quality, "Pip's village garden is thriving.", 0)
	task.delay(2, function()
		if self.lease == nil then
			self:_resetBeds()
		end
	end)
end

function VillageGardenActivityService:abandonPlayer(player: Player)
	if self.lease ~= nil and self.lease.ownerId == player.UserId then
		self.lease = nil
		self:_resetBeds()
	end
end

function VillageGardenActivityService:removePlayer(player: Player)
	self:abandonPlayer(player)
end

function VillageGardenActivityService:stop()
	self.lease = nil
	self:_resetBeds()
	for _, prompt in self.prompts do
		prompt:Destroy()
	end
	self.prompts = {}
end

return VillageGardenActivityService
