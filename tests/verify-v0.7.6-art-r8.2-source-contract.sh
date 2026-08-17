#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "R8.2 runtime hardening contract failed: $1" >&2
  exit 1
}

traversal_service="src/server/TraversalSafetyService.luau"
portal_service="src/server/PortalService.luau"
main="src/server/Main.server.luau"
runner="tests/run.luau"

for path in "$traversal_service" "$portal_service" "$main" "$runner"; do
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

grep -q 'portalService:hasValidSession' "$main" || fail "Main must wire PortalService authority into traversal safety"
grep -q 'TraversalSafetyRules.spec' "$runner" || fail "TraversalSafetyRules regression spec is not registered"
grep -q 'PortalSessionRules.spec' "$runner" || fail "PortalSessionRules regression spec is not registered"

echo "R8.2 runtime hardening source contract passed."
