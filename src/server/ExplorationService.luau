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
	world.boundary.explorerPrompt.ActionText = "Finish Village Trail"
	world.boundary.explorerPrompt.ObjectText = "Village Explorer"
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
		self.PlayerStateService.message(
			player,
			string.format("Village Trail landmark found: %d/3. Find all three, then return to the Explorer Board.", visitedCount)
		)
		self.ProfileStore.save(player)
	elseif reason == "already_visited" then
		self.PlayerStateService.message(
			player,
			string.format("You already found this Village Trail landmark today: %d/3 found.", visitedCount)
		)
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
		self.PlayerStateService.message(
			player,
			"Village Trail complete: +250 coins, +100 XP. A new trail is waiting tomorrow." .. suffix
		)
		self.ProfileStore.save(player)
	elseif reason == "incomplete" then
		self.PlayerStateService.message(
			player,
			string.format("Find all three Village Trail landmarks first: %d/3 found.", ExplorationRules.count(profile))
		)
	elseif reason == "already_claimed" then
		self.PlayerStateService.message(player, "You already finished today's Village Trail. Come back tomorrow.")
	end
end

return ExplorationService
