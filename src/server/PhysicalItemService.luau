local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local Inventory = require(shared:WaitForChild("Inventory"))
local PhysicalAffordanceRules = require(shared:WaitForChild("PhysicalAffordanceRules"))
local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))

local PhysicalItemService = {}
PhysicalItemService.__index = PhysicalItemService
PhysicalItemService.PHYSICAL_AFFORDANCE_INVARIANT = "world-or-popup"

local VISUALS = {
	Carrot = { color = VisualTheme.Colors.warmLight, material = Enum.Material.SmoothPlastic, artRole = "inventory-carrot" },
	SugarCrystal = { color = VisualTheme.Colors.crystal, material = Enum.Material.Neon, artRole = "inventory-sugar-crystal" },
	MeadowSeed = { color = VisualTheme.Colors.leafLight, material = Enum.Material.Grass, artRole = "inventory-seed" },
	Seashell = { color = VisualTheme.Colors.white, material = Enum.Material.CeramicTiles, artRole = "inventory-seashell" },
	WoodToken = { color = VisualTheme.Colors.woodLight, material = Enum.Material.Wood, artRole = "inventory-wood-token" },
}

local function makePart(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material, shape: Enum.PartType?, artRole: string?): Part
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
	part:SetAttribute("TinyWorldArtRole", artRole or "inventory-object-detail")
	part:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
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

local function makeInventoryShape(parent: Instance, itemId: string, position: Vector3, color: Color3, material: Enum.Material, artRole: string): Part
	if itemId == "Carrot" then
		local body = makePart(parent, itemId .. "Body", Vector3.new(1.2, 1.8, 1.2), position, color, material, Enum.PartType.Ball, artRole)
		makePart(parent, itemId .. "Leaves", Vector3.new(1.3, 0.5, 1.3), position + Vector3.new(0, 1, 0), VisualTheme.Colors.leaf, Enum.Material.Grass, Enum.PartType.Ball, "inventory-carrot-leaves")
		return body
	elseif itemId == "SugarCrystal" then
		local crystal = makePart(parent, itemId .. "Object", Vector3.new(1.5, 2.6, 1.5), position, color, material, Enum.PartType.Block, artRole)
		crystal.Orientation = Vector3.new(0, 45, 0)
		return crystal
	elseif itemId == "MeadowSeed" then
		local seed = makePart(parent, itemId .. "Object", Vector3.new(1.4, 1.4, 1.4), position, color, material, Enum.PartType.Ball, artRole)
		seed.Orientation = Vector3.new(0, 0, 18)
		return seed
	elseif itemId == "Seashell" then
		local shell = makePart(parent, itemId .. "Object", Vector3.new(1.8, 0.8, 1.4), position, color, material, Enum.PartType.Ball, artRole)
		shell.Orientation = Vector3.new(0, 0, 22)
		makePart(parent, itemId .. "Ridge", Vector3.new(1.2, 0.25, 1), position + Vector3.new(0, 0.4, 0), VisualTheme.Colors.warmLight, Enum.Material.CeramicTiles, Enum.PartType.Ball, "inventory-seashell-ridge")
		return shell
	end
	return makePart(parent, itemId .. "Object", Vector3.new(1.5, 1.5, 1.5), position, color, material, Enum.PartType.Block, artRole)
end

local function summary(profile): string
	local entries = {}
	for _, itemId in PhysicalAffordanceRules.inventoryItems() do
		local count = Inventory.get(profile, itemId)
		if count > 0 then
			table.insert(entries, string.format("%s x%d", PhysicalAffordanceRules.displayName(itemId), count))
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
	plot.itemChest:SetAttribute("TinyWorldArtRole", "home-furniture-display")
	plot.itemDisplay:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	local origin = plot.itemChest.Position + Vector3.new(-1.8, 2.8, 0)
	local visible = 0
	for index, itemId in PhysicalAffordanceRules.inventoryItems() do
		local count = Inventory.get(profile, itemId)
		if count > 0 then
			visible += 1
			local x = ((index - 1) % 3) * 1.8
			local z = if index > 3 then 1.1 else 0
			local visual = VISUALS[itemId]
			local object = makeInventoryShape(plot.itemDisplay, itemId, origin + Vector3.new(x, 0, z), visual.color, visual.material, visual.artRole)
			object.Name = "InventoryItem_" .. itemId
			object:SetAttribute("TinyWorldItem", itemId)
			object:SetAttribute("TinyWorldItemCount", count)
			object:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
			object:SetAttribute("TinyWorldRecognizableSilhouette", true)
			makeLabel(object, string.format("%s x%d", PhysicalAffordanceRules.displayName(itemId), count))
		end
	end

	if visible == 0 then
		local empty = makePart(plot.itemDisplay, "InventoryEmpty", Vector3.new(1.8, 0.4, 1.8), plot.itemChest.Position + Vector3.new(0, 2.75, 0), VisualTheme.Colors.inkSoft, Enum.Material.Wood, nil, "inventory-empty-display")
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
