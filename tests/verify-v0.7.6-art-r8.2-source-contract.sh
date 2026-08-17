#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "R8.2 runtime hardening contract failed: $1" >&2
  exit 1
}

traversal_service="src/server/TraversalSafetyService.luau"
portal_service="src/server/PortalService.luau"
activity_service="src/server/VillageActivityService.luau"
garden_service="src/server/VillageGardenActivityService.luau"
fishing_service="src/server/FishingActivityService.luau"
builder_service="src/server/BuilderRepairActivityService.luau"
legacy_retirement="src/server/R8LegacyPresentationRetirement.luau"
gameplay_access="src/server/GameplayAccessService.luau"
main="src/server/Main.server.luau"
runner="tests/run.luau"
project="default.project.json"
performance_doc="docs/reviews/2026-08-17-v0.7.6-r8.2-dev-performance-acceptance.md"

for path in "$traversal_service" "$portal_service" "$activity_service" "$garden_service" "$fishing_service" "$builder_service" "$main" "$runner" "$gameplay_access" "$project"; do
  test -f "$path" || fail "missing $path"
done

grep -q 'TraversalSafetyRules' "$traversal_service" || fail "TraversalSafetyService must consume TraversalSafetyRules"
if grep -q 'COASTAL_RECOVERY_BUFFER' "$traversal_service"; then
  fail "coastal recovery must not stop at a finite outer buffer"
fi
grep -q 'hasValidPortalSession' "$traversal_service" || fail "traversal exemption must depend on authoritative portal-session validity"

grep -q 'function PortalService:hasValidSession' "$portal_service" || fail "PortalService must expose authoritative session validity"
grep -q 'CharacterAdded:Connect' "$portal_service" || fail "PortalService must reconcile transient state on character respawn"
grep -q '_resetToVillageState' "$portal_service" || fail "PortalService must use one canonical Village reset path"
grep -q 'PortalSessionRules.isValid' "$portal_service" || fail "PortalService must validate server session and replicated world consistently"
grep -q 'onPortalTransition' "$portal_service" || fail "portal entry must expose a transition hook for transient village state"

grep -q 'function VillageActivityService:abandon' "$activity_service" || fail "village activities need an explicit abandon path"
grep -q 'function VillageActivityService:setupPlayer' "$activity_service" || fail "village activity lifecycle must reconcile on respawn"
grep -q 'CharacterAdded:Connect' "$activity_service" || fail "village activities must release on character respawn"

for path in "$garden_service" "$fishing_service" "$builder_service"; do
  grep -q 'ActivityLeaseRules' "$path" || fail "$path must use shared activity lease rules"
  grep -q 'function .*:abandonPlayer' "$path" || fail "$path must expose abandonPlayer"
  if grep -q 'self\.owner' "$path"; then
    fail "$path must not retain unbounded self.owner locking"
  fi
done

test -f "$legacy_retirement" || fail "R8 legacy presentation retirement helper is missing"
grep -q 'VillageBoundary' "$legacy_retirement" || fail "legacy boundary presentation must be explicitly retired"
grep -q 'CanCollide = false' "$legacy_retirement" || fail "hidden legacy boundary geometry must not remain as invisible collision"
grep -q 'VillageSquare' "$legacy_retirement" || fail "legacy village square/path presentation must be explicitly retired"
grep -q 'TinyWorldLegacyPresentationRetired' "$legacy_retirement" || fail "retirement must leave an auditable runtime marker"

grep -q 'PlayerPhaseRules' "$gameplay_access" || fail "GameplayAccessService must use deterministic PlayerPhaseRules"
grep -q 'function GameplayAccessService.requireAccess' "$gameplay_access" || fail "central gameplay access helper must expose requireAccess"
grep -q 'function GameplayAccessService.guardedProfileStore' "$gameplay_access" || fail "central gameplay access helper must expose a fail-closed ProfileStore view"

for path in \
  src/server/DailyRewardService.luau \
  src/server/VillageActivityService.luau \
  src/server/JobService.luau \
  src/server/TransportService.luau \
  src/server/BoatService.luau \
  src/server/PortalService.luau \
  src/server/HomeStoreService.luau; do
  grep -q 'GameplayAccessService.requireAccess' "$path" || fail "$path must call the central server gameplay access gate"
