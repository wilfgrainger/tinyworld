#!/usr/bin/env python3
"""Compile TinyWorld ART R4 product-art specs to deterministic glTF 2.0.

No external Python packages are required. The generated `.gltf` files embed their
binary buffers as data URIs so every role is a self-contained upload candidate.
"""

from __future__ import annotations

import argparse
import base64
import json
import math
import struct
from pathlib import Path
from typing import Iterable

Vec3 = tuple[float, float, float]
Tri = tuple[int, int, int]


def spow(value: float, exponent: float) -> float:
    if value == 0:
        return 0.0
    return math.copysign(abs(value) ** exponent, value)


def merge(parts: Iterable[tuple[list[Vec3], list[Tri]]]) -> tuple[list[Vec3], list[Tri]]:
    vertices: list[Vec3] = []
    triangles: list[Tri] = []
    for part_vertices, part_triangles in parts:
        offset = len(vertices)
        vertices.extend(part_vertices)
        triangles.extend((a + offset, b + offset, c + offset) for a, b, c in part_triangles)
    return vertices, triangles


def cuboid(size: list[float], offset: Vec3 = (0.0, 0.0, 0.0)) -> tuple[list[Vec3], list[Tri]]:
    hx, hy, hz = size[0] / 2, size[1] / 2, size[2] / 2
    ox, oy, oz = offset
    v = [
        (-hx + ox, -hy + oy, -hz + oz),
        (hx + ox, -hy + oy, -hz + oz),
        (hx + ox, hy + oy, -hz + oz),
        (-hx + ox, hy + oy, -hz + oz),
        (-hx + ox, -hy + oy, hz + oz),
        (hx + ox, -hy + oy, hz + oz),
        (hx + ox, hy + oy, hz + oz),
        (-hx + ox, hy + oy, hz + oz),
    ]
    t = [
        (0, 3, 2), (0, 2, 1),
        (4, 5, 6), (4, 6, 7),
        (0, 4, 7), (0, 7, 3),
        (1, 2, 6), (1, 6, 5),
        (3, 7, 6), (3, 6, 2),
        (0, 1, 5), (0, 5, 4),
    ]
    return v, t


def superellipsoid(size: list[float], exponent: float, segments: int, rings: int) -> tuple[list[Vec3], list[Tri]]:
    hx, hy, hz = size[0] / 2, size[1] / 2, size[2] / 2
    vertices: list[Vec3] = []
    for ring in range(rings + 1):
        eta = -math.pi / 2 + math.pi * ring / rings
        for segment in range(segments):
            omega = 2 * math.pi * segment / segments
            cos_eta = math.cos(eta)
            vertices.append((
                hx * spow(cos_eta, exponent) * spow(math.cos(omega), exponent),
                hy * spow(math.sin(eta), exponent),
                hz * spow(cos_eta, exponent) * spow(math.sin(omega), exponent),
            ))
    triangles: list[Tri] = []
    for ring in range(rings):
        for segment in range(segments):
            n = (segment + 1) % segments
            a = ring * segments + segment
            b = ring * segments + n
            c = (ring + 1) * segments + n
            d = (ring + 1) * segments + segment
            triangles.extend(((a, b, c), (a, c, d)))
    return vertices, triangles


def frustum(size: list[float], segments: int, top_scale: float) -> tuple[list[Vec3], list[Tri]]:
    rx, rz = size[0] / 2, size[2] / 2
    ry = size[1] / 2
    vertices: list[Vec3] = []
    for y, scale in ((-ry, 1.0), (ry, top_scale)):
        for segment in range(segments):
            angle = 2 * math.pi * segment / segments
            vertices.append((rx * scale * math.cos(angle), y, rz * scale * math.sin(angle)))
    bottom_center = len(vertices)
    vertices.append((0.0, -ry, 0.0))
    top_center = len(vertices)
    vertices.append((0.0, ry, 0.0))
    triangles: list[Tri] = []
    for segment in range(segments):
        n = (segment + 1) % segments
        b0, b1 = segment, n
        t0, t1 = segments + segment, segments + n
        triangles.extend(((b0, b1, t1), (b0, t1, t0)))
        triangles.append((bottom_center, b1, b0))
        triangles.append((top_center, t0, t1))
    return vertices, triangles


