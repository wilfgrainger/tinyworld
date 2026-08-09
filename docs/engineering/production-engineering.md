# Production engineering

## v0.5.3 operating authority

v0.5.3, **Production Engineering Foundation**, makes the build and release
boundary explicit without changing TinyWorld's server-authoritative runtime or
profile schema 10. This document and the [v0.5.3 acceptance record](../releases/v0.5.3/acceptance.md)
are the authority for engineering and release work. The v0.5.2 acceptance
record remains the authority for product and presentation acceptance.

| State category | Authority | Rule |
| --- | --- | --- |
| Git-authoritative | Luau, tests, configuration, docs, Rojo project, build tooling, release/environment declarations, asset manifest | Changes are reviewed, built, and evidenced from Git. |
| Roblox-authoritative | Published places, DataStores, cloud asset/package IDs, permissions, analytics, moderation, platform configuration | Never invent or overwrite this state from an undocumented local assumption. |
| Git-declared / Roblox-hosted | Named future asset and deployment entries | Declare the relationship in a manifest or environment contract; do not scatter IDs in source or Studio. |

Studio remains valuable for visual authoring and runtime playtesting. It is not
an undocumented release master: source inputs, target identity, artifact, and
evidence must be recorded through the repository contracts.

## Build boundary and local contract

`default.project.json` is the current Rojo build boundary. The exact Rojo
version is the `config/release.json` `rojoVersion` property (7.7.0), while
`rokit.toml` pins the matching package; no DataModel remapping is part of this
release.

```sh
./scripts/verify-release-contract.sh
./scripts/build.sh
```

Windows developers may run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/build.ps1
```

The existing source gates remain required:

```sh
luau tests/run.luau
luau-analyze src/shared/*.luau tests/*.luau
luau-compile src/server/*.luau >/dev/null
luau-compile src/client/*.luau >/dev/null
```

The build produces ignored output:

```text
dist/TinyWorld-v0.5.3.rbxlx
dist/release.json
```

`release.json` is the artifact manifest. It records product version and release
name, source commit and branch, exact `buildTimestampUtc`, Rojo version, project
file, profile schema, artifact filename, and SHA-256. The artifact is a release
candidate; the manifest supplies its traceability. Reproducible means a clean
checkout can produce a functionally equivalent artifact, not byte identity of
build-time metadata.

## CI, environments, and credentials

The `Rojo build` CI workflow is credential-free PR/main validation: it reads
Rokit `1.2.0` and immutable installer commit
`2f2618428ef31279e2fc80b0b1d73485bc929ddd` from `config/release.json`, installs
that pinned bootstrap with the configured version as its first positional
installer argument, builds from the pinned toolchain, and uploads the
artifact and manifest. CI validation is not deployment.

`config/environments/dev.json` and `config/environments/live.json` declare
separate DEV and LIVE channels. Both are intentionally unconfigured in v0.5.3:
they contain no real IDs, secrets, or publishing capability. DEV and LIVE must
remain separate identities and later require separately scoped credentials and
DataStore namespaces. Never commit credentials, cookies, API keys, private
keys, universe IDs, or place IDs. Codex must not publish DEV or LIVE casually;
LIVE requires an explicit human promotion decision over an approved artifact.

## Evidence and deferrals

Evidence is cumulative and has distinct classes: source, assembly, Roblox
runtime, multiplayer, published DEV, device/family, and production. Local
guards and CI prove only source and assembly evidence; they do not imply a
Studio run, multiplayer behavior, a published place, device/family acceptance,
or LIVE readiness.

v0.5.3 implements only the credential-free foundation. It defers real
universe/place IDs, Open Cloud publishing, environment secrets and approvals,
DEV/LIVE DataStore wiring, automated runtime tests, same-artifact promotion,
asset/package uploads, production art export/licensing governance, and rollback
automation. Follow the [v0.5.3 roadmap](../roadmap/v0.5.3-production-engineering.md)
for the gated order of that work.
