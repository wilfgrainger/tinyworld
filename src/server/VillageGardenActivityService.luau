local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local Profession = require(shared:WaitForChild("Profession"))
local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))

local VillageGardenActivityService = {}
VillageGardenActivityService.__index = VillageGardenActivityService

local function findAnchor(world, name: string): CFrame
	local found = world.root:FindFirstChild(name, true)
	if found and found:IsA("BasePart") then
		return found.CFrame
	end
	return CFrame.new(-30, 1, 30)
end

local function makeBed(parent: Instance, index: number, cframe: CFrame): Part
	local bed = Instance.new("Part")
	bed.Name = "VillageGardenBed" .. index
	bed.Anchored = true
	bed.Size = Vector3.new(5.5, 0.7, 4.2)
	bed.CFrame = cframe
	bed.Color = VisualTheme.Colors.timberDark
	bed.Material = Enum.Material.Ground
	bed.TopSurface = Enum.SurfaceType.Smooth
	bed.BottomSurface = Enum.SurfaceType.Smooth
	bed:SetAttribute("TinyWorldActivityRole", "VillageGarden")
	bed:SetAttribute("TinyWorldGardenState", "dry")
	bed.Parent = parent

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "TendPrompt"
	prompt.ActionText = "Tend garden bed"
	prompt.ObjectText = "Pip's village garden"
	prompt.HoldDuration = 0.15
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = bed
	return bed
end

function VillageGardenActivityService.new(world, hooks)
	local self = setmetatable({}, VillageGardenActivityService)
	self.hooks = hooks
	self.folder = Instance.new("Model")
	self.folder.Name = "R6VillageGardenActivity"
	self.folder.Parent = world.root
	self.beds = {}

	local anchor = findAnchor(world, "Garden") * CFrame.new(8, 0, -5)
	for index = 1, 3 do
		local bed = makeBed(self.folder, index, anchor * CFrame.new((index - 2) * 6.2, 0.4, 0))
		self.beds[index] = bed
		local prompt = bed:FindFirstChild("TendPrompt")
		if prompt and prompt:IsA("ProximityPrompt") then
			prompt.Triggered:Connect(function(player)
				self:_tend(player, index)
			end)
		end
	end
	return self
end

function VillageGardenActivityService:_setBed(index: number, tended: boolean)
	local bed = self.beds[index]
	if not bed then
		return
	end
	bed:SetAttribute("TinyWorldGardenState", if tended then "tended" else "dry")
	bed.Color = if tended then VisualTheme.Colors.leafLight else VisualTheme.Colors.timberDark
	bed.Material = if tended then Enum.Material.Ground else Enum.Material.Ground
end

function VillageGardenActivityService:_resetBeds()
	for index = 1, #self.beds do
		self:_setBed(index, false)
	end
end

function VillageGardenActivityService:start(player: Player, state): (boolean, string?)
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
	if state == nil or state.id ~= "VillageGarden" then
		self.hooks.message(player, "Ask Pip to start a village garden round first.")
		return
	end
	state.tended = state.tended or {}
	if state.tended[index] then
		self.hooks.message(player, "That bed is already tended. Find another dry bed.")
		return
	end

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
	self.hooks.finish(player, "VillageGarden", quality, "Pip's village garden is thriving.", 0)
	task.delay(2, function()
		self:_resetBeds()
	end)
end

function VillageGardenActivityService:removePlayer(_player: Player) end

function VillageGardenActivityService:stop()
	self.folder:Destroy()
end

return VillageGardenActivityService
