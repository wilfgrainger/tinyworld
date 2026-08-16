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
  "scripts/publish-dev.sh"
  ".github/workflows/tinyworld-ci.yml"
  "tests/verify-v0.7.3-art-r7-source-contract.sh"
  "tests/build-contract.sh"
  "tests/publish-dev-contract.sh"
  "src/shared/CompanionRules.luau"
  "src/shared/MermaidQuestRules.luau"
  "src/shared/VillageNpcDefinitions.luau"
  "src/shared/VillageActivityDefinitions.luau"
  "src/shared/VillageActivityRules.luau"
  "src/server/CompanionService.luau"
  "src/server/CarService.luau"
  "src/server/MermaidLandService.luau"
  "src/server/CoastBuilder.luau"
  "src/server/ProductionVisualService.luau"
  "src/server/ProductionMeshFactory.luau"
  "src/server/PublishedFallbackFactory.luau"
  "src/server/VillageNpcBuilder.luau"
  "src/server/VillageActivityService.luau"
  "src/server/R7WorldCompositionBuilder.luau"
  "src/server/R7BuildingPolishBuilder.luau"
  "src/server/R7ActivityPresentationBuilder.luau"
)
for path in "${required_paths[@]}"; do [[ -e "$path" ]] || fail "missing required path: $path"; done

jq -e '
  .productVersion == "0.7.3" and
  .releaseName == "Premium Visual World Pass" and
  .profileSchema == 11 and
  .rojoVersion == "7.7.0" and
  .styluaVersion == "2.5.2" and
  .rokitVersion == "1.2.0" and
  .rokitInstallerCommit == "2f2618428ef31279e2fc80b0b1d73485bc929ddd" and
  .projectFile == "default.project.json" and
  .artifactFile == "TinyWorld-v0.7.3.rbxlx"
' config/release.json >/dev/null || fail "config/release.json is not the exact v0.7.3 contract"
pass "release metadata is exact"

for expected in \
  'rojo = "rojo-rbx/rojo@7.7.0"' \
  'stylua = "JohnnyMorganz/StyLua@2.5.2"'; do
  grep -Fqx "$expected" rokit.toml || fail "rokit.toml missing pin: $expected"
done
pass "toolchain pins are exact"

jq -e '
  .schemaVersion == 3 and
  .policy.allowInventedIds == false and
  .policy.nativeFallbacksRemainValid == true and
  .policy.studioEditableMeshPreviewAllowed == true and
  .policy.publishedEditableMeshPreviewAllowed == false and
  (.assets | type == "array") and
  all(.assets[]?;
    (.id | type == "string" and length > 0) and
    (.robloxAssetId | type == "number" and . > 0 and floor == .) and
    (.owner | type == "string" and length > 0) and
    (.source | type == "string" and length > 0) and
    (.sourceSha256 | type == "string" and test("^[0-9a-f]{64}$")) and
    (.licenseOrProvenance | type == "string" and length > 0) and
    (.prefabRole | type == "string" and length > 0) and
    (.version | type == "string" and length > 0) and
    (.status | type == "string" and length > 0) and
    (.qualityTier | type == "string" and length > 0) and
    (.devApproved | type == "boolean") and
    (.liveApproved | type == "boolean")
  )
' assets/manifests/assets.json >/dev/null || fail "production asset manifest must remain fail-closed with published-safe fallback"
pass "asset manifest is fail-closed and published-safe"

grep -Fq 'ProfileSchema.VERSION = 11' src/shared/ProfileSchema.luau || fail "ProfileSchema.VERSION must remain 11"
grep -Fq 'TinyWorld_DEV_PlayerProfile_v11' src/server/EnvironmentConfig.luau || fail "DEV DataStore namespace missing"
grep -Fq 'TinyWorld_LIVE_PlayerProfile_v11' src/server/EnvironmentConfig.luau || fail "LIVE DataStore namespace missing"
pass "profile v11 remains compatible"

jq -e '.configured == true and (.universeId | tostring) == "10654114907" and (.placeId | tostring) == "76129528245924" and .publishing == "open-cloud"' config/environments/dev.json >/dev/null || fail "DEV target is not approved TinyWorld DEV"
jq -e '.configured == false and .universeId == null and .placeId == null and .publishing == "deferred"' config/environments/live.json >/dev/null || fail "LIVE must remain deferred"
pass "DEV and LIVE boundaries are explicit"

workflow_count="$(find .github/workflows -maxdepth 1 -type f \( -name '*.yml' -o -name '*.yaml' \) | wc -l | tr -d ' ')"
[[ "$workflow_count" == "1" ]] || fail "exactly one active workflow is required"
WORKFLOW=.github/workflows/tinyworld-ci.yml
grep -Fq 'name: TinyWorld CI' "$WORKFLOW" || fail "canonical workflow name missing"
grep -Fq 'runs-on: ubuntu-latest' "$WORKFLOW" || fail "standard free runner missing"
grep -Fq 'luau tests/run.luau' "$WORKFLOW" || fail "unit test gate missing"
grep -Fq 'stylua --check src tests' "$WORKFLOW" || fail "format gate missing"
grep -Fq 'bash ./tests/verify-v0.7.3-art-r7-source-contract.sh' "$WORKFLOW" || fail "ART R7 source gate missing"
grep -Fq 'bash ./scripts/build.sh' "$WORKFLOW" || fail "build step missing"
grep -Fq "if: github.event_name == 'push' && github.ref == 'refs/heads/main'" "$WORKFLOW" || fail "DEV publishing must be main-only"
grep -Fq 'ROBLOX_DEV_API_KEY: ${{ secrets.ROBLOX_DEV_API_KEY }}' "$WORKFLOW" || fail "DEV secret binding missing"
grep -Fq 'bash ./scripts/publish-dev.sh' "$WORKFLOW" || fail "DEV publisher missing"
if grep -R -n -E 'uses:[[:space:]]+actions/(upload-artifact|cache)@' .github/workflows; then
  fail "persistent Actions storage is prohibited"
fi
pass "one free-only CI and DEV publish workflow is authoritative"

if grep -RIEq --exclude='verify-release-contract.sh' --exclude='publish-dev-contract.sh' --exclude-dir='.git' \
  'ROBLOX_DEV_API_KEY[[:space:]]*=[[:space:]]*[^$<{[:space:]]+' \
  src scripts .github config assets tests 2>/dev/null; then
  fail "literal DEV API key found in repository"
fi
pass "repository contains no Roblox credential literal"

echo "PASS: TinyWorld v0.7.3 ART R7 Premium Visual World Pass release contract is valid"
