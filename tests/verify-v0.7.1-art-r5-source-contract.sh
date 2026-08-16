#!/usr/bin/env bash
set -euo pipefail

fail() { echo "FAIL: $1" >&2; exit 1; }
pass() { echo "PASS: $1"; }

jq -e '.productVersion == "0.7.1" and .releaseName == "Published DEV Recovery" and .profileSchema == 11 and .artifactFile == "TinyWorld-v0.7.1.rbxlx"' config/release.json >/dev/null || fail "ART R5 release metadata is not exact"
pass "ART R5 release identity is exact"

for token in ProductionArtCleanup ProductionVisualService ProductionVillageVisuals CoastBuilder TraversalSafetyService CompanionService VillageNpcService CarService MermaidLandService PrestigePadBuilder; do
  grep -Fq "$token" src/server/Main.server.luau || fail "Main missing runtime composition: $token"
done
pass "v0.7 family world services remain on one startup path"

[[ -f art/specs/village-product-art.json ]] || fail "product-art authoring spec missing"
[[ -f src/server/ProductionMeshFactory.luau ]] || fail "production mesh factory missing"
grep -Fq 'EditableMesh' src/server/ProductionMeshFactory.luau || fail "Studio custom-mesh authoring path missing"
pass "Studio custom-mesh authoring path remains available"

jq -e '
  .policy.nativeFallbacksRemainValid == true and
  .policy.studioEditableMeshPreviewAllowed == true and
  .policy.publishedEditableMeshPreviewAllowed == false
' assets/manifests/assets.json >/dev/null || fail "asset policy does not encode safe published fallback"
pass "asset policy distinguishes Studio preview from published fallback"

if grep -Fq 'ReleaseInfo.channel == "DEV"' src/server/ProductionVisualService.luau; then
  fail "DEV release channel still authorizes preview geometry"
fi
grep -Fq '_canUseStudioPreview' src/server/ProductionVisualService.luau || fail "Studio-only preview capability missing"
grep -Fq 'return RunService:IsStudio()' src/server/ProductionVisualService.luau || fail "preview capability is not Studio-only"
pass "published DEV cannot authorize preview from release channel"

grep -Fq 'RunService:IsStudio()' src/server/EditableMeshPreviewFactory.luau || fail "preview factory has no Studio guard"
grep -Fq 'EditableMesh preview rejected outside Studio' src/server/EditableMeshPreviewFactory.luau || fail "preview factory does not fail closed outside Studio"
pass "preview factory fails closed outside Studio"

[[ -f src/server/PublishedFallbackFactory.luau ]] || fail "published fallback factory missing"
grep -Fq 'PublishedFallbackFactory' src/server/ProductionMeshFactory.luau || fail "production mesh factory does not route published servers to safe fallback"
grep -Fq 'published-safe-fallback-r5' src/server/PublishedFallbackFactory.luau || fail "fallback visual state missing"
if grep -Eq 'EditableMesh|CreateMeshPartAsync|Content\.fromObject' src/server/PublishedFallbackFactory.luau; then
  fail "published fallback must not use runtime mesh APIs"
fi

guard_line="$(grep -nF 'if not RunService:IsStudio() then' src/server/ProductionMeshFactory.luau | head -n1 | cut -d: -f1 || true)"
mesh_line="$(grep -nF 'AssetService:CreateEditableMesh()' src/server/ProductionMeshFactory.luau | head -n1 | cut -d: -f1 || true)"
[[ -n "$guard_line" && -n "$mesh_line" && "$guard_line" -lt "$mesh_line" ]] || fail "published fallback guard must execute before EditableMesh allocation"
pass "direct production-mesh callers are intercepted before EditableMesh allocation"

