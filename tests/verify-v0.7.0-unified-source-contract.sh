#!/usr/bin/env bash
set -euo pipefail

fail() { echo "FAIL: $1" >&2; exit 1; }
pass() { echo "PASS: $1"; }

jq -e '.productVersion == "0.7.0" and .releaseName == "Family World & Production Art" and .profileSchema == 11 and .artifactFile == "TinyWorld-v0.7.0.rbxlx"' config/release.json >/dev/null || fail "unified release metadata is not exact"
pass "unified v0.7.0 release identity is exact"

for token in ProductionArtCleanup ProductionVisualService ProductionVillageVisuals CoastBuilder TraversalSafetyService CompanionService VillageNpcService CarService MermaidLandService; do
  grep -Fq "$token" src/server/Main.server.luau || fail "Main missing runtime composition: $token"
done
pass "production art, coast and family world services share one startup path"

[[ -f art/specs/village-product-art.json ]] || fail "ART R4 product-art spec missing"
[[ -f src/server/ProductionMeshFactory.luau ]] || fail "production mesh factory missing"
grep -Fq 'EditableMesh' src/server/ProductionMeshFactory.luau || fail "custom mesh pipeline missing"
pass "ART R4 custom-mesh production path remains present"

grep -Fq 'Terrain:FillBlock' src/server/CoastBuilder.luau || fail "real Terrain coast water missing"
grep -Fq 'tiny_boat_required' src/shared/TraversalRules.luau || fail "Tiny Boat outer-sea gate missing"
grep -Fq 'worldRecoveryCFrame' src/server/TraversalSafetyService.luau || fail "safe recovery missing"
pass "coastal traversal and recovery remain server-authoritative"

for role in Trader Gardener Fisherman BoatKeeper Builder; do
  grep -Fq "id = \"$role\"" src/shared/VillageNpcDefinitions.luau || fail "village NPC role missing: $role"
done
if grep -Eq 'Instance.new\("(Part|WedgePart)"\)' src/server/VillageNpcService.luau; then
  fail "finished village NPCs must not use primitive Part-built bodies"
fi
pass "five useful authored village NPC roles are explicit"

grep -Fq 'TINY_CAR_LEVEL = 8' src/shared/TransportRules.luau || fail "Tiny Car level gate missing"
grep -Fq 'ProductionMeshFactory' src/server/CarBuilder.luau || fail "Tiny Car is not custom-mesh authored"
pass "Tiny Car progression and authored presentation are explicit"

grep -Fq 'ProductionMeshFactory' src/server/BikeBuilder.luau || fail "Tiny Bike still lacks production custom-mesh presentation"
grep -Fq 'authored-custom-mesh' src/server/BikeBuilder.luau || fail "Tiny Bike visual state not production-authored"
grep -Fq 'ProductionMeshFactory' src/server/BoatBuilder.luau || fail "Tiny Boat still lacks production custom-mesh presentation"
grep -Fq 'authored-custom-mesh' src/server/BoatBuilder.luau || fail "Tiny Boat visual state not production-authored"
pass "bike and boat hero vehicles use the production mesh path"

for quest in PearlTrail CoralGarden LostParcel MoonShells WhirlpoolPromise; do
  grep -Fq "$quest" src/shared/MermaidQuestRules.luau || fail "Mermaid quest missing: $quest"
done
quest_count="$(grep -Ec '^\s*[A-Za-z]+ = \{ coins = [0-9]+, xp = [0-9]+ \},$' src/shared/MermaidQuestRules.luau || true)"
[[ "$quest_count" == "5" ]] || fail "Mermaid Land must expose exactly five finite reward definitions"
grep -Fq 'profile.ownsTinyBoat' src/shared/MermaidQuestRules.luau || fail "Mermaid entry does not require Tiny Boat ownership"
grep -Fq 'profile.boatActive' src/shared/MermaidQuestRules.luau || fail "Mermaid entry does not require active Tiny Boat"
grep -Fq 'already_complete' src/shared/MermaidQuestRules.luau || fail "Mermaid quest idempotency missing"
grep -Fq 'ReturnPrompt' src/server/MermaidLandBuilder.luau || fail "Mermaid Land safe return missing"
pass "hidden Mermaid Land has five idempotent boat-gated quests and a return path"

grep -Fq 'Starter Shed' src/shared/HouseCatalog.luau || fail "starter home does not read as intentional shed"
grep -Fq 'Tiny Castle' src/shared/HouseCatalog.luau || fail "castle home prestige tier missing"
grep -Fq 'REQUIRED_LEVEL = 10' src/shared/CompanionRules.luau || fail "companion level gate missing"
grep -Fq 'TinyCat' src/shared/CompanionRules.luau || fail "Tiny Cat rule missing"
grep -Fq 'TinyDog' src/shared/CompanionRules.luau || fail "Tiny Dog rule missing"
grep -Fq 'TinyWorldCatFlap' src/server/CompanionService.luau || fail "cat-flap home affordance missing"
if grep -Eq 'Instance.new\("(Part|WedgePart)"\)' src/server/CompanionService.luau; then
  fail "finished companion bodies must not be primitive Part-built"
fi
pass "shed-to-castle homes and level-10 authored companions are present"

[[ -f src/server/PrestigePadBuilder.luau ]] || fail "future spaceship prestige pad builder missing"
grep -Fq 'FutureSpaceshipPad' src/server/PrestigePadBuilder.luau || fail "spaceship pad prestige identity missing"
if grep -Fq 'TeleportService' src/server/PrestigePadBuilder.luau; then
  fail "spaceship pad must not implement inter-world travel in v0.7.0"
fi
pass "future spaceship-pad prestige is visual-only"

grep -Fq 'grass-parcel home is already reserved' src/server/Main.server.luau || fail "simplified plot ownership onboarding missing"
grep -Fq "'s Plot" src/server/PlotService.luau || fail "claimed plot owner identity missing"
pass "plot ownership is automatic, discoverable and visibly identified"

grep -Fq 'productVersion = "0.7.0"' src/shared/ReleaseInfo.luau || fail "release stamp version missing"
grep -Fq 'candidate = "PR #13"' src/shared/ReleaseInfo.luau || fail "unified PR stamp missing"
pass "DEV build stamp identifies the unified candidate"

workflow_count="$(find .github/workflows -maxdepth 1 -type f \( -name '*.yml' -o -name '*.yaml' \) | wc -l | tr -d ' ')"
[[ "$workflow_count" == "1" ]] || fail "exactly one Actions workflow is allowed"
[[ -f .github/workflows/tinyworld-ci.yml ]] || fail "canonical unified workflow missing"
if grep -R -Eq 'actions/(upload-artifact|cache)@' .github/workflows; then
  fail "persistent GitHub Actions storage was reintroduced"
fi
pass "single free-only Actions workflow is authoritative"

echo "PASS: TinyWorld v0.7.0 unified source contract"
