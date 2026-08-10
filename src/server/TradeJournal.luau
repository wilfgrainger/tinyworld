local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EnvironmentConfig = require(script.Parent:WaitForChild("EnvironmentConfig"))

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local TradeTransactionRules = require(shared:WaitForChild("TradeTransactionRules"))

local TradeJournal = {}

local STORE_NAME = string.format("TinyWorld_%s_TradeJournal_v1", EnvironmentConfig.environment())
local store = DataStoreService:GetDataStore(STORE_NAME)

local function keyFor(transactionId: string): string
	return "trade_" .. transactionId
end

local function pendingKey(userId: number): string
	return "pending_user_" .. tostring(userId)
end

local function terminal(state: any): boolean
	return state == "committed" or state == "cancelled"
end

local function snapshotFor(transaction: any)
	return {
		id = transaction.id,
		playerAUserId = transaction.playerAUserId,
		playerBUserId = transaction.playerBUserId,
		fromA = transaction.fromA,
		fromB = transaction.fromB,
		beforeA = transaction.beforeA,
		beforeB = transaction.beforeB,
		afterA = transaction.afterA,
		afterB = transaction.afterB,
		offerVersion = transaction.offerVersion,
		state = transaction.state,
		confirmedA = transaction.confirmedA == true,
		confirmedB = transaction.confirmedB == true,
		cancelReason = transaction.cancelReason,
		recoveryReason = transaction.recoveryReason,
		persistedA = transaction.persistedA == true,
		persistedB = transaction.persistedB == true,
		rollbackSavedA = transaction.rollbackSavedA == true,
		rollbackSavedB = transaction.rollbackSavedB == true,
		updatedAt = os.time(),
	}
end

local function updatePendingIndex(userId: number, transactionId: string, state: string): boolean
	local ok = pcall(function()
		store:UpdateAsync(pendingKey(userId), function(previous)
			if terminal(state) then
				if previous == transactionId then
					return nil
				end
				return previous
			end
			return transactionId
		end)
	end)
	return ok
end

function TradeJournal.write(transaction: any): (boolean, any?)
	if
		type(transaction) ~= "table"
		or type(transaction.id) ~= "string"
		or type(transaction.playerAUserId) ~= "number"
		or type(transaction.playerBUserId) ~= "number"
	then
		return false, nil
	end
	local snapshot = snapshotFor(transaction)
	local ok, authoritative = pcall(function()
		return store:UpdateAsync(keyFor(transaction.id), function(previous)
			return TradeTransactionRules.mergeRecoveryCheckpoint(previous, snapshot)
		end)
	end)
	if not ok or type(authoritative) ~= "table" then
		return false, nil
	end

	local indexedA = updatePendingIndex(transaction.playerAUserId, transaction.id, authoritative.state)
	local indexedB = updatePendingIndex(transaction.playerBUserId, transaction.id, authoritative.state)
	if terminal(authoritative.state) then
		-- The terminal row is authoritative. A stale participant index is safe
		-- because pendingForUser reads the transaction row and self-cleans it.
		return true, authoritative
	end
	-- Non-terminal transactions are safe only if both participants can discover
	-- the same durable journal row after a server interruption.
	return indexedA and indexedB, authoritative
end

function TradeJournal.read(transactionId: string): (boolean, any?)
	local ok, result = pcall(function()
		return store:GetAsync(keyFor(transactionId))
	end)
	if not ok then
		return false, nil
	end
	if result == nil then
		return true, nil
	end
	if type(result) ~= "table" then
		return false, nil
	end
	return true, result
end

function TradeJournal.pendingForUser(userId: number): (boolean, any?)
	local ok, transactionId = pcall(function()
		return store:GetAsync(pendingKey(userId))
	end)
	if not ok then
		return false, nil
	end
	if transactionId == nil then
		return true, nil
	end
	if type(transactionId) ~= "string" then
		return false, nil
	end

	local readOk, transaction = TradeJournal.read(transactionId)
	if not readOk or transaction == nil then
		return false, nil
	end
	if terminal(transaction.state) then
		updatePendingIndex(userId, transactionId, transaction.state)
		return true, nil
	end
	return true, transaction
end

function TradeJournal.storeName(): string
	return STORE_NAME
end

return TradeJournal
