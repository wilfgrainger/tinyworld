local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local Profession = require(shared:WaitForChild("Profession"))

local ProfessionService = {}
ProfessionService.__index = ProfessionService

local function progressText(profile, professionId: string): string
	local definition = Profession.get(professionId)
	if definition == nil then
		return professionId
	end
	local level = profile[definition.levelField] or 1
	local xp = profile[definition.xpField] or 0
	return string.format("%s Lv.%d (%d/%d XP)", definition.name, level, xp, Profession.xpForNextLevel(level))
end

function ProfessionService.new(world, ProfileStore, PlayerStateService)
	local self = setmetatable({}, ProfessionService)
	self.ProfileStore = ProfileStore
	self.PlayerStateService = PlayerStateService
	world.professionPrompt.Triggered:Connect(function(player)
		self:_inspect(player)
	end)
	return self
end

function ProfessionService:_inspect(player: Player)
	local profile = self.ProfileStore.get(player)
	if profile == nil then
		return
	end
	self.PlayerStateService.message(player, "Village Jobs: " .. table.concat({
		progressText(profile, "Courier"),
		progressText(profile, "Farmer"),
		progressText(profile, "Designer"),
	}, " • ") .. ". Courier deliveries, garden harvests, and home expression build your path.")
end

return ProfessionService
