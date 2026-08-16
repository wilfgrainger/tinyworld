#!/usr/bin/env python3
"""Generate the checked-in Luau registry from the truthful production asset manifest."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


def q(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def lua_bool(value: bool) -> str:
    return "true" if value else "false"


def generate(manifest: dict) -> str:
    records = sorted(manifest.get("assets", []), key=lambda item: item.get("prefabRole", item.get("id", "")))
    lines = [
        "local ProductionAssetRegistry = {}",
        "",
    ]
    if records:
        lines.append("local assets = {")
    else:
        lines.append("local assets = {}")

    for record in records:
        role = record["prefabRole"]
        asset_id = record.get("robloxAssetId")
        if not isinstance(asset_id, int) or asset_id <= 0:
            raise ValueError(f"{role}: robloxAssetId must be a real positive integer once an asset record exists")
        lines.extend(
            [
                f"\t[{q(role)}] = {{",
                f"\t\tid = {q(record['id'])},",
                f"\t\trobloxAssetId = {asset_id},",
                f"\t\towner = {q(record['owner'])},",
                f"\t\tsource = {q(record['source'])},",
                f"\t\tsourceSha256 = {q(record['sourceSha256'])},",
                f"\t\tlicenseOrProvenance = {q(record['licenseOrProvenance'])},",
                f"\t\tversion = {int(record['version'])},",
                f"\t\tstatus = {q(record['status'])},",
                f"\t\tqualityTier = {q(record['qualityTier'])},",
                f"\t\tdevApproved = {lua_bool(bool(record['devApproved']))},",
                f"\t\tliveApproved = {lua_bool(bool(record['liveApproved']))},",
                "\t},",
            ]
        )
    if records:
        lines.append("}")
    lines.extend(
        [
            "",
            f"ProductionAssetRegistry.specVersion = {q(manifest.get('specVersion', ''))}",
            "",
            "function ProductionAssetRegistry.get(role: string)",
            "\treturn assets[role]",
            "end",
            "",
            "function ProductionAssetRegistry.all()",
            "\treturn assets",
            "end",
            "",
            "return ProductionAssetRegistry",
            "",
        ]
    )
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--manifest", default="assets/manifests/assets.json")
    parser.add_argument("--output", default="src/shared/ProductionAssetRegistry.luau")
    args = parser.parse_args()

    manifest_path = Path(args.manifest)
    output_path = Path(args.output)
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    if manifest.get("schemaVersion") != 3:
        raise SystemExit("production asset manifest schemaVersion must be 3")
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(generate(manifest), encoding="utf-8", newline="\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
