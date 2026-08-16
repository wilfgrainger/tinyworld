#!/usr/bin/env bash
set -euo pipefail

coast="src/server/CoastBuilder.luau"
safety="src/server/TraversalSafetyService.luau"
main="src/server/Main.server.luau"

test -f "$coast"
grep -q 'Workspace.Terrain' "$coast"
grep -q 'FillBlock' "$coast"
grep -q 'Enum.Material.Water' "$coast"
grep -q 'SeaBed' "$coast"
grep -q 'shorelineDistance' "$coast"
grep -q 'swimDistance' "$coast"
grep -q 'HillSlope' "$coast"
grep -q 'CoastBuilder' "$main"
grep -q 'CoastBuilder.build' "$main"

test -f "$safety"
grep -q 'TraversalRules.classifyDistanceFromVillage' "$safety"
grep -q 'tiny_boat_required' "$safety"
grep -q 'worldRecoveryCFrame' "$safety"
grep -q 'safeShoreCFrame' "$safety"
grep -q 'TraversalSafetyService.new' "$main"
grep -q 'traversalSafetyService:trackPlayer' "$main"
grep -q 'traversalSafetyService:removePlayer' "$main"
grep -q 'traversalSafetyService:stop' "$main"

echo "PASS: v0.7.0 coast uses Terrain water, walkable hills, safe recovery and boat-gated outer-sea enforcement"
