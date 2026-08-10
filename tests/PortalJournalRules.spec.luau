local TestUtil = require("./TestUtil")
local ok, PortalJournalRules = pcall(require, "../src/shared/PortalJournalRules")

return function()
	TestUtil.isTrue(ok, "PortalJournalRules must exist")
	if not ok then
		return
	end

	local empty = PortalJournalRules.copy({})
	TestUtil.isTrue(string.find(empty, "Giant Kitchen  ○", 1, true) ~= nil)
	TestUtil.isTrue(string.find(empty, "Moonlit Meadow  ○", 1, true) ~= nil)
	TestUtil.isTrue(string.find(empty, "Cloudpost Observatory  ○", 1, true) ~= nil)
	TestUtil.isTrue(string.find(empty, "Clockwork Orchard  ○", 1, true) ~= nil)

	local outOfOrder = PortalJournalRules.copy({
		CloudpostObservatory = true,
		ClockworkOrchard = true,
	})
	TestUtil.isTrue(string.find(outOfOrder, "Giant Kitchen  ○", 1, true) ~= nil)
	TestUtil.isTrue(string.find(outOfOrder, "Moonlit Meadow  ○", 1, true) ~= nil)
	TestUtil.isTrue(string.find(outOfOrder, "Cloudpost Observatory  ●", 1, true) ~= nil)
	TestUtil.isTrue(string.find(outOfOrder, "Clockwork Orchard  ●", 1, true) ~= nil)
end
