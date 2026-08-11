# TinyWorld product art

`art/specs/` is the source of truth for TinyWorld v0.6.3 ART R4 production visuals.

The ART R1-R3 strategy of assembling finished hero art from visible Roblox `Part` recipes is retired. ART R4 describes deliberate composite 3D models using a small mesh vocabulary. The same specifications are consumed in two ways:

1. **Studio/DEV preview:** `ProductionMeshFactory` creates true `EditableMesh` geometry and `MeshPart` instances at runtime so the exact art direction can be reviewed immediately without invented Roblox asset IDs.
2. **Permanent production asset:** `tools/art/build_asset_pack.py` converts the same specifications to deterministic glTF 2.0. The generated file can be imported with Roblox Studio or uploaded with the Open Cloud Assets API. A successful upload is then recorded in `assets/manifests/assets.json`.

Generated glTF files are build outputs under `dist/art-r4/` and are not authoritative source.

## Shape vocabulary

- `beveledBox`: chamfered rectangular solid for furniture, bases and structural masses.
- `panel`: shallow chamfered solid for doors, glazing, signs and facade layers.
- `gableRoof`: extruded pitched roof profile.
- `hipRoof`: four-sided hipped roof.
- `frustum`: tapered low-poly column/pot/trunk.
- `cylinder`: faceted cylindrical solid.
- `ellipsoid`: faceted organic volume for foliage and soft forms.
- `archSegment`: extruded arch ring/portal profile.
- `windowSet`: one mesh containing a framed window perimeter and mullions.
- `waterArc`: low-poly tube following a curved fountain arc.

## Coordinate convention

- Y is up.
- +Z is the primary building front.
- Building pivots are ground-centre.
- One specification unit equals one Roblox stud.
- Rotation arrays are degrees in X, Y, Z order.

## Art rules

- Original TinyWorld art only.
- No Creator Store model copying.
- No reference-game geometry copying.
- No hard-coded or invented Roblox IDs.
- Hero objects use custom mesh silhouettes; invisible/simple Parts may remain for gameplay anchors and collision.
- Labels never rescue unclear geometry.
- Visual acceptance still happens from the exact Studio candidate, not from this specification file.
