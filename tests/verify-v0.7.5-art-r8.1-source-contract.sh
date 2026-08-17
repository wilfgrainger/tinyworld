#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "ART R8.1 source contract failed: $1" >&2
  exit 1
}

main=src/server/Main.server.luau
locations=src/server/VillageActivityLocations.luau

for retired in \
  'R6CivicPresentationBuilder.apply' \
  'R7BuildingPolishBuilder.apply' \
  'R7ActivityPresentationBuilder.apply'; do
  if grep -F "$retired" "$main" >/dev/null; then
    fail "active Main still invokes $retired"
  fi
done

grep -F 'R8CivicPrefabBuilder.apply' "$main" >/dev/null || fail "Main must retain authored R8 civic prefabs"
grep -F 'R8AssetLibrary.clonePrefab("Homes",' src/server/HomePrefabBuilder.luau >/dev/null || fail "HomePrefabBuilder must retain authored R8 homes"
grep -F 'R8DestinationBuilder.apply' "$main" >/dev/null || fail "Main must build the R8 destination registry"
grep -F 'world.r8Destinations' "$locations" >/dev/null || fail "VillageActivityLocations must read the R8 destination registry"

if grep -F 'perimeterHalf(world)' "$locations" >/dev/null; then
  fail "legacy perimeter-derived activity coordinates remain active"
fi
if grep -F 'local dock = Instance.new("Part")' src/server/FishingActivityService.luau >/dev/null; then
  fail "fishing service still sculpts a structural dock"
fi
if grep -F 'makeBed(' src/server/VillageGardenActivityService.luau >/dev/null; then
  fail "garden service still sculpts destination-defining beds"
fi
if grep -F 'makeBoard(' src/server/BuilderRepairActivityService.luau >/dev/null; then
  fail "builder service still sculpts the old repair frame"
fi
if grep -F 'destination = Instance.new("Part")' src/server/CoastalDeliveryActivityService.luau >/dev/null; then
  fail "coastal delivery service still sculpts the structural buoy"
fi

for id in activity-garden-beds activity-fishing-dock activity-repair-station activity-delivery-buoy; do
  jq -e --arg id "$id" '.models[] | select(.id == $id and .devApproved == true)' assets/manifests/r8-models.json >/dev/null || fail "missing DEV-approved activity prefab: $id"
done

jq -e '.productVersion == "0.7.5" and .releaseName == "Finish the Rebuild" and .artifactFile == "TinyWorld-v0.7.5.rbxlx"' config/release.json >/dev/null || fail "release.json identity mismatch"
grep -F 'productVersion = "0.7.5"' src/shared/ReleaseInfo.luau >/dev/null || fail "ReleaseInfo productVersion mismatch"
grep -F 'candidate = "ART R8.1"' src/shared/ReleaseInfo.luau >/dev/null || fail "ReleaseInfo candidate mismatch"
grep -F 'artRevision = "ART R8.1"' src/shared/ReleaseInfo.luau >/dev/null || fail "ReleaseInfo art revision mismatch"
grep -F 'releaseName = "Finish the Rebuild"' src/shared/ReleaseInfo.luau >/dev/null || fail "ReleaseInfo release name mismatch"

# Preserve existing R8 asset integrity and published safety.
bash ./tests/verify-v0.7.4-art-r8-source-contract.sh >/dev/null

echo "ART R8.1 source contract passed"
