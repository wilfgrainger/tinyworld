local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local HouseCatalog = require(shared:WaitForChild("HouseCatalog"))
local HouseUpgrade = require(shared:WaitForChild("HouseUpgrade"))
local LivingWorldRules = require(shared:WaitForChild("LivingWorldRules"))
local SocialRules = require(shared:WaitForChild("SocialRules"))
local HomePrefabBuilder = require(script.Parent:WaitForChild("HomePrefabBuilder"))
local VillageSceneryBuilder = require(script.Parent:WaitForChild("VillageSceneryBuilder"))

local PlotService = {}
PlotService.__index = PlotService

local function displayNameFor(player: Player, profile): string
	if profile and type(profile.displayName) == "string" and profile.displayName ~= "" then
		return profile.displayName
	end
	return player.Name
end

local function nextPrivacy(current: string): string
	if current == "Open" then
		return "Friends"
	elseif current == "Friends" then
		return "Private"
	end
	return "Open"
end

local function applyHomePlacement(plot)
	local homeAnchorCFrame = plot.homeAnchorCFrame
	if homeAnchorCFrame == nil or plot.houseAnchor == nil then
		return
	end

	local delta = homeAnchorCFrame * CFrame.new(-plot.houseAnchor)
	plot.houseContainer:PivotTo(delta * plot.houseContainer:GetPivot())
end

function PlotService.new(world, ProfileStore, PlayerStateService, SocialService, HomeService)
	local self = setmetatable({}, PlotService)
	self.world = world
	self.ProfileStore = ProfileStore
	self.PlayerStateService = PlayerStateService
	self.SocialService = SocialService
	self.HomeService = HomeService
	self.FurniturePlacementService = nil
	self.playerPlots = {}
	self.plotOwners = {}
	self.identityConnections = {}

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
		plot.homeCharmPrompt.Triggered:Connect(function(player)
			self:_decorate(player, plotIndex)
		end)
	end

	return self
end

function PlotService:setFurniturePlacementService(service)
	self.FurniturePlacementService = service
end

function PlotService:_ownerProfile(plotIndex: number)
	local owner = self.plotOwners[plotIndex]
	if owner == nil then
		return nil, nil
	end
	return owner, self.ProfileStore.get(owner)
end

function PlotService:_decorate(player: Player, plotIndex: number)
	local owner, profile = self:_ownerProfile(plotIndex)
	if owner ~= player or profile == nil then
		self.PlayerStateService.message(player, "Only the plot owner can add a Home Charm.")
		return
	end

	local applied, reason = LivingWorldRules.addHomeCharm(profile)
	if not applied then
		self.PlayerStateService.message(player, if reason == "already_applied" then "Your home already has a Home Charm." else "Find a Meadow Seed, Seashell, and Wood Token first.")
		return
	end

	self:rebuildHouse(player, profile)
	self:refreshIdentity(player, profile)
	self.PlayerStateService.sync(player, profile)
	self.PlayerStateService.message(player, "Home Charm added: your garden is blooming.")
	self.ProfileStore.save(player)
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
			else "Your home is already at the highest tier."
		self.PlayerStateService.message(player, text)
		return
	end

	self:rebuildHouse(player, profile)
	self:refreshIdentity(player, profile)
	self.PlayerStateService.sync(player, profile)
	local house = HouseCatalog.get(profile.houseTier)
	self.PlayerStateService.message(player, string.format("Home upgraded to %s!", if house then house.name else "the next tier"))
	self.ProfileStore.save(player)
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
	self.ProfileStore.save(player)
end

function PlotService:_visit(player: Player, plotIndex: number)
	local owner, profile = self:_ownerProfile(plotIndex)
	if owner == nil or profile == nil then
		self.PlayerStateService.message(player, "This plot is currently available.")
		return
	end

	local isFriend = false
	if player ~= owner and profile.homePrivacy == "Friends" then
		local ok, friendResult = pcall(function()
			return player:IsFriendsWithAsync(owner.UserId)
		end)
		isFriend = ok and friendResult
	end
	local allowed = SocialRules.privacyAllows(profile.homePrivacy, player == owner, isFriend)

	if not allowed then
		self.PlayerStateService.message(player, displayNameFor(owner, profile) .. "'s home is private.")
		return
	end

	local character = player.Character
	if character then
		character:PivotTo(self.world.plots[plotIndex].insideCFrame)
		if self.SocialService then
			self.SocialService:recordVisit(player, owner, plotIndex)
		end
		self.PlayerStateService.message(player, "Welcome to " .. displayNameFor(owner, profile) .. "'s home.")
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
			plot.ownerLabel.Text = displayNameFor(player, profile) .. "'s Plot"
			plot.privacyPrompt.ObjectText = "Home Access: " .. profile.homePrivacy
			self:rebuildHouse(player, profile)
			self:refreshIdentity(player, profile)
			self.identityConnections[player] = player:GetAttributeChangedSignal("TinyWorldDisplayName"):Connect(function()
				local latest = self.ProfileStore.get(player)
				if latest then
					self:refreshIdentity(player, latest)
				end
			end)
			return index
		end
	end
	self.PlayerStateService.message(player, "All home plots are occupied; village activities still work.")
	return nil
end

function PlotService:rebuildHouse(player: Player, profile)
	local plotIndex = self.playerPlots[player]
	if plotIndex == nil then
		return
	end
	local plot = self.world.plots[plotIndex]
	VillageSceneryBuilder.releaseHomeAmbient(self.world.ambientLife, plotIndex)
	plot.houseContainer:ClearAllChildren()
	plot.houseContainer:PivotTo(CFrame.new(plot.houseAnchor))
	local house = HouseCatalog.get(profile.houseTier)
	HomePrefabBuilder.buildShell(plot.houseContainer, plot.houseAnchor, profile, house)
	if self.HomeService then
		self.HomeService:buildInterior(plot, profile)
	end
	VillageSceneryBuilder.bindHomeAmbient(self.world.ambientLife, plot.houseContainer, plotIndex, self.world.layout.artSeed)
	applyHomePlacement(plot)
	if self.FurniturePlacementService then
		self.FurniturePlacementService:renderAll(player, plot, profile)
	end
	plot.ownerLabel.Text = string.format("%s's Plot • %s", player.Name, if house then house.name else "Home")
end

function PlotService:refreshIdentity(player: Player, profile)
	local plotIndex = self.playerPlots[player]
	if plotIndex == nil then
		return
	end
	local house = HouseCatalog.get(profile.houseTier)
	self.world.plots[plotIndex].ownerLabel.Text = string.format("%s's Plot - %s", displayNameFor(player, profile), if house then house.name else "Home")
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
	VillageSceneryBuilder.releaseHomeAmbient(self.world.ambientLife, index)
	plot.houseContainer:ClearAllChildren()
	plot.ownerLabel.Text = "Available Plot"
	plot.privacyPrompt.ObjectText = "Home Access"
	local identityConnection = self.identityConnections[player]
	if identityConnection then
		identityConnection:Disconnect()
		self.identityConnections[player] = nil
	end
	self.plotOwners[index] = nil
	self.playerPlots[player] = nil
end

return PlotService
