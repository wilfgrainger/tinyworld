local DataStoreService = game:GetService("DataStoreService")
local EnvironmentConfig = require(script.Parent:WaitForChild("EnvironmentConfig"))

local TradeJournal = {}

local STORE_NAME = string.format("TinyWorld_%s_TradeJournal_v1", EnvironmentConfig.environment())
local store = DataStoreService:GetDataStore(STORE_NAME)

local function keyFor(transactionId: string): string
	return "trade_" .. transactionId
end

function TradeJournal.write(transaction: any): boolean
	if type(transaction) ~= "table" or type(transaction.id) ~= "string" then
		return false
	end
	local snapshot = {
		id = transaction.id,
		playerAUserId = transaction.playerAUserId,
		playerBUserId = transaction.playerBUserId,
		fromA = transaction.fromA,
		fromB = transaction.fromB,
		offerVersion = transaction.offerVersion,
		state = transaction.state,
		confirmedA = transaction.confirmedA == true,
		confirmedB = transaction.confirmedB == true,
		cancelReason = transaction.cancelReason,
		updatedAt = os.time(),
	}
	local ok = pcall(function()
		store:UpdateAsync(keyFor(transaction.id), function(previous)
			if type(previous) == "table" and previous.state == "committed" and snapshot.state ~= "committed" then
				return previous
			end
			return snapshot
		end)
	end)
	return ok
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

function TradeJournal.storeName(): string
	return STORE_NAME
end

return TradeJournal
