local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local HouseCatalog = require(shared:WaitForChild("HouseCatalog"))
local HouseUpgrade = require(shared:WaitForChild("HouseUpgrade"))

local PlotService = {}
PlotService.__index = PlotService

local function makeHousePart(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material?): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Size = size
	part.Position = position
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function makeHouseLabel(parent: BasePart, text: string)
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(220, 55)
	gui.StudsOffset = Vector3.new(0, 3, 0)
	gui.AlwaysOnTop = true
	gui.Parent = parent
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = Color3.fromRGB(34, 38, 48)
	label.BackgroundTransparency = 0.15
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextScaled = true
	label.TextWrapped = true
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.Parent = gui
end

local function nextPrivacy(current: string): string
	if current == "Open" then
		return "Friends"
	elseif current == "Friends" then
		return "Private"
	end
	return "Open"
end

function PlotService.new(world, ProfileStore, PlayerStateService)
	local self = setmetatable({}, PlotService)
	self.world = world
	self.ProfileStore = ProfileStore
	self.PlayerStateService = PlayerStateService
	self.playerPlots = {}
	self.plotOwners = {}

	for plotIndex, plot in world.plots do
		plot.upgradePrompt.Triggered:Connect(function(player)
			self:_upgrade(player, plotIndex)
		end)
		plot.privacyPrompt.Triggered:Connect(function(player)
			self:_cyclePrivacy(player, plotIndex)
		end)
		plot.visitPrompt.Triggered:Connect(function(player)
			self:_visit(player, plotIndex)
		end)
	end

	return self
end

function PlotService:_ownerProfile(plotIndex: number)
	local owner = self.plotOwners[plotIndex]
	if owner == nil then
		return nil, nil
	end
	return owner, self.ProfileStore.get(owner)
end

function PlotService:_upgrade(player: Player, plotIndex: number)
	local owner, profile = self:_ownerProfile(plotIndex)
	if owner ~= player or profile == nil then
		self.PlayerStateService.message(player, "Only the plot owner can upgrade this home.")
		return
	end

	local upgraded, reason = HouseUpgrade.tryUpgrade(profile)
	if not upgraded then
		local text = if reason == "level_too_low" then "You need a higher player level for the next home."
			elseif reason == "not_enough_coins" then "You need more coins for the next home."
			else "Your home is already at the highest v0.01 tier."
		self.PlayerStateService.message(player, text)
		return
	end

	self:rebuildHouse(player, profile)
	self.PlayerStateService.sync(player, profile)
	local house = HouseCatalog.get(profile.houseTier)
	self.PlayerStateService.message(player, string.format("Home upgraded to %s!", if house then house.name else "the next tier"))
end

function PlotService:_cyclePrivacy(player: Player, plotIndex: number)
	local owner, profile = self:_ownerProfile(plotIndex)
	if owner ~= player or profile == nil then
		self.PlayerStateService.message(player, "Only the plot owner can change home privacy.")
		return
	end
	profile.homePrivacy = nextPrivacy(profile.homePrivacy)
	self.world.plots[plotIndex].privacyPrompt.ObjectText = "Home Access: " .. profile.homePrivacy
	self.PlayerStateService.sync(player, profile)
	self.PlayerStateService.message(player, "Home privacy is now " .. profile.homePrivacy .. ".")
end

function PlotService:_visit(player: Player, plotIndex: number)
	local owner, profile = self:_ownerProfile(plotIndex)
	if owner == nil or profile == nil then
		self.PlayerStateService.message(player, "This plot is currently available.")
		return
	end

	local allowed = player == owner or profile.homePrivacy == "Open"
	if not allowed and profile.homePrivacy == "Friends" then
		local ok, isFriend = pcall(function()
			return player:IsFriendsWith(owner.UserId)
		end)
		allowed = ok and isFriend
	end

	if not allowed then
		self.PlayerStateService.message(player, owner.Name .. "'s home is private.")
		return
	end

	local character = player.Character
	if character then
		character:PivotTo(self.world.plots[plotIndex].insideCFrame)
		self.PlayerStateService.message(player, "Welcome to " .. owner.Name .. "'s home.")
	end
end

