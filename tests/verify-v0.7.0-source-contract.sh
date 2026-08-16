#!/usr/bin/env bash
set -euo pipefail

boundary="src/server/BoundaryBuilder.luau"

grep -q 'Workspace.Terrain' "$boundary"
grep -q 'FillBlock' "$boundary"
grep -q 'Enum.Material.Water' "$boundary"
grep -q 'SeaBed' "$boundary"
grep -q 'shorelineDistance' "$boundary"
grep -q 'swimDistance' "$boundary"

if grep -q 'makeDecoration(parent, name, size, position, VisualTheme.Colors.water, Enum.Material.Water)' "$boundary"; then
  echo "FAIL: fake Part-based sea remains in BoundaryBuilder"
  exit 1
fi

echo "PASS: v0.7.0 coast uses Terrain water and explicit traversal metadata"
