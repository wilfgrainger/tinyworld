# TinyWorld tooling decisions

## Active pinned tools

v0.6.0 uses the smallest toolchain that provides distinct value:

- **Rojo 7.7.0**: Git-to-Roblox project assembly and reproducible candidate build.
- **StyLua 2.5.2**: deterministic Luau formatting.
- **Luau 0.732 CLI in CI**: pure tests, analysis and syntax compilation.
- **Rokit 1.2.0**: pinned Roblox development tool installation.

Versions are declared in repository configuration and checked by the release contract.

## Selene evaluation

Selene was considered as requested by the target-state review, but is **not adopted in v0.6.0**.

Reason:

1. the existing Luau analyser is already an active release gate;
2. v0.6.0 is a broad consolidation release and should not add a second diagnostics surface without proving a distinct defect class;
3. overlapping/noisy lint rules reduce trust in CI rather than improve it.

A later branch may trial Selene with Roblox std configuration. It should be adopted only if the trial demonstrates useful non-duplicative findings with a low false-positive/noise rate. The trial itself must not weaken `luau-analyze`.

## Wally decision

Wally is intentionally **not introduced**. TinyWorld currently has no approved external runtime package dependency. A dependency-free game source is a supply-chain and maintenance advantage.

If a future approved dependency creates a real need for Wally:

- pin the package/version;
- commit dependency/lock declarations;
- record licence/provenance;
- map Packages deliberately in Rojo;
- review supply-chain risk;
- add CI verification.

Do not add Wally because a generic Roblox checklist mentions it.

## Studio automation

A Studio/MCP smoke harness remains an evidence enhancement, not a fabricated CI claim. When a reliable Studio automation path is connected, automate only what it can prove reliably:

1. start Play;
2. collect Output;
3. assert no critical runtime errors;
4. assert key semantic world objects/remotes exist;
5. stop Play.

Recognisability, tactile feel, phone ergonomics and visual craft still require human/device evidence.

## External Roblox development skill

`brockmartin/roblox-game-skill` is used as review/process guidance for architecture, security, DataStores, inventory, UI/mobile, performance, testing and publish readiness. Its source is not vendored into TinyWorld because the reviewed external repository did not expose licence provenance suitable for copying.
