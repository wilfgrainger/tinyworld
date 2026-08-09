local Players = game:GetService("Players")

local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))
local PlayerStateService = require(script.Parent:WaitForChild("PlayerStateService"))
local OnboardingService = require(script.Parent:WaitForChild("OnboardingService"))
local WorldBuilder = require(script.Parent:WaitForChild("WorldBuilder"))
local PlotService = require(script.Parent:WaitForChild("PlotService"))
local GardenService = require(script.Parent:WaitForChild("GardenService"))
local DailyRewardService = require(script.Parent:WaitForChild("DailyRewardService"))
local JobService = require(script.Parent:WaitForChild("JobService"))
local TransportService = require(script.Parent:WaitForChild("TransportService"))
local PortalService = require(script.Parent:WaitForChild("PortalService"))
local TradeService = require(script.Parent:WaitForChild("TradeService"))
local VillageService = require(script.Parent:WaitForChild("VillageService"))
local ExplorationService = require(script.Parent:WaitForChild("ExplorationService"))
local LivingWorldService = require(script.Parent:WaitForChild("LivingWorldService"))
local RouteService = require(script.Parent:WaitForChild("RouteService"))
local SocialService = require(script.Parent:WaitForChild("SocialService"))
local HomeService = require(script.Parent:WaitForChild("HomeService"))
local AlphaOpsService = require(script.Parent:WaitForChild("AlphaOpsService"))

local world = WorldBuilder.build(Players.MaxPlayers)
local routeService = RouteService.new(ProfileStore, PlayerStateService)
local socialService = SocialService.new(world, ProfileStore, PlayerStateService)
local homeService = HomeService.new(world, ProfileStore, PlayerStateService)
local plotService = PlotService.new(world, ProfileStore, PlayerStateService, socialService, homeService)
homeService:setPlotService(plotService)
local onboardingService = OnboardingService.new(ProfileStore, PlayerStateService)
local alphaOpsService = AlphaOpsService.new(world, ProfileStore, PlayerStateService)
local gardenService = GardenService.new(world, plotService, ProfileStore, PlayerStateService, routeService)
local _dailyRewardService = DailyRewardService.new(world, ProfileStore, PlayerStateService, routeService)
local jobService = JobService.new(world, ProfileStore, PlayerStateService, routeService)
local transportService = TransportService.new(world, ProfileStore, PlayerStateService)
local portalService = PortalService.new(world, ProfileStore, PlayerStateService)
local tradeService = TradeService.new(world, ProfileStore, PlayerStateService, socialService)
local _villageService = VillageService.new(world, ProfileStore, PlayerStateService)
local _explorationService = ExplorationService.new(world, ProfileStore, PlayerStateService, routeService)
local _livingWorldService = LivingWorldService.new(world, ProfileStore, PlayerStateService)

local function onPlayerAdded(player: Player)
	local profile = ProfileStore.load(player)
	if profile == nil then
		player:Kick("TinyWorld could not safely load your saved data. Please rejoin in a moment.")
		return
	end

	PlayerStateService.setup(player, profile)
	onboardingService:setupPlayer(player, profile)
	alphaOpsService:setupPlayer(player)
	routeService:sync(player, profile)
	socialService:setupPlayer(player)
	homeService:syncPlayer(player, profile)
	plotService:assign(player, profile)
	gardenService:syncPlayer(player)
	jobService:trackPlayer(player)
	transportService:trackPlayer(player)
	transportService:apply(player, profile)
	player:SetAttribute("TinyWorldPortalCrystals", 0)
	player:SetAttribute("TinyWorldCarryingParcel", false)
	if profile.onboardingComplete then
		PlayerStateService.message(player, "Welcome back to TinyWorld, " .. profile.displayName .. ".")
	else
		PlayerStateService.message(player, "Welcome to TinyWorld. Choose your name and starter look to begin.")
	end
end

local function onPlayerRemoving(player: Player)
	tradeService:removePlayer(player)
	socialService:removePlayer(player)
	portalService:removePlayer(player)
	jobService:removePlayer(player)
	transportService:removePlayer(player)
	onboardingService:removePlayer(player)
	alphaOpsService:removePlayer(player)
	plotService:release(player)
	ProfileStore.release(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

for _, player in Players:GetPlayers() do
	task.spawn(onPlayerAdded, player)
end

game:BindToClose(function()
	alphaOpsService:stop()
	ProfileStore.shutdown(25)
end)