def gable_roof(size: list[float]) -> tuple[list[Vec3], list[Tri]]:
    hx, hy, hz = size[0] / 2, size[1] / 2, size[2] / 2
    v = [(-hx, -hy, hz), (hx, -hy, hz), (0, hy, hz), (-hx, -hy, -hz), (hx, -hy, -hz), (0, hy, -hz)]
    t = [(0, 1, 2), (5, 4, 3), (0, 2, 5), (0, 5, 3), (2, 1, 4), (2, 4, 5), (1, 0, 3), (1, 3, 4)]
    return v, t


def hip_roof(size: list[float]) -> tuple[list[Vec3], list[Tri]]:
    hx, hy, hz = size[0] / 2, size[1] / 2, size[2] / 2
    ridge = min(size[2] * 0.28, size[0] * 0.3) / 2
    v = [(-hx, -hy, -hz), (hx, -hy, -hz), (hx, -hy, hz), (-hx, -hy, hz), (0, hy, -ridge), (0, hy, ridge)]
    t = [(0, 3, 2), (0, 2, 1), (0, 1, 4), (3, 5, 2), (0, 4, 5), (0, 5, 3), (1, 2, 5), (1, 5, 4)]
    return v, t


def window_set(size: list[float]) -> tuple[list[Vec3], list[Tri]]:
    width, height, depth = size
    frame = max(0.22, min(width, height) * 0.09)
    parts = [
        cuboid([width, frame, depth], (0, height / 2 - frame / 2, 0)),
        cuboid([width, frame, depth], (0, -height / 2 + frame / 2, 0)),
        cuboid([frame, height, depth], (-width / 2 + frame / 2, 0, 0)),
        cuboid([frame, height, depth], (width / 2 - frame / 2, 0, 0)),
        cuboid([frame * 0.65, height - frame * 2, depth * 1.04]),
        cuboid([width - frame * 2, frame * 0.65, depth * 1.04]),
    ]
    return merge(parts)


def arch_segment(size: list[float], segments: int, thickness: float) -> tuple[list[Vec3], list[Tri]]:
    width, height, depth = size
    outer = width / 2
    inner = max(1.0, outer - thickness)
    leg_height = max(0.5, height - outer)
    spring_y = -height / 2 + leg_height
    hz = depth / 2
    vertices: list[Vec3] = []
    fo: list[int] = []
    fi: list[int] = []
    bo: list[int] = []
    bi: list[int] = []
    for segment in range(segments + 1):
        angle = math.pi * segment / segments
        ox = math.cos(angle) * outer
        oy = spring_y + math.sin(angle) * outer
        ix = math.cos(angle) * inner
        iy = spring_y + math.sin(angle) * inner
        fo.append(len(vertices)); vertices.append((ox, oy, hz))
        fi.append(len(vertices)); vertices.append((ix, iy, hz))
        bo.append(len(vertices)); vertices.append((ox, oy, -hz))
        bi.append(len(vertices)); vertices.append((ix, iy, -hz))
    triangles: list[Tri] = []
    for s in range(segments):
        n = s + 1
        triangles.extend(((fo[s], fo[n], fi[n]), (fo[s], fi[n], fi[s])))
        triangles.extend(((bi[s], bi[n], bo[n]), (bi[s], bo[n], bo[s])))
        triangles.extend(((fo[s], bo[s], bo[n]), (fo[s], bo[n], fo[n])))
        triangles.extend(((fi[n], bi[n], bi[s]), (fi[n], bi[s], fi[s])))
    legs = merge([
        cuboid([thickness, leg_height, depth], (-outer + thickness / 2, -height / 2 + leg_height / 2, 0)),
        cuboid([thickness, leg_height, depth], (outer - thickness / 2, -height / 2 + leg_height / 2, 0)),
    ])
    return merge([(vertices, triangles), legs])


