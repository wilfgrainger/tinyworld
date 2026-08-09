local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local HomeCatalog = require(shared:WaitForChild("HomeCatalog"))
local HomeRules = require(shared:WaitForChild("HomeRules"))
local HomeExpressionRules = require(shared:WaitForChild("HomeExpressionRules"))
local Profession = require(shared:WaitForChild("Profession"))
local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))

local HomeService = {}
HomeService.__index = HomeService

local function makeFurniturePart(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material, artRole: string?): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part:SetAttribute("TinyWorldArtRole", artRole or "home-furniture-display")
	part:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	part.Color = color
	part.Material = material
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function makeRoom(parent: Instance, name: string, artRole: string): Model
	local room = Instance.new("Model")
	room.Name = name
	room:SetAttribute("TinyWorldArtRole", artRole)
	room:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	room.Parent = parent
	return room
end

local function makeInteractionAnchor(parent: Instance, name: string, base: BasePart): Part
	local anchor = Instance.new("Part")
	anchor.Name = name
	anchor.Size = base.Size + Vector3.new(1, 1, 1)
	anchor.CFrame = base.CFrame
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanTouch = false
	anchor.CanQuery = true
	anchor.Transparency = 1
	anchor:SetAttribute("TinyWorldArtRole", "home-interaction-anchor")
	anchor:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	anchor:SetAttribute("TinyWorldInteractionAnchor", true)
	anchor.Parent = parent
	return anchor
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

local function makeAmbientPrompt(parent: BasePart, actionId: string, actionText: string, objectText: string): ProximityPrompt
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "HomeAmbientPrompt_" .. actionId
	prompt.ActionText = actionText
	prompt.ObjectText = objectText
	prompt.HoldDuration = 0.15
	prompt.MaxActivationDistance = 9
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

function HomeService:_use(player: Player, plotIndex: number, itemId: string, target: BasePart?)
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
	local plot = self.world.plots[plotIndex]
	if target and plot and target:IsDescendantOf(plot.houseContainer) then
		local active = target:GetAttribute("TinyWorldHomeItemActive") == true
		target:SetAttribute("TinyWorldHomeItemActive", not active)
		if itemId == "Wardrobe" then
			local closed = target:GetAttribute("TinyWorldClosedCFrame")
			if closed == nil then
				closed = target.CFrame
				target:SetAttribute("TinyWorldClosedCFrame", closed)
			end
			target.CFrame = if active then closed else closed * CFrame.Angles(0, math.rad(-32), 0)
		elseif itemId == "Bed" then
			target.Color = if active then VisualTheme.Colors.paper else themeColour(profile.homeTheme)
		elseif itemId == "KitchenCounter" then
			local kitchenActive = not active
			target:SetAttribute("TinyWorldKitchenReady", kitchenActive)
			local kitchen = target.Parent
			if kitchen ~= nil and kitchen.Name == "HomeRoom_Kitchen" and kitchen:IsDescendantOf(plot.houseContainer) then
				local cooker = kitchen:FindFirstChild("HomeFurniture_Cooker")
				local hob = kitchen:FindFirstChild("HomeFurniture_CookerHob")
				local food = kitchen:FindFirstChild("HomeFurniture_TableFood")
				if cooker and cooker:IsA("BasePart") and cooker:IsDescendantOf(plot.houseContainer) then
					cooker:SetAttribute("TinyWorldKitchenCookerOn", kitchenActive)
					cooker.Material = if kitchenActive then Enum.Material.SmoothPlastic else Enum.Material.Metal
					cooker.Color = if kitchenActive then VisualTheme.Colors.berry else VisualTheme.Colors.inkSoft
				end
				if hob and hob:IsA("BasePart") and hob:IsDescendantOf(plot.houseContainer) then
					hob:SetAttribute("TinyWorldKitchenHobOn", kitchenActive)
					hob.Material = if kitchenActive then Enum.Material.Neon else Enum.Material.Metal
					hob.Color = if kitchenActive then VisualTheme.Colors.gold else VisualTheme.Colors.metal
				end
				if food and food:IsA("BasePart") and food:IsDescendantOf(plot.houseContainer) then
					food:SetAttribute("TinyWorldKitchenFoodReady", kitchenActive)
					food.Transparency = if kitchenActive then 0 else 0.65
					food.Color = if kitchenActive then VisualTheme.Colors.gold else VisualTheme.Colors.flower
				end
			end
		elseif itemId == "CreativeDesk" then
			target.Material = if active then Enum.Material.Glass else Enum.Material.Neon
		end
	end
	self.PlayerStateService.sync(player, profile)
	self:syncPlayer(player, profile)
	player:SetAttribute("TinyWorldHomeLastAction", item.name)
	self.PlayerStateService.message(player, if itemId == "Bed" then "You rested in your Cosy Bed. Home is your safe starting point." elseif itemId == "KitchenCounter" then "The kitchen is ready for your next TinyWorld recipe." elseif itemId == "Wardrobe" then "Wardrobe opened. Your free starter looks are part of your identity." else "Creative Desk ready. This is where future TinyWorld stories will be made.")
	self.ProfileStore.save(player)
