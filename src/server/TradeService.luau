local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local Inventory = require(shared:WaitForChild("Inventory"))
local TradeRules = require(shared:WaitForChild("TradeRules"))
local TradeTransactionRules = require(shared:WaitForChild("TradeTransactionRules"))
local AnalyticsEvents = require(shared:WaitForChild("AnalyticsEvents"))
local TradeJournal = require(script.Parent:WaitForChild("TradeJournal"))
local TinyAnalyticsService = require(script.Parent:WaitForChild("AnalyticsService"))

local TradeService = {}
TradeService.__index = TradeService

local function offerName(itemName: string?): string
	if itemName == "SugarCrystal" then
		return "Sugar Crystal"
	elseif itemName == "Carrot" then
		return "Carrot"
	end
	return "nothing"
end

local function offerSnapshot(itemName: string?): any
	local result = {}
	if itemName then
		result[itemName] = 1
	end
	return result
end

local function inventorySnapshot(profile: any, firstItem: string, secondItem: string): any
	local result = {
		[firstItem] = Inventory.get(profile, firstItem),
	}
	result[secondItem] = Inventory.get(profile, secondItem)
	return result
end

local function expectedAfter(before: any, outgoing: string, incoming: string): any
	local result = {}
	for itemId, amount in before do
		result[itemId] = amount
	end
	if outgoing ~= incoming then
		result[outgoing] = math.max(0, (result[outgoing] or 0) - 1)
		result[incoming] = (result[incoming] or 0) + 1
	end
	return result
end

local function matchesSnapshot(profile: any, snapshot: any): boolean
	if type(snapshot) ~= "table" then
		return false
	end
	for itemId, amount in snapshot do
		if type(itemId) ~= "string" or type(amount) ~= "number" or Inventory.get(profile, itemId) ~= amount then
			return false
		end
	end
	return true
end

local function restoreSnapshot(profile: any, before: any, after: any): (boolean, string)
	if matchesSnapshot(profile, before) then
		return true, "already_before"
	end
	if not matchesSnapshot(profile, after) then
		return false, "ambiguous_inventory"
	end
	for itemId, target in before do
		local current = Inventory.get(profile, itemId)
		if current > target then
			if not Inventory.remove(profile, itemId, current - target) then
				return false, "remove_failed"
			end
		elseif current < target then
			if not Inventory.add(profile, itemId, target - current) then
				return false, "add_failed"
			end
		end
	end
	return true, "restored"
end

function TradeService.new(world, ProfileStore, PlayerStateService, SocialService)
	local self = setmetatable({}, TradeService)
	self.world = world
	self.ProfileStore = ProfileStore
	self.PlayerStateService = PlayerStateService
	self.SocialService = SocialService
	self.players = {}
	self.offers = {}
	self.confirmedVersion = {}
	self.lastActivity = {}
	self.version = 1
	self.commitInProgress = false
	self.commitMutationOwner = nil
	self.commitMutationPlayers = {}
	self.TRADE_TIMEOUT_SECONDS = 120

	for side, refs in world.trade.sides do
		refs.joinPrompt.Triggered:Connect(function(player)
			self:_join(player, side)
		end)
		refs.offerPrompt.Triggered:Connect(function(player)
			self:_chooseOffer(player, side)
		end)
		refs.confirmPrompt.Triggered:Connect(function(player)
			self:_confirm(player, side)
		end)
	end
	self:_updateSign()
	return self
end

function TradeService:_touch(player: Player)
	self.lastActivity[player] = os.clock()
end

function TradeService:_pruneExpired()
	if self.commitInProgress then
		return
	end
	local now = os.clock()
	local changed = false
	for player, last in self.lastActivity do
		if now - last >= self.TRADE_TIMEOUT_SECONDS then
			local side = self:_sideForPlayer(player)
			if side then
				self.players[side] = nil
				self.offers[player] = nil
				self.confirmedVersion[player] = nil
				changed = true
			end
			self.lastActivity[player] = nil
		end
	end
	if changed then
		self:_invalidateConfirmations()
		self:_updateSign()
	end
