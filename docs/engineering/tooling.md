# TinyWorld tooling decisions

## Active pinned tools

v0.6.1 uses the smallest toolchain that provides distinct value:

- **Rojo 7.7.0**: Git-to-Roblox project assembly and reproducible candidate build.
- **StyLua 2.5.2**: deterministic Luau formatting.
- **Luau 0.732 CLI in CI**: pure tests, analysis and syntax compilation.
- **Rokit 1.2.0**: pinned Roblox development tool installation.

Versions are declared in repository configuration and checked by the release contract.

v0.6.1 does not introduce a new UI framework, package manager, rendering library or external runtime dependency. The visual rescue is implemented inside existing TinyWorld builder/UI boundaries.

## Selene evaluation

Selene remains **not adopted**.

Reason:

1. the existing Luau analyser is already an active release gate;
2. v0.6.1 is a focused presentation correction and should not add a second diagnostics surface unrelated to the proven visual failures;
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

## Visual source guards

v0.6.1 adds narrow fail-closed source guards for defects that were directly observed:

- primitive Part character hair/shoe fallback;
- large always-on-top ordinary-world information walls;
- known prototype system-label copy;
- oversized permanent HUD structure;
- wrong release authority/version.

These checks do **not** claim to score aesthetics. They prevent known bad mechanisms from silently returning while Studio/device evidence judges the actual rendered result.

Do not build a generic visual-lint framework merely to increase coverage. Add a source rule only when it protects a concrete current requirement.

## Studio automation

A Studio/MCP smoke harness remains an evidence enhancement, not a fabricated CI claim. When a reliable Studio automation path is connected, automate only what it can prove reliably:

1. start Play;
2. collect Output;
3. assert no critical runtime errors;
4. assert key semantic world objects/remotes exist;
5. capture deterministic diagnostic screenshots where the harness can do so reliably;
6. stop Play.

Recognisability, tactile feel, phone ergonomics and visual craft still require observed human/device evidence.

## External delivery/review methods

v0.6.1 uses external methods as process guidance without vendoring their source into the game:

- **Superpowers:** design, TDD, planning, debugging and verification discipline;
- **Graphite Mountain:** full lifecycle, product/architecture/engineering/platform/adversarial/customer review and evidence gates;
- **Cave Pony:** smallest trustworthy change and anti-bloat/root-cause audit;
- **brockmartin/roblox-game-skill:** Roblox-specific architecture/security/persistence/UI/performance/testing guidance.

These methods do not become runtime dependencies, package requirements or proof that a check ran. Their contribution is reflected in repository decisions/tests/evidence only.

## Agent neutrality

TinyWorld's active implementation contracts are tool-neutral. ChatGPT, Codex or another authorised implementation agent may work on the repository if it follows the same authority, evidence and safety rules.

Historical documents may truthfully name the agent/tool that performed historical work. Current product architecture must not require Codex merely because an earlier release used it.