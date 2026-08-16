#!/usr/bin/env python3
"""Validate TinyWorld ART R4 product-art specifications without external dependencies."""

from __future__ import annotations

import argparse
import json
import math
from pathlib import Path

ALLOWED_SHAPES = {
    "beveledBox",
    "gableRoof",
    "hipRoof",
    "frustum",
    "cylinder",
    "ellipsoid",
    "archSegment",
    "panel",
    "windowSet",
    "waterArc",
}

REQUIRED_ROLES = {
    "town-hall",
    "starter-home",
    "village-shop",
    "home-store",
    "courier-depot",
    "workshop",
    "market-stall-a",
    "market-stall-b",
    "fountain",
    "portal-clockwork",
    "tree-a",
    "tree-b",
    "tree-c",
    "lantern",
    "bench",
    "planter",
    "hedge",
    "parcel-crates",
    "starter-interior-kit",
}


def finite_number(value: object) -> bool:
    return isinstance(value, (int, float)) and not isinstance(value, bool) and math.isfinite(float(value))


def triple(value: object, label: str, *, positive: bool = False) -> list[float]:
    if not isinstance(value, list) or len(value) != 3 or not all(finite_number(item) for item in value):
        raise ValueError(f"{label} must be a finite three-number array")
    result = [float(item) for item in value]
    if positive and any(item <= 0 for item in result):
        raise ValueError(f"{label} must contain positive values")
    return result


def validate(spec: dict, palette: dict) -> None:
    if spec.get("schemaVersion") != 1:
        raise ValueError("product-art spec schemaVersion must be 1")
    if palette.get("schemaVersion") != 1:
        raise ValueError("palette schemaVersion must be 1")

    colors = palette.get("colors")
    materials = palette.get("materials")
    if not isinstance(colors, dict) or not colors:
        raise ValueError("palette colors must be a non-empty object")
    if not isinstance(materials, dict) or not materials:
        raise ValueError("palette materials must be a non-empty object")

    for name, value in colors.items():
        rgb = triple(value, f"color {name}")
        if any(channel < 0 or channel > 255 for channel in rgb):
            raise ValueError(f"color {name} must use RGB 0..255")

    assets = spec.get("assets")
    if not isinstance(assets, dict):
        raise ValueError("assets must be an object")
    missing = sorted(REQUIRED_ROLES - set(assets))
    if missing:
        raise ValueError("missing required ART R4 roles: " + ", ".join(missing))

    for role, asset in sorted(assets.items()):
        if not isinstance(asset, dict):
            raise ValueError(f"{role}: asset must be an object")
        display_name = asset.get("displayName")
        if not isinstance(display_name, str) or not display_name.startswith("TinyWorld_"):
            raise ValueError(f"{role}: displayName must be a TinyWorld_* name")
        quality = asset.get("qualityTier")
        if quality not in {"hero", "supporting", "background"}:
            raise ValueError(f"{role}: invalid qualityTier {quality!r}")
        components = asset.get("components")
        if not isinstance(components, list) or not components:
            raise ValueError(f"{role}: components must be a non-empty list")

        names: set[str] = set()
        for index, component in enumerate(components):
            if not isinstance(component, dict):
                raise ValueError(f"{role}[{index}]: component must be an object")
            name = component.get("name")
            if not isinstance(name, str) or not name:
                raise ValueError(f"{role}[{index}]: component name missing")
            if name in names:
                raise ValueError(f"{role}: duplicate component name {name}")
            names.add(name)
            shape = component.get("shape")
            if shape not in ALLOWED_SHAPES:
                raise ValueError(f"{role}/{name}: unsupported shape {shape!r}")
            triple(component.get("size"), f"{role}/{name}.size", positive=True)
            triple(component.get("position"), f"{role}/{name}.position")
            if "rotation" in component:
                triple(component["rotation"], f"{role}/{name}.rotation")
            color = component.get("color")
            material = component.get("material")
            if color not in colors:
                raise ValueError(f"{role}/{name}: unknown color key {color!r}")
            if material not in materials:
                raise ValueError(f"{role}/{name}: unknown material key {material!r}")
            transparency = component.get("transparency", 0)
            if not finite_number(transparency) or not 0 <= float(transparency) < 1:
                raise ValueError(f"{role}/{name}: transparency must be >=0 and <1")
            for numeric_field in ("bevel", "topScale", "thickness"):
                if numeric_field in component and not finite_number(component[numeric_field]):
                    raise ValueError(f"{role}/{name}: {numeric_field} must be finite")
            for integer_field in ("segments", "rings"):
                if integer_field in component:
                    value = component[integer_field]
                    if not isinstance(value, int) or isinstance(value, bool) or value < 3 or value > 64:
                        raise ValueError(f"{role}/{name}: {integer_field} must be integer 3..64")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--spec", default="art/specs/village-product-art.json")
    parser.add_argument("--palette", default="art/specs/palette.json")
    args = parser.parse_args()

    spec = json.loads(Path(args.spec).read_text(encoding="utf-8"))
    palette = json.loads(Path(args.palette).read_text(encoding="utf-8"))
    validate(spec, palette)
    component_count = sum(len(asset["components"]) for asset in spec["assets"].values())
    print(f"PASS: ART R4 product art validated: {len(spec['assets'])} roles, {component_count} components")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
