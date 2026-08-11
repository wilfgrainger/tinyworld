#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

fail() { echo "FAIL: $1" >&2; exit 1; }
pass() { echo "PASS: $1"; }

[[ -f docs/roadmap/v0.6.3-production-art-world-craft.md ]] || fail "v0.6.3 roadmap missing"
[[ -f docs/releases/v0.6.3/acceptance.md ]] || fail "v0.6.3 acceptance missing"
for path in \
  src/server/ArchitecturalDetailBuilder.luau \
  src/server/VillageLandscapeBuilder.luau \
  src/server/CivicCraftBuilder.luau \
  src/server/ProductionArtCleanup.luau; do
  [[ -f "$path" ]] || fail "visual helper missing: $path"
done
pass "v0.6.3 release and focused visual helper files exist"

jq -e '.productVersion == "0.6.3" and .releaseName == "Production Art & World Craft" and .profileSchema == 11 and .artifactFile == "TinyWorld-v0.6.3.rbxlx"' config/release.json >/dev/null \
  || fail "release metadata is not v0.6.3 Production Art & World Craft / schema 11"
pass "v0.6.3 release metadata is exact"

for path in src/server/HomePrefabBuilder.luau src/server/HomeStoreDestinationBuilder.luau; do
  grep -Fq 'ArchitecturalDetailBuilder' "$path" || fail "$path does not use ArchitecturalDetailBuilder"
done
grep -Fq 'ProductionArtCleanup.apply(world.root)' src/server/Main.server.luau \
  || fail "server composition root does not apply legacy ordinary-world visual cleanup"
grep -Fq 'CivicCraftBuilder.apply(world.root)' src/server/Main.server.luau \
  || fail "server composition root does not apply civic craft"
grep -Fq 'VillageLandscapeBuilder.build(world.root, world.layout)' src/server/Main.server.luau \
  || fail "server composition root does not activate VillageLandscapeBuilder"
pass "hero architecture, civic craft, cleanup and landscape are active"

if grep -Fq '"PorchLamp",' src/server/HomePrefabBuilder.luau || grep -Fq '"HomeLantern",' src/server/HomePrefabBuilder.luau; then
  fail "old naked home practical-light recipe survived"
fi
if grep -Fq 'Enum.PartType.Ball' src/server/ArchitecturalDetailBuilder.luau; then
  fail "architectural lantern helper must not use ball geometry"
fi
grep -Fq 'replaceLegacyPracticalLights' src/server/ProductionArtCleanup.luau \
  || fail "legacy practical lights are not cleaned from the rendered ordinary village"
grep -Fq 'hideSpawnPad' src/server/ProductionArtCleanup.luau \
  || fail "visible development spawn pad cleanup missing"
pass "ordinary practical lighting and spawn presentation address v0.6.2 failures"

grep -Fq 'removePrimitiveAmbientCharacters' src/server/ProductionArtCleanup.luau \
  || fail "rendered primitive ambient character cleanup missing"
for actor in BirdAmbient ButterflyAmbient; do
  grep -Fq "$actor" src/server/ProductionArtCleanup.luau \
    || fail "cleanup does not cover $actor"
done
pass "surviving legacy Part-built ambient actors are removed before play"

if grep -Fq 'Vector3.new(width + 2, 1, depth + 2)' src/server/HomePrefabBuilder.luau; then
  fail "hero home still contains the v0.6.2 full-footprint slab roof"
fi
if grep -Fq '"HomeStoreRoof"' src/server/HomeStoreDestinationBuilder.luau && \
   ! grep -Fq 'addPitchedRoof' src/server/HomeStoreDestinationBuilder.luau; then
  fail "Home Store still uses slab-dominated roof recipe"
fi
pass "known hero slab-roof recipes are absent"

for requirement in addPitchedRoof addWindow addDoor addPorch addChimney addLantern; do
  grep -Fq "function ArchitecturalDetailBuilder.${requirement}" src/server/ArchitecturalDetailBuilder.luau \
    || fail "ArchitecturalDetailBuilder missing ${requirement}"
done
pass "architectural craft primitives are explicit"

grep -Fq 'PointLight' src/server/ArchitecturalDetailBuilder.luau || fail "architectural lantern lacks bounded PointLight"
grep -Fq 'light.Range' src/server/ArchitecturalDetailBuilder.luau || fail "architectural lantern lacks explicit light range"
grep -Fq 'light.Brightness' src/server/ArchitecturalDetailBuilder.luau || fail "architectural lantern lacks explicit brightness"
pass "practical-light implementation has bounded lighting"

for feature in cottageGarden flowerMeadow retainingWall dockClutter coastalPlanting canopy rockClusters narrowPath woodlandFence orchard vegetableBeds nursery terrace fountainPlaza plantedEdges seating framedApproaches; do
  grep -Fq "$feature" src/shared/VillageCompositionRules.luau || fail "composition manifest missing $feature"
done
for neighbourhood in MeadowLane HarbourRow WoodlandRise OrchardEnd; do
  grep -Fq "$neighbourhood" src/server/VillageLandscapeBuilder.luau || fail "production landscape missing $neighbourhood"
done
pass "neighbourhood/civic composition contract and implementation are explicit"

for destination in TownHall Courier VillageShop Workshop Market; do
  grep -Fq "$destination" src/server/CivicCraftBuilder.luau || fail "civic craft missing $destination"
done
grep -Fq 'HomeStorePitchedRoof' src/server/HomeStoreDestinationBuilder.luau || fail "crafted Home Store roof missing"
pass "civic destinations receive a production-craft pass"

grep -Fq 'v0.6.3' README.md || fail "README does not identify v0.6.3"
grep -Fq 'v0.6.3' AGENTS.md || fail "AGENTS does not identify v0.6.3"
grep -Fq 'v0.6.3' docs/README.md || fail "docs index does not identify v0.6.3"
grep -Fq 'reserved for the family/girls review' docs/roadmap/v0.7.0-village-life.md || fail "v0.7.0 reservation missing"
pass "current documentation authority and reserved v0.7.0 are explicit"

grep -Fq 'tinyworld-v0.6.3-${{ github.sha }}' .github/workflows/rojo-build.yml || fail "Rojo artifact name is stale"
grep -Fq 'dist/TinyWorld-v0.6.3.rbxlx' .github/workflows/rojo-build.yml || fail "Rojo artifact path is stale"
pass "build workflow targets v0.6.3"

echo "PASS: TinyWorld v0.6.3 Production Art & World Craft source contract"
