local VillageService = {}
VillageService.__index = VillageService

function VillageService.new(world, ProfileStore, PlayerStateService)
	local self = setmetatable({}, VillageService)
	self.world = world
	self.ProfileStore = ProfileStore
	self.PlayerStateService = PlayerStateService
	self.fund = 0

	world.contributionPrompt.Triggered:Connect(function(player)
		self:_contribute(player)
	end)
	return self
end

function VillageService:_contribute(player: Player)
	local profile = self.ProfileStore.get(player)
	if profile == nil then
		return
	end
	if profile.coins < 50 then
		self.PlayerStateService.message(player, "A Village Fund contribution is 50 coins.")
		return
	end
	profile.coins -= 50
	profile.villageContribution += 50
	self.fund += 50
	self.world.fundLabel.Text = string.format("Village Fund: %d coins\nFuture public works live here", self.fund)
	self.PlayerStateService.sync(player, profile)
	self.PlayerStateService.message(player, "You contributed 50 coins to the Village Fund.")
	self.ProfileStore.save(player)
end

return VillageService

