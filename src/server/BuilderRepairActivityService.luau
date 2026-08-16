local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local VillageActivityRules = require(shared:WaitForChild("VillageActivityRules"))
local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))

local BuilderRepairActivityService = {}
BuilderRepairActivityService.__index = BuilderRepairActivityService

local function findAnchor(world, name: string): CFrame
	local found = world.root:FindFirstChild(name, true)
	if found and found:IsA("BasePart") then
		return found.CFrame
	end
	return CFrame.new(30, 1, 30)
end

local function makeBoard(parent: Instance, name: string, cframe: CFrame): Part
	local board = Instance.new("Part")
	board.Name = name
	board.Anchored = true
	board.Size = Vector3.new(6, 0.65, 1.0)
	board.CFrame = cframe
	board.Color = VisualTheme.Colors.timber
	board.Material = Enum.Material.WoodPlanks
	board:SetAttribute("TinyWorldActivityRole", "BuilderRepair")
	board.Parent = parent
	return board
end

function BuilderRepairActivityService.new(world, hooks)
	local self = setmetatable({}, BuilderRepairActivityService)
	self.hooks = hooks
	self.model = Instance.new("Model")
	self.model.Name = "R6BuilderRepairActivity"
	self.model.Parent = world.root

	local origin = findAnchor(world, "Workshop") * CFrame.new(9, 1.8, -4)
	self.boards = {
		makeBoard(self.model, "RepairBoard1", origin * CFrame.new(0, 0, 0)),
		makeBoard(self.model, "RepairBoard2", origin * CFrame.new(0, 1.7, 0)),
		makeBoard(self.model, "RepairBoard3", origin * CFrame.new(0, 3.4, 0)),
	}

	local postLeft = Instance.new("Part")
	postLeft.Name = "RepairPostLeft"
	postLeft.Anchored = true
	postLeft.Size = Vector3.new(0.8, 6, 0.8)
	postLeft.CFrame = origin * CFrame.new(-2.6, 1.7, 0)
	postLeft.Color = VisualTheme.Colors.timberDark
	postLeft.Material = Enum.Material.Wood
	postLeft.Parent = self.model

	local postRight = postLeft:Clone()
	postRight.Name = "RepairPostRight"
	postRight.CFrame = origin * CFrame.new(2.6, 1.7, 0)
	postRight.Parent = self.model

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "RepairPrompt"
	prompt.ActionText = "Repair board"
	prompt.ObjectText = "Milo's repair job"
	prompt.HoldDuration = 0.2
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = self.boards[2]
	prompt.Triggered:Connect(function(player)
		self:_repair(player)
	end)

	self:_showDamaged()
	return self
end

function BuilderRepairActivityService:_showDamaged()
	for index, board in self.boards do
		board.Color = Color3.fromRGB(113, 87, 70)
		board:SetAttribute("TinyWorldRepairState", "damaged")
		local angle = if index == 1 then -8 elseif index == 2 then 6 else -4
		local position = board.Position
		board.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(angle))
	end
end

function BuilderRepairActivityService:_showRepaired()
	for _, board in self.boards do
		board.Color = VisualTheme.Colors.timber
		board:SetAttribute("TinyWorldRepairState", "repaired")
		local position = board.Position
		board.CFrame = CFrame.new(position)
	end
end

function BuilderRepairActivityService:start(player: Player, state): (boolean, string?)
	state.repairProgress = 0
	state.startedAt = os.clock()
	self:_showDamaged()
	self.hooks.message(
		player,
		"Milo needs three boards secured at the repair frame. Use the repair prompt three times."
	)
	return true, nil
end

function BuilderRepairActivityService:interact(player: Player, state)
	self.hooks.message(player, string.format("Milo's repair: %d of 3 boards secured.", state.repairProgress or 0))
end

function BuilderRepairActivityService:_repair(player: Player)
	local state = self.hooks.getState(player)
	if state == nil or state.id ~= "BuilderRepair" then
		self.hooks.message(player, "Ask Milo to take a repair job first.")
		return
	end
	state.repairProgress = math.min(3, (state.repairProgress or 0) + 1)
	local board = self.boards[state.repairProgress]
	if board then
		board.Color = VisualTheme.Colors.timber
		board:SetAttribute("TinyWorldRepairState", "secured")
	end
	if state.repairProgress < 3 then
		self.hooks.message(player, string.format("Board secured. %d of 3 complete.", state.repairProgress))
		return
	end

	local elapsed = math.max(0, os.clock() - (state.startedAt or os.clock()))
	local quality = VillageActivityRules.gradeTiming(elapsed, 40, 20)
	self:_showRepaired()
	self.hooks.finish(
		player,
		"BuilderRepair",
		quality,
		string.format("Village repair complete in %.0f seconds.", elapsed),
		0
	)
	task.delay(3, function()
		self:_showDamaged()
	end)
end

function BuilderRepairActivityService:removePlayer(_player: Player) end

function BuilderRepairActivityService:stop()
	self.model:Destroy()
end

return BuilderRepairActivityService
