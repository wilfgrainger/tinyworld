#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

fail() { echo "FAIL: $1" >&2; exit 1; }
pass() { echo "PASS: $1"; }

required_files=(
  art/README.md
  art/specs/palette.json
  art/specs/village-product-art.json
  src/shared/ProductionArtSpec.luau
  src/shared/ProductionAssetRegistry.luau
  src/server/ProductionMeshFactory.luau
  src/server/EditableMeshPreviewFactory.luau
  src/server/ProductionVisualService.luau
  src/server/ProductionVillageVisuals.luau
  src/server/ProductionHomeVisuals.luau
  tools/art/build_asset_pack.py
  tools/art/validate_asset_pack.py
  scripts/generate-production-asset-registry.py
  scripts/upload-roblox-assets.py
)

for path in "${required_files[@]}"; do
  [[ -f "$path" ]] || fail "ART R4 required file missing: $path"
done
pass "ART R4 source/tooling surface exists"

grep -Fq 'artRevision = "ART R4"' src/shared/ReleaseInfo.luau \
  || fail "runtime candidate identity is not ART R4"
pass "ART R4 candidate identity is explicit"

python3 - <<'PY'
import json
from pathlib import Path

manifest = json.loads(Path('assets/manifests/assets.json').read_text())
if manifest.get('schemaVersion') != 3:
    raise SystemExit('manifest schemaVersion must be 3')

spec = json.loads(Path('art/specs/village-product-art.json').read_text())
if spec.get('schemaVersion') != 1:
    raise SystemExit('product art schemaVersion must be 1')

roles = set(spec.get('assets', {}).keys())
required = {
    'town-hall', 'starter-home', 'village-shop', 'home-store', 'courier-depot',
    'workshop', 'market-stall-a', 'market-stall-b', 'fountain', 'portal-clockwork',
    'tree-a', 'tree-b', 'tree-c', 'lantern', 'bench', 'planter', 'hedge',
    'parcel-crates', 'starter-interior-kit'
}
missing = sorted(required - roles)
if missing:
    raise SystemExit('missing ART R4 asset roles: ' + ', '.join(missing))

allowed = {'beveledBox', 'gableRoof', 'hipRoof', 'frustum', 'cylinder', 'ellipsoid', 'archSegment', 'panel', 'windowSet', 'waterArc'}
for role, asset in spec['assets'].items():
    components = asset.get('components') or []
    if not components:
        raise SystemExit(f'{role} has no components')
    for component in components:
        shape = component.get('shape')
        if shape not in allowed:
            raise SystemExit(f'{role} uses unsupported shape {shape!r}')
print('PASS: ART R4 product-art role/spec contract')
PY

# ART R4 is a replacement architecture, not another visible layer after R1-R3.
for legacy_call in \
  'CivicCraftBuilder.apply(world.root)' \
  'CivicHeroRebuildBuilder.apply(world.root)' \
  'CivicFacadePolishBuilder.apply(world.root)' \
  'VillageArrivalPolishBuilder.apply(world.root)' \
  'HeroPortalBuilder.apply(world.root)' \
  'HeroFountainBuilder.apply(world.root)' \
  'OrganicNatureBuilder.apply(world.root)'; do
  if grep -Fq "$legacy_call" src/server/Main.server.luau; then
    fail "legacy visible ART R1-R3 call remains active in Main: $legacy_call"
  fi
done

grep -Fq 'ProductionVisualService.new()' src/server/Main.server.luau \
  || fail "ProductionVisualService is not initialised in Main"
grep -Fq 'ProductionVillageVisuals.apply(world, productionVisualService)' src/server/Main.server.luau \
  || fail "production village visuals are not mounted in Main"
pass "Main uses the ART R4 production-visual path"

# The runtime must build real MeshParts in DEV, not substitute a Roblox Part recipe.
grep -Fq 'AssetService:CreateEditableMesh()' src/server/ProductionMeshFactory.luau \
  || fail "ProductionMeshFactory does not create EditableMesh geometry"
grep -Fq 'AssetService:CreateMeshPartAsync' src/server/ProductionMeshFactory.luau \
  || fail "ProductionMeshFactory does not create MeshParts"
grep -Fq 'Content.fromObject' src/server/ProductionMeshFactory.luau \
  || fail "ProductionMeshFactory does not link EditableMesh content into MeshParts"
if grep -Fq 'Instance.new("Part")' src/server/ProductionMeshFactory.luau; then
  fail "ProductionMeshFactory must not implement product art as ordinary Parts"
fi
pass "DEV preview uses true custom mesh geometry"

# Production asset IDs must come from the manifest, never literals in art mounting code.
if grep -Eq 'rbxassetid://[0-9]+' src/server/ProductionVisualService.luau src/server/ProductionVillageVisuals.luau src/server/ProductionHomeVisuals.luau; then
  fail "runtime production visual code contains hard-coded Roblox asset IDs"
fi
grep -Fq 'AssetService:LoadAssetAsync' src/server/ProductionVisualService.luau \
  || fail "ProductionVisualService lacks permanent Model asset loading"
grep -Fq 'EditableMeshPreviewFactory.build' src/server/ProductionVisualService.luau \
  || fail "ProductionVisualService lacks the DEV mesh preview path"
pass "production IDs and DEV preview have explicit boundaries"

python3 tools/art/validate_asset_pack.py --spec art/specs/village-product-art.json --palette art/specs/palette.json
python3 tools/art/build_asset_pack.py --spec art/specs/village-product-art.json --palette art/specs/palette.json --out /tmp/tinyworld-art-r4-a --registry /tmp/tinyworld-art-r4-a/ProductionArtSpec.luau
python3 tools/art/build_asset_pack.py --spec art/specs/village-product-art.json --palette art/specs/palette.json --out /tmp/tinyworld-art-r4-b --registry /tmp/tinyworld-art-r4-b/ProductionArtSpec.luau
python3 - <<'PY'
from pathlib import Path
import hashlib

def tree_digest(root):
    h = hashlib.sha256()
    for path in sorted(Path(root).rglob('*')):
        if path.is_file():
            h.update(path.relative_to(root).as_posix().encode())
            h.update(b'\0')
            h.update(path.read_bytes())
            h.update(b'\0')
    return h.hexdigest()

a = tree_digest('/tmp/tinyworld-art-r4-a')
b = tree_digest('/tmp/tinyworld-art-r4-b')
if a != b:
    raise SystemExit(f'ART R4 generator is not deterministic: {a} != {b}')
print('PASS: ART R4 generator is deterministic', a)
PY

# Registry generator must reproduce the checked-in registry without network calls.
python3 scripts/generate-production-asset-registry.py --manifest assets/manifests/assets.json --output /tmp/ProductionAssetRegistry.luau
cmp -s /tmp/ProductionAssetRegistry.luau src/shared/ProductionAssetRegistry.luau \
  || fail "ProductionAssetRegistry.luau has drifted from assets manifest"
pass "production asset registry is generated from manifest"

echo "PASS: TinyWorld v0.6.3 ART R4 production asset contract"
