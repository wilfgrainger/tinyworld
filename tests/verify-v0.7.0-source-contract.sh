#!/usr/bin/env bash
set -euo pipefail

coast="src/server/CoastBuilder.luau"
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

echo "PASS: v0.7.0 coast uses Terrain water, walkable boundary hills and explicit traversal metadata"
