local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local HomeCatalog = require(shared:WaitForChild("HomeCatalog"))
local HomeRules = require(shared:WaitForChild("HomeRules"))
local HomeExpressionRules = require(shared:WaitForChild("HomeExpressionRules"))
local Profession = require(shared:WaitForChild("Profession"))
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
	part:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
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

local function themeColour(theme: string): Color3
	if theme == "Harbor" then
		return VisualTheme.Colors.sky
	elseif theme == "Sunset" then
		return VisualTheme.Colors.berry
	end
	return VisualTheme.Colors.flower
end

local function resourceName(resource: string): string
	local names = {
		MeadowSeed = "a Meadow Seed",
		Seashell = "a Seashell",
		WoodToken = "a Wood Token",
	}
	return names[resource] or resource
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
	world.homeDecorPrompt.Triggered:Connect(function(player)
		self:_acquireNextDecoration(player)
	end)
	world.homeStylePrompt.Triggered:Connect(function(player)
		self:_cycleStyle(player)
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
	player:SetAttribute("TinyWorldHomeTheme", profile.homeTheme)
	player:SetAttribute("TinyWorldHomeDecorCount", HomeExpressionRules.decorCount(profile))
	player:SetAttribute("TinyWorldHomeShowcaseCount", profile.homeShowcaseCount)
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
	self.world.homeDecorLabel.Text = "HOME GALLERY\nSix authored pieces\nCoins, keepsakes, portals"
	self.world.homeStyleLabel.Text = "HOME STYLE\nMeadow • Harbor • Sunset\nChoose your light"
end

function HomeService:_acquireNextDecoration(player: Player)
	local profile = self.ProfileStore.get(player)
	if profile == nil then
		return
	end
	local itemId = HomeExpressionRules.nextDecoration(profile)
	if itemId == nil then
		self.PlayerStateService.message(player, "Your home collection is complete. Choose a style and show it off.")
		return
	end
	local item = HomeExpressionRules.getDecoration(itemId)
	local acquired, reason = HomeExpressionRules.acquire(profile, itemId)
	if not acquired then
		local text = if reason == "not_enough_coins" then string.format("%s costs %d coins. Keep playing to bring it home.", item.name, item.costCoins)
			elseif reason == "missing_resource" then string.format("Bring %s to craft your %s.", resourceName(item.resource), item.name)
			elseif reason == "world_gate" then "Complete a portal world before collecting the Portal Painting."
			else "That home piece is not available yet."
		self.PlayerStateService.message(player, text)
		return
	end
	local designerLevels = Profession.addXp(profile, "Designer", 50)
	local plot = self.plotService and self.plotService:getPlotForPlayer(player)
	if plot then
		self.plotService:rebuildHouse(player, profile)
	end
	self.PlayerStateService.sync(player, profile)
	self:syncPlayer(player, profile)
	self.PlayerStateService.message(player, string.format("%s added to your home. Designer XP +50%s. Your rooms are becoming yours.", item.name, if designerLevels > 0 then " — Designer level up!" else ""))
	self.ProfileStore.save(player)
end

function HomeService:_cycleStyle(player: Player)
	local profile = self.ProfileStore.get(player)
	if profile == nil then
		return
	end
	local nextTheme = HomeExpressionRules.cycleTheme(profile.homeTheme)
	HomeExpressionRules.setTheme(profile, nextTheme)
	local plot = self.plotService and self.plotService:getPlotForPlayer(player)
	if plot then
		self.plotService:rebuildHouse(player, profile)
	end
	self.PlayerStateService.sync(player, profile)
	self:syncPlayer(player, profile)
	self.PlayerStateService.message(player, "Home style changed to " .. nextTheme .. ". Make it feel like yours.")
	self.ProfileStore.save(player)
end

function HomeService:_showcase(player: Player, plotIndex: number)
	if self.plotService == nil then
		return
	end
	local owner = self.plotService:getOwnerForPlot(plotIndex)
	if owner ~= player then
		self.PlayerStateService.message(player, "Only the homeowner can place their home on showcase.")
		return
	end
	local profile = self.ProfileStore.get(player)
	if profile == nil then
		return
	end
	local count = HomeExpressionRules.showcase(profile)
	local designerLevels = Profession.addXp(profile, "Designer", 25)
	self.PlayerStateService.sync(player, profile)
	self:syncPlayer(player, profile)
	self.PlayerStateService.message(player, string.format("Home showcased: %s style, %d display visit(s). Designer XP +25%s.", profile.homeTheme, count, if designerLevels > 0 then " — Designer level up!" else ""))
	self.ProfileStore.save(player)
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
	local accent = themeColour(profile.homeTheme)
	makeFurniturePart(parent, "HomeStyleBanner", Vector3.new(9, 0.7, 0.25), anchor + Vector3.new(0, 6.3, -7.4), accent, Enum.Material.Fabric)
	makeFurniturePart(parent, "HomeRoomRest", Vector3.new(7.5, 0.12, 7), anchor + Vector3.new(-5, 1.64, -3), accent, Enum.Material.Fabric)
	makeFurniturePart(parent, "HomeRoomMake", Vector3.new(7.5, 0.12, 7), anchor + Vector3.new(5, 1.64, -3), VisualTheme.Colors.sky, Enum.Material.Fabric)
	makeFurniturePart(parent, "HomeRoomShowcase", Vector3.new(11, 0.12, 4.2), anchor + Vector3.new(0, 1.64, 4.6), VisualTheme.Colors.gold, Enum.Material.Fabric)
	makeFurniturePart(parent, "HomeRoomDivider", Vector3.new(0.3, 2.6, 7), anchor + Vector3.new(0, 2.8, -3), VisualTheme.Colors.timber, Enum.Material.WoodPlanks)
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

	if HomeExpressionRules.hasDecoration(profile, "LanternNook") then
		local lantern = makeFurniturePart(parent, "HomeDecor_LanternNook", Vector3.new(1.4, 1.8, 1.4), anchor + Vector3.new(-8, 4.3, 4), VisualTheme.Colors.gold, Enum.Material.Neon)
		lantern.Shape = Enum.PartType.Ball
		makeFurniturePart(parent, "HomeDecor_LanternStand", Vector3.new(0.5, 2.5, 0.5), anchor + Vector3.new(-8, 2.7, 4), VisualTheme.Colors.timberDark, Enum.Material.Wood)
	end
	if HomeExpressionRules.hasDecoration(profile, "StoryBookStack") then
		makeFurniturePart(parent, "HomeDecor_StoryBookStack1", Vector3.new(2.4, 0.45, 1.8), anchor + Vector3.new(0.8, 2.25, 4), VisualTheme.Colors.berry, Enum.Material.Fabric)
		makeFurniturePart(parent, "HomeDecor_StoryBookStack2", Vector3.new(2.1, 0.45, 1.7), anchor + Vector3.new(0.8, 2.7, 4), VisualTheme.Colors.sky, Enum.Material.Fabric)
		makeFurniturePart(parent, "HomeDecor_StoryBookStack3", Vector3.new(1.8, 0.45, 1.6), anchor + Vector3.new(0.8, 3.15, 4), VisualTheme.Colors.gold, Enum.Material.Fabric)
	end
	if HomeExpressionRules.hasDecoration(profile, "MeadowSeedShelf") then
		makeFurniturePart(parent, "HomeDecor_MeadowSeedShelf", Vector3.new(4.5, 0.45, 1.4), anchor + Vector3.new(2.5, 4.3, 4), VisualTheme.Colors.timber, Enum.Material.WoodPlanks)
		for index = 1, 3 do
			local seed = makeFurniturePart(parent, "HomeDecor_MeadowSeed" .. index, Vector3.new(0.7, 0.9, 0.7), anchor + Vector3.new(1.1 + (index * 1.2), 5, 4), accent, Enum.Material.Neon)
			seed.Shape = Enum.PartType.Ball
		end
	end
	if HomeExpressionRules.hasDecoration(profile, "SeashellDisplay") then
		makeFurniturePart(parent, "HomeDecor_SeashellDisplay", Vector3.new(4, 2.3, 1.1), anchor + Vector3.new(-2.5, 3.8, 4), VisualTheme.Colors.sky, Enum.Material.Glass)
		for index = 1, 2 do
			local shell = makeFurniturePart(parent, "HomeDecor_Seashell" .. index, Vector3.new(0.8, 0.5, 0.8), anchor + Vector3.new(-3.3 + (index * 1.4), 5, 3.3), VisualTheme.Colors.white, Enum.Material.CeramicTiles)
			shell.Shape = Enum.PartType.Ball
		end
	end
	if HomeExpressionRules.hasDecoration(profile, "WoodlandBench") then
		makeFurniturePart(parent, "HomeDecor_WoodlandBenchSeat", Vector3.new(5, 0.8, 1.5), anchor + Vector3.new(5, 2.1, 4.3), VisualTheme.Colors.timber, Enum.Material.WoodPlanks)
		makeFurniturePart(parent, "HomeDecor_WoodlandBenchBack", Vector3.new(5, 2.1, 0.5), anchor + Vector3.new(5, 3, 4.8), VisualTheme.Colors.timberDark, Enum.Material.Wood)
	end
	if HomeExpressionRules.hasDecoration(profile, "PortalPainting") then
		makeFurniturePart(parent, "HomeDecor_PortalPaintingFrame", Vector3.new(5.5, 4.5, 0.4), anchor + Vector3.new(0, 5, -7.1), VisualTheme.Colors.gold, Enum.Material.Wood)
		makeFurniturePart(parent, "HomeDecor_PortalPainting", Vector3.new(4.7, 3.7, 0.2), anchor + Vector3.new(0, 5, -6.85), VisualTheme.Colors.portal, Enum.Material.Neon)
	end

	local plaque = makeFurniturePart(parent, "HomeShowcasePlaque", Vector3.new(3.5, 1.8, 0.35), anchor + Vector3.new(7, 3, 4.5), accent, Enum.Material.WoodPlanks)
	local showcasePrompt = makeFurniturePrompt(plaque, "Showcase", { action = "Showcase Home", name = profile.homeTheme .. " Home" })
	showcasePrompt.Triggered:Connect(function(player)
		self:_showcase(player, plot.index)
	end)
end

return HomeService
