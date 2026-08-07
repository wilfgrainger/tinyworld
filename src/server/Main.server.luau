local Players = game:GetService("Players")

local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))
local PlayerStateService = require(script.Parent:WaitForChild("PlayerStateService"))
local WorldBuilder = require(script.Parent:WaitForChild("WorldBuilder"))
local PlotService = require(script.Parent:WaitForChild("PlotService"))
local GardenService = require(script.Parent:WaitForChild("GardenService"))
local DailyRewardService = require(script.Parent:WaitForChild("DailyRewardService"))
local JobService = require(script.Parent:WaitForChild("JobService"))
local TransportService = require(script.Parent:WaitForChild("TransportService"))
local PortalService = require(script.Parent:WaitForChild("PortalService"))
local TradeService = require(script.Parent:WaitForChild("TradeService"))
local VillageService = require(script.Parent:WaitForChild("VillageService"))

local world = WorldBuilder.build()
local plotService = PlotService.new(world, ProfileStore, PlayerStateService)
local gardenService = GardenService.new(world, plotService, ProfileStore, PlayerStateService)
local _dailyRewardService = DailyRewardService.new(world, ProfileStore, PlayerStateService)
local jobService = JobService.new(world, ProfileStore, PlayerStateService)
local transportService = TransportService.new(world, ProfileStore, PlayerStateService)
local portalService = PortalService.new(world, ProfileStore, PlayerStateService)
local tradeService = TradeService.new(world, ProfileStore, PlayerStateService)
local _villageService = VillageService.new(world, ProfileStore, PlayerStateService)

local function onPlayerAdded(player: Player)
	local profile = ProfileStore.load(player)
	if profile == nil then
		player:Kick("TinyWorld could not safely load your saved data. Please rejoin in a moment.")
		return
	end

	PlayerStateService.setup(player, profile)
	plotService:assign(player, profile)
	gardenService:syncPlayer(player)
	jobService:trackPlayer(player)
	transportService:trackPlayer(player)
	transportService:apply(player, profile)
	player:SetAttribute("TinyWorldPortalCrystals", 0)
	player:SetAttribute("TinyWorldCarryingParcel", false)
	PlayerStateService.message(player, "Welcome to TinyWorld v0.01. Your whole virtual life starts in this village.")
end

local function onPlayerRemoving(player: Player)
	tradeService:removePlayer(player)
	portalService:removePlayer(player)
	jobService:removePlayer(player)
	transportService:removePlayer(player)
	plotService:release(player)
	ProfileStore.release(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

for _, player in Players:GetPlayers() do
	task.spawn(onPlayerAdded, player)
end

game:BindToClose(function()
	ProfileStore.saveAll()
end)
