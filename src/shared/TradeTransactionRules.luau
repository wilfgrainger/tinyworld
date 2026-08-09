local TradeTransactionRules = {}

local function copyOffer(offer: any)
	local result = {}
	if type(offer) ~= "table" then
		return result
	end
	for itemId, quantity in offer do
		if type(itemId) == "string" and type(quantity) == "number" and quantity > 0 then
			result[itemId] = math.floor(quantity)
		end
	end
	return result
end

local function shallowCopy(value: any)
	local result = {}
	if type(value) ~= "table" then
		return result
	end
	for key, child in value do
		result[key] = child
	end
	return result
end

local function terminal(state: any): boolean
	return state == "committed" or state == "cancelled"
end

function TradeTransactionRules.new(
	id: string,
	playerAUserId: number,
	playerBUserId: number,
	offerA: any,
	offerB: any,
	offerVersion: number
)
	return {
		id = id,
		playerAUserId = playerAUserId,
		playerBUserId = playerBUserId,
		fromA = copyOffer(offerA),
		fromB = copyOffer(offerB),
		offerVersion = offerVersion,
		state = "locked",
		confirmedA = false,
		confirmedB = false,
		cancelReason = nil,
		recoveryReason = nil,
		persistedA = false,
		persistedB = false,
		rollbackSavedA = false,
		rollbackSavedB = false,
	}
end

function TradeTransactionRules.confirm(transaction: any, userId: number, offerVersion: number): (boolean, string)
	if type(transaction) ~= "table" or transaction.state ~= "locked" then
		return false, "invalid_state"
	end
	if offerVersion ~= transaction.offerVersion then
		return false, "stale_offer"
	end
	if userId == transaction.playerAUserId then
		transaction.confirmedA = true
	elseif userId == transaction.playerBUserId then
		transaction.confirmedB = true
	else
		return false, "not_participant"
	end
	return true, "confirmed"
end

function TradeTransactionRules.readyToCommit(transaction: any): boolean
	return type(transaction) == "table"
		and transaction.state == "locked"
		and transaction.confirmedA == true
		and transaction.confirmedB == true
end

function TradeTransactionRules.beginCommit(transaction: any): (boolean, string)
	if not TradeTransactionRules.readyToCommit(transaction) then
		return false, "not_ready"
	end
	transaction.state = "committing"
	return true, "committing"
end

function TradeTransactionRules.beginRecovery(transaction: any, reason: string): (boolean, string)
	if type(transaction) ~= "table" then
		return false, "invalid_transaction"
	end
	if transaction.state ~= "committing" then
		return false, "invalid_state"
	end
	transaction.state = "recovering"
	transaction.recoveryReason = if type(reason) == "string" and reason ~= "" then reason else "recovery_required"
	return true, "recovering"
end

function TradeTransactionRules.finishRecovery(transaction: any): (boolean, string)
	if type(transaction) ~= "table" then
		return false, "invalid_transaction"
	end
	if transaction.state ~= "recovering" then
		return false, "invalid_state"
	end
	if transaction.rollbackSavedA ~= true or transaction.rollbackSavedB ~= true then
		return false, "rollback_not_durable"
	end
	transaction.state = "cancelled"
	transaction.cancelReason = transaction.recoveryReason or "recovered"
	return true, "cancelled"
end

function TradeTransactionRules.commit(transaction: any): (boolean, string)
	if type(transaction) ~= "table" then
		return false, "invalid_transaction"
	end
	if transaction.state == "committed" then
		return false, "already_committed"
	end
	if transaction.state ~= "committing" then
		return false, "invalid_state"
	end
	transaction.state = "committed"
	return true, "committed"
end

function TradeTransactionRules.cancel(transaction: any, reason: string): (boolean, string)
	if type(transaction) ~= "table" then
		return false, "invalid_transaction"
	end
	if transaction.state == "committed" then
		return false, "already_committed"
	end
	if transaction.state == "recovering" then
		return false, "recovery_required"
	end
	if transaction.state == "cancelled" then
		return false, "already_cancelled"
	end
	transaction.state = "cancelled"
	transaction.cancelReason = reason
	return true, "cancelled"
end

function TradeTransactionRules.mergeRecoveryCheckpoint(previous: any, incoming: any): any
	if type(previous) ~= "table" then
		return shallowCopy(incoming)
	end
	if type(incoming) ~= "table" then
		return shallowCopy(previous)
	end
	if previous.id ~= nil and incoming.id ~= nil and previous.id ~= incoming.id then
		return shallowCopy(previous)
	end
	if terminal(previous.state) then
		return shallowCopy(previous)
	end

	local merged = shallowCopy(incoming)
	for key, value in previous do
		if merged[key] == nil then
			merged[key] = value
		end
	end
	merged.persistedA = previous.persistedA == true or incoming.persistedA == true
	merged.persistedB = previous.persistedB == true or incoming.persistedB == true
	merged.rollbackSavedA = previous.rollbackSavedA == true or incoming.rollbackSavedA == true
	merged.rollbackSavedB = previous.rollbackSavedB == true or incoming.rollbackSavedB == true

	local recoveryDominates = previous.state == "recovering" or incoming.state == "recovering"
	if recoveryDominates then
		merged.state = "recovering"
		merged.cancelReason = nil
		merged.recoveryReason = incoming.recoveryReason or previous.recoveryReason or "recovery_required"
	end
	if incoming.state == "cancelled" then
		if merged.rollbackSavedA and merged.rollbackSavedB then
			merged.state = "cancelled"
			merged.cancelReason = incoming.cancelReason or merged.recoveryReason or "recovered"
		else
			merged.state = "recovering"
			merged.cancelReason = nil
		end
	elseif incoming.state == "committed" and not recoveryDominates then
		merged.state = "committed"
	end
	return merged
end

return TradeTransactionRules