end

function HomeService:_useAmbient(player: Player, plotIndex: number, actionId: string, target: BasePart)
	if self.plotService == nil then
		return
	end
	local owner = self.plotService:getOwnerForPlot(plotIndex)
	if owner ~= player then
		self.PlayerStateService.message(player, "Only the homeowner can change things in this home.")
		return
	end
	local plot = self.world.plots[plotIndex]
	if plot == nil or not target:IsDescendantOf(plot.houseContainer) then
		return
	end
	local messages = {
		KitchenUse = "The kitchen is ready for your next TinyWorld recipe.",
		LampToggle = "The bedside lamp gives the room a cosy glow.",
		FridgeToggle = "Fridge opened. There is a little snack waiting inside.",
		SinkUse = "The kitchen tap sparkles, then switches off.",
		ShowerUse = "The shower runs for a moment, warm and bubbly.",
		StorageView = "Storage chest opened. Your collected things stay safely in the Item Chest.",
		PottingUse = "The potting bench is ready for the next garden project.",
	}
	local message = messages[actionId]
	if message == nil then
		return
	end

	local active = target:GetAttribute("TinyWorldAmbientActive") == true
	local nextActive = not active
	target:SetAttribute("TinyWorldAmbientActive", nextActive)
	if actionId == "LampToggle" then
		target.Material = if nextActive then Enum.Material.Neon else Enum.Material.Glass
		target.Transparency = if nextActive then 0 else 0.35
	elseif actionId == "KitchenUse" then
		local kitchenActive = nextActive
		target:SetAttribute("TinyWorldKitchenReady", kitchenActive)
		local kitchen = target.Parent
		if kitchen ~= nil and kitchen.Name == "HomeRoom_Kitchen" and kitchen:IsDescendantOf(plot.houseContainer) then
			local cooker = kitchen:FindFirstChild("HomeFurniture_Cooker")
			local hob = kitchen:FindFirstChild("HomeFurniture_CookerHob")
			local food = kitchen:FindFirstChild("HomeFurniture_TableFood")
			if cooker and cooker:IsA("BasePart") and cooker:IsDescendantOf(plot.houseContainer) then
				cooker:SetAttribute("TinyWorldKitchenCookerOn", kitchenActive)
				cooker.Material = if kitchenActive then Enum.Material.SmoothPlastic else Enum.Material.Metal
				cooker.Color = if kitchenActive then VisualTheme.Colors.berry else VisualTheme.Colors.inkSoft
			end
			if hob and hob:IsA("BasePart") and hob:IsDescendantOf(plot.houseContainer) then
				hob:SetAttribute("TinyWorldKitchenHobOn", kitchenActive)
				hob.Material = if kitchenActive then Enum.Material.Neon else Enum.Material.Metal
				hob.Color = if kitchenActive then VisualTheme.Colors.gold else VisualTheme.Colors.metal
			end
			if food and food:IsA("BasePart") and food:IsDescendantOf(plot.houseContainer) then
				food:SetAttribute("TinyWorldKitchenFoodReady", kitchenActive)
				food.Transparency = if kitchenActive then 0 else 0.65
				food.Color = if kitchenActive then VisualTheme.Colors.gold else VisualTheme.Colors.flower
			end
		end
	elseif actionId == "FridgeToggle" or actionId == "StorageView" then
		local closed = target:GetAttribute("TinyWorldClosedCFrame")
		if closed == nil then
			closed = target.CFrame
			target:SetAttribute("TinyWorldClosedCFrame", closed)
		end
		target.CFrame = if nextActive then closed * CFrame.Angles(0, math.rad(-28), 0) else closed
	elseif actionId == "SinkUse" or actionId == "ShowerUse" then
		target.Transparency = if nextActive then 0.15 else 0.85
		target.Material = if nextActive then Enum.Material.Neon else Enum.Material.Glass
	elseif actionId == "PottingUse" then
		target.Color = if nextActive then VisualTheme.Colors.leafLight else VisualTheme.Colors.timber
	end
	player:SetAttribute("TinyWorldHomeLastAction", actionId)
	self.PlayerStateService.message(player, message)
