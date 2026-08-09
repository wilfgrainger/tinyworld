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

return TradeTransactionRules