end

function TradeService:_sideForPlayer(player: Player): number?
	for side, occupant in self.players do
		if occupant == player then
			return side
		end
	end
	return nil
end

function TradeService:_invalidateConfirmations()
	self.version += 1
	self.confirmedVersion = {}
end

function TradeService:_releaseMutationLocks()
	local owner = self.commitMutationOwner
	if owner ~= nil then
		for _, player in self.commitMutationPlayers do
			self.ProfileStore.unlockMutations(player, owner)
		end
	end
	self.commitMutationOwner = nil
	self.commitMutationPlayers = {}
end

function TradeService:_resetActiveTrade()
	self:_releaseMutationLocks()
	self.players = {}
	self.offers = {}
	self.lastActivity = {}
	self.commitInProgress = false
	self:_invalidateConfirmations()
	self:_updateSign()
end

function TradeService:_join(player: Player, side: number)
	self:_pruneExpired()
	if self.commitInProgress then
		self.PlayerStateService.message(player, "This trade is being safely committed. Please wait for it to finish.")
		return
	end
	if self.ProfileStore.get(player) == nil then
		return
	end
	local currentSide = self:_sideForPlayer(player)
	if currentSide == side then
		self.players[side] = nil
		self.offers[player] = nil
		self.lastActivity[player] = nil
		self:_invalidateConfirmations()
		self.PlayerStateService.message(player, "You left the Trading Post.")
		self:_updateSign()
		return
	elseif currentSide ~= nil then
		self.PlayerStateService.message(player, "You are already on the other trade side.")
		return
	end
	if self.players[side] ~= nil then
		self.PlayerStateService.message(player, "That trade side is already occupied.")
		return
	end
	self.players[side] = player
	self.offers[player] = nil
	self:_touch(player)
	self:_invalidateConfirmations()
	self.PlayerStateService.message(
		player,
		string.format("Joined Trading Post side %s. Choose an item to offer.", if side == 1 then "A" else "B")
	)
	self:_updateSign()
end

function TradeService:_nextOffer(profile, current: string?): string?
	-- v0.6 keeps public trading deliberately limited to low-value stackables.
	-- Unique/high-value furniture trading remains disabled until recovery evidence passes.
	local candidates = { "Carrot", "SugarCrystal", false }
	local start = 1
	if current == "Carrot" then
		start = 2
	elseif current == "SugarCrystal" then
		start = 3
	end
	for offset = 0, 2 do
		local index = ((start - 1 + offset) % 3) + 1
		local candidate = candidates[index]
		if candidate == false then
			return nil
		end
		if Inventory.get(profile, candidate) > 0 then
			return candidate
		end
	end
	return nil
end

function TradeService:_chooseOffer(player: Player, side: number)
	self:_pruneExpired()
	if self.commitInProgress then
		self.PlayerStateService.message(player, "This trade is being safely committed. Offers are locked.")
		return
	end
	if self.players[side] ~= player then
		self.PlayerStateService.message(player, "Join this side of the Trading Post first.")
		return
	end
	local profile = self.ProfileStore.get(player)
	if profile == nil then
		return
	end
	local nextItem = self:_nextOffer(profile, self.offers[player])
	self.offers[player] = nextItem
	self:_touch(player)
	self:_invalidateConfirmations()
	self.PlayerStateService.message(player, "Trade offer set to " .. offerName(nextItem) .. ".")
	self:_updateSign()
end

function TradeService:_confirm(player: Player, side: number)
	self:_pruneExpired()
	if self.commitInProgress then
		self.PlayerStateService.message(player, "This trade is already being safely committed.")
		return
	end
	if self.players[side] ~= player then
		self.PlayerStateService.message(player, "Join this trade side first.")
		return
	end
	if self.offers[player] == nil then
		self.PlayerStateService.message(player, "Choose an item to offer before confirming.")
		return
	end
	self.confirmedVersion[player] = self.version
	self:_touch(player)
	self.PlayerStateService.message(player, "Trade confirmed. Waiting for the other player.")
	self:_updateSign()

	local a = self.players[1]
	local b = self.players[2]
	if a and b and self.confirmedVersion[a] == self.version and self.confirmedVersion[b] == self.version then
		self:_complete(a, b)
	end
