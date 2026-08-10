local TestUtil = require("./TestUtil")
local ok, RemoteGuardRules = pcall(require, "../src/shared/RemoteGuardRules")

return function()
	TestUtil.isTrue(ok, "RemoteGuardRules must exist")
	if not ok then
		return
	end

	TestUtil.isTrue(RemoteGuardRules.isFiniteNumber(42))
	TestUtil.isFalse(RemoteGuardRules.isFiniteNumber(0 / 0))
	TestUtil.isFalse(RemoteGuardRules.isFiniteNumber(math.huge))
	TestUtil.isTrue(RemoteGuardRules.integerInRange(4, 1, 5))
	TestUtil.isFalse(RemoteGuardRules.integerInRange(4.5, 1, 5))
	TestUtil.isTrue(RemoteGuardRules.stringWithin("TinyWorld", 3, 16))
	TestUtil.isFalse(RemoteGuardRules.stringWithin(string.rep("x", 17), 3, 16))
	TestUtil.isTrue(RemoteGuardRules.allowedId("Meadow", { Meadow = true, Harbor = true }))
	TestUtil.isFalse(RemoteGuardRules.allowedId("Injected", { Meadow = true, Harbor = true }))

	local state = nil
	local allowed1
	allowed1, state = RemoteGuardRules.consumeWindow(state, 100, 3, 10)
	TestUtil.isTrue(allowed1)
	local allowed2
	allowed2, state = RemoteGuardRules.consumeWindow(state, 101, 3, 10)
	TestUtil.isTrue(allowed2)
	local allowed3
	allowed3, state = RemoteGuardRules.consumeWindow(state, 102, 3, 10)
	TestUtil.isTrue(allowed3)
	local blocked
	blocked, state = RemoteGuardRules.consumeWindow(state, 103, 3, 10)
	TestUtil.isFalse(blocked)
	local reset
	reset, state = RemoteGuardRules.consumeWindow(state, 111, 3, 10)
	TestUtil.isTrue(reset)
	TestUtil.equal(state.count, 1)
end
