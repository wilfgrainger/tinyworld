local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local HomeCatalog = require(shared:WaitForChild("HomeCatalog"))
local HomeRules = require(shared:WaitForChild("HomeRules"))
local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))

local HomeService = {}
HomeService.__index = HomeService

local function makeFurniturePart(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Color = color
	part.Material = material
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function makeFurniturePrompt(parent: BasePart, itemId: string, item)
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "HomeUsePrompt_" .. itemId
	prompt.ActionText = item.action
	prompt.ObjectText = item.name
	prompt.HoldDuration = 0.2
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = parent
	return prompt
end

function HomeService.new(world, ProfileStore, PlayerStateService)
	local self = setmetatable({}, HomeService)
	self.world = world
	self.ProfileStore = ProfileStore
	self.PlayerStateService = PlayerStateService
	self.plotService = nil
	world.homeSupplyPrompt.Triggered:Connect(function(player)
		self:_buyNext(player)
	end)
	self:_updateSupplyLabel()
	return self
end

function HomeService:setPlotService(plotService)
	self.plotService = plotService
end

function HomeService:syncPlayer(player: Player, profile)
	player:SetAttribute("TinyWorldHomeUseCount", profile.homeUseCount)
	player:SetAttribute("TinyWorldHomeOwnedCount", self:_ownedCount(profile))
end

function HomeService:_ownedCount(profile): number
	local count = 0
	for _, item in HomeCatalog.all() do
		if HomeRules.has(profile, item.id) then
			count += 1
		end
	end
	return count
end

function HomeService:_updateSupplyLabel()
	local names = {}
	for _, item in HomeCatalog.all() do
		if item.price == 0 then
			table.insert(names, item.name .. " included")
		else
			table.insert(names, string.format("%s %d coins", item.name, item.price))
		end
	end
	self.world.homeSupplyLabel.Text = "HOME SUPPLY\n" .. table.concat(names, "\n")
end

function HomeService:_buyNext(player: Player)
	local profile = self.ProfileStore.get(player)
	if profile == nil then
		return
	end
	local itemId = HomeRules.nextItem(profile)
	if itemId == nil then
		self.PlayerStateService.message(player, "Your home has every essential. Go inside and use what you own.")
		return
	end
	local item = HomeCatalog.get(itemId)
	local bought, reason = HomeRules.buy(profile, itemId)
	if not bought then
		local missing = math.max(0, item.price - profile.coins)
		self.PlayerStateService.message(player, if reason == "not_enough_coins" then string.format("%s costs %d coins. You need %d more.", item.name, item.price, missing) else "That home item is already owned.")
		return
	end
	if self.plotService then
		local plot = self.plotService:getPlotForPlayer(player)
		if plot then
			self.plotService:rebuildHouse(player, profile)
		end
	end
	self.PlayerStateService.sync(player, profile)
	self:syncPlayer(player, profile)
	self.PlayerStateService.message(player, string.format("Bought %s for %d coins. Return home to use it.", item.name, item.price))
	self.ProfileStore.save(player)
end

function HomeService:_use(player: Player, plotIndex: number, itemId: string)
	if self.plotService == nil then
		return
	end
	local owner = self.plotService:getOwnerForPlot(plotIndex)
	if owner ~= player then
		self.PlayerStateService.message(player, "Only the homeowner can use this home item.")
		return
	end
	local profile = self.ProfileStore.get(player)
	if profile == nil then
		return
	end
	local used, reason = HomeRules.use(profile, itemId)
	if not used then
		self.PlayerStateService.message(player, if reason == "not_owned" then "Buy this home item at the Home Supply counter first." else "That home item is unavailable.")
		return
	end
	local item = HomeCatalog.get(itemId)
	self.PlayerStateService.sync(player, profile)
	self:syncPlayer(player, profile)
	player:SetAttribute("TinyWorldHomeLastAction", item.name)
	self.PlayerStateService.message(player, if itemId == "Bed" then "You rested in your Cosy Bed. Home is your safe starting point." elseif itemId == "KitchenCounter" then "The kitchen is ready for your next TinyWorld recipe." elseif itemId == "Wardrobe" then "Wardrobe opened. Your free starter looks are part of your identity." else "Creative Desk ready. This is where future TinyWorld stories will be made.")
	self.ProfileStore.save(player)
end

function HomeService:buildInterior(plot, profile)
	local anchor = plot.houseAnchor
	local parent = plot.houseContainer
	local function addPrompt(itemId: string, base: BasePart)
		local item = HomeCatalog.get(itemId)
		local prompt = makeFurniturePrompt(base, itemId, item)
		prompt.Triggered:Connect(function(player)
			self:_use(player, plot.index, itemId)
		end)
	end

	makeFurniturePart(parent, "HomeInteriorMat", Vector3.new(10, 0.12, 4), anchor + Vector3.new(0, 1.58, 4.8), VisualTheme.Colors.warmLight, Enum.Material.Fabric)
	if HomeRules.has(profile, "Bed") then
		local bed = makeFurniturePart(parent, "HomeFurniture_BedFrame", Vector3.new(6.5, 1, 4.2), anchor + Vector3.new(-5, 2, -3), VisualTheme.Colors.timberDark, Enum.Material.WoodPlanks)
		makeFurniturePart(parent, "HomeFurniture_BedMattress", Vector3.new(6, 0.7, 3.7), anchor + Vector3.new(-5, 2.8, -3), VisualTheme.Colors.paper, Enum.Material.Fabric)
		makeFurniturePart(parent, "HomeFurniture_BedBlanket", Vector3.new(3, 0.15, 3.6), anchor + Vector3.new(-3.5, 3.25, -3), VisualTheme.Colors.portal, Enum.Material.Fabric)
		makeFurniturePart(parent, "HomeFurniture_BedPillow", Vector3.new(2.2, 0.45, 1.5), anchor + Vector3.new(-6.6, 3.35, -3), VisualTheme.Colors.white, Enum.Material.Fabric)
		addPrompt("Bed", bed)
	end
	if HomeRules.has(profile, "KitchenCounter") then
		local counter = makeFurniturePart(parent, "HomeFurniture_KitchenCounter", Vector3.new(7, 3, 2), anchor + Vector3.new(5, 3, -3), VisualTheme.Colors.sky, Enum.Material.WoodPlanks)
		makeFurniturePart(parent, "HomeFurniture_KitchenTop", Vector3.new(7.3, 0.35, 2.3), anchor + Vector3.new(5, 4.65, -3), VisualTheme.Colors.paper, Enum.Material.Marble)
		makeFurniturePart(parent, "HomeFurniture_KitchenStove", Vector3.new(2, 0.15, 1.4), anchor + Vector3.new(3.5, 4.9, -3), VisualTheme.Colors.inkSoft, Enum.Material.Metal)
		makeFurniturePart(parent, "HomeFurniture_KitchenBowl", Vector3.new(1.3, 0.5, 1.3), anchor + Vector3.new(6.2, 5.05, -3), VisualTheme.Colors.flower, Enum.Material.CeramicTiles)
		addPrompt("KitchenCounter", counter)
	end
	if HomeRules.has(profile, "Wardrobe") then
		local wardrobe = makeFurniturePart(parent, "HomeFurniture_Wardrobe", Vector3.new(4, 6, 2), anchor + Vector3.new(-5, 4.5, 3), VisualTheme.Colors.berry, Enum.Material.Wood)
		makeFurniturePart(parent, "HomeFurniture_WardrobeDoor", Vector3.new(1.7, 5.1, 0.25), anchor + Vector3.new(-5.9, 4.5, 1.9), VisualTheme.Colors.warmLight, Enum.Material.WoodPlanks)
		makeFurniturePart(parent, "HomeFurniture_WardrobeKnob", Vector3.new(0.3, 0.3, 0.3), anchor + Vector3.new(-5.1, 4.5, 1.7), VisualTheme.Colors.gold, Enum.Material.Metal)
		addPrompt("Wardrobe", wardrobe)
	end
	if HomeRules.has(profile, "CreativeDesk") then
		local desk = makeFurniturePart(parent, "HomeFurniture_CreativeDesk", Vector3.new(5, 2, 2.4), anchor + Vector3.new(5, 2.5, 3), VisualTheme.Colors.timber, Enum.Material.WoodPlanks)
		makeFurniturePart(parent, "HomeFurniture_DeskScreen", Vector3.new(2.5, 1.8, 0.3), anchor + Vector3.new(5, 4.4, 1.8), VisualTheme.Colors.skyDeep, Enum.Material.Glass)
		makeFurniturePart(parent, "HomeFurniture_DeskLamp", Vector3.new(0.5, 2, 0.5), anchor + Vector3.new(6.7, 4, 2.2), VisualTheme.Colors.gold, Enum.Material.Neon)
		addPrompt("CreativeDesk", desk)
	end
end

return HomeService
