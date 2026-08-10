local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local ProfileSchema = require(shared:WaitForChild("ProfileSchema"))
local ProfileMigrations = require(shared:WaitForChild("ProfileMigrations"))
local ProfileStoreRules = require(shared:WaitForChild("ProfileStoreRules"))
local EnvironmentConfig = require(script.Parent:WaitForChild("EnvironmentConfig"))

local ProfileStore = {}

local DATASTORE_NAME = EnvironmentConfig.dataStoreName()
local store = DataStoreService:GetDataStore(DATASTORE_NAME)
local profiles = {}

local function keyFor(player: Player): string
	return string.format("player_%d", player.UserId)
end

local function now(): number
	return os.time()
end

local function decode(value): (any?, any?, string?)
	local rawProfile, session, envelopeError = ProfileStoreRules.unwrapPersisted(value)
	if envelopeError ~= nil then
		return nil, session, envelopeError
	end
	local migrated, migrationError = ProfileMigrations.migrate(rawProfile)
	if migrated == nil then
		return nil, session, migrationError or "migration_failed"
	end
	return ProfileSchema.normalize(migrated), session, nil
end

local function envelope(profile, token: string, expiresAt: number)
	return {
		profile = ProfileSchema.normalize(profile),
		session = {
			token = token,
			expiresAt = expiresAt,
		},
	}
end

local function releasedEnvelope(profile)
	return {
		profile = ProfileSchema.normalize(profile),
	}
end

local function setDiagnostics(player: Player, record)
	if player.Parent == nil then
		return
	end
	player:SetAttribute("TinyWorldSaveState", record.state)
	player:SetAttribute("TinyWorldSaveVersion", record.version)
	player:SetAttribute("TinyWorldSaveRetryAttempt", record.retryAttempt)
	player:SetAttribute("TinyWorldSessionState", record.sessionState)
	player:SetAttribute("TinyWorldEnvironment", EnvironmentConfig.environment())
	player:SetAttribute("TinyWorldProfileSchema", ProfileSchema.VERSION)
	player:SetAttribute("TinyWorldProfileMutationLocked", record.mutationLockOwner ~= nil)
end

local function setState(player: Player, record, state: string)
	record.state = state
	setDiagnostics(player, record)
end

local function scheduleSave(player: Player, delaySeconds: number)
	local record = profiles[player]
	if record == nil or record.releasing or record.scheduled then
		return
	end

	record.scheduled = true
	task.delay(delaySeconds, function()
		local current = profiles[player]
		if current == nil then
			return
		end
		current.scheduled = false
		if current.releasing or current.saving then
			return
		end
		if current.version > current.savedVersion or current.state == "retrying" then
			ProfileStore.saveNow(player)
		end
	end)
end

local function scheduleHeartbeat(player: Player, delaySeconds: number?)
	task.delay(delaySeconds or (ProfileStoreRules.SESSION_LEASE_SECONDS / 3), function()
		local record = profiles[player]
		if record == nil or record.releasing then
			return
		end

		local lost = false
		local migrationFailure = nil
		local ok, result = pcall(function()
			return store:UpdateAsync(keyFor(player), function(previous)
				local persistedProfile, session, migrationError = decode(previous)
				if persistedProfile == nil then
					migrationFailure = migrationError
					return nil
				end
				if not ProfileStoreRules.isLeaseOwned(session, now(), record.token) then
					lost = true
					return nil
				end
				return envelope(persistedProfile, record.token, now() + ProfileStoreRules.SESSION_LEASE_SECONDS)
			end)
		end)

		if ok and result ~= nil and not lost and migrationFailure == nil then
			record.heartbeatFailures = 0
			scheduleHeartbeat(player)
			return
		end

		record.heartbeatFailures += 1
		if lost or migrationFailure ~= nil or record.heartbeatFailures >= 3 then
			record.sessionState = "lost"
			setState(player, record, "failed")
			warn(
				string.format(
					"TinyWorld: session lease could not be kept safe for %s (%s).",
					player.Name,
					tostring(migrationFailure or "lease_failure")
				)
			)
			if player.Parent ~= nil then
				player:Kick("TinyWorld could not keep your session safe. Please rejoin in a moment.")
			end
			return
		end

		scheduleHeartbeat(player, 10)
	end)
end