function PlotService:assign(player: Player, profile)
	if self.playerPlots[player] ~= nil then
		return self.playerPlots[player]
	end
	for index, plot in self.world.plots do
		if self.plotOwners[index] == nil then
			self.plotOwners[index] = player
			self.playerPlots[player] = index
			plot.ownerLabel.Text = player.Name .. "'s Plot"
			plot.privacyPrompt.ObjectText = "Home Access: " .. profile.homePrivacy
			self:rebuildHouse(player, profile)
			return index
		end
	end
	self.PlayerStateService.message(player, "All four prototype home plots are occupied; village activities still work.")
	return nil
end

function PlotService:rebuildHouse(player: Player, profile)
	local plotIndex = self.playerPlots[player]
	if plotIndex == nil then
		return
	end
	local plot = self.world.plots[plotIndex]
	plot.houseContainer:ClearAllChildren()

	local tier = profile.houseTier
	local house = HouseCatalog.get(tier)
	local width = 18 + ((tier - 1) * 5)
	local depth = 16 + ((tier - 1) * 4)
	local height = 9 + ((tier - 1) * 2)
	local anchor = plot.houseAnchor
	local wallColor = Color3.fromRGB(236 - (tier * 9), 204 - (tier * 5), 161 + (tier * 5))
	local roofColor = Color3.fromRGB(121 + (tier * 8), 72, 64 + (tier * 5))

	makeHousePart(plot.houseContainer, "Floor", Vector3.new(width, 1, depth), anchor, Color3.fromRGB(185, 154, 112), Enum.Material.WoodPlanks)
	makeHousePart(plot.houseContainer, "BackWall", Vector3.new(width, height, 1), anchor + Vector3.new(0, height / 2, -depth / 2), wallColor)
	makeHousePart(plot.houseContainer, "LeftWall", Vector3.new(1, height, depth), anchor + Vector3.new(-width / 2, height / 2, 0), wallColor)
	makeHousePart(plot.houseContainer, "RightWall", Vector3.new(1, height, depth), anchor + Vector3.new(width / 2, height / 2, 0), wallColor)
	local frontSegment = math.max(4, (width - 7) / 2)
	makeHousePart(plot.houseContainer, "FrontLeft", Vector3.new(frontSegment, height, 1), anchor + Vector3.new(-(width - frontSegment) / 2, height / 2, depth / 2), wallColor)
	makeHousePart(plot.houseContainer, "FrontRight", Vector3.new(frontSegment, height, 1), anchor + Vector3.new((width - frontSegment) / 2, height / 2, depth / 2), wallColor)
	makeHousePart(plot.houseContainer, "Roof", Vector3.new(width + 2, 2, depth + 2), anchor + Vector3.new(0, height + 1, 0), roofColor, Enum.Material.Slate)

	if tier >= 3 then
		makeHousePart(plot.houseContainer, "UpperFeature", Vector3.new(width * 0.55, 5 + tier, depth * 0.5), anchor + Vector3.new(0, height + 4, -2), wallColor)
		makeHousePart(plot.houseContainer, "UpperRoof", Vector3.new((width * 0.55) + 2, 2, (depth * 0.5) + 2), anchor + Vector3.new(0, height + 8 + (tier / 2), -2), roofColor, Enum.Material.Slate)
	end
	if tier == 5 then
		makeHousePart(plot.houseContainer, "VillaTower", Vector3.new(7, 14, 7), anchor + Vector3.new((width / 2) - 5, height + 6, 0), wallColor)
	end

	local namePost = makeHousePart(plot.houseContainer, "HouseName", Vector3.new(8, 3, 1), anchor + Vector3.new(0, 3, (depth / 2) + 2), roofColor)
	makeHouseLabel(namePost, if house then house.name else "TinyWorld Home")
	plot.ownerLabel.Text = string.format("%s's Plot • %s", player.Name, if house then house.name else "Home")
end

function PlotService:getPlotForPlayer(player: Player)
	local index = self.playerPlots[player]
	if index == nil then
		return nil
	end
	return self.world.plots[index]
end

function PlotService:getOwnerForPlot(plotIndex: number)
	return self.plotOwners[plotIndex]
end

function PlotService:release(player: Player)
	local index = self.playerPlots[player]
	if index == nil then
		return
	end
	local plot = self.world.plots[index]
	plot.houseContainer:ClearAllChildren()
	plot.ownerLabel.Text = "Available Plot"
	plot.privacyPrompt.ObjectText = "Home Access"
	self.plotOwners[index] = nil
	self.playerPlots[player] = nil
end

return PlotService
