local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local GardenRules = require(shared:WaitForChild("GardenRules"))
local Profession = require(shared:WaitForChild("Profession"))
local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))

local GardenService = {}
GardenService.__index = GardenService

local function actionForBed(bed): string
	if bed.stage == "empty" then
		return "Plant Carrot"
	elseif bed.stage == "planted" then
		return "Water Carrot"
	elseif bed.stage == "watered" then
		return "Check Carrot"
	end
	return "Harvest Carrot"
end

local function makeCropPart(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material, shape: Enum.PartType?): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Color = color
	part.Material = material
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	if shape then
		part.Shape = shape
	end
	part:SetAttribute("TinyWorldArtRole", "garden-carrot-detail")
	part:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	part.Parent = parent
	return part
end

local function renderBed(plot, bedIndex: number, stage: string)
	local name = "GardenCrop" .. tostring(bedIndex)
	local existing = plot.model:FindFirstChild(name)
	if existing then
		existing:Destroy()
	end
	if stage == "empty" then
		return
	end

	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("TinyWorldArtRole", "garden-carrot-crop")
	model:SetAttribute("TinyWorldGardenStage", stage)
	model:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	model:SetAttribute("TinyWorldRecognizableSilhouette", true)
	model.Parent = plot.model
	local bed = plot.gardenBeds[bedIndex]
	local base = bed.Position + Vector3.new(0, 0.8, 0)
	local offsets = {
		Vector3.new(-2, 0, -2),
		Vector3.new(0, 0, 0),
		Vector3.new(2, 0, 2),
		Vector3.new(-2, 0, 2),
		Vector3.new(2, 0, -2),
	}
	local count = if stage == "planted" then 3 elseif stage == "watered" then 5 else 5
	for index = 1, count do
		local offset = offsets[index]
		local height = if stage == "planted" then 0.9 else 1.5
		makeCropPart(model, "CarrotLeaf" .. index, Vector3.new(0.35, height, 0.35), base + offset + Vector3.new(0, height / 2, 0), VisualTheme.Colors.leaf, Enum.Material.Grass)
		if stage ~= "planted" then
			makeCropPart(model, "CarrotLeafTop" .. index, Vector3.new(0.8, 0.35, 0.8), base + offset + Vector3.new(0, height + 0.15, 0), VisualTheme.Colors.leafLight, Enum.Material.Grass, Enum.PartType.Ball)
		end
	end
	if stage == "ready" then
		local carrot = makeCropPart(model, "ReadyCarrot", Vector3.new(1.4, 2, 1.4), base + Vector3.new(0, 1.2, 0), VisualTheme.Colors.warmLight, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
		carrot:SetAttribute("TinyWorldItem", "Carrot")
		carrot:SetAttribute("TinyWorldArtRole", "garden-ready-carrot")
		carrot:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
		makeCropPart(model, "ReadyCarrotTop", Vector3.new(1.2, 0.45, 1.2), carrot.Position + Vector3.new(0, 1.15, 0), VisualTheme.Colors.leaf, Enum.Material.Grass, Enum.PartType.Ball)
		local gui = Instance.new("BillboardGui")
		gui.Name = "ReadyLabel"
		gui.Size = UDim2.fromOffset(120, 30)
		gui.StudsOffset = Vector3.new(0, 2.6, 0)
		gui.MaxDistance = 45
		gui.AlwaysOnTop = true
		gui.Parent = carrot
		local label = Instance.new("TextLabel")
		label.BackgroundColor3 = VisualTheme.Colors.inkSoft
		label.BackgroundTransparency = 0.08
		label.Size = UDim2.fromScale(1, 1)
		label.TextColor3 = VisualTheme.Colors.paper
		label.TextScaled = true
		label.Font = Enum.Font.GothamBold
		label.Text = "CARROT READY"
		label.Parent = gui
	end
end

function GardenService.new(world, plotService, ProfileStore, PlayerStateService, RouteService)
	local self = setmetatable({}, GardenService)
	self.world = world
	self.plotService = plotService
	self.ProfileStore = ProfileStore
	self.PlayerStateService = PlayerStateService
	self.RouteService = RouteService

	for plotIndex, plot in world.plots do
		for bedIndex, prompt in plot.gardenPrompts do
			prompt.Triggered:Connect(function(player)
				self:_interact(player, plotIndex, bedIndex)
			end)
		end
	end
	task.spawn(function()
		while task.wait(1) do
			for _, player in Players:GetPlayers() do
				self:syncPlayer(player)
			end
		end
	end)
	return self
end

function GardenService:_syncBed(player: Player, bedIndex: number)
	local profile = self.ProfileStore.get(player)
	local plot = self.plotService:getPlotForPlayer(player)
	if profile == nil or plot == nil then
		return
	end
	local bed = profile.gardenBeds[bedIndex]
	local stage = GardenRules.refresh(bed, os.time())
	plot.gardenPrompts[bedIndex].ActionText = actionForBed(bed)
	local cropName = "GardenCrop" .. tostring(bedIndex)
	local existing = plot.model:FindFirstChild(cropName)
	local existingStage = if existing then existing:GetAttribute("TinyWorldGardenStage") else nil
	if (stage == "empty" and existing ~= nil) or (stage ~= "empty" and existingStage ~= stage) then
		renderBed(plot, bedIndex, stage)
	end
end

function GardenService:syncPlayer(player: Player)
	for bedIndex = 1, 3 do
		self:_syncBed(player, bedIndex)
	end
end

function GardenService:_interact(player: Player, plotIndex: number, bedIndex: number)
	local owner = self.plotService:getOwnerForPlot(plotIndex)
	if owner ~= player then
		self.PlayerStateService.message(player, "This garden belongs to another player.")
		return
	end
	local profile = self.ProfileStore.get(player)
	if profile == nil then
		return
	end
	local bed = profile.gardenBeds[bedIndex]
	local now = os.time()
	local stage = GardenRules.refresh(bed, now)
	local ok, reason
	if stage == "empty" then
		ok, reason = GardenRules.plant(bed, now)
	elseif stage == "planted" then
		ok, reason = GardenRules.water(bed, now)
	elseif stage == "ready" then
		ok, reason = GardenRules.harvest(profile, bed, now)
	else
		ok, reason = false, "growing"
	end

	local routeText = ""
	local farmerLevels = 0
	if ok and reason == "harvested" then
		farmerLevels = Profession.addXp(profile, "Farmer", 50)
		local _routeChanged
		_routeChanged, routeText = self.RouteService:record(player, "garden_harvest")
	end
	self:_syncBed(player, bedIndex)
	self.PlayerStateService.sync(player, profile)
	if ok then
		self.ProfileStore.save(player)
	end
	if ok and reason == "planted" then
		self.PlayerStateService.message(player, "Carrot planted. Water it next.")
	elseif ok and reason == "watered" then
		self.PlayerStateService.message(player, "Carrot watered. It grows in about 5 seconds in this prototype.")
	elseif ok and reason == "harvested" then
		local suffix = if routeText == "" then "" else " " .. routeText
		local levelSuffix = if farmerLevels > 0 then " Farmer level up!" else ""
		self.PlayerStateService.message(player, "Carrot harvested: +1 Carrot and +10 XP. Farmer XP +50." .. levelSuffix .. suffix)
	else
		local remaining = math.max(0, bed.readyAt - now)
		self.PlayerStateService.message(player, string.format("Your Carrot is still growing: about %d seconds.", remaining))
	end
end

return GardenService