done

grep -q 'local gameplayProfileStore = GameplayAccessService.guardedProfileStore(ProfileStore)' "$main" || fail "Main must construct the fail-closed gameplay ProfileStore view"
for pattern in \
  'HomeService.new(world, gameplayProfileStore' \
  'FurniturePlacementService.new(gameplayProfileStore' \
  'GardenService.new(world, plotService, gameplayProfileStore' \
  'CarService.new(world, gameplayProfileStore' \
  'TradeService.new(world, gameplayProfileStore' \
  'VillageService.new(world, gameplayProfileStore' \
  'ExplorationService.new(world, gameplayProfileStore' \
  'LivingWorldService.new(world, gameplayProfileStore' \
  'ProfessionService.new(world, gameplayProfileStore' \
  'CompanionService.new(world, plotService, gameplayProfileStore' \
  'MermaidLandService.new(world, gameplayProfileStore'; do
  grep -q "$pattern" "$main" || fail "Main must use the guarded gameplay ProfileStore for: $pattern"
done

grep -q 'R8LegacyPresentationRetirement' "$main" || fail "Main must invoke legacy presentation retirement during R8 composition"
grep -q 'R8LegacyPresentationRetirement.apply(world)' "$main" || fail "Main must retire legacy presentation explicitly"
grep -q 'portalService:hasValidSession' "$main" || fail "Main must wire PortalService authority into traversal safety"
grep -q 'villageActivityService:setupPlayer' "$main" || fail "Main must register village activity respawn lifecycle"
grep -q 'villageActivityService:abandon(player, true)' "$main" || fail "Main must release village activity state before portal travel"

grep -q 'TraversalSafetyRules.spec' "$runner" || fail "TraversalSafetyRules regression spec is not registered"
grep -q 'PortalSessionRules.spec' "$runner" || fail "PortalSessionRules regression spec is not registered"
grep -q 'ActivityLeaseRules.spec' "$runner" || fail "ActivityLeaseRules regression spec is not registered"
grep -q 'PlayerPhaseRules.spec' "$runner" || fail "PlayerPhaseRules regression spec is not registered"
grep -q 'PerformanceBudgetRules.spec' "$runner" || fail "PerformanceBudgetRules regression spec is not registered"

jq -e '.tree.Workspace."$className" == "Workspace"' "$project" >/dev/null || fail "Workspace must be explicitly mapped in the Rojo project"
jq -e '.tree.Workspace."$ignoreUnknownInstances" == false' "$project" >/dev/null || fail "Rojo Workspace mapping must preserve unknown Studio children"
jq -e '.tree.Workspace."$properties".StreamingEnabled == true' "$project" >/dev/null || fail "Workspace.StreamingEnabled must be source-controlled true"
jq -e '.tree.Workspace."$properties".StreamingMinRadius == 64' "$project" >/dev/null || fail "Workspace.StreamingMinRadius must be 64"
jq -e '.tree.Workspace."$properties".StreamingTargetRadius == 1024' "$project" >/dev/null || fail "Workspace.StreamingTargetRadius must be 1024"

test -f "$performance_doc" || fail "DEV performance acceptance document is missing"
grep -q 'PENDING REAL DEVICE' "$performance_doc" || fail "performance evidence must remain explicitly pending until measured"
grep -q '30 FPS' "$performance_doc" || fail "performance document must state the FPS floor"
grep -q '500 MB' "$performance_doc" || fail "performance document must state the memory ceiling"
grep -q '15 seconds' "$performance_doc" || fail "performance document must state the load-time ceiling"
grep -q 'Developer Console' "$performance_doc" || fail "performance document must require Developer Console evidence"
grep -q 'MicroProfiler' "$performance_doc" || fail "performance document must require MicroProfiler evidence"
grep -q 'instance count' "$performance_doc" || fail "performance document must record runtime instance count"

echo "R8.2 runtime hardening source contract passed."
