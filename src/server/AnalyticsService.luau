local RobloxAnalyticsService = game:GetService("AnalyticsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local AnalyticsEvents = require(shared:WaitForChild("AnalyticsEvents"))

local AnalyticsService = {}
local sessions = {}

function AnalyticsService.log(player: Player, eventName: string, value: number?)
	if not AnalyticsEvents.isAllowed(eventName) then
		warn("TinyWorld analytics rejected unknown event: " .. tostring(eventName))
		return false
	end
	local eventValue = if type(value) == "number"
			and value == value
			and value ~= math.huge
			and value ~= -math.huge
		then value
		else 1
	local ok, err = pcall(function()
		RobloxAnalyticsService:LogCustomEvent(player, eventName, eventValue)
	end)
	if not ok then
		warn(string.format("TinyWorld analytics failed: event=%s error=%s", eventName, tostring(err)))
	end
	return ok
end

function AnalyticsService.setupPlayer(player: Player, profile)
	sessions[player] = os.clock()
	AnalyticsService.log(player, AnalyticsEvents.Joined)
	if profile.onboardingComplete then
		AnalyticsService.log(player, AnalyticsEvents.JoinedReturning)
	else
		AnalyticsService.log(player, AnalyticsEvents.JoinedNew)
		AnalyticsService.log(player, AnalyticsEvents.OnboardingStarted)
	end
end

function AnalyticsService.removePlayer(player: Player)
	local startedAt = sessions[player]
	if startedAt then
		AnalyticsService.log(player, AnalyticsEvents.SessionDuration, math.max(0, os.clock() - startedAt))
	end
	sessions[player] = nil
end

return AnalyticsService