function ProfileStore.load(player: Player)
	if profiles[player] ~= nil then
		return profiles[player].profile
	end
	if not EnvironmentConfig.assertSafe() then
		warn("TinyWorld: refusing to load profiles because environment/DataStore namespace separation is unsafe.")
		return nil
	end

	local token = HttpService:GenerateGUID(false)
	local conflict = false
	local migrationFailure = nil
	local ok, result = pcall(function()
		return store:UpdateAsync(keyFor(player), function(previous)
			local persistedProfile, session, migrationError = decode(previous)
			if persistedProfile == nil then
				migrationFailure = migrationError
				return nil
			end
			if ProfileStoreRules.isLeaseActive(session, now(), token) and session.token ~= token then
				conflict = true
				return nil
			end
			return envelope(persistedProfile, token, now() + ProfileStoreRules.SESSION_LEASE_SECONDS)
		end)
	end)

	if not ok or result == nil or conflict or migrationFailure ~= nil then
		warn(
			string.format(
				"TinyWorld: failed to acquire a safe profile session for %s (%s).",
				player.Name,
				tostring(migrationFailure or "lease_or_datastore")
			)
		)
		return nil
	end

	local profile, _, decodeError = decode(result)
	if profile == nil then
		warn(
			string.format("TinyWorld: migrated profile decode failed for %s (%s).", player.Name, tostring(decodeError))
		)
		return nil
	end
	local record = {
		profile = profile,
		token = token,
		version = 0,
		savedVersion = 0,
		state = "clean",
		retryAttempt = 0,
		scheduled = false,
		saving = false,
		releasing = false,
		heartbeatFailures = 0,
		sessionState = "active",
		mutationLockOwner = nil,
	}
	profiles[player] = record
	setDiagnostics(player, record)
	scheduleHeartbeat(player)
	return profile
end

function ProfileStore.get(player: Player)
	local record = profiles[player]
	if record == nil or not ProfileStoreRules.externalMutationAllowed(record.mutationLockOwner) then
		return nil
	end
	return record.profile
end

function ProfileStore.lockMutations(player: Player, owner: string): boolean
	local record = profiles[player]
	if
		record == nil
		or record.releasing
		or not ProfileStoreRules.canAcquireMutationLock(record.mutationLockOwner, owner)
	then
		return false
	end
	record.mutationLockOwner = ProfileStoreRules.acquireMutationLock(record.mutationLockOwner, owner)
	setDiagnostics(player, record)
	return record.mutationLockOwner == owner
end

function ProfileStore.unlockMutations(player: Player, owner: string): boolean
	local record = profiles[player]
	if record == nil then
		return false
	end
	local previous = record.mutationLockOwner
	record.mutationLockOwner = ProfileStoreRules.releaseMutationLock(record.mutationLockOwner, owner)
	setDiagnostics(player, record)
	return previous == owner and record.mutationLockOwner == nil
end

function ProfileStore.isMutationLocked(player: Player): boolean
	local record = profiles[player]
	return record ~= nil and not ProfileStoreRules.externalMutationAllowed(record.mutationLockOwner)
end

function ProfileStore.save(player: Player): boolean
	local record = profiles[player]
	if record == nil or record.releasing then
		return false
	end

	record.version += 1
	setState(player, record, "dirty")
	scheduleSave(player, ProfileStoreRules.SAVE_DEBOUNCE_SECONDS)
	return true
end

local function markSaveFailure(player: Player, record): boolean
	record.saving = false
	record.retryAttempt += 1
	if ProfileStoreRules.shouldRetry(record.retryAttempt) then
		setState(player, record, "retrying")
		scheduleSave(player, ProfileStoreRules.retryDelay(record.retryAttempt, math.random()))
	else
		setState(player, record, "failed")
		warn(
			string.format(
				"TinyWorld: failed to save profile for %s after %d attempts.",
				player.Name,
				record.retryAttempt
			)
		)
	end
	return false
end

