# v0.5.3 Production Engineering Foundation acceptance

## Contract

This record covers engineering/release evidence for product version 0.5.3,
release name **Production Engineering Foundation**, profile schema 10, Rojo
7.7.0, and artifact `TinyWorld-v0.5.3.rbxlx`. It does not replace the v0.5.2
Village Soul product/presentation acceptance record.

The artifact metadata contract is `dist/release.json`: product version, release
name, source commit, branch, exact `buildTimestampUtc`, Rojo version,
`default.project.json`, profile schema, artifact filename, and SHA-256. No
credentials, real Roblox IDs, DEV publishing, or LIVE publishing are in scope.
CI reads Rokit `1.2.0` and the immutable installer commit
`2f2618428ef31279e2fc80b0b1d73485bc929ddd` from `config/release.json` before
installing the Rojo toolchain, passing the configured Rokit version as the
installer's first positional argument.

## Source and assembly gates

- [ ] Local release guard: `./scripts/verify-release-contract.sh` passes.
- [ ] Shell build contract: `./tests/build-contract.sh` passes.
- [ ] PowerShell build contract: `powershell -NoProfile -ExecutionPolicy Bypass -File tests/build-contract.ps1` passes on Windows.
- [ ] Existing Luau tests: `luau tests/run.luau` passes.
- [ ] Existing Luau analysis: `luau-analyze src/shared/*.luau tests/*.luau` passes.
- [ ] Existing server compilation: `luau-compile src/server/*.luau >/dev/null` passes.
- [ ] Existing client compilation: `luau-compile src/client/*.luau >/dev/null` passes.
- [ ] CI `Rojo build` uploads `TinyWorld-v0.5.3.rbxlx` and `release.json`.
- [ ] `git diff --check` passes and the recorded release tree is clean.

## Human and environment gates (open until evidenced)

- [ ] Studio opens the built artifact and records one-player runtime/Output evidence.
- [ ] Studio Server & Clients records multiplayer evidence.
- [ ] A deliberately configured DEV target receives a published artifact.
- [ ] Mobile and controller/device behavior is checked against the built artifact.
- [ ] Family playtesting records acceptance and child-safety observations.
- [ ] LIVE promotion is explicitly approved, uses a separately scoped LIVE identity,
  and records DataStore safety and production evidence.

Unchecked gates are not implied to pass. Local and CI checks provide source and
assembly evidence only; use [production engineering](../../engineering/production-engineering.md)
and the [roadmap](../../roadmap/v0.5.3-production-engineering.md) before opening
any later deployment phase.
