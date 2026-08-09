local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local Inventory = require(shared:WaitForChild("Inventory"))
local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))

local PhysicalItemService = {}
PhysicalItemService.__index = PhysicalItemService
PhysicalItemService.PHYSICAL_AFFORDANCE_INVARIANT = "world-or-popup"

local ITEMS = {
	{ id = "Carrot", name = "Carrot", color = VisualTheme.Colors.warmLight, material = Enum.Material.SmoothPlastic },
	{ id = "SugarCrystal", name = "Sugar Crystal", color = VisualTheme.Colors.crystal, material = Enum.Material.Neon },
	{ id = "MeadowSeed", name = "Meadow Seed", color = VisualTheme.Colors.leafLight, material = Enum.Material.Grass },
	{ id = "Seashell", name = "Seashell", color = VisualTheme.Colors.white, material = Enum.Material.SmoothPlastic },
	{ id = "WoodToken", name = "Wood Token", color = VisualTheme.Colors.woodLight, material = Enum.Material.Wood },
}

local function makePart(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material, shape: Enum.PartType?): Part
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
	part.Parent = parent
	return part
end

local function makeLabel(parent: BasePart, text: string)
	local gui = Instance.new("BillboardGui")
	gui.Name = "ItemLabel"
	gui.Size = UDim2.fromOffset(110, 30)
	gui.StudsOffset = Vector3.new(0, 1.8, 0)
	gui.MaxDistance = 55
	gui.AlwaysOnTop = true
	gui.Parent = parent

	local label = Instance.new("TextLabel")
	label.BackgroundColor3 = VisualTheme.Colors.inkSoft
	label.BackgroundTransparency = 0.08
	label.Size = UDim2.fromScale(1, 1)
	label.TextColor3 = VisualTheme.Colors.paper
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.Parent = gui

	local constraint = Instance.new("UITextSizeConstraint")
	constraint.MinTextSize = 10
	constraint.MaxTextSize = 16
	constraint.Parent = label
	return label
end

local function makeInventoryShape(parent: Instance, itemId: string, position: Vector3, color: Color3, material: Enum.Material): Part
	if itemId == "Carrot" then
		local body = makePart(parent, itemId .. "Body", Vector3.new(1.2, 1.8, 1.2), position, color, material, Enum.PartType.Ball)
		makePart(parent, itemId .. "Leaves", Vector3.new(1.3, 0.5, 1.3), position + Vector3.new(0, 1, 0), VisualTheme.Colors.leaf, Enum.Material.Grass, Enum.PartType.Ball)
		return body
	elseif itemId == "SugarCrystal" then
		local crystal = makePart(parent, itemId .. "Object", Vector3.new(1.5, 2.6, 1.5), position, color, material, Enum.PartType.Wedge)
		crystal.Orientation = Vector3.new(0, 45, 0)
		return crystal
	elseif itemId == "MeadowSeed" then
		return makePart(parent, itemId .. "Object", Vector3.new(1.4, 1.4, 1.4), position, color, material, Enum.PartType.Ball)
	elseif itemId == "Seashell" then
		local shell = makePart(parent, itemId .. "Object", Vector3.new(1.8, 0.8, 1.4), position, color, material, Enum.PartType.Ball)
		shell.Orientation = Vector3.new(0, 0, 22)
		return shell
	end
	return makePart(parent, itemId .. "Object", Vector3.new(1.5, 1.5, 1.5), position, color, material, Enum.PartType.Block)
end

local function summary(profile): string
	local entries = {}
	for _, item in ITEMS do
		local count = Inventory.get(profile, item.id)
		if count > 0 then
			table.insert(entries, string.format("%s x%d", item.name, count))
		end
	end
	return if #entries == 0 then "nothing collected yet" else table.concat(entries, " • ")
end

function PhysicalItemService.new(world, plotService, ProfileStore, PlayerStateService)
	local self = setmetatable({}, PhysicalItemService)
	self.world = world
	self.plotService = plotService
	self.ProfileStore = ProfileStore
	self.PlayerStateService = PlayerStateService

	for plotIndex, plot in world.plots do
		plot.itemChestPrompt.Triggered:Connect(function(player)
			self:_inspectChest(player, plotIndex)
		end)
	end

	PlayerStateService.addSyncListener(function(player, profile)
		self:refresh(player, profile)
	end)

	return self
end

function PhysicalItemService:refresh(player: Player, profile)
	local plot = self.plotService:getPlotForPlayer(player)
	if plot == nil or plot.itemDisplay == nil then
		return
	end

	plot.itemDisplay:ClearAllChildren()
	local origin = plot.itemChest.Position + Vector3.new(-1.8, 2.8, 0)
	local visible = 0
	for index, item in ITEMS do
		local count = Inventory.get(profile, item.id)
		if count > 0 then
			visible += 1
			local x = ((index - 1) % 3) * 1.8
			local z = if index > 3 then 1.1 else 0
			local object = makeInventoryShape(plot.itemDisplay, "InventoryItem_" .. item.id, origin + Vector3.new(x, 0, z), item.color, item.material)
			makeLabel(object, string.format("%s x%d", item.name, count))
		end
	end

	if visible == 0 then
		local empty = makePart(plot.itemDisplay, "InventoryEmpty", Vector3.new(1.8, 0.4, 1.8), plot.itemChest.Position + Vector3.new(0, 2.75, 0), VisualTheme.Colors.inkSoft, Enum.Material.Wood)
		makeLabel(empty, "Empty")
	end
	plot.itemChestLabel.Text = "ITEM CHEST\n" .. (if visible == 0 then "Nothing collected" else string.format("%d kinds on display", visible))
end

function PhysicalItemService:_inspectChest(player: Player, plotIndex: number)
	local owner = self.plotService:getOwnerForPlot(plotIndex)
	if owner ~= player then
		self.PlayerStateService.message(player, "That item chest belongs to another player.")
		return
	end
	local profile = self.ProfileStore.get(player)
	if profile == nil then
		return
	end
	self.PlayerStateService.message(player, "Item Chest: " .. summary(profile))
end

return PhysicalItemService