end

function TradeService:_recoverActiveTrade(
	transaction: any,
	a: Player,
	b: Player,
	profileA: any,
	profileB: any,
	itemA: string,
	itemB: string,
	reason: string
): boolean
	if transaction.state == "committing" then
		TradeTransactionRules.beginRecovery(transaction, reason)
	else
		transaction.recoveryReason = reason
	end
	TradeJournal.write(transaction)

	local reversed, reverseReason = TradeRules.exchange(profileA, itemB, profileB, itemA)
	if not reversed then
		transaction.recoveryReason = reason .. ":" .. reverseReason
		TradeJournal.write(transaction)
		self.PlayerStateService.sync(a, profileA)
		self.PlayerStateService.sync(b, profileB)
		self:_resetActiveTrade()
		if a.Parent then
			a:Kick("TinyWorld paused an incomplete trade to protect your inventory. Please rejoin.")
		end
		if b.Parent then
			b:Kick("TinyWorld paused an incomplete trade to protect your inventory. Please rejoin.")
		end
		return false
	end

	transaction.rollbackSavedA = self.ProfileStore.saveNow(a)
	TradeJournal.write(transaction)
	transaction.rollbackSavedB = self.ProfileStore.saveNow(b)
	local wroteCheckpoint, authoritative = TradeJournal.write(transaction)
	self.PlayerStateService.sync(a, profileA)
	self.PlayerStateService.sync(b, profileB)

	if wroteCheckpoint and authoritative and authoritative.rollbackSavedA and authoritative.rollbackSavedB then
		local finished = TradeTransactionRules.finishRecovery(authoritative)
		if finished and TradeJournal.write(authoritative) then
			self.PlayerStateService.message(a, "Trade was safely rolled back. Nothing was lost.")
			self.PlayerStateService.message(b, "Trade was safely rolled back. Nothing was lost.")
			self:_resetActiveTrade()
			return true
		end
	end

	self:_resetActiveTrade()
	if a.Parent then
		a:Kick("TinyWorld is finishing recovery of an incomplete trade. Please rejoin in a moment.")
	end
	if b.Parent then
		b:Kick("TinyWorld is finishing recovery of an incomplete trade. Please rejoin in a moment.")
	end
	return false
end

