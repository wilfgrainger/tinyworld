#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

bash ./scripts/verify-release-contract.sh
bash ./tests/verify-v0.7.2-art-r6-source-contract.sh

echo "PASS: repository release contract matches TinyWorld v0.7.2 ART R6"
