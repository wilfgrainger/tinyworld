#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

fail() {
  echo "FAIL: $1" >&2
  exit 1
}

pass() {
  echo "PASS: $1"
}

[[ -f docs/releases/v0.6.1/acceptance.md ]] || fail "missing v0.6.1 acceptance"
[[ -f docs/roadmap/v0.6.1-visual-rescue.md ]] || fail "missing v0.6.1 roadmap"
[[ -f docs/superpowers/specs/2026-08-10-tinyworld-v0.6.1-visual-rescue-design.md ]] || fail "missing v0.6.1 design"
[[ -f docs/superpowers/plans/2026-08-10-tinyworld-v0.6.1-visual-rescue.md ]] || fail "missing v0.6.1 plan"
pass "v0.6.1 visual release documents exist"

if [[ -f src/server/CharacterAppearanceBuilder.luau ]]; then
  if grep -Fq 'TinyWorldHairFallback' src/server/CharacterAppearanceBuilder.luau; then
    fail "primitive TinyWorldHairFallback still exists"
  fi
  if grep -Fq 'TinyWorldShoesFallback' src/server/CharacterAppearanceBuilder.luau; then
    fail "primitive TinyWorldShoesFallback still exists"
  fi
fi

if grep -Fq 'CharacterAppearanceBuilder' src/server/AppearanceService.luau; then
  fail "AppearanceService still depends on primitive character builder"
fi
pass "primitive character fallback is not in the active appearance path"

ordinary_world_files=(
  src/server/AuthoredPrefabBuilder.luau
  src/server/WorldBuilder.luau
  src/server/HomePrefabBuilder.luau
  src/server/HomeService.luau
  src/server/BoundaryBuilder.luau
  src/server/LivingWorldBuilder.luau
)

for path in "${ordinary_world_files[@]}"; do
  [[ -f "$path" ]] || continue
  if grep -Fq 'AlwaysOnTop = true' "$path"; then
    fail "$path still creates always-on-top ordinary world labels"
  fi
done
pass "ordinary world builders do not create always-on-top information walls"

for forbidden in 'HOME GATE' 'HOME STYLE' 'HOME SUPPLY' 'DAILY FOUNTAIN' 'VILLAGE FUND' 'PROFESSION BOARD'; do
  if grep -RFq "$forbidden" src/server src/client; then
    fail "prototype floating-copy token remains in runtime source: $forbidden"
  fi
done
pass "prototype system-label copy is absent from runtime source"

grep -Fq 'StatusCluster' src/client/Main.client.luau || fail "compact StatusCluster missing"
grep -Fq 'GameNav' src/client/Main.client.luau || fail "compact GameNav missing"
if grep -Fq 'UDim2.new(1, -208, 0, 44)' src/client/Main.client.luau; then
  fail "full-width level bar still present"
fi
pass "normal HUD uses the v0.6.1 compact structure"

echo "PASS: v0.6.1 visual source contract"