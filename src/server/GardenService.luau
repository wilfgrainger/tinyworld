local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local GardenRules = require(shared:WaitForChild("GardenRules"))

local GardenService = {}
GardenService.__index = GardenService

local function actionForBed(bed): string
	if bed.stage == "empty" then
		return "Plant Carrot"
	elseif bed.stage == "planted" then
		return "Water Carrot"
	elseif bed.stage == "watered" then
		return "Check Carrot"
	end
	return "Harvest Carrot"
end

function GardenService.new(world, plotService, ProfileStore, PlayerStateService)
	local self = setmetatable({}, GardenService)
	self.world = world
	self.plotService = plotService
	self.ProfileStore = ProfileStore
	self.PlayerStateService = PlayerStateService

	for plotIndex, plot in world.plots do
		for bedIndex, prompt in plot.gardenPrompts do
			prompt.Triggered:Connect(function(player)
				self:_interact(player, plotIndex, bedIndex)
			end)
		end
	end
	return self
end

function GardenService:_syncBed(player: Player, bedIndex: number)
	local profile = self.ProfileStore.get(player)
	local plot = self.plotService:getPlotForPlayer(player)
	if profile == nil or plot == nil then
		return
	end
	local bed = profile.gardenBeds[bedIndex]
	GardenRules.refresh(bed, os.time())
	plot.gardenPrompts[bedIndex].ActionText = actionForBed(bed)
end

function GardenService:syncPlayer(player: Player)
	for bedIndex = 1, 3 do
		self:_syncBed(player, bedIndex)
	end
end

function GardenService:_interact(player: Player, plotIndex: number, bedIndex: number)
	local owner = self.plotService:getOwnerForPlot(plotIndex)
	if owner ~= player then
		self.PlayerStateService.message(player, "This garden belongs to another player.")
		return
	end
	local profile = self.ProfileStore.get(player)
	if profile == nil then
		return
	end
	local bed = profile.gardenBeds[bedIndex]
	local now = os.time()
	local stage = GardenRules.refresh(bed, now)
	local ok, reason
	if stage == "empty" then
		ok, reason = GardenRules.plant(bed, now)
	elseif stage == "planted" then
		ok, reason = GardenRules.water(bed, now)
	elseif stage == "ready" then
		ok, reason = GardenRules.harvest(profile, bed, now)
	else
		ok, reason = false, "growing"
	end

	self:_syncBed(player, bedIndex)
	self.PlayerStateService.sync(player, profile)
	if ok and reason == "planted" then
		self.PlayerStateService.message(player, "Carrot planted. Water it next.")
	elseif ok and reason == "watered" then
		self.PlayerStateService.message(player, "Carrot watered. It grows in about 5 seconds in this prototype.")
	elseif ok and reason == "harvested" then
		self.PlayerStateService.message(player, "Carrot harvested: +1 Carrot and +10 XP.")
	else
		local remaining = math.max(0, bed.readyAt - now)
		self.PlayerStateService.message(player, string.format("Your Carrot is still growing: about %d seconds.", remaining))
	end
end

return GardenService
