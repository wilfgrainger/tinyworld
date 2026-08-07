local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local ProfileSchema = require(shared:WaitForChild("ProfileSchema"))

local ProfileStore = {}

local DATASTORE_NAME = "TinyWorldPlayerProfile_v1"
local store = DataStoreService:GetDataStore(DATASTORE_NAME)
local profiles = {}

local function keyFor(player: Player): string
	return string.format("player_%d", player.UserId)
end

local function serialise(profile)
	return {
		version = profile.version,
		coins = profile.coins,
		level = profile.level,
		xp = profile.xp,
		houseTier = profile.houseTier,
	}
end

function ProfileStore.load(player: Player)
	if profiles[player] ~= nil then
		return profiles[player]
	end

	local ok, result = pcall(function()
		return store:GetAsync(keyFor(player))
	end)

	if not ok then
		warn(string.format("TinyWorld: failed to load profile for %s: %s", player.Name, tostring(result)))
		return nil
	end

	local profile = ProfileSchema.normalize(result)
	profiles[player] = profile
	return profile
end

function ProfileStore.get(player: Player)
	return profiles[player]
end

function ProfileStore.save(player: Player): boolean
	local profile = profiles[player]
	if profile == nil then
		return true
	end

	local payload = serialise(profile)
	local ok, result = pcall(function()
		store:UpdateAsync(keyFor(player), function(_previous)
			return payload
		end)
	end)

	if not ok then
		warn(string.format("TinyWorld: failed to save profile for %s: %s", player.Name, tostring(result)))
		return false
	end

	return true
end

function ProfileStore.release(player: Player): boolean
	local saved = ProfileStore.save(player)
	profiles[player] = nil
	return saved
end

function ProfileStore.saveAll(): boolean
	local allSaved = true
	for player in profiles do
		if not ProfileStore.save(player) then
			allSaved = false
		end
	end
	return allSaved
end

return ProfileStore