def water_arc(size: list[float], segments: int) -> tuple[list[Vec3], list[Tri]]:
    width, height, diameter = size
    radius = max(0.08, diameter / 2)
    sides = 6
    vertices: list[Vec3] = []
    rings: list[list[int]] = []
    for step in range(segments + 1):
        t = step / segments
        x = -width / 2 + width * t
        normalized = t * 2 - 1
        y = height * (1 - normalized * normalized)
        ring: list[int] = []
        for side in range(sides):
            angle = 2 * math.pi * side / sides
            ring.append(len(vertices))
            vertices.append((x, y + math.cos(angle) * radius, math.sin(angle) * radius))
        rings.append(ring)
    triangles: list[Tri] = []
    for step in range(segments):
        for side in range(sides):
            n = (side + 1) % sides
            a, b = rings[step][side], rings[step][n]
            c, d = rings[step + 1][n], rings[step + 1][side]
            triangles.extend(((a, b, c), (a, c, d)))
    return vertices, triangles


def geometry(component: dict) -> tuple[list[Vec3], list[Tri]]:
    size = [float(v) for v in component["size"]]
    shape = component["shape"]
    if shape in {"beveledBox", "panel"}:
        bevel = float(component.get("bevel", min(size) * 0.12))
        normalized = max(0.05, min(0.85, bevel / max(0.001, min(size) / 2)))
        exponent = 0.18 + normalized * 0.22
        return superellipsoid(size, exponent, int(component.get("segments", 12)), int(component.get("rings", 7)))
    if shape == "ellipsoid":
        return superellipsoid(size, 1.0, int(component.get("segments", 10)), int(component.get("rings", 5)))
    if shape == "frustum":
        return frustum(size, int(component.get("segments", 10)), float(component.get("topScale", 0.7)))
    if shape == "cylinder":
        return frustum(size, int(component.get("segments", 16)), 1.0)
    if shape == "gableRoof":
        return gable_roof(size)
    if shape == "hipRoof":
        return hip_roof(size)
    if shape == "windowSet":
        return window_set(size)
    if shape == "archSegment":
        return arch_segment(size, int(component.get("segments", 12)), float(component.get("thickness", max(1.0, size[0] * 0.12))))
    if shape == "waterArc":
        return water_arc(size, int(component.get("segments", 12)))
    raise ValueError(f"unsupported shape {shape!r}")


def quaternion_xyz(rotation: list[float]) -> list[float]:
    x, y, z = (math.radians(value) / 2 for value in rotation)
    cx, sx = math.cos(x), math.sin(x)
    cy, sy = math.cos(y), math.sin(y)
    cz, sz = math.cos(z), math.sin(z)
    qx = sx * cy * cz + cx * sy * sz
    qy = cx * sy * cz - sx * cy * sz
    qz = cx * cy * sz + sx * sy * cz
    qw = cx * cy * cz - sx * sy * sz
    return [round(qx, 9), round(qy, 9), round(qz, 9), round(qw, 9)]


def align4(data: bytearray) -> None:
    while len(data) % 4:
        data.append(0)


