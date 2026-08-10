#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

fail() { echo "FAIL: $1" >&2; exit 1; }
pass() { echo "PASS: $1"; }

[[ -f docs/roadmap/v0.6.2-village-life-visual-craft.md ]] || fail "v0.6.2 roadmap missing"
[[ -f docs/releases/v0.6.2/acceptance.md ]] || fail "v0.6.2 acceptance missing"
[[ -f src/shared/CourierRouteRules.luau ]] || fail "CourierRouteRules missing"
[[ -f src/server/HomeStoreDestinationBuilder.luau ]] || fail "distinct Home Store builder missing"
pass "v0.6.2 release and focused Village Life files exist"

jq -e '.productVersion == "0.6.2" and .releaseName == "Village Life & Visual Craft" and .profileSchema == 11 and .artifactFile == "TinyWorld-v0.6.2.rbxlx"' config/release.json >/dev/null \
  || fail "release metadata is not v0.6.2 Village Life & Visual Craft / schema 11"
pass "v0.6.2 release metadata is exact"

for activity in 'id = "Courier"' 'id = "Gardener"' 'id = "Designer"' 'id = "VillageExplorer"'; do
  grep -Fq "$activity" src/shared/ActivityDefinitions.luau || fail "missing canonical activity: $activity"
done
if grep -Fq 'id = "HarborHelper"' src/shared/ActivityDefinitions.luau; then
  fail "obsolete HarborHelper remains canonical"
fi
grep -Fq 'professionId = "Farmer"' src/shared/ActivityDefinitions.luau || fail "Gardener persistence compatibility missing"
pass "canonical Village Life activities are explicit"

grep -Fq 'VillageShop' src/shared/CourierRouteRules.luau || fail "Village Shop courier destination missing"
grep -Fq 'TownHall' src/shared/CourierRouteRules.luau || fail "Town Hall courier destination missing"
grep -Fq 'HomeStore' src/shared/CourierRouteRules.luau || fail "Home Store courier destination missing"
grep -Fq 'Workshop' src/shared/CourierRouteRules.luau || fail "Workshop courier destination missing"
grep -Fq 'TinyWorldCourierDestination' src/server/JobService.luau || fail "server courier destination state missing"
grep -Fq 'CourierDeliveryPrompt_' src/server/JobService.luau || fail "physical destination delivery prompts missing"
pass "Courier uses bounded server-owned destination routes"

grep -Fq 'home_design = 16' src/shared/RouteRules.luau || fail "home design route bit missing"
grep -Fq 'FurniturePlacementService.new(ProfileStore, PlayerStateService, RouteService)' src/server/FurniturePlacementService.luau \
  || fail "FurniturePlacementService does not receive RouteService"
grep -Fq 'self.RouteService:record(player, "home_design")' src/server/FurniturePlacementService.luau \
  || fail "successful furniture placement does not record home-design route progress"
pass "Designer route progress is connected to authoritative placement"

if grep -Eq 'local function (bird|cat)\(' src/server/AmbientLifeService.luau; then
  fail "primitive Part-built ambient animal fallback remains"
fi
if grep -Eq 'Village(Bird|Cat)' src/server/AmbientLifeService.luau; then
  fail "primitive ambient animal instances remain"
fi
pass "unfinished ambient character fallback is absent"

if grep -Fq 'in this prototype' src/server/GardenService.luau; then
  fail "prototype garden copy remains player-facing"
fi
grep -Fq 'Gardener' src/server/ProfessionService.luau || fail "Gardener player-facing path missing"
grep -Fq 'Village Trail' src/server/ExplorationService.luau || fail "Village Explorer trail language missing"
pass "Gardener and Village Explorer read as player-facing activities"

# The former v0.7.0 destination/home/social scope must exist in source, not only the roadmap.
grep -Fq 'WorldLayoutRules.MAX_PLOTS = 16' src/shared/WorldLayoutRules.luau || fail "sixteen-home cap missing"
for builder in buildTownHall buildCourierDepot buildVillageShop buildTransportWorkshop buildMarket; do
  grep -Fq "$builder" src/server/WorldBuilder.luau || fail "civic destination builder missing: $builder"
done
grep -Fq 'HomeStoreDestinationBuilder.extend(world)' src/server/Main.server.luau \
  || fail "distinct Home Store destination is not activated"
grep -Fq 'model.Name = "HomeStoreDestination"' src/server/HomeStoreDestinationBuilder.luau \
  || fail "Home Store destination model missing"
grep -Fq 'TinyWorldRecognizableSilhouette' src/server/HomeStoreDestinationBuilder.luau \
  || fail "Home Store destination lacks explicit silhouette intent"
pass "six civic destinations have separate physical source surfaces"

grep -Fq 'RemoteGuard.checkRate(player, "home_store"' src/server/HomeStoreService.luau \
  || fail "Home Store server mutation guard missing"
grep -Fq 'ShopDefinitions.priceFor("HomeStore", furnitureId)' src/server/HomeStoreService.luau \
  || fail "Home Store server-owned price path missing"
grep -Fq '#furniture >= 80' tests/ContentDefinitions.spec.luau \
  || fail "80+ home-content catalogue contract missing"
pass "Home Store and home-content authority remain in scope"

grep -Fq 'function SocialService:recordVisit' src/server/SocialService.luau \
  || fail "safe home-visiting path missing"
grep -Fq 'self.ProfileStore.get(player)' src/server/FurniturePlacementService.luau \
  || fail "home mutation ownership/profile authority missing"
pass "safe social visiting remains available without visitor mutation authority"

[[ -f src/server/TradeJournal.luau ]] || fail "durable trade journal missing"
grep -Fq 'TradeJournal' src/server/TradeService.luau || fail "Trading Post service no longer uses durable trade journal"
pass "Market/Trading Post retains hardened durable trade path"

grep -Fq 'MotionAnimator' default.project.json src/client/MotionAnimator.client.luau 2>/dev/null \
  || [[ -f src/client/MotionAnimator.client.luau ]] \
  || fail "existing authored ambient/world motion path missing"
pass "restrained existing ambient/world motion path remains without an NPC framework"

grep -Fq 'reserved for the family/girls review' docs/roadmap/v0.7.0-village-life.md \
  || fail "v0.7.0 is not explicitly reserved for the family/girls review"
pass "v0.7.0 milestone is reserved for the later review"

grep -Fq 'fallback/prototype' docs/engineering/asset-pipeline.md || fail "fallback/prototype visual state missing"
grep -Fq 'authored-native' docs/engineering/asset-pipeline.md || fail "authored-native visual state missing"
grep -Fq 'approved-production' docs/engineering/asset-pipeline.md || fail "approved-production visual state missing"
pass "Claude visual-craft asset states are durable"

grep -Fq 'tinyworld-v0.6.2-${{ github.sha }}' .github/workflows/rojo-build.yml || fail "Rojo artifact name is stale"
grep -Fq 'dist/TinyWorld-v0.6.2.rbxlx' .github/workflows/rojo-build.yml || fail "Rojo artifact path is stale"
pass "build workflow targets v0.6.2"

echo "PASS: TinyWorld v0.6.2 source contract"
