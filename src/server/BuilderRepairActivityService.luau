local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local VillageActivityRules = require(shared:WaitForChild("VillageActivityRules"))
local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))

local BuilderRepairActivityService = {}
BuilderRepairActivityService.__index = BuilderRepairActivityService

function BuilderRepairActivityService.new(world, hooks)
	local self = setmetatable({}, BuilderRepairActivityService)
	self.hooks = hooks
	self.owner = nil

	local registry = world.r8Destinations
	local destination = registry and registry.Builder
	if destination == nil or destination.repairBoards == nil or #destination.repairBoards ~= 3 then
		error("R8 Builder destination must expose exactly three authored repair boards")
	end
	self.boards = destination.repairBoards
	self.baseCFrames = {}
	for index, board in self.boards do
		self.baseCFrames[index] = board.CFrame
		board:SetAttribute("TinyWorldActivityRole", "BuilderRepair")
	end

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "RepairPrompt"
	prompt.ActionText = "Repair board"
	prompt.ObjectText = "Milo's repair job"
	prompt.HoldDuration = 0.2
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = destination.activityOrigin
	prompt.Triggered:Connect(function(player)
		self:_repair(player)
	end)
	self.prompt = prompt

	self:_showDamaged()
	return self
end

function BuilderRepairActivityService:_showDamaged()
	for index, board in self.boards do
		board.Color = Color3.fromRGB(113, 87, 70)
		board:SetAttribute("TinyWorldRepairState", "damaged")
		local angle = if index == 1 then -8 elseif index == 2 then 6 else -4
		board.CFrame = self.baseCFrames[index] * CFrame.Angles(0, 0, math.rad(angle))
	end
end

function BuilderRepairActivityService:_showRepaired()
	for index, board in self.boards do
		board.Color = VisualTheme.Colors.timber
		board:SetAttribute("TinyWorldRepairState", "repaired")
		board.CFrame = self.baseCFrames[index]
	end
end

function BuilderRepairActivityService:start(player: Player, state): (boolean, string?)
	if self.owner ~= nil and self.owner ~= player then
		return false, "Milo is already helping another builder. Try again in a moment."
	end
	self.owner = player
	state.repairProgress = 0
	state.startedAt = os.clock()
	self:_showDamaged()
	self.hooks.message(
		player,
		"Milo needs three boards secured at the workshop repair station. Use the repair prompt three times."
	)
	return true, nil
end

function BuilderRepairActivityService:interact(player: Player, state)
	self.hooks.message(player, string.format("Milo's repair: %d of 3 boards secured.", state.repairProgress or 0))
end

function BuilderRepairActivityService:_repair(player: Player)
	local state = self.hooks.getState(player)
	if state == nil or state.id ~= "BuilderRepair" or self.owner ~= player then
		self.hooks.message(player, "Ask Milo to take a repair job first.")
		return
	end
	state.repairProgress = math.min(3, (state.repairProgress or 0) + 1)
	local board = self.boards[state.repairProgress]
	if board then
		board.Color = VisualTheme.Colors.timber
		board:SetAttribute("TinyWorldRepairState", "secured")
		board.CFrame = self.baseCFrames[state.repairProgress]
	end
	if state.repairProgress < 3 then
		self.hooks.message(player, string.format("Board secured. %d of 3 complete.", state.repairProgress))
		return
	end

	local elapsed = math.max(0, os.clock() - (state.startedAt or os.clock()))
	local quality = VillageActivityRules.gradeTiming(elapsed, 40, 20)
	self:_showRepaired()
	self.owner = nil
	self.hooks.finish(
		player,
		"BuilderRepair",
		quality,
		string.format("Village repair complete in %.0f seconds.", elapsed),
		0
	)
	task.delay(3, function()
		if self.owner == nil then
			self:_showDamaged()
		end
	end)
end

function BuilderRepairActivityService:removePlayer(player: Player)
	if self.owner == player then
		self.owner = nil
		self:_showDamaged()
	end
end

function BuilderRepairActivityService:stop()
	self.owner = nil
	self:_showDamaged()
	if self.prompt then
		self.prompt:Destroy()
	end
end

return BuilderRepairActivityService
