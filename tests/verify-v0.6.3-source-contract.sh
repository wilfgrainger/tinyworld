#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

fail() { echo "FAIL: $1" >&2; exit 1; }
pass() { echo "PASS: $1"; }

[[ -f docs/roadmap/v0.6.3-production-art-world-craft.md ]] || fail "v0.6.3 roadmap missing"
[[ -f docs/releases/v0.6.3/acceptance.md ]] || fail "v0.6.3 acceptance missing"
for path in \
  src/server/ProductionArtCleanup.luau \
  src/server/VillageLandscapeBuilder.luau \
  src/server/VillageGroundRebuildBuilder.luau \
  src/server/SpawnPresentationBuilder.luau \
  src/server/ProductionVisualService.luau \
  src/server/ProductionVillageVisuals.luau \
  src/server/ProductionHomeVisuals.luau \
  src/server/ProductionMeshFactory.luau \
  src/shared/ProductionArtSpec.luau \
  src/shared/ProductionAssetRegistry.luau \
  src/shared/ReleaseInfo.luau \
  src/client/BuildStamp.client.luau; do
  [[ -f "$path" ]] || fail "current visual/candidate helper missing: $path"
done
pass "v0.6.3 ART R4 source surface exists"

jq -e '.productVersion == "0.6.3" and .releaseName == "Production Art & World Craft" and .profileSchema == 11 and .artifactFile == "TinyWorld-v0.6.3.rbxlx"' config/release.json >/dev/null \
  || fail "release metadata is not v0.6.3 Production Art & World Craft / schema 11"
pass "v0.6.3 release metadata is exact"

grep -Fq 'ProductionArtCleanup.apply(world.root)' src/server/Main.server.luau \
  || fail "server composition root does not apply legacy ordinary-world cleanup"
grep -Fq 'VillageLandscapeBuilder.build(world.root, world.layout)' src/server/Main.server.luau \
  || fail "server composition root does not retain deterministic neighbourhood landscape"
grep -Fq 'VillageGroundRebuildBuilder.apply(world.root)' src/server/Main.server.luau \
  || fail "server composition root does not retain district ground composition"
grep -Fq 'SpawnPresentationBuilder.apply(world.root)' src/server/Main.server.luau \
  || fail "server composition root does not retain safe hidden spawn presentation"
grep -Fq 'local productionVisualService = ProductionVisualService.new()' src/server/Main.server.luau \
  || fail "server composition root does not initialise ART R4 production visuals"
grep -Fq 'ProductionVillageVisuals.apply(world, productionVisualService)' src/server/Main.server.luau \
  || fail "server composition root does not mount ART R4 village visuals"
pass "semantic world foundation and ART R4 production visual boundary are active"

# Current hero rendering must not reactivate the screenshot-failed additive chain.
for oldCall in \
  'CivicCraftBuilder.apply(world.root)' \
  'CivicHeroRebuildBuilder.apply(world.root)' \
  'CivicFacadePolishBuilder.apply(world.root)' \
  'VillageArrivalPolishBuilder.apply(world.root)' \
  'HeroPortalBuilder.apply(world.root)' \
  'HeroFountainBuilder.apply(world.root)' \
  'OrganicNatureBuilder.apply(world.root)'; do
  if grep -Fq "$oldCall" src/server/Main.server.luau; then
    fail "retired R1-R3 visible hero layer is active: $oldCall"
  fi
done
pass "R1-R3 additive hero layering is retired from Main"

grep -Fq 'replaceLegacyPracticalLights' src/server/ProductionArtCleanup.luau \
  || fail "legacy practical-light cleanup missing"
grep -Fq 'hideSpawnPad' src/server/ProductionArtCleanup.luau \
  || fail "legacy development spawn cleanup missing"
grep -Fq 'removePrimitiveAmbientCharacters' src/server/ProductionArtCleanup.luau \
  || fail "primitive ambient-character cleanup missing"
pass "known legacy presentation hazards remain fail-closed"

for feature in cottageGarden flowerMeadow retainingWall dockClutter coastalPlanting canopy rockClusters narrowPath woodlandFence orchard vegetableBeds nursery terrace fountainPlaza plantedEdges seating framedApproaches; do
  grep -Fq "$feature" src/shared/VillageCompositionRules.luau || fail "composition manifest missing $feature"
done
for neighbourhood in MeadowLane HarbourRow WoodlandRise OrchardEnd; do
  grep -Fq "$neighbourhood" src/server/VillageLandscapeBuilder.luau || fail "landscape missing $neighbourhood"
  grep -Fq "$neighbourhood" src/server/VillageGroundRebuildBuilder.luau || fail "ground composition missing $neighbourhood"
done
grep -Fq 'fallback-ground-only' src/server/VillageGroundRebuildBuilder.luau \
  || fail "VillageGround is not explicitly demoted to fallback visual role"
pass "neighbourhood composition and green-board correction remain active"

grep -Fq 'productVersion = "0.6.3"' src/shared/ReleaseInfo.luau || fail "runtime release identity is stale"
grep -Fq 'channel = "DEV"' src/shared/ReleaseInfo.luau || fail "runtime release channel is not DEV"
grep -Fq 'candidate = "PR #8"' src/shared/ReleaseInfo.luau || fail "runtime candidate identity is not PR #8"
grep -Fq 'artRevision = "ART R4"' src/shared/ReleaseInfo.luau || fail "runtime art revision is not ART R4"
grep -Fq 'ReleaseInfo' src/client/BuildStamp.client.luau || fail "candidate stamp is not sourced from ReleaseInfo"
grep -Fq 'UDim2.fromOffset(12, 120)' src/client/BuildStamp.client.luau || fail "candidate stamp does not reserve space below the normal HUD"
pass "Studio/DEV screenshots identify v0.6.3 PR #8 ART R4"

grep -Fq 'v0.6.3' README.md || fail "README does not identify v0.6.3"
grep -Fq 'v0.6.3' AGENTS.md || fail "AGENTS does not identify v0.6.3"
grep -Fq 'v0.6.3' docs/README.md || fail "docs index does not identify v0.6.3"
grep -Fq 'reserved for the family/girls review' docs/roadmap/v0.7.0-village-life.md || fail "v0.7.0 reservation missing"
pass "current documentation authority and reserved v0.7.0 are explicit"

grep -Fq 'tinyworld-v0.6.3-${{ github.sha }}' .github/workflows/rojo-build.yml || fail "Rojo artifact name is stale"
grep -Fq 'dist/TinyWorld-v0.6.3.rbxlx' .github/workflows/rojo-build.yml || fail "Rojo artifact path is stale"
pass "build workflow targets v0.6.3"

echo "PASS: TinyWorld v0.6.3 Production Art & World Craft source contract (ART R4 authority)"
