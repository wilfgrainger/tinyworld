#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

fail() { echo "FAIL: $1" >&2; exit 1; }
pass() { echo "PASS: $1"; }

command -v jq >/dev/null 2>&1 || fail "jq is required"

required_paths=(
  "default.project.json"
  "rokit.toml"
  "stylua.toml"
  "config/release.json"
  "config/environments/dev.json"
  "config/environments/live.json"
  "assets/manifests/assets.json"
  "scripts/build.sh"
  "scripts/build.ps1"
  ".github/workflows/rojo-build.yml"
  ".github/workflows/luau-tests.yml"
  ".github/workflows/release-authority.yml"
  "docs/product/target-state-v1.md"
  "docs/roadmap/v0.6.1-visual-rescue.md"
  "docs/releases/v0.6.1/acceptance.md"
  "docs/superpowers/specs/2026-08-10-tinyworld-v0.6.1-visual-rescue-design.md"
  "docs/superpowers/plans/2026-08-10-tinyworld-v0.6.1-visual-rescue.md"
  "tests/verify-release-authority.sh"
  "tests/verify-v0.6.1-visual-contract.sh"
  "tests/build-contract.sh"
  "tests/build-contract.ps1"
  "src/shared/ProfileMigrations.luau"
  "src/shared/FurnitureDefinitions.luau"
  "src/shared/FurniturePlacementRules.luau"
  "src/shared/TradeTransactionRules.luau"
  "src/server/security/RemoteGuard.luau"
  "src/server/FurniturePlacementService.luau"
  "src/server/TradeJournal.luau"
)
for path in "${required_paths[@]}"; do [[ -e "$path" ]] || fail "missing required path: $path"; done

CONFIG="config/release.json"
ASSETS="assets/manifests/assets.json"
WORKFLOW=".github/workflows/rojo-build.yml"
AUTHORITY_WORKFLOW=".github/workflows/release-authority.yml"

jq -e '
  .productVersion == "0.6.1" and
  .releaseName == "Visual Rescue" and
  .profileSchema == 11 and
  .rojoVersion == "7.7.0" and
  .styluaVersion == "2.5.2" and
  .rokitVersion == "1.2.0" and
  .rokitInstallerCommit == "2f2618428ef31279e2fc80b0b1d73485bc929ddd" and
  .projectFile == "default.project.json" and
  .artifactFile == "TinyWorld-v0.6.1.rbxlx"
' "$CONFIG" >/dev/null || fail "config/release.json is not the exact v0.6.1 contract"
pass "release metadata is exact"

for expected in \
  'rojo = "rojo-rbx/rojo@7.7.0"' \
  'stylua = "JohnnyMorganz/StyLua@2.5.2"'; do
  grep -Fqx "$expected" rokit.toml || fail "rokit.toml missing pin: $expected"
done
pass "toolchain pins are exact"

jq -e '
  .schemaVersion == 2 and
  .policy.allowInventedIds == false and
  (.assets | type == "array") and
  all(.assets[]?;
    (.id | type == "string" and length > 0) and
    (.robloxAssetId | type == "number" and . > 0 and floor == .) and
    (.owner | type == "string" and length > 0) and
    (.source | type == "string" and length > 0) and
    (.licenseOrProvenance | type == "string" and length > 0) and
    (.prefabRole | type == "string" and length > 0) and
    (.version | type == "string" and length > 0) and
    (.status | type == "string" and length > 0) and
    (.devApproved | type == "boolean") and
    (.liveApproved | type == "boolean")
  )
' "$ASSETS" >/dev/null || fail "asset manifest must reject invented IDs and require provenance"
pass "asset manifest is fail-closed"

grep -Fq 'ProfileSchema.VERSION = 11' src/shared/ProfileSchema.luau || fail "ProfileSchema.VERSION must be 11"
grep -Fq 'TinyWorld_DEV_PlayerProfile_v11' src/server/EnvironmentConfig.luau || fail "DEV DataStore namespace missing"
grep -Fq 'TinyWorld_LIVE_PlayerProfile_v11' src/server/EnvironmentConfig.luau || fail "LIVE DataStore namespace missing"
pass "profile v11 and environment separation are explicit"

jq -e '.configured == false and .universeId == null and .placeId == null and .publishing == "deferred"' config/environments/dev.json >/dev/null || fail "DEV publishing must remain unconfigured"
jq -e '.configured == false and .universeId == null and .placeId == null and .publishing == "deferred"' config/environments/live.json >/dev/null || fail "LIVE publishing must remain unconfigured"
pass "publishing remains credential-free and human-gated"

grep -Eq '^name:[[:space:]]+Rojo build[[:space:]]*$' "$WORKFLOW" || fail "Rojo workflow name changed unexpectedly"
grep -Fq 'actions/checkout@v6' "$WORKFLOW" || fail "checkout action pin missing"
grep -Fq 'rokit install --no-trust-check' "$WORKFLOW" || fail "pinned Rokit tools are not installed"
grep -Fq './tests/build-contract.sh' "$WORKFLOW" || fail "build-contract verification step missing"
grep -Fq './scripts/verify-release-contract.sh' "$WORKFLOW" || fail "release guard step missing"
grep -Fq './scripts/build.sh' "$WORKFLOW" || fail "build step missing"
grep -Fq 'tinyworld-v0.6.1-${{ github.sha }}' "$WORKFLOW" || fail "v0.6.1 artifact name missing"
grep -Fq 'dist/TinyWorld-v0.6.1.rbxlx' "$WORKFLOW" || fail "v0.6.1 artifact path missing"
grep -Fq 'dist/release.json' "$WORKFLOW" || fail "release manifest path missing"
pass "Rojo workflow verifies contracts and builds only traceable v0.6.1 evidence"

grep -Fq 'bash ./tests/verify-release-authority.sh' "$AUTHORITY_WORKFLOW" || fail "release authority workflow must use generic current-release guard"
pass "release authority workflow is version-name independent"

for rule in 'dist/' '.rokit/' '.worktrees/' '.superpowers/'; do
  grep -Fqx "$rule" .gitignore || fail ".gitignore missing required rule: $rule"
done

if grep -RIEq --exclude='verify-release-contract.sh' --exclude-dir='.git' \
  '(\.ROBLOSECURITY|ROBLOX_COOKIE)[[:space:]]*[:=][[:space:]]*[^$<{[:space:]]+' \
  src scripts .github config assets 2>/dev/null; then
  fail "credential-shaped literal found in executable repository surfaces"
fi
if grep -RIEq --exclude='verify-release-contract.sh' --exclude-dir='.git' \
  '(upload-place|opencloud.*publish|publish.*opencloud)' .github scripts 2>/dev/null; then
  fail "publishing automation is not approved in v0.6.1"
fi
pass "repository remains free of production publishing credentials/actions"

if find . -maxdepth 3 -type f \( -name 'wally.toml' -o -name 'wally.lock' \) | grep -q .; then
  fail "Wally must not be introduced without an approved dependency"
fi
pass "no unnecessary dependency surface introduced"

if find . -type f \( -path '*/roblox-game-skill/*' -o -name 'SKILL.md' \) | grep -q .; then
  fail "external skill source must not be vendored into TinyWorld"
fi
pass "external skill source is not vendored"

echo "PASS: TinyWorld v0.6.1 Visual Rescue release contract is valid"
