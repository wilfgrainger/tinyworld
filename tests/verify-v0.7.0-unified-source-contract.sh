#!/usr/bin/env bash
set -euo pipefail

grep -Fq 'ProductionArtCleanup' src/server/Main.server.luau
grep -Fq 'ProductionVisualService' src/server/Main.server.luau
grep -Fq 'ProductionVillageVisuals' src/server/Main.server.luau
grep -Fq '"productVersion": "0.7.0"' config/release.json
