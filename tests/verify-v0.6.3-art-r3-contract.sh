#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

fail() { echo "FAIL: $1" >&2; exit 1; }
pass() { echo "PASS: $1"; }

for path in \
  src/server/SpawnPresentationBuilder.luau \
  src/server/HeroPortalBuilder.luau \
  src/server/HeroFountainBuilder.luau \
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

for activation in \
  'SpawnPresentationBuilder.apply(world.root)' \
  'HeroPortalBuilder.apply(world.root)' \
  'HeroFountainBuilder.apply(world.root)' \
  'OrganicNatureBuilder.apply(world.root)'; do
  grep -Fq "$activation" src/server/Main.server.luau \
    || fail "ART R3 static replacement pass is not active: $activation"
done
grep -Fq 'StarterHomeHeroInteriorBuilder.apply(plot)' src/server/HomeInteriorCraftBuilder.luau \
  || fail "starter-home R3 interior is not bound to every home rebuild"
grep -Fq 'OrganicNatureBuilder.apply(plot.houseContainer)' src/server/PlotService.luau \
  || fail "R3 nature language is not reapplied after each home rebuild"
pass "ART R3 replacement passes are active at the correct lifecycle boundaries"

# The Studio SpawnLocation star must be physically buried, not merely made transparent.
grep -Fq 'spawn.Position = Vector3.new(spawn.Position.X, -3, spawn.Position.Z)' src/server/SpawnPresentationBuilder.luau \
  || fail "VillageSpawn is not buried below the visible ground plane"
grep -Fq 'spawn.Transparency = 1' src/server/SpawnPresentationBuilder.luau \
  || fail "VillageSpawn is not transparent"
grep -Fq 'spawn.CanCollide = false' src/server/SpawnPresentationBuilder.luau \
  || fail "VillageSpawn still participates in visible plaza collision"
grep -Fq 'TinyWorldSpawnPresentation", "buried-r3"' src/server/SpawnPresentationBuilder.luau \
  || fail "buried spawn presentation marker missing"
pass "spawn presentation is physically removed from the player camera"

# Hero portals must be authored landmarks, not a giant translucent rectangle plus glowing balls.
if grep -Fq 'Enum.PartType.Ball' src/server/HeroPortalBuilder.luau; then
  fail "hero portal builder must not use ball ornaments"
fi
grep -Fq 'TinyWorldPortalLanguage", "landmark-arch-r3"' src/server/HeroPortalBuilder.luau \
  || fail "hero portal landmark language marker missing"
grep -Fq 'PortalThreshold' src/server/HeroPortalBuilder.luau \
  || fail "hero portal lacks a readable threshold/entry plane"
grep -Fq 'clearLegacyPortalGeometry' src/server/HeroPortalBuilder.luau \
  || fail "hero portal pass does not clear conflicting legacy portal geometry"
pass "portal language is rebuilt as an authored landmark"

# The fountain is the civic hero: preserve the reward prompt, replace toy-stack geometry, and use real water arcs.
grep -Fq 'TinyWorldFountainLanguage", "civic-hero-r3"' src/server/HeroFountainBuilder.luau \
  || fail "hero fountain language marker missing"
grep -Fq 'clearLegacyFountainGeometry' src/server/HeroFountainBuilder.luau \
  || fail "hero fountain does not clear conflicting legacy geometry"
grep -Fq 'FountainOuterBasin' src/server/HeroFountainBuilder.luau \
  || fail "hero fountain outer basin missing"
grep -Fq 'FountainWaterSurface' src/server/HeroFountainBuilder.luau \
  || fail "hero fountain water surface missing"
grep -Fq 'Beam' src/server/HeroFountainBuilder.luau \
  || fail "hero fountain lacks curved water-arc beams"
if grep -Fq 'Enum.PartType.Ball' src/server/HeroFountainBuilder.luau; then
  fail "hero fountain must not use a ball finial"
fi
pass "fountain is rebuilt as the civic-square hero"

# Nature must replace giant lollipop trees and ball-on-stick flowers in hero routes and rebuilt homes.
grep -Fq 'replacePrimitiveTrees' src/server/OrganicNatureBuilder.luau \
  || fail "organic nature pass does not replace primitive trees"
grep -Fq 'replacePrimitiveFlowers' src/server/OrganicNatureBuilder.luau \
  || fail "organic nature pass does not replace primitive flowers"
grep -Fq 'TinyWorldNatureLanguage", "layered-lowpoly-r3"' src/server/OrganicNatureBuilder.luau \
  || fail "organic nature language marker missing"
pass "hero-route and home nature have an explicit R3 replacement language"

# The starter home must become a real enclosed, navigable hero environment.
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