for path in src/server/BikeBuilder.luau src/server/BoatBuilder.luau src/server/CarBuilder.luau src/server/CompanionService.luau src/server/VillageNpcService.luau src/server/PrestigePadBuilder.luau; do
  grep -Fq 'ProductionMeshFactory' "$path" || fail "expected direct presentation caller missing from audit: $path"
  if grep -Eq 'CreateEditableMesh|CreateMeshPartAsync|Content\.fromObject' "$path"; then
    fail "direct presentation caller bypasses central safe factory: $path"
  fi
done
pass "all known direct ART users depend on the central published-safe factory"

grep -Fq 'mountThenHideLegacy' src/server/ProductionVillageVisuals.luau || fail "transactional mount-before-hide helper missing"
if grep -Fq $'hideLegacyVisuals(model)\n\treturn productionVisualService:mount' src/server/ProductionVillageVisuals.luau; then
  fail "fixed village visuals still hide legacy before mounting replacement"
fi
grep -Fq 'published-safe-legacy-fallback' src/server/ProductionVillageVisuals.luau || fail "ART R5 village architecture marker missing"
pass "village replacement is fail-safe and legacy-first"

grep -Fq 'Terrain:FillBlock' src/server/CoastBuilder.luau || fail "real Terrain coast water missing"
grep -Fq 'tiny_boat_required' src/shared/TraversalRules.luau || fail "Tiny Boat outer-sea gate missing"
grep -Fq 'worldRecoveryCFrame' src/server/TraversalSafetyService.luau || fail "safe traversal recovery missing"

for role in Trader Gardener Fisherman BoatKeeper Builder; do
  grep -Fq "id = \"$role\"" src/shared/VillageNpcDefinitions.luau || fail "village NPC role missing: $role"
done

grep -Fq 'TINY_CAR_LEVEL = 8' src/shared/TransportRules.luau || fail "Tiny Car level gate missing"
for quest in PearlTrail CoralGarden LostParcel MoonShells WhirlpoolPromise; do
  grep -Fq "$quest" src/shared/MermaidQuestRules.luau || fail "Mermaid quest missing: $quest"
done
grep -Fq 'already_complete' src/shared/MermaidQuestRules.luau || fail "Mermaid quest idempotency missing"
grep -Fq 'ReturnPrompt' src/server/MermaidLandBuilder.luau || fail "Mermaid Land return path missing"
grep -Fq 'REQUIRED_LEVEL = 10' src/shared/CompanionRules.luau || fail "companion level gate missing"
grep -Fq 'TinyWorldCatFlap' src/server/CompanionService.luau || fail "cat flap affordance missing"
grep -Fq 'FutureSpaceshipPad' src/server/PrestigePadBuilder.luau || fail "future spaceship prestige pad missing"
if grep -Fq 'TeleportService' src/server/PrestigePadBuilder.luau; then
  fail "prestige pad must remain visual-only"
fi
pass "v0.7 gameplay scope remains present"

grep -Fq 'productVersion = "0.7.1"' src/shared/ReleaseInfo.luau || fail "R5 release stamp version missing"
grep -Fq 'artRevision = "ART R5"' src/shared/ReleaseInfo.luau || fail "R5 art revision missing"
pass "DEV build stamp identifies ART R5"

workflow_count="$(find .github/workflows -maxdepth 1 -type f \( -name '*.yml' -o -name '*.yaml' \) | wc -l | tr -d ' ')"
[[ "$workflow_count" == "1" ]] || fail "exactly one Actions workflow is allowed"
[[ -f .github/workflows/tinyworld-ci.yml ]] || fail "canonical TinyWorld CI workflow missing"
grep -Fq 'bash ./tests/verify-v0.7.1-art-r5-source-contract.sh' .github/workflows/tinyworld-ci.yml || fail "ART R5 source gate is not wired into CI"
if grep -R -Eq 'actions/(upload-artifact|cache)@' .github/workflows; then
  fail "persistent GitHub Actions storage was reintroduced"
fi
pass "single free-only CI remains authoritative"

echo "PASS: TinyWorld v0.7.1 ART R5 published visual safety contract"
