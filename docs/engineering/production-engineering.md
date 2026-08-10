# Production engineering

## v0.6.0 operating authority

v0.6.0 **Target-State Consolidation** is the current repository/build contract. The [v0.6.0 acceptance record](../releases/v0.6.0/acceptance.md) owns evidence status; the [v1 target state](../product/target-state-v1.md) owns product direction.

| State category | Authority | Rule |
| --- | --- | --- |
| Git-authoritative | Luau, tests, configuration, docs, Rojo project, tooling, release/environment declarations, asset manifest | Review/build/evidence from Git. |
| Roblox-authoritative | Published places, DataStores, hosted asset IDs, permissions, analytics/moderation/platform state | Never invent or overwrite from undocumented assumptions. |
| Git-declared / Roblox-hosted | Approved asset/deployment relationships | Declare in manifest/environment contracts; never scatter IDs/secrets through source. |

Studio is a runtime/visual evidence surface, not an undocumented release master.

## Toolchain/build

Pinned through repository contracts:

- Rojo 7.7.0;
- StyLua 2.5.2;
- Rokit 1.2.0;
- profile schema 11.

Required source/build gates:

```sh
luau tests/run.luau
luau-analyze src/shared/*.luau tests/*.luau
stylua --check src tests
find src/server -type f -name '*.luau' -print0 | xargs -0 luau-compile >/dev/null
find src/client -type f -name '*.luau' -print0 | xargs -0 luau-compile >/dev/null
./scripts/verify-release-contract.sh
./tests/build-contract.sh
./scripts/build.sh
git diff --check
```

Windows build parity uses `scripts/build.ps1` and `tests/build-contract.ps1`.

The candidate output is:

```text
dist/TinyWorld-v0.6.0.rbxlx
dist/release.json
```

The manifest records source commit/branch, build timestamp, tool/project/profile versions, artifact filename and SHA-256. The artifact is a candidate until runtime/device evidence passes.

## DEV/LIVE environment safety

Repository environment declarations remain credential-free/unconfigured until explicit approval.

Persistence is already separated by runtime namespace:

- DEV: `TinyWorld_DEV_PlayerProfile_v11`;
- LIVE: `TinyWorld_LIVE_PlayerProfile_v11`.

Studio defaults to DEV. Never let Studio testing write LIVE player data.

Future configured deployment requires separate DEV/LIVE place identity, scoped Open Cloud credentials stored outside source control and environment protection. Untrusted PRs must never receive publishing credentials.

## Target same-artifact promotion

```text
commit
  -> CI tests/analysis/format/compile
  -> exact Rojo artifact + SHA manifest
  -> publish that exact artifact to DEV
  -> runtime/multiplayer/device evidence
  -> explicit human approval
  -> promote the exact approved artifact to LIVE
```

Do not rebuild different source for LIVE after DEV approval.

## Rollback contract

Before LIVE publishing is enabled, document/record:

- last-known-good artifact/SHA;
- rollback trigger/operator;
- exact rollback procedure;
- profile-schema compatibility;
- migrations that cannot be reversed;
- emergency disable strategy for risky systems.

A code rollback cannot blindly reverse persisted data migrations.

## Asset release boundary

Roblox-hosted production assets enter only through `assets/manifests/assets.json` with real IDs and provenance. Empty manifest means native fallbacks remain authoritative. Asset upload/publishing remains separately permissioned.

## Evidence classes

Keep these independent:

1. automated source/build;
2. Studio single-client;
3. Studio multi-client;
4. real-device/accessibility/performance;
5. published DEV;
6. LIVE promotion/rollback.

CI success proves only class 1. v0.6.0 must never mark the other classes PASS without direct evidence.