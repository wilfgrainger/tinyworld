local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local PlayerPhaseRules = require(shared:WaitForChild("PlayerPhaseRules"))

local GameplayAccessService = {}

function GameplayAccessService.canEnter(player: Player, ProfileStore): (boolean, string?)
	return PlayerPhaseRules.canEnterGameplay(ProfileStore.get(player))
end

function GameplayAccessService.requireAccess(player: Player, ProfileStore, PlayerStateService): boolean
	local allowed, reason = GameplayAccessService.canEnter(player, ProfileStore)
	if allowed then
		return true
	end
	if reason == "onboarding_incomplete" then
		PlayerStateService.message(player, "Finish your TinyWorld setup before starting normal village activities.")
	end
	return false
end

function GameplayAccessService.guardedProfileStore(ProfileStore)
	local guarded = {}
	setmetatable(guarded, { __index = ProfileStore })
	guarded.get = function(player)
		local profile = ProfileStore.get(player)
		local allowed = PlayerPhaseRules.canEnterGameplay(profile)
		if not allowed then
			return nil
		end
		return profile
	end
	return guarded
end

return GameplayAccessService
