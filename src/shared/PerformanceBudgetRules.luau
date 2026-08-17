local PerformanceBudgetRules = {}

PerformanceBudgetRules.MIN_FPS = 30
PerformanceBudgetRules.MAX_MEMORY_MB = 500
PerformanceBudgetRules.MAX_LOAD_SECONDS = 15

local function finiteNumber(value: any): boolean
	return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end

function PerformanceBudgetRules.evaluate(metrics: any)
	metrics = if type(metrics) == "table" then metrics else {}

	local fpsComplete = finiteNumber(metrics.fps)
	local memoryComplete = finiteNumber(metrics.memoryMb)
	local loadComplete = finiteNumber(metrics.loadSeconds)
	local complete = fpsComplete and memoryComplete and loadComplete

	local fpsPass = fpsComplete and metrics.fps >= PerformanceBudgetRules.MIN_FPS
	local memoryPass = memoryComplete and metrics.memoryMb <= PerformanceBudgetRules.MAX_MEMORY_MB
	local loadPass = loadComplete and metrics.loadSeconds <= PerformanceBudgetRules.MAX_LOAD_SECONDS

	return {
		complete = complete,
		fps = fpsPass,
		memory = memoryPass,
		load = loadPass,
		passed = complete and fpsPass and memoryPass and loadPass,
	}
end

return PerformanceBudgetRules
