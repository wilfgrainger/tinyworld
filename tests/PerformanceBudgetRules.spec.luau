local TestUtil = require("./TestUtil")
local PerformanceBudgetRules = require("../src/shared/PerformanceBudgetRules")

return function()
	TestUtil.equal(PerformanceBudgetRules.MIN_FPS, 30)
	TestUtil.equal(PerformanceBudgetRules.MAX_MEMORY_MB, 500)
	TestUtil.equal(PerformanceBudgetRules.MAX_LOAD_SECONDS, 15)

	local passing = PerformanceBudgetRules.evaluate({
		fps = 30,
		memoryMb = 500,
		loadSeconds = 15,
	})
	TestUtil.isTrue(passing.passed)
	TestUtil.isTrue(passing.fps)
	TestUtil.isTrue(passing.memory)
	TestUtil.isTrue(passing.load)

	local failing = PerformanceBudgetRules.evaluate({
		fps = 29.9,
		memoryMb = 500.1,
		loadSeconds = 15.1,
	})
	TestUtil.isFalse(failing.passed)
	TestUtil.isFalse(failing.fps)
	TestUtil.isFalse(failing.memory)
	TestUtil.isFalse(failing.load)

	local incomplete = PerformanceBudgetRules.evaluate({})
	TestUtil.isFalse(incomplete.passed)
	TestUtil.isFalse(incomplete.complete)
end
