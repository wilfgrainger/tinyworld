#!/usr/bin/env bash
set -euo pipefail

fail() { echo "FAIL: $1" >&2; exit 1; }
pass() { echo "PASS: $1"; }
require_file() { [[ -f "$1" ]] || fail "required file missing: $1"; }

jq -e '.productVersion == "0.7.2" and .releaseName == "Full Game Experience" and .profileSchema == 11 and .artifactFile == "TinyWorld-v0.7.2.rbxlx"' config/release.json >/dev/null || fail "ART R6 release metadata is not exact"
grep -Fq 'productVersion = "0.7.2"' src/shared/ReleaseInfo.luau || fail "R6 release stamp version missing"
grep -Fq 'artRevision = "ART R6"' src/shared/ReleaseInfo.luau || fail "R6 art revision missing"
grep -Fq 'releaseName = "Full Game Experience"' src/shared/ReleaseInfo.luau || fail "R6 release name missing"
pass "ART R6 release identity is exact"

for path in \
  src/shared/VillageActivityDefinitions.luau \
  src/shared/VillageActivityRules.luau \
  src/server/VillageNpcBuilder.luau \
  src/server/VillageActivityService.luau \
  src/server/TraderRequestActivityService.luau \
  src/server/VillageGardenActivityService.luau \
  src/server/FishingActivityService.luau \
  src/server/CoastalDeliveryActivityService.luau \
  src/server/BuilderRepairActivityService.luau \
  src/server/R6CivicPresentationBuilder.luau; do
  require_file "$path"
done
pass "R6 activity and civic architecture is present"

for role in Trader Gardener Fisherman BoatKeeper Builder; do
  grep -Fq "id = \"$role\"" src/shared/VillageNpcDefinitions.luau || fail "village NPC role missing: $role"
done
for activity in TraderRequest VillageGarden Fishing CoastalDelivery BuilderRepair; do
  grep -Fq "id = \"$activity\"" src/shared/VillageActivityDefinitions.luau || fail "activity definition missing: $activity"
done
pass "five NPC roles and five activity loops are defined"

grep -Fq 'VillageNpcBuilder' src/server/VillageNpcService.luau || fail "VillageNpcService does not delegate to native NPC builder"
if grep -Fq 'ProductionMeshFactory' src/server/VillageNpcService.luau; then
  fail "VillageNpcService still uses generic production mesh fallback"
fi
for token in Head Torso LeftArm RightArm LeftLeg RightLeg Humanoid; do
  grep -Fq "$token" src/server/VillageNpcBuilder.luau || fail "native NPC anatomy marker missing: $token"
done
pass "NPCs use dedicated native character presentation"

for token in VillageActivityService VillageNpcService JobService GardenService TradeService MermaidLandService R6CivicPresentationBuilder; do
  grep -Fq "$token" src/server/Main.server.luau || fail "Main missing runtime composition: $token"
done
pass "R6 gameplay and civic presentation are composed without dropping existing game systems"

# Preserve R5 published visual safety.
if grep -Fq 'ReleaseInfo.channel == "DEV"' src/server/ProductionVisualService.luau; then
  fail "DEV release channel authorizes preview geometry"
fi
grep -Fq 'return RunService:IsStudio()' src/server/ProductionVisualService.luau || fail "visual preview capability is not Studio-only"
grep -Fq 'RunService:IsStudio()' src/server/EditableMeshPreviewFactory.luau || fail "EditableMesh preview factory has no Studio guard"
grep -Fq 'PublishedFallbackFactory' src/server/ProductionMeshFactory.luau || fail "published fallback route missing"
if grep -Eq 'EditableMesh|CreateMeshPartAsync|Content\.fromObject' src/server/PublishedFallbackFactory.luau; then
  fail "published fallback uses runtime mesh APIs"
fi
pass "ART R5 published-safe rendering boundary remains intact"

# R6 grass regression guard: the old district lawn sheets were 0.04 studs thick and nearly coplanar.
if grep -Fq 'Vector3.new(size.X, 0.04, size.Y)' src/server/VillageGroundRebuildBuilder.luau; then
  fail "legacy coplanar 0.04-stud ground overlay remains"
fi
if grep -nA10 -B2 '"FieldA"\|"FieldB"' src/server/VillageGroundRebuildBuilder.luau | grep -Fq 'Enum.Material.Grass'; then
  fail "district decorative fields still layer Grass over base Grass"
fi
pass "coplanar grass overlay pattern is absent"

for service in TraderRequestActivityService VillageGardenActivityService FishingActivityService CoastalDeliveryActivityService BuilderRepairActivityService; do
  grep -Fq "$service" src/server/VillageActivityService.luau || fail "activity coordinator missing handler: $service"
done
pass "activity coordinator owns all five role services"

grep -Fq '60' src/shared/VillageActivityDefinitions.luau || fail "short reward band missing"
grep -Fq '140' src/shared/VillageActivityDefinitions.luau || fail "coastal reward band missing"
grep -Fq '1.15' src/shared/VillageActivityRules.luau || fail "good quality multiplier missing"
grep -Fq '1.30' src/shared/VillageActivityRules.luau || fail "perfect quality multiplier missing"
pass "R6 reward and quality bands are encoded"

# Civic R6 must actively apply the authored fountain, shrink the market status sign,
# and add five role-readable station treatments using only safe native instances.
grep -Fq 'HeroFountainBuilder.apply' src/server/R6CivicPresentationBuilder.luau || fail "R6 civic pass does not apply hero fountain"
grep -Fq 'MarketStatusSign' src/server/R6CivicPresentationBuilder.luau || fail "R6 civic pass does not tame market status sign"
grep -Fq 'Vector3.new(12, 3.5, 0.65)' src/server/R6CivicPresentationBuilder.luau || fail "market sign remains oversized"
for marker in trader-station gardener-station fisherman-station boatkeeper-station builder-station; do
  grep -Fq "$marker" src/server/R6CivicPresentationBuilder.luau || fail "missing R6 activity station marker: $marker"
done
grep -Fq 'civic-hero-r6' src/server/HeroFountainBuilder.luau || fail "hero fountain is not stamped ART R6"
pass "R6 civic presentation is explicit and player-facing"

workflow_count="$(find .github/workflows -maxdepth 1 -type f \( -name '*.yml' -o -name '*.yaml' \) | wc -l | tr -d ' ')"
[[ "$workflow_count" == "1" ]] || fail "exactly one Actions workflow is allowed"
[[ -f .github/workflows/tinyworld-ci.yml ]] || fail "canonical TinyWorld CI workflow missing"
grep -Fq 'bash ./tests/verify-v0.7.2-art-r6-source-contract.sh' .github/workflows/tinyworld-ci.yml || fail "ART R6 source gate is not wired into CI"
if grep -R -Eq 'actions/(upload-artifact|cache)@' .github/workflows; then
  fail "persistent GitHub Actions storage was reintroduced"
fi
pass "single free-only CI remains authoritative"

echo "PASS: TinyWorld v0.7.2 ART R6 full game source contract"
