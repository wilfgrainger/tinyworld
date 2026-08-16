#!/usr/bin/env bash
set -euo pipefail

fail() { echo "FAIL: $1" >&2; exit 1; }
pass() { echo "PASS: $1"; }
require_file() { [[ -f "$1" ]] || fail "required file missing: $1"; }

jq -e '.productVersion == "0.7.3" and .releaseName == "Premium Visual World Pass" and .profileSchema == 11 and .artifactFile == "TinyWorld-v0.7.3.rbxlx"' config/release.json >/dev/null || fail "ART R7 release metadata is not exact"
grep -Fq 'productVersion = "0.7.3"' src/shared/ReleaseInfo.luau || fail "R7 release stamp version missing"
grep -Fq 'artRevision = "ART R7"' src/shared/ReleaseInfo.luau || fail "R7 art revision missing"
grep -Fq 'releaseName = "Premium Visual World Pass"' src/shared/ReleaseInfo.luau || fail "R7 release name missing"
pass "ART R7 release identity is exact"

for path in \
  src/server/R7WorldCompositionBuilder.luau \
  src/server/R7BuildingPolishBuilder.luau \
  src/server/R7ActivityPresentationBuilder.luau \
  src/server/VillageNpcBuilder.luau \
  src/server/VillageActivityLocations.luau; do
  require_file "$path"
done
pass "R7 visual architecture is present"

for token in R7WorldCompositionBuilder R7BuildingPolishBuilder R7ActivityPresentationBuilder VillageActivityService VillageNpcService JobService GardenService TradeService MermaidLandService; do
  grep -Fq "$token" src/server/Main.server.luau || fail "Main missing required R7/R6 composition: $token"
done
pass "R7 composes over the complete R6 game experience"

# General map contract.
grep -Fq 'ART_R7_WorldComposition' src/server/R7WorldCompositionBuilder.luau || fail "R7 world composition root marker missing"
grep -Fq '"district-" .. id' src/server/R7WorldCompositionBuilder.luau || fail "R7 district marker prefix construction missing"
for district in plaza homes market garden harbour; do
  grep -Fq "districtMarker(parent, \"$district\")" src/server/R7WorldCompositionBuilder.luau || fail "R7 district construction missing: $district"
done
grep -Fq 'TinyWorldR7Decorative' src/server/R7WorldCompositionBuilder.luau || fail "R7 world decoration safety marker missing"
grep -Fq 'CanCollide = false' src/server/R7WorldCompositionBuilder.luau || fail "R7 world decoration is not explicitly non-colliding"
if grep -Fq 'Vector3.new(size.X, 0.04, size.Y)' src/server/VillageGroundRebuildBuilder.luau; then
  fail "legacy coplanar 0.04-stud ground overlay returned"
fi
if grep -nA10 -B2 '"FieldA"\|"FieldB"' src/server/VillageGroundRebuildBuilder.luau | grep -Fq 'Enum.Material.Grass'; then
  fail "district decorative fields layer Grass over base Grass"
fi
pass "R7 map composition preserves grass safety"

# House/building contract.
grep -Fq 'ART_R7_BuildingPolish' src/server/R7BuildingPolishBuilder.luau || fail "R7 building polish root marker missing"
for role in residential market workshop garden harbour; do
  grep -Fq "building-$role" src/server/R7BuildingPolishBuilder.luau || fail "R7 building role missing: $role"
done
for token in roof-overhang framed-window porch-detail awning-detail lived-in-detail; do
  grep -Fq "$token" src/server/R7BuildingPolishBuilder.luau || fail "R7 architectural detail marker missing: $token"
done
grep -Fq 'CanCollide = false' src/server/R7BuildingPolishBuilder.luau || fail "R7 building dressing is not explicitly non-colliding"
pass "R7 houses and civic silhouettes are explicit"

