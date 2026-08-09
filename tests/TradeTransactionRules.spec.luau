local TestUtil = require("./TestUtil")
local ok, TradeTransactionRules = pcall(require, "../src/shared/TradeTransactionRules")

return function()
	TestUtil.isTrue(ok, "TradeTransactionRules must exist")
	if not ok then
		return
	end

	local tx = TradeTransactionRules.new("tx-1", 101, 202, { Carrot = 2 }, { Seashell = 1 }, 7)
	TestUtil.equal(tx.id, "tx-1")
	TestUtil.equal(tx.state, "locked")
	TestUtil.equal(tx.offerVersion, 7)
	TestUtil.equal(tx.fromA.Carrot, 2)
	TestUtil.equal(tx.fromB.Seashell, 1)

	local confirmed, confirmReason = TradeTransactionRules.confirm(tx, 101, 7)
	TestUtil.isTrue(confirmed)
	TestUtil.equal(confirmReason, "confirmed")
	local confirmedB = TradeTransactionRules.confirm(tx, 202, 7)
	TestUtil.isTrue(confirmedB)
	TestUtil.isTrue(TradeTransactionRules.readyToCommit(tx))

	local committing, committingReason = TradeTransactionRules.beginCommit(tx)
	TestUtil.isTrue(committing)
	TestUtil.equal(committingReason, "committing")
	local committed, committedReason = TradeTransactionRules.commit(tx)
	TestUtil.isTrue(committed)
	TestUtil.equal(committedReason, "committed")
	local duplicate, duplicateReason = TradeTransactionRules.commit(tx)
	TestUtil.isFalse(duplicate)
	TestUtil.equal(duplicateReason, "already_committed")

	local stale = TradeTransactionRules.new("tx-2", 1, 2, {}, {}, 3)
	local staleConfirm, staleReason = TradeTransactionRules.confirm(stale, 1, 2)
	TestUtil.isFalse(staleConfirm)
	TestUtil.equal(staleReason, "stale_offer")
	local cancelled, cancelReason = TradeTransactionRules.cancel(stale, "timeout")
	TestUtil.isTrue(cancelled)
	TestUtil.equal(cancelReason, "cancelled")
	TestUtil.equal(stale.cancelReason, "timeout")
end