end

function HomeService:buildInterior(plot, profile)
	local anchor = plot.houseAnchor
	local parent = plot.houseContainer
	local accent = themeColour(profile.homeTheme)

	local function addOwnedPrompt(itemId: string, target: BasePart, promptBase: BasePart?)
		local item = HomeCatalog.get(itemId)
		local base = promptBase or target
		local interactionAnchor = makeInteractionAnchor(base.Parent, "HomeUseAnchor_" .. itemId, base)
		local prompt = makeFurniturePrompt(interactionAnchor, itemId, item)
		prompt.Triggered:Connect(function(player)
			self:_use(player, plot.index, itemId, target)
		end)
	end

	local function addAmbientPrompt(actionId: string, target: BasePart, actionText: string, objectText: string, promptBase: BasePart?)
		local base = promptBase or target
		local interactionAnchor = makeInteractionAnchor(base.Parent, "HomeAmbientAnchor_" .. actionId, base)
		local prompt = makeAmbientPrompt(interactionAnchor, actionId, actionText, objectText)
		prompt.Triggered:Connect(function(player)
			self:_useAmbient(player, plot.index, actionId, target)
		end)
	end

	local bedroom = makeRoom(parent, "HomeRoom_Bedroom", "home-room-bedroom")
	local kitchen = makeRoom(parent, "HomeRoom_Kitchen", "home-room-kitchen")
	local living = makeRoom(parent, "HomeRoom_Living", "home-room-living")
	local bathroom = makeRoom(parent, "HomeRoom_Bathroom", "home-room-bathroom")
	local storage = makeRoom(parent, "HomeRoom_Storage", "home-room-storage")
	local garden = makeRoom(parent, "HomeRoom_Garden", "home-room-garden")

	makeFurniturePart(bedroom, "HomeRoom_BedroomRug", Vector3.new(7.5, 0.12, 6.8), anchor + Vector3.new(-5, 1.64, -3), accent, Enum.Material.Fabric, "home-bedroom-rug")
	makeFurniturePart(kitchen, "HomeRoom_KitchenFloor", Vector3.new(7.5, 0.12, 6.8), anchor + Vector3.new(5, 1.64, -3), VisualTheme.Colors.sky, Enum.Material.CeramicTiles, "home-kitchen-floor")
	makeFurniturePart(living, "HomeFurniture_LivingRug", Vector3.new(8, 0.12, 5), anchor + Vector3.new(-2.5, 1.64, 4.7), VisualTheme.Colors.warmLight, Enum.Material.Fabric, "home-living-rug")
	makeFurniturePart(bathroom, "HomeRoom_BathroomFloor", Vector3.new(4.5, 0.12, 5), anchor + Vector3.new(6.6, 1.65, 4.8), VisualTheme.Colors.paper, Enum.Material.CeramicTiles, "home-bathroom-floor")
	makeFurniturePart(parent, "HomeStyleBanner", Vector3.new(9, 0.7, 0.25), anchor + Vector3.new(0, 6.3, -7.4), accent, Enum.Material.Fabric, "home-theme-banner")
	makeFurniturePart(parent, "HomeRoomDivider", Vector3.new(0.3, 2.6, 7), anchor + Vector3.new(0, 2.8, -3), VisualTheme.Colors.timber, Enum.Material.WoodPlanks, "home-room-divider")

	if HomeRules.has(profile, "Bed") then
		local bed = makeFurniturePart(bedroom, "HomeFurniture_BedFrame", Vector3.new(6.5, 1, 4.2), anchor + Vector3.new(-5, 2, -3), VisualTheme.Colors.timberDark, Enum.Material.WoodPlanks, "home-furniture-bed")
		makeFurniturePart(bedroom, "HomeFurniture_BedMattress", Vector3.new(6, 0.7, 3.7), anchor + Vector3.new(-5, 2.8, -3), VisualTheme.Colors.paper, Enum.Material.Fabric, "home-bed-mattress")
		local blanket = makeFurniturePart(bedroom, "HomeFurniture_BedBlanket", Vector3.new(3, 0.15, 3.6), anchor + Vector3.new(-3.5, 3.25, -3), VisualTheme.Colors.portal, Enum.Material.Fabric, "home-bed-blanket")
		makeFurniturePart(bedroom, "HomeFurniture_BedPillow", Vector3.new(2.2, 0.45, 1.5), anchor + Vector3.new(-6.6, 3.35, -3), VisualTheme.Colors.white, Enum.Material.Fabric, "home-bed-pillow")
		addOwnedPrompt("Bed", blanket, bed)
	end
	local lampStand = makeFurniturePart(bedroom, "HomeFurniture_BedsideLampStand", Vector3.new(0.45, 2.5, 0.45), anchor + Vector3.new(-8, 2.8, -5.7), VisualTheme.Colors.timberDark, Enum.Material.Wood, "home-bedside-lamp-stand")
	local lamp = makeFurniturePart(bedroom, "HomeFurniture_BedsideLamp", Vector3.new(1.3, 1.3, 1.3), anchor + Vector3.new(-8, 4.2, -5.7), VisualTheme.Colors.gold, Enum.Material.Neon, "home-bedside-lamp")
	lamp.Shape = Enum.PartType.Ball
	addAmbientPrompt("LampToggle", lamp, "Toggle Lamp", "Bedside Lamp", lampStand)
	makeFurniturePart(bedroom, "HomeFurniture_BedroomMirror", Vector3.new(0.3, 4, 2.8), anchor + Vector3.new(-8.3, 4.2, 0), VisualTheme.Colors.sky, Enum.Material.Glass, "home-bedroom-mirror")
	makeFurniturePart(bedroom, "HomeFurniture_BedroomShelf", Vector3.new(4, 0.5, 1.2), anchor + Vector3.new(-3, 5.2, -6.7), VisualTheme.Colors.timber, Enum.Material.WoodPlanks, "home-bedroom-shelf")
	if HomeRules.has(profile, "Wardrobe") then
		local wardrobe = makeFurniturePart(bedroom, "HomeFurniture_Wardrobe", Vector3.new(4, 6, 2), anchor + Vector3.new(-6.2, 4.5, 1.2), VisualTheme.Colors.berry, Enum.Material.Wood, "home-furniture-wardrobe")
		local wardrobeDoor = makeFurniturePart(bedroom, "HomeFurniture_WardrobeDoor", Vector3.new(1.7, 5.1, 0.25), anchor + Vector3.new(-7.1, 4.5, 0.1), VisualTheme.Colors.warmLight, Enum.Material.WoodPlanks, "home-wardrobe-door")
		makeFurniturePart(bedroom, "HomeFurniture_WardrobeKnob", Vector3.new(0.3, 0.3, 0.3), anchor + Vector3.new(-6.3, 4.5, -0.1), VisualTheme.Colors.gold, Enum.Material.Metal, "home-wardrobe-handle")
		addOwnedPrompt("Wardrobe", wardrobeDoor, wardrobe)
	end

	local fridge = makeFurniturePart(kitchen, "HomeFurniture_Fridge", Vector3.new(3, 6, 2.4), anchor + Vector3.new(7, 4.5, -5.5), VisualTheme.Colors.paper, Enum.Material.Metal, "home-kitchen-fridge")
	local fridgeDoor = makeFurniturePart(kitchen, "HomeFurniture_FridgeDoor", Vector3.new(2.7, 5.4, 0.3), anchor + Vector3.new(7, 4.5, -4.15), VisualTheme.Colors.sky, Enum.Material.Metal, "home-fridge-door")
	makeFurniturePart(kitchen, "HomeFurniture_FridgeHandle", Vector3.new(0.25, 2.2, 0.25), anchor + Vector3.new(7.9, 4.5, -3.9), VisualTheme.Colors.metal, Enum.Material.Metal, "home-fridge-handle")
	addAmbientPrompt("FridgeToggle", fridgeDoor, "Open / Close", "Fridge", fridge)
	local counter = makeFurniturePart(kitchen, "HomeFurniture_KitchenCounter", Vector3.new(6.5, 3, 2), anchor + Vector3.new(3.5, 3, -6), VisualTheme.Colors.sky, Enum.Material.WoodPlanks, "home-furniture-kitchen-counter")
	makeFurniturePart(kitchen, "HomeFurniture_KitchenTop", Vector3.new(6.8, 0.35, 2.3), anchor + Vector3.new(3.5, 4.65, -6), VisualTheme.Colors.paper, Enum.Material.Marble, "home-kitchen-worktop")
	if HomeRules.has(profile, "KitchenCounter") then
		addOwnedPrompt("KitchenCounter", counter)
	else
		addAmbientPrompt("KitchenUse", counter, "Use Kitchen", "Kitchen Counter", counter)
	end
	local kitchenSink = makeFurniturePart(kitchen, "HomeFurniture_KitchenSink", Vector3.new(2.1, 0.45, 1.4), anchor + Vector3.new(5, 4.95, -6), VisualTheme.Colors.metal, Enum.Material.Metal, "home-kitchen-sink")
	local kitchenWater = makeFurniturePart(kitchen, "HomeFurniture_KitchenTapWater", Vector3.new(0.25, 1.5, 0.25), anchor + Vector3.new(5, 5.7, -6), VisualTheme.Colors.sky, Enum.Material.Glass, "home-kitchen-water")
	kitchenWater.Transparency = 0.85
	addAmbientPrompt("SinkUse", kitchenWater, "Run Tap", "Kitchen Sink", kitchenSink)
	local cooker = makeFurniturePart(kitchen, "HomeFurniture_Cooker", Vector3.new(2.5, 3.2, 2), anchor + Vector3.new(1.3, 3.1, -6), VisualTheme.Colors.inkSoft, Enum.Material.Metal, "home-kitchen-cooker")
	makeFurniturePart(kitchen, "HomeFurniture_CookerHob", Vector3.new(2.2, 0.18, 1.6), anchor + Vector3.new(1.3, 4.8, -6), VisualTheme.Colors.metal, Enum.Material.Metal, "home-cooker-hob")
	local diningTable = makeFurniturePart(kitchen, "HomeFurniture_DiningTable", Vector3.new(4.5, 0.7, 3), anchor + Vector3.new(4.2, 2.8, -0.7), VisualTheme.Colors.timber, Enum.Material.WoodPlanks, "home-dining-table")
	makeFurniturePart(kitchen, "HomeFurniture_DiningChairLeft", Vector3.new(1.6, 2.4, 1.6), anchor + Vector3.new(1.2, 2.7, -0.7), VisualTheme.Colors.timberDark, Enum.Material.Wood, "home-dining-chair")
	makeFurniturePart(kitchen, "HomeFurniture_DiningChairRight", Vector3.new(1.6, 2.4, 1.6), anchor + Vector3.new(7.1, 2.7, -0.7), VisualTheme.Colors.timberDark, Enum.Material.Wood, "home-dining-chair")
	local food = makeFurniturePart(kitchen, "HomeFurniture_TableFood", Vector3.new(1.1, 0.7, 1.1), diningTable.Position + Vector3.new(0, 0.75, 0), VisualTheme.Colors.flower, Enum.Material.SmoothPlastic, "home-table-food")
	food.Shape = Enum.PartType.Ball

	local sofa = makeFurniturePart(living, "HomeFurniture_Sofa", Vector3.new(5.5, 2.4, 2.3), anchor + Vector3.new(-4, 3, 5.5), accent, Enum.Material.Fabric, "home-living-sofa")
	makeFurniturePart(living, "HomeFurniture_SofaBack", Vector3.new(5.5, 2.8, 0.7), anchor + Vector3.new(-4, 4.3, 6.2), accent, Enum.Material.Fabric, "home-sofa-back")
	makeFurniturePart(living, "HomeFurniture_SideTable", Vector3.new(2, 1.8, 2), anchor + Vector3.new(-7.3, 2.6, 5.5), VisualTheme.Colors.timber, Enum.Material.WoodPlanks, "home-side-table")
	makeFurniturePart(living, "HomeFurniture_BookToyShelf", Vector3.new(4, 4.5, 1.2), anchor + Vector3.new(-7, 3.8, 1.8), VisualTheme.Colors.timberDark, Enum.Material.Wood, "home-book-toy-shelf")
	makeFurniturePart(living, "HomeFurniture_ToyBlock", Vector3.new(1, 1, 1), anchor + Vector3.new(-6.5, 2.2, 1), VisualTheme.Colors.gold, Enum.Material.Wood, "home-toy")
	if HomeRules.has(profile, "CreativeDesk") then
		local desk = makeFurniturePart(living, "HomeFurniture_CreativeDesk", Vector3.new(4.5, 2, 2.2), anchor + Vector3.new(0.4, 2.5, 5.8), VisualTheme.Colors.timber, Enum.Material.WoodPlanks, "home-furniture-creative-desk")
		local screen = makeFurniturePart(living, "HomeFurniture_DeskScreen", Vector3.new(2.5, 1.8, 0.3), anchor + Vector3.new(0.4, 4.4, 4.6), VisualTheme.Colors.skyDeep, Enum.Material.Glass, "home-desk-screen")
		makeFurniturePart(living, "HomeFurniture_DeskLamp", Vector3.new(0.5, 2, 0.5), anchor + Vector3.new(2.1, 4, 5), VisualTheme.Colors.gold, Enum.Material.Neon, "home-desk-lamp")
		addOwnedPrompt("CreativeDesk", screen, desk)
	end
	sofa:SetAttribute("TinyWorldRecognizableSilhouette", true)

	local bathroomSink = makeFurniturePart(bathroom, "HomeFurniture_BathroomSink", Vector3.new(2.2, 1.2, 1.8), anchor + Vector3.new(5.5, 3, 3.2), VisualTheme.Colors.paper, Enum.Material.CeramicTiles, "home-bathroom-sink")
	makeFurniturePart(bathroom, "HomeFurniture_Toilet", Vector3.new(1.8, 2.2, 2.4), anchor + Vector3.new(7.8, 2.8, 3.3), VisualTheme.Colors.paper, Enum.Material.CeramicTiles, "home-bathroom-toilet")
	local shower = makeFurniturePart(bathroom, "HomeFurniture_Shower", Vector3.new(3.4, 0.4, 2.8), anchor + Vector3.new(6.7, 1.9, 6.5), VisualTheme.Colors.sky, Enum.Material.CeramicTiles, "home-bathroom-shower")
	makeFurniturePart(bathroom, "HomeFurniture_ShowerScreen", Vector3.new(3.4, 4.5, 0.25), anchor + Vector3.new(6.7, 4.1, 5.1), VisualTheme.Colors.sky, Enum.Material.Glass, "home-shower-screen")
	local showerWater = makeFurniturePart(bathroom, "HomeFurniture_ShowerWater", Vector3.new(0.45, 3.5, 0.45), anchor + Vector3.new(6.7, 4.8, 6.5), VisualTheme.Colors.sky, Enum.Material.Glass, "home-shower-water")
	showerWater.Transparency = 0.85
	addAmbientPrompt("ShowerUse", showerWater, "Run Shower", "Shower", shower)
	bathroomSink:SetAttribute("TinyWorldRecognizableSilhouette", true)

	local chest = makeFurniturePart(storage, "HomeFurniture_StorageChest", Vector3.new(3.8, 2.2, 2.8), anchor + Vector3.new(2.8, 2.7, 6.6), VisualTheme.Colors.timber, Enum.Material.WoodPlanks, "home-storage-chest")
	chest:SetAttribute("TinyWorldStorageContract", "ItemChest")
	local chestLid = makeFurniturePart(storage, "HomeFurniture_StorageChestLid", Vector3.new(4, 0.45, 3), anchor + Vector3.new(2.8, 4, 6.6), VisualTheme.Colors.woodLight, Enum.Material.Wood, "home-storage-chest-lid")
	makeFurniturePart(storage, "HomeFurniture_StorageChestHandle", Vector3.new(1.4, 0.35, 0.4), anchor + Vector3.new(2.8, 3.4, 8.1), VisualTheme.Colors.gold, Enum.Material.Metal, "home-storage-chest-handle")
	addAmbientPrompt("StorageView", chestLid, "View Storage", "Item Chest", chest)

	local pottingBench = makeFurniturePart(garden, "HomeGarden_PottingBench", Vector3.new(7, 2.2, 3), anchor + Vector3.new(13, 2.2, -3), VisualTheme.Colors.timber, Enum.Material.WoodPlanks, "home-garden-potting-bench")
	makeFurniturePart(garden, "HomeGarden_PottingShelf", Vector3.new(6.5, 0.5, 2), anchor + Vector3.new(13, 4.8, -3), VisualTheme.Colors.timberDark, Enum.Material.Wood, "home-garden-potting-shelf")
	makeFurniturePart(garden, "HomeGarden_FlowerArchLeft", Vector3.new(0.8, 7, 0.8), anchor + Vector3.new(10, 4, 3), VisualTheme.Colors.leaf, Enum.Material.LeafyGrass, "home-garden-flower-arch")
	makeFurniturePart(garden, "HomeGarden_FlowerArchRight", Vector3.new(0.8, 7, 0.8), anchor + Vector3.new(16, 4, 3), VisualTheme.Colors.leaf, Enum.Material.LeafyGrass, "home-garden-flower-arch")
	makeFurniturePart(garden, "HomeGarden_FlowerArch", Vector3.new(7, 0.9, 0.9), anchor + Vector3.new(13, 7.4, 3), VisualTheme.Colors.flower, Enum.Material.LeafyGrass, "home-garden-flower-arch")
	makeFurniturePart(garden, "HomeGarden_RaisedBed", Vector3.new(7, 0.7, 4), anchor + Vector3.new(13, 1, -7), VisualTheme.Colors.timberDark, Enum.Material.Ground, "home-garden-raised-bed")
	addAmbientPrompt("PottingUse", pottingBench, "Use Potting Bench", "Garden Workbench")

	if HomeExpressionRules.hasDecoration(profile, "LanternNook") then
		local lantern = makeFurniturePart(living, "HomeDecor_LanternNook", Vector3.new(1.4, 1.8, 1.4), anchor + Vector3.new(-8, 4.3, 4), VisualTheme.Colors.gold, Enum.Material.Neon, "home-decor-lantern-nook")
		lantern.Shape = Enum.PartType.Ball
		makeFurniturePart(living, "HomeDecor_LanternStand", Vector3.new(0.5, 2.5, 0.5), anchor + Vector3.new(-8, 2.7, 4), VisualTheme.Colors.timberDark, Enum.Material.Wood, "home-decor-lantern-stand")
	end
	if HomeExpressionRules.hasDecoration(profile, "StoryBookStack") then
		makeFurniturePart(living, "HomeDecor_StoryBookStack1", Vector3.new(2.4, 0.45, 1.8), anchor + Vector3.new(0.8, 2.25, 4), VisualTheme.Colors.berry, Enum.Material.Fabric, "home-decor-story-books")
		makeFurniturePart(living, "HomeDecor_StoryBookStack2", Vector3.new(2.1, 0.45, 1.7), anchor + Vector3.new(0.8, 2.7, 4), VisualTheme.Colors.sky, Enum.Material.Fabric, "home-decor-story-books")
		makeFurniturePart(living, "HomeDecor_StoryBookStack3", Vector3.new(1.8, 0.45, 1.6), anchor + Vector3.new(0.8, 3.15, 4), VisualTheme.Colors.gold, Enum.Material.Fabric, "home-decor-story-books")
	end
	if HomeExpressionRules.hasDecoration(profile, "MeadowSeedShelf") then
		makeFurniturePart(living, "HomeDecor_MeadowSeedShelf", Vector3.new(4.5, 0.45, 1.4), anchor + Vector3.new(2.5, 4.3, 4), VisualTheme.Colors.timber, Enum.Material.WoodPlanks, "home-decor-seed-shelf")
		for index = 1, 3 do
			local seed = makeFurniturePart(living, "HomeDecor_MeadowSeed" .. index, Vector3.new(0.7, 0.9, 0.7), anchor + Vector3.new(1.1 + (index * 1.2), 5, 4), accent, Enum.Material.Grass, "inventory-seed")
			seed.Shape = Enum.PartType.Ball
		end
	end
	if HomeExpressionRules.hasDecoration(profile, "SeashellDisplay") then
		makeFurniturePart(living, "HomeDecor_SeashellDisplay", Vector3.new(4, 2.3, 1.1), anchor + Vector3.new(-2.5, 3.8, 4), VisualTheme.Colors.sky, Enum.Material.Glass, "home-decor-seashell-display")
		for index = 1, 2 do
			local seashell = makeFurniturePart(living, "HomeDecor_Seashell" .. index, Vector3.new(0.8, 0.5, 0.8), anchor + Vector3.new(-3.3 + (index * 1.4), 5, 3.3), VisualTheme.Colors.white, Enum.Material.CeramicTiles, "inventory-seashell")
			seashell.Shape = Enum.PartType.Ball
		end
	end
	if HomeExpressionRules.hasDecoration(profile, "WoodlandBench") then
		makeFurniturePart(living, "HomeDecor_WoodlandBenchSeat", Vector3.new(5, 0.8, 1.5), anchor + Vector3.new(5, 2.1, 4.3), VisualTheme.Colors.timber, Enum.Material.WoodPlanks, "home-decor-woodland-bench")
		makeFurniturePart(living, "HomeDecor_WoodlandBenchBack", Vector3.new(5, 2.1, 0.5), anchor + Vector3.new(5, 3, 4.8), VisualTheme.Colors.timberDark, Enum.Material.Wood, "home-decor-woodland-bench")
	end
	if HomeExpressionRules.hasDecoration(profile, "PortalPainting") then
		makeFurniturePart(parent, "HomeDecor_PortalPaintingFrame", Vector3.new(5.5, 4.5, 0.4), anchor + Vector3.new(0, 5, -7.1), VisualTheme.Colors.gold, Enum.Material.Wood, "home-decor-portal-painting-frame")
		makeFurniturePart(parent, "HomeDecor_PortalPainting", Vector3.new(4.7, 3.7, 0.2), anchor + Vector3.new(0, 5, -6.85), VisualTheme.Colors.portal, Enum.Material.Neon, "home-decor-portal-painting")
	end

	local plaque = makeFurniturePart(living, "HomeShowcasePlaque", Vector3.new(3.5, 1.8, 0.35), anchor + Vector3.new(0, 3, 7), accent, Enum.Material.WoodPlanks, "home-showcase-plaque")
	local showcaseAnchor = makeInteractionAnchor(living, "HomeShowcaseAnchor", plaque)
	local showcasePrompt = makeFurniturePrompt(showcaseAnchor, "Showcase", { action = "Showcase Home", name = profile.homeTheme .. " Home" })
	showcasePrompt.Triggered:Connect(function(player)
		self:_showcase(player, plot.index)
	end)
end

return HomeService