function TradeService:_complete(a: Player, b: Player)
	if self.commitInProgress then
		return
	end
	local profileA = self.ProfileStore.get(a)
	local profileB = self.ProfileStore.get(b)
	if profileA == nil or profileB == nil then
		self:_invalidateConfirmations()
		self:_updateSign()
		return
	end
	local itemA = self.offers[a]
	local itemB = self.offers[b]
	if itemA == nil or itemB == nil then
		self:_invalidateConfirmations()
		self:_updateSign()
		return
	end
	local canTrade, canTradeReason = TradeRules.canExchange(profileA, itemA, profileB, itemB)
	if not canTrade then
		self:_invalidateConfirmations()
		self.PlayerStateService.message(a, "Trade stopped because inventory changed: " .. canTradeReason)
		self.PlayerStateService.message(b, "Trade stopped because inventory changed: " .. canTradeReason)
		self:_updateSign()
		return
	end

	local transaction = TradeTransactionRules.new(
		HttpService:GenerateGUID(false),
		a.UserId,
		b.UserId,
		offerSnapshot(itemA),
		offerSnapshot(itemB),
		self.version
	)
	transaction.beforeA = inventorySnapshot(profileA, itemA, itemB)
	transaction.beforeB = inventorySnapshot(profileB, itemA, itemB)
	transaction.afterA = expectedAfter(transaction.beforeA, itemA, itemB)
	transaction.afterB = expectedAfter(transaction.beforeB, itemB, itemA)
	TradeTransactionRules.confirm(transaction, a.UserId, self.version)
	TradeTransactionRules.confirm(transaction, b.UserId, self.version)
	local started = TradeTransactionRules.beginCommit(transaction)
	if not started then
		self:_invalidateConfirmations()
		self:_updateSign()
		return
	end

	local mutationOwner = "trade:" .. transaction.id
	if not self.ProfileStore.lockMutations(a, mutationOwner) then
		self:_invalidateConfirmations()
		self.PlayerStateService.message(a, "Trade stopped because your inventory is busy. Please try again.")
		self.PlayerStateService.message(b, "Trade stopped because the other inventory is busy. Please try again.")
		self:_updateSign()
		return
	end
	if not self.ProfileStore.lockMutations(b, mutationOwner) then
		self.ProfileStore.unlockMutations(a, mutationOwner)
		self:_invalidateConfirmations()
		self.PlayerStateService.message(a, "Trade stopped because the other inventory is busy. Please try again.")
		self.PlayerStateService.message(b, "Trade stopped because your inventory is busy. Please try again.")
		self:_updateSign()
		return
	end
	self.commitMutationOwner = mutationOwner
	self.commitMutationPlayers = { a, b }

	-- The trade single-flight and both participant mutation locks are active
	-- before the first DataStore-yielding journal write. Normal ProfileStore.get
	-- calls now fail closed for both participants until commit/recovery is safe.
	self.commitInProgress = true
	if not TradeJournal.write(transaction) then
		TradeTransactionRules.beginRecovery(transaction, "journal_index_failed_before_exchange")
		transaction.rollbackSavedA = true
		transaction.rollbackSavedB = true
		TradeTransactionRules.finishRecovery(transaction)
		TradeJournal.write(transaction)
		self:_resetActiveTrade()
		self.PlayerStateService.message(
			a,
			"Trade stopped because TinyWorld could not create a recoverable transaction record."
		)
		self.PlayerStateService.message(
			b,
			"Trade stopped because TinyWorld could not create a recoverable transaction record."
		)
		return
	end

	local traded, reason = TradeRules.exchange(profileA, itemA, profileB, itemB)
	if not traded then
		TradeTransactionRules.cancel(transaction, reason)
		TradeJournal.write(transaction)
		self:_resetActiveTrade()
		self.PlayerStateService.message(a, "Trade stopped because inventory changed: " .. reason)
		self.PlayerStateService.message(b, "Trade stopped because inventory changed: " .. reason)
		return
	end

	local savedA = self.ProfileStore.saveNow(a)
	transaction.persistedA = savedA
	if savedA and not TradeJournal.write(transaction) then
		self:_recoverActiveTrade(transaction, a, b, profileA, profileB, itemA, itemB, "journal_failed_after_first_save")
		return
	end
	if not savedA then
		self:_recoverActiveTrade(transaction, a, b, profileA, profileB, itemA, itemB, "first_profile_save_failed")
		return
	end

	local savedB = self.ProfileStore.saveNow(b)
	transaction.persistedB = savedB
	if not savedB then
		self:_recoverActiveTrade(transaction, a, b, profileA, profileB, itemA, itemB, "second_profile_save_failed")
		return
	end

	local committedSnapshot = table.clone(transaction)
	committedSnapshot.state = "committed"
	local wroteCommit, authoritativeCommit = TradeJournal.write(committedSnapshot)
	if not TradeTransactionRules.authoritativeCommitAccepted(wroteCommit, authoritativeCommit) then
		local recoveryReason = if wroteCommit
			then "commit_rejected_by_authoritative_recovery"
			else "commit_journal_failed"
		self:_recoverActiveTrade(transaction, a, b, profileA, profileB, itemA, itemB, recoveryReason)
		return
	end
	TradeTransactionRules.commit(transaction)
	self:_releaseMutationLocks()
	self.PlayerStateService.sync(a, profileA)
	self.PlayerStateService.sync(b, profileB)
	TinyAnalyticsService.log(a, AnalyticsEvents.TradeCompleted)
	TinyAnalyticsService.log(b, AnalyticsEvents.TradeCompleted)
	if self.SocialService then
		self.SocialService:recordTrade(a, b)
	end
	self.PlayerStateService.message(
		a,
		string.format("Trade complete: your %s for %s's %s.", offerName(itemA), b.Name, offerName(itemB))
	)
	self.PlayerStateService.message(
		b,
		string.format("Trade complete: your %s for %s's %s.", offerName(itemB), a.Name, offerName(itemA))
	)
	self:_resetActiveTrade()
