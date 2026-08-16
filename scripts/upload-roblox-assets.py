#!/usr/bin/env python3
"""Upload generated TinyWorld ART R4 glTF Models through Roblox Open Cloud.

Default mode is dry-run. Real uploads require --execute plus all required environment
variables. The script never invents an asset ID and only writes the manifest after
Roblox reports a successful operation containing a positive asset ID.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import mimetypes
import os
import secrets
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

CREATE_URL = "https://apis.roblox.com/assets/v1/assets"
OPERATION_URL = "https://apis.roblox.com/assets/v1/operations/{operation_id}"


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def creator_payload(creator_id: str, creator_type: str) -> dict:
    if creator_type == "user":
        return {"userId": creator_id}
    if creator_type == "group":
        return {"groupId": creator_id}
    raise ValueError("creator type must be user or group")


def multipart_body(request_payload: dict, source: Path) -> tuple[bytes, str]:
    boundary = "TinyWorldART" + secrets.token_hex(12)
    content_type = mimetypes.guess_type(source.name)[0] or "model/gltf+json"
    if source.suffix.lower() == ".gltf":
        content_type = "model/gltf+json"
    chunks: list[bytes] = []

    def add(value: str | bytes) -> None:
        chunks.append(value.encode("utf-8") if isinstance(value, str) else value)

    add(f"--{boundary}\r\n")
    add('Content-Disposition: form-data; name="request"\r\n')
    add("Content-Type: application/json\r\n\r\n")
    add(json.dumps(request_payload, separators=(",", ":"), sort_keys=True))
    add("\r\n")
    add(f"--{boundary}\r\n")
    add(f'Content-Disposition: form-data; name="fileContent"; filename="{source.name}"\r\n')
    add(f"Content-Type: {content_type}\r\n\r\n")
    add(source.read_bytes())
    add("\r\n")
    add(f"--{boundary}--\r\n")
    return b"".join(chunks), f"multipart/form-data; boundary={boundary}"


def request_json(url: str, api_key: str, method: str = "GET", data: bytes | None = None, content_type: str | None = None) -> dict:
    headers = {"x-api-key": api_key, "Accept": "application/json"}
    if content_type:
        headers["Content-Type"] = content_type
    request = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(request, timeout=90) as response:
            return json.loads(response.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"Roblox Open Cloud HTTP {exc.code}: {body}") from exc


def operation_id_from(response: dict) -> str:
    path = response.get("path") or response.get("operationPath") or response.get("operationId")
    if not isinstance(path, str) or not path:
        raise RuntimeError(f"Create Asset response did not include an operation path: {response}")
    return path.rsplit("/", 1)[-1]


def positive_asset_id(operation: dict) -> int | None:
    candidates: list[object] = []
    response = operation.get("response")
    if isinstance(response, dict):
        candidates.extend([response.get("assetId"), response.get("assetID"), response.get("id")])
    result = operation.get("result")
    if isinstance(result, dict):
        candidates.extend([result.get("assetId"), result.get("assetID"), result.get("id")])
    candidates.extend([operation.get("assetId"), operation.get("assetID")])
    for value in candidates:
        try:
            parsed = int(value)
        except (TypeError, ValueError):
            continue
        if parsed > 0:
            return parsed
    return None


def poll_operation(api_key: str, operation_id: str, timeout_seconds: int = 300) -> int:
    deadline = time.monotonic() + timeout_seconds
    while time.monotonic() < deadline:
        operation = request_json(OPERATION_URL.format(operation_id=operation_id), api_key)
        error = operation.get("error")
        if error:
            raise RuntimeError(f"Roblox asset operation failed: {json.dumps(error, sort_keys=True)}")
        asset_id = positive_asset_id(operation)
        if asset_id is not None:
            return asset_id
        done = operation.get("done")
        if done is True:
            raise RuntimeError(f"Roblox asset operation completed without a positive asset ID: {operation}")
        time.sleep(2)
    raise TimeoutError(f"Timed out waiting for Roblox asset operation {operation_id}")


def manifest_record(role: str, asset: dict, source: Path, asset_id: int) -> dict:
    return {
        "id": role + "-v1",
        "robloxAssetId": asset_id,
        "owner": "TinyWorld",
        "source": source.as_posix(),
        "sourceSha256": sha256(source),
        "licenseOrProvenance": "Original TinyWorld asset generated from repository-owned ART R4 product-art specification",
        "prefabRole": role,
        "version": 1,
        "status": "uploaded-candidate",
        "qualityTier": asset["qualityTier"],
        "devApproved": False,
        "liveApproved": False,
    }


def upsert_record(manifest: dict, record: dict) -> None:
    assets = manifest.setdefault("assets", [])
    assets[:] = [item for item in assets if item.get("prefabRole") != record["prefabRole"]]
    assets.append(record)
    assets.sort(key=lambda item: item["prefabRole"])


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--role", action="append", help="ART R4 role to validate/upload; repeatable")
    parser.add_argument("--all", action="store_true", help="Process every ART R4 role")
    parser.add_argument("--execute", action="store_true", help="Actually call Roblox Open Cloud; default is dry-run")
    parser.add_argument("--spec", default="art/specs/village-product-art.json")
    parser.add_argument("--asset-dir", default="dist/art-r4")
    parser.add_argument("--manifest", default="assets/manifests/assets.json")
    args = parser.parse_args()

    spec = json.loads(Path(args.spec).read_text(encoding="utf-8"))
    manifest_path = Path(args.manifest)
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    if manifest.get("schemaVersion") != 3:
        raise SystemExit("asset manifest must be schemaVersion 3")

    roles = sorted(spec["assets"]) if args.all else sorted(set(args.role or []))
    if not roles:
        raise SystemExit("choose --all or at least one --role")
    unknown = [role for role in roles if role not in spec["assets"]]
    if unknown:
        raise SystemExit("unknown ART R4 role(s): " + ", ".join(unknown))

    creator_id = os.getenv("TINY_WORLD_ASSET_CREATOR_ID", "")
    creator_type = os.getenv("TINY_WORLD_ASSET_CREATOR_TYPE", "")
    api_key = os.getenv("ROBLOX_OPEN_CLOUD_API_KEY", "")
    if args.execute:
        if not api_key or not creator_id or creator_type not in {"user", "group"}:
            raise SystemExit(
                "--execute requires ROBLOX_OPEN_CLOUD_API_KEY, TINY_WORLD_ASSET_CREATOR_ID, "
                "and TINY_WORLD_ASSET_CREATOR_TYPE=user|group"
            )

    for role in roles:
        asset = spec["assets"][role]
        source = Path(args.asset_dir) / f"{role}.gltf"
        if not source.is_file():
            raise SystemExit(f"missing generated glTF for {role}: {source}")
        digest = sha256(source)
        print(f"VALID {role}: {source} sha256={digest}")
        if not args.execute:
            continue

        request_payload = {
            "assetType": "Model",
            "displayName": asset["displayName"],
            "description": f"Original TinyWorld ART R4 production model for {role}",
            "creationContext": {"creator": creator_payload(creator_id, creator_type)},
        }
        body, content_type = multipart_body(request_payload, source)
        create_response = request_json(CREATE_URL, api_key, method="POST", data=body, content_type=content_type)
        operation_id = operation_id_from(create_response)
        print(f"UPLOAD {role}: operation={operation_id}")
        asset_id = poll_operation(api_key, operation_id)
        if asset_id <= 0:
            raise RuntimeError(f"Roblox returned invalid asset ID for {role}: {asset_id}")
        print(f"CREATED {role}: assetId={asset_id}")
        upsert_record(manifest, manifest_record(role, asset, source, asset_id))
        manifest_path.write_text(json.dumps(manifest, indent=2, sort_keys=False) + "\n", encoding="utf-8", newline="\n")

    if not args.execute:
        print("DRY RUN ONLY: no Roblox requests made and manifest not changed")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except KeyboardInterrupt:
        print("cancelled", file=sys.stderr)
        raise SystemExit(130)