# Activity presentation contract.
grep -Fq 'ART_R7_ActivityPresentation' src/server/R7ActivityPresentationBuilder.luau || fail "R7 activity presentation root marker missing"
for role in Mara Pip Finn Skye Milo; do
  grep -Fq "R7${role}ActivityZone" src/server/R7ActivityPresentationBuilder.luau || fail "R7 activity zone missing: $role"
done
for marker in market-display garden-nook fishing-nook harbour-launch builder-workshop; do
  grep -Fq "$marker" src/server/R7ActivityPresentationBuilder.luau || fail "R7 activity visual marker missing: $marker"
done
grep -Fq 'VillageActivityLocations' src/server/R7ActivityPresentationBuilder.luau || fail "R7 activities do not use canonical location authority"
pass "R7 activity spaces are role-readable and canonical"

# Character contract.
for token in Head Torso UpperArm LowerArm UpperLeg LowerLeg Hand Shoe Face Hair Clothing RoleProp; do
  grep -Fq "$token" src/server/VillageNpcBuilder.luau || fail "R7 NPC anatomy/style marker missing: $token"
done
for role in Trader Gardener Fisherman BoatKeeper Builder; do
  grep -Fq "$role" src/server/VillageNpcBuilder.luau || fail "R7 NPC role styling missing: $role"
done
grep -Fq 'VillageActivityLocations' src/server/VillageNpcService.luau || fail "NPC placement is not canonical"
pass "R7 NPCs have character-grade native presentation markers"

# R5/R6 published visual safety must remain intact.
if grep -Fq 'ReleaseInfo.channel == "DEV"' src/server/ProductionVisualService.luau; then
  fail "DEV release channel authorizes preview geometry"
fi
grep -Fq 'return RunService:IsStudio()' src/server/ProductionVisualService.luau || fail "visual preview capability is not Studio-only"
grep -Fq 'RunService:IsStudio()' src/server/EditableMeshPreviewFactory.luau || fail "EditableMesh preview factory has no Studio guard"
grep -Fq 'PublishedFallbackFactory' src/server/ProductionMeshFactory.luau || fail "published fallback route missing"
if grep -Eq 'EditableMesh|CreateMeshPartAsync|Content\.fromObject' src/server/PublishedFallbackFactory.luau; then
  fail "published fallback uses runtime mesh APIs"
fi
pass "ART R5/R6 published-safe rendering boundary remains intact"

# Existing R6 activity ownership/progression remains present.
for service in TraderRequestActivityService VillageGardenActivityService FishingActivityService CoastalDeliveryActivityService BuilderRepairActivityService; do
  grep -Fq "$service" src/server/VillageActivityService.luau || fail "R6 activity coordinator missing handler: $service"
done
for path in src/server/VillageGardenActivityService.luau src/server/FishingActivityService.luau src/server/BuilderRepairActivityService.luau; do
  grep -Fq 'self.owner' "$path" || fail "shared-world activity ownership arbitration missing: $path"
done
grep -Fq 'TinyWorldFishingState' src/server/FishingActivityService.luau || fail "fishing visible bite state missing"
grep -Fq 'model.Name = PARCEL_NAME' src/server/CoastalDeliveryActivityService.luau || fail "coastal parcel atomic cleanup model missing"
pass "R6 gameplay safety remains composed"

workflow_count="$(find .github/workflows -maxdepth 1 -type f \( -name '*.yml' -o -name '*.yaml' \) | wc -l | tr -d ' ')"
[[ "$workflow_count" == "1" ]] || fail "exactly one Actions workflow is allowed"
[[ -f .github/workflows/tinyworld-ci.yml ]] || fail "canonical TinyWorld CI workflow missing"
grep -Fq 'bash ./tests/verify-v0.7.3-art-r7-source-contract.sh' .github/workflows/tinyworld-ci.yml || fail "ART R7 source gate is not wired into CI"
if grep -R -Eq 'actions/(upload-artifact|cache)@' .github/workflows; then
  fail "persistent GitHub Actions storage was reintroduced"
fi
pass "single free-only CI remains authoritative"

echo "PASS: TinyWorld v0.7.3 ART R7 premium visual world source contract"
