local RunService = game:GetService("RunService")

local EnvironmentConfig = {}

local DATASTORE_NAMES = {
	DEV = "TinyWorld_DEV_PlayerProfile_v11",
	LIVE = "TinyWorld_LIVE_PlayerProfile_v11",
}

function EnvironmentConfig.environment(): string
	if RunService:IsStudio() then
		return "DEV"
	end
	local configured = game:GetAttribute("TinyWorldEnvironment")
	if configured == "LIVE" then
		return "LIVE"
	end
	return "DEV"
end

function EnvironmentConfig.dataStoreName(): string
	return DATASTORE_NAMES[EnvironmentConfig.environment()]
end

function EnvironmentConfig.isLive(): boolean
	return EnvironmentConfig.environment() == "LIVE"
end

function EnvironmentConfig.assertSafe(): boolean
	local environment = EnvironmentConfig.environment()
	local name = EnvironmentConfig.dataStoreName()
	if environment == "DEV" then
		return string.find(name, "_DEV_", 1, true) ~= nil
	end
	return string.find(name, "_LIVE_", 1, true) ~= nil
end

return EnvironmentConfig
