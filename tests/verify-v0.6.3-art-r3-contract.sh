#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

fail() { echo "FAIL: $1" >&2; exit 1; }
pass() { echo "PASS: $1"; }

for path in \
  src/server/HeroPortalBuilder.luau \
  src/server/OrganicNatureBuilder.luau \
  src/server/StarterHomeHeroInteriorBuilder.luau; do
  [[ -f "$path" ]] || fail "ART R3 replacement module missing: $path"
done
pass "ART R3 replacement modules exist"

grep -Fq 'artRevision = "ART R3"' src/shared/ReleaseInfo.luau \
  || fail "runtime candidate identity is not ART R3"
grep -Fq 'ReleaseInfo.artRevision' src/client/BuildStamp.client.luau \
  || fail "build stamp does not render ART revision"
pass "ART R3 screenshots are revision-identifiable"

# The Studio SpawnLocation star must be physically buried, not merely made transparent.
grep -Fq 'spawn.Position = Vector3.new(0, -3, 0)' src/server/WorldBuilder.luau \
  || fail "VillageSpawn is not buried below the visible ground plane"
grep -Fq 'spawn.Transparency = 1' src/server/WorldBuilder.luau \
  || fail "VillageSpawn is not transparent"
grep -Fq 'spawn.CanCollide = false' src/server/WorldBuilder.luau \
  || fail "VillageSpawn still participates in visible plaza collision"
pass "spawn presentation is physically removed from the player camera"

# Hero portals must be authored landmarks, not a giant translucent rectangle plus glowing balls.
grep -Fq 'HeroPortalBuilder.build' src/server/AuthoredPrefabBuilder.luau \
  || fail "world portals are not delegated to the ART R3 hero portal builder"
if grep -Fq 'Enum.PartType.Ball' src/server/HeroPortalBuilder.luau; then
  fail "hero portal builder must not use ball ornaments"
fi
grep -Fq 'TinyWorldPortalLanguage", "landmark-arch-r3"' src/server/HeroPortalBuilder.luau \
  || fail "hero portal landmark language marker missing"
grep -Fq 'PortalThreshold' src/server/HeroPortalBuilder.luau \
  || fail "hero portal lacks a readable threshold/entry plane"
pass "portal language is rebuilt as an authored landmark"

# Nature must replace giant lollipop trees and ball-on-stick flowers in hero routes.
grep -Fq 'OrganicNatureBuilder.apply(world.root)' src/server/Main.server.luau \
  || fail "organic nature replacement pass is not active"
grep -Fq 'replacePrimitiveTrees' src/server/OrganicNatureBuilder.luau \
  || fail "organic nature pass does not replace primitive trees"
grep -Fq 'replacePrimitiveFlowers' src/server/OrganicNatureBuilder.luau \
  || fail "organic nature pass does not replace primitive flowers"
grep -Fq 'TinyWorldNatureLanguage", "layered-lowpoly-r3"' src/server/OrganicNatureBuilder.luau \
  || fail "organic nature language marker missing"
pass "hero-route nature has an explicit R3 replacement language"

# The starter home must become a real enclosed, navigable hero environment.
grep -Fq 'StarterHomeHeroInteriorBuilder.apply(world.root)' src/server/Main.server.luau \
  || fail "starter-home hero interior pass is not active"
grep -Fq 'TinyWorldInteriorLanguage", "starter-home-r3"' src/server/StarterHomeHeroInteriorBuilder.luau \
  || fail "starter-home R3 interior language marker missing"
for feature in HeroCeiling KitchenZone LivingZone SleepZone HeroRug HeroCurtain; do
  grep -Fq "$feature" src/server/StarterHomeHeroInteriorBuilder.luau \
    || fail "starter-home hero interior missing $feature"
done
grep -Fq 'clearInteriorCraft' src/server/StarterHomeHeroInteriorBuilder.luau \
  || fail "starter-home hero pass does not clear conflicting legacy craft"
pass "starter home has an enclosed, zoned R3 hero interior"

echo "PASS: TinyWorld v0.6.3 ART R3 visual replacement contract"
