local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local DailyReward = require(shared:WaitForChild("DailyReward"))
local ExplorationRules = require(shared:WaitForChild("ExplorationRules"))

local ExplorationService = {}
ExplorationService.__index = ExplorationService

function ExplorationService.new(world, ProfileStore, PlayerStateService, RouteService)
	local self = setmetatable({}, ExplorationService)
	self.ProfileStore = ProfileStore
	self.PlayerStateService = PlayerStateService
	self.RouteService = RouteService

	for landmark, prompt in world.boundary.landmarkPrompts do
		prompt.Triggered:Connect(function(player)
			self:_visit(player, landmark)
		end)
	end
	world.boundary.explorerPrompt.Triggered:Connect(function(player)
		self:_claim(player)
	end)

	return self
end

function ExplorationService:_visit(player: Player, landmark: string)
	local profile = self.ProfileStore.get(player)
	if profile == nil then
		return
	end

	local visited, reason = ExplorationRules.visit(profile, landmark, DailyReward.dayKey())
	local visitedCount = ExplorationRules.count(profile)
	if visited then
		self.PlayerStateService.sync(player, profile)
		self.PlayerStateService.message(player, string.format("Boundary landmark found: %d/3. Return to the Explorer Board when all three are visited.", visitedCount))
		self.ProfileStore.save(player)
	elseif reason == "already_visited" then
		self.PlayerStateService.message(player, string.format("You already visited this landmark today: %d/3 found.", visitedCount))
	end
end

function ExplorationService:_claim(player: Player)
	local profile = self.ProfileStore.get(player)
	if profile == nil then
		return
	end

	local claimed, reason = ExplorationRules.claim(profile, DailyReward.dayKey())
	if claimed then
		local _routeChanged, routeText = self.RouteService:record(player, "boundary_route")
		self.PlayerStateService.sync(player, profile)
		local suffix = if routeText == "" then "" else " " .. routeText
		self.PlayerStateService.message(player, "Boundary route complete: +250 coins, +100 XP. Come back tomorrow for a new route." .. suffix)
		self.ProfileStore.save(player)
	elseif reason == "incomplete" then
		self.PlayerStateService.message(player, string.format("Visit all three boundary landmarks first: %d/3 found.", ExplorationRules.count(profile)))
	elseif reason == "already_claimed" then
		self.PlayerStateService.message(player, "You already claimed today's Boundary Explorer reward. Come back tomorrow.")
	end
end

return ExplorationService