def compile_role(role: str, asset: dict, palette: dict) -> dict:
    binary = bytearray()
    buffer_views: list[dict] = []
    accessors: list[dict] = []
    meshes: list[dict] = []
    nodes: list[dict] = []
    materials: list[dict] = []
    material_map: dict[tuple, int] = {}

    def material_index(component: dict) -> int:
        rgb = palette["colors"][component["color"]]
        alpha = 1.0 - float(component.get("transparency", 0.0))
        material_key = (component["color"], component["material"], round(alpha, 6))
        if material_key in material_map:
            return material_map[material_key]
        index = len(materials)
        material_map[material_key] = index
        roughness = 0.85
        metallic = 0.65 if component["material"] == "metal" else 0.0
        materials.append({
            "name": f"{component['material']}_{component['color']}",
            "pbrMetallicRoughness": {
                "baseColorFactor": [round(channel / 255, 6) for channel in rgb] + [round(alpha, 6)],
                "metallicFactor": metallic,
                "roughnessFactor": roughness,
            },
            "alphaMode": "BLEND" if alpha < 0.999 else "OPAQUE",
            "doubleSided": component["material"] in {"fabric", "foliage"},
        })
        return index

    for component in asset["components"]:
        vertices, triangles = geometry(component)
        align4(binary)
        position_offset = len(binary)
        for x, y, z in vertices:
            binary.extend(struct.pack("<fff", x, y, z))
        position_length = len(binary) - position_offset
        position_view = len(buffer_views)
        buffer_views.append({"buffer": 0, "byteOffset": position_offset, "byteLength": position_length, "target": 34962})
        mins = [min(v[i] for v in vertices) for i in range(3)]
        maxs = [max(v[i] for v in vertices) for i in range(3)]
        position_accessor = len(accessors)
        accessors.append({
            "bufferView": position_view,
            "byteOffset": 0,
            "componentType": 5126,
            "count": len(vertices),
            "type": "VEC3",
            "min": [round(v, 6) for v in mins],
            "max": [round(v, 6) for v in maxs],
        })

        align4(binary)
        index_offset = len(binary)
        flat_indices = [index for triangle in triangles for index in triangle]
        for index in flat_indices:
            binary.extend(struct.pack("<I", index))
        index_length = len(binary) - index_offset
        index_view = len(buffer_views)
        buffer_views.append({"buffer": 0, "byteOffset": index_offset, "byteLength": index_length, "target": 34963})
        index_accessor = len(accessors)
        accessors.append({
            "bufferView": index_view,
            "byteOffset": 0,
            "componentType": 5125,
            "count": len(flat_indices),
            "type": "SCALAR",
            "min": [min(flat_indices)],
            "max": [max(flat_indices)],
        })

        mesh_index = len(meshes)
        meshes.append({
            "name": component["name"],
            "primitives": [{
                "attributes": {"POSITION": position_accessor},
                "indices": index_accessor,
                "material": material_index(component),
                "mode": 4,
            }],
        })
        node = {
            "name": component["name"],
            "mesh": mesh_index,
            "translation": [round(float(v), 6) for v in component["position"]],
        }
        rotation = component.get("rotation", [0, 0, 0])
        if any(rotation):
            node["rotation"] = quaternion_xyz(rotation)
        nodes.append(node)

    encoded = base64.b64encode(bytes(binary)).decode("ascii")
    return {
        "asset": {"version": "2.0", "generator": "TinyWorld ART R4 deterministic product-art compiler"},
        "scene": 0,
        "scenes": [{"name": asset["displayName"], "nodes": list(range(len(nodes)))}],
        "nodes": nodes,
        "meshes": meshes,
        "materials": materials,
        "buffers": [{"byteLength": len(binary), "uri": "data:application/octet-stream;base64," + encoded}],
        "bufferViews": buffer_views,
        "accessors": accessors,
        "extras": {"tinyWorldRole": role, "qualityTier": asset["qualityTier"], "specVersion": "art-r4-v1"},
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--spec", default="art/specs/village-product-art.json")
    parser.add_argument("--palette", default="art/specs/palette.json")
    parser.add_argument("--out", default="dist/art-r4")
    parser.add_argument("--registry", default=None, help="Optional generated Luau summary for deterministic build evidence")
    args = parser.parse_args()

    spec = json.loads(Path(args.spec).read_text(encoding="utf-8"))
    palette = json.loads(Path(args.palette).read_text(encoding="utf-8"))
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)

    summary: list[dict] = []
    for role in sorted(spec["assets"]):
        asset = spec["assets"][role]
        gltf = compile_role(role, asset, palette)
        target = out / f"{role}.gltf"
        target.write_text(json.dumps(gltf, ensure_ascii=False, sort_keys=True, separators=(",", ":")) + "\n", encoding="utf-8", newline="\n")
        summary.append({"role": role, "file": target.name, "components": len(asset["components"])})

    (out / "asset-pack.json").write_text(
        json.dumps({"specVersion": "art-r4-v1", "assets": summary}, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
        newline="\n",
    )

    if args.registry:
        registry_path = Path(args.registry)
        registry_path.parent.mkdir(parents=True, exist_ok=True)
        lines = ["-- Generated ART R4 build summary. Runtime art source is src/shared/ProductionArtSpec.luau.", "return {"]
        for item in summary:
            lines.append(f'\t["{item["role"]}"] = {{ file = "{item["file"]}", components = {item["components"]} }},')
        lines.extend(["}", ""])
        registry_path.write_text("\n".join(lines), encoding="utf-8", newline="\n")

    print(f"PASS: generated {len(summary)} deterministic ART R4 glTF assets in {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
