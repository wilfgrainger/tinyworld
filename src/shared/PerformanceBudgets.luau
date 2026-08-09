local PerformanceBudgets = {}

PerformanceBudgets.Mobile = {
	minimumFps = 30,
	frameBudgetMs = 33.3,
	memoryMb = 500,
	loadSeconds = 15,
	visibleParts = 7000,
}

PerformanceBudgets.Desktop = {
	targetFps = 60,
	frameBudgetMs = 16.6,
	visibleParts = 10000,
}

PerformanceBudgets.Network = {
	maxGameplayRemoteCallsPerSecondPerClient = 50,
	placementRequestsPerFiveSeconds = 12,
}

PerformanceBudgets.World = {
	maxPartsPerModel = 500,
	maxActiveParticleEmittersInView = 20,
	maxParticleRatePerEmitter = 200,
	streamingTargetRadius = 256,
	streamingMinRadius = 64,
}

return PerformanceBudgets