function ProfileStore.saveNow(player: Player): boolean
	local record = profiles[player]
	if record == nil or record.saving then
		return false
	end

	local snapshotVersion = record.version
	local snapshot = ProfileSchema.normalize(record.profile)
	local conflict = false
	local migrationFailure = nil
	record.saving = true
	setState(player, record, "saving")

	local ok, result = pcall(function()
		return store:UpdateAsync(keyFor(player), function(previous)
			local persistedProfile, session, migrationError = decode(previous)
			if persistedProfile == nil then
				migrationFailure = migrationError
				return nil
			end
			if not ProfileStoreRules.isLeaseOwned(session, now(), record.token) then
				conflict = true
				return nil
			end
			return envelope(snapshot, record.token, now() + ProfileStoreRules.SESSION_LEASE_SECONDS)
		end)
	end)

	if migrationFailure ~= nil then
		record.saving = false
		record.sessionState = "lost"
		setState(player, record, "failed")
		warn(
			string.format(
				"TinyWorld: refusing to overwrite unsupported profile data for %s (%s).",
				player.Name,
				migrationFailure
			)
		)
		return false
	end
	if not ok or result == nil or conflict then
		if conflict then
			record.sessionState = "lost"
			setState(player, record, "failed")
			warn(string.format("TinyWorld: refusing to overwrite a competing session for %s.", player.Name))
			record.saving = false
			return false
		end
		return markSaveFailure(player, record)
	end

	record.saving = false
	record.savedVersion = snapshotVersion
	record.retryAttempt = 0
	if record.version > snapshotVersion then
		setState(player, record, "queued")
		scheduleSave(player, ProfileStoreRules.SAVE_DEBOUNCE_SECONDS)
	else
		setState(player, record, "clean")
	end
	return true
end

local function releaseSession(player: Player, record): boolean
	local conflict = false
	local migrationFailure = nil
	local ok, result = pcall(function()
		return store:UpdateAsync(keyFor(player), function(previous)
			local persistedProfile, session, migrationError = decode(previous)
			if persistedProfile == nil then
				migrationFailure = migrationError
				return nil
			end
			if not ProfileStoreRules.isLeaseOwned(session, now(), record.token) then
				conflict = true
				return nil
			end
			return releasedEnvelope(persistedProfile)
		end)
	end)
	if not ok or result == nil or conflict or migrationFailure ~= nil then
		warn(string.format("TinyWorld: failed to release profile session for %s.", player.Name))
		return false
	end
	return true
end

function ProfileStore.release(player: Player, timeoutSeconds: number?): boolean
	local record = profiles[player]
	if record == nil then
		return true
	end

	record.releasing = true
	setState(player, record, "releasing")
	local deadline = os.clock() + (timeoutSeconds or 10)
	local saved = false
	repeat
		saved = ProfileStore.saveNow(player)
		if saved or record.sessionState == "lost" or os.clock() >= deadline then
			break
		end
		task.wait(math.min(0.5, math.max(0, deadline - os.clock())))
	until saved
	local released = if saved then releaseSession(player, record) else false
	record.sessionState = if released then "released" else record.sessionState
	profiles[player] = nil
	return saved and released
end

function ProfileStore.saveAll(): boolean
	local allSaved = true
	local players = {}
	for player in profiles do
		table.insert(players, player)
	end
	for _, player in players do
		if not ProfileStore.saveNow(player) then
			allSaved = false
		end
	end
	return allSaved
end

function ProfileStore.shutdown(timeoutSeconds: number?): boolean
	local deadline = os.clock() + (timeoutSeconds or 25)
	local allReleased = true
	local players = {}
	for player in profiles do
		table.insert(players, player)
	end
	for _, player in players do
		local remaining = math.max(0, deadline - os.clock())
		if remaining <= 0 or not ProfileStore.release(player, remaining) then
			allReleased = false
		end
	end
	return allReleased
end

function ProfileStore.getDiagnostics(player: Player?)
	if player then
		local record = profiles[player]
		if record == nil then
			return {
				state = "unloaded",
				queueDepth = 0,
				sessionState = "released",
				environment = EnvironmentConfig.environment(),
				dataStoreName = DATASTORE_NAME,
			}
		end
		return {
			state = record.state,
			queueDepth = if record.version > record.savedVersion then 1 else 0,
			retryAttempt = record.retryAttempt,
			sessionState = record.sessionState,
			version = record.version,
			savedVersion = record.savedVersion,
			mutationLocked = record.mutationLockOwner ~= nil,
			environment = EnvironmentConfig.environment(),
			dataStoreName = DATASTORE_NAME,
		}
	end

	local active = 0
	local queued = 0
	for _, record in profiles do
		active += 1
		if record.version > record.savedVersion or record.state == "retrying" then
			queued += 1
		end
	end
	return {
		activeProfiles = active,
		queueDepth = queued,
		environment = EnvironmentConfig.environment(),
		dataStoreName = DATASTORE_NAME,
	}
end

return ProfileStore