end

function TradeService:setupPlayer(player: Player): boolean
	local lookupOk, transaction = TradeJournal.pendingForUser(player.UserId)
	if not lookupOk then
		return false
	end
	if transaction == nil then
		return true
	end
	local profile = self.ProfileStore.get(player)
	if profile == nil then
		return false
	end

	if transaction.state == "committing" then
		local started = TradeTransactionRules.beginRecovery(transaction, "server_resume")
		local wroteRecovery, authoritative = TradeJournal.write(transaction)
		if not started or not wroteRecovery or authoritative == nil then
			return false
		end
		transaction = authoritative
	elseif transaction.state ~= "recovering" then
		return false
	end

	local isA = transaction.playerAUserId == player.UserId
	local isB = transaction.playerBUserId == player.UserId
	if not isA and not isB then
		return false
	end
	local before = if isA then transaction.beforeA else transaction.beforeB
	local after = if isA then transaction.afterA else transaction.afterB
	local restored, restoreReason = restoreSnapshot(profile, before, after)
	if not restored then
		transaction.recoveryReason = "ambiguous_resume:" .. restoreReason
		TradeJournal.write(transaction)
		return false
	end

	local durable = restoreReason == "already_before" or self.ProfileStore.saveNow(player)
	if not durable then
		return false
	end
	if isA then
		transaction.rollbackSavedA = true
	else
		transaction.rollbackSavedB = true
	end
	local wroteCheckpoint, authoritative = TradeJournal.write(transaction)
	if not wroteCheckpoint or authoritative == nil then
		return false
	end
	transaction = authoritative

	if not (transaction.rollbackSavedA and transaction.rollbackSavedB) then
		-- Do not admit either participant until both rollback checkpoints are
		-- durably represented in one authoritative journal row.
		return false
	end

	local finished = TradeTransactionRules.finishRecovery(transaction)
	if not finished then
		return false
	end
	local wroteTerminal, terminalSnapshot = TradeJournal.write(transaction)
	if not wroteTerminal or terminalSnapshot == nil or terminalSnapshot.state ~= "cancelled" then
		return false
	end
	self.PlayerStateService.message(player, "TinyWorld recovered an interrupted trade before you rejoined.")
	return true
end

function TradeService:_updateSign()
	local lines = { "TRADING POST" }
	if self.commitInProgress then
		table.insert(lines, "Safely committing trade…")
	end
	for side = 1, 2 do
		local player = self.players[side]
		if player then
			local confirmed = self.confirmedVersion[player] == self.version
			table.insert(
				lines,
				string.format(
					"%s: %s offers %s%s",
					if side == 1 then "A" else "B",
					player.Name,
					offerName(self.offers[player]),
					if confirmed then " ✓" else ""
				)
			)
		else
			table.insert(lines, string.format("%s: available", if side == 1 then "A" else "B"))
		end
	end
	self.world.trade.statusLabel.Text = table.concat(lines, "\n")
end

function TradeService:removePlayer(player: Player)
	if self.commitInProgress then
		self.lastActivity[player] = nil
		return
	end
	local side = self:_sideForPlayer(player)
	if side then
		self.players[side] = nil
		self.offers[player] = nil
		self.lastActivity[player] = nil
		self:_invalidateConfirmations()
		self:_updateSign()
	end
end

return TradeService
