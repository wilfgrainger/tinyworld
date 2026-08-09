local DataStoreService = game:GetService("DataStoreService")
local EnvironmentConfig = require(script.Parent:WaitForChild("EnvironmentConfig"))

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

function TradeJournal.write(transaction: any): boolean
	if
		type(transaction) ~= "table"
		or type(transaction.id) ~= "string"
		or type(transaction.playerAUserId) ~= "number"
		or type(transaction.playerBUserId) ~= "number"
	then
		return false
	end
	local snapshot = snapshotFor(transaction)
	local ok = pcall(function()
		store:UpdateAsync(keyFor(transaction.id), function(previous)
			if type(previous) == "table" and previous.state == "committed" and snapshot.state ~= "committed" then
				return previous
			end
			return snapshot
		end)
	end)
	if not ok then
		return false
	end
	local indexedA = updatePendingIndex(transaction.playerAUserId, transaction.id, transaction.state)
	local indexedB = updatePendingIndex(transaction.playerBUserId, transaction.id, transaction.state)
	return indexedA and indexedB
end

function TradeJournal.read(transactionId: string): any?
	local ok, result = pcall(function()
		return store:GetAsync(keyFor(transactionId))
	end)
	if not ok or type(result) ~= "table" then
		return nil
	end
	return result
end

function TradeJournal.pendingForUser(userId: number): any?
	local ok, transactionId = pcall(function()
		return store:GetAsync(pendingKey(userId))
	end)
	if not ok or type(transactionId) ~= "string" then
		return nil
	end
	local transaction = TradeJournal.read(transactionId)
	if transaction == nil then
		return nil
	end
	if terminal(transaction.state) then
		updatePendingIndex(userId, transactionId, transaction.state)
		return nil
	end
	return transaction
end

function TradeJournal.storeName(): string
	return STORE_NAME
end

return TradeJournal
