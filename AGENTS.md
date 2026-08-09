# TinyWorld agent guide

## Product north star

TinyWorld is a persistent Roblox life sandbox: **Build your life. Explore impossible worlds. Discover the secrets of TinyWorld.**

## Active product contract

For current work, treat the canonical documentation index and active release records as authoritative:

1. `docs/README.md` for documentation authority and current links.
2. `docs/releases/v0.5.2/acceptance.md` for the active release contract and evidence state.
3. `docs/roadmap/v0.5.2-village-soul.md` for active-release sequencing and implementation inputs.
4. `README.md` for the current Studio smoke-test route.

Earlier v0.01 and foundation specs/plans remain historical context for the progression scaffold. They are useful decision records, but do not override the canonical index or active release acceptance/roadmap. Where historical guidance conflicts with the active v0.5.2 documents, **the active release documents win**.

Before adding the next feature slice, run the Superpowers brainstorming/design process and write a new dated spec/plan rather than silently expanding scope.

## Engineering rules

1. Keep authoritative economy/progression logic on the server.
2. Put deterministic, Roblox-service-free game rules in `src/shared`.
3. Keep files focused; do not build unrelated future systems while implementing a slice.
4. Use test-first development for gameplay rules. Add a failing behavior test before production logic.
5. Do not trust client-supplied coins, XP, levels, prices, ownership, rewards, or trade contents.
6. Never silently replace inaccessible saved data with a fresh profile after a DataStore failure.
7. Prefer clear boring code over framework-heavy abstractions until the game needs them.
8. Do not add pay-to-win mechanics. Premium content may be cosmetic, expressive, convenient, or a bounded variant, but free players must retain equivalent gameplay power.
9. Do not add fake Roblox product/game-pass IDs. Monetisation wiring starts only after real experience products exist.
10. Preserve schema-v2 migration compatibility unless a new spec explicitly defines a migration.

## Source layout

- `src/shared`: pure Luau domain rules mapped to `ReplicatedStorage/TinyWorld/Shared`.
- `src/server`: server-only Roblox adapters and services mapped to `ServerScriptService/TinyWorld`.
- `src/client`: presentation-only code mapped to `StarterPlayerScripts/TinyWorld`; it must not mint or validate economic state.
- `tests`: Luau CLI behavior tests for deterministic rules.

## Verification before merge

At minimum:

```sh
luau tests/run.luau
luau-analyze src/shared/*.luau tests/*.luau
luau-compile src/server/*.luau >/dev/null
luau-compile src/client/*.luau >/dev/null
```

For gameplay/runtime changes, the README Studio smoke test is also required before merging the active vertical-slice PR.

## Commit discipline

Use small commits with conventional prefixes (`feat:`, `fix:`, `test:`, `docs:`, `chore:`). Keep PRs scoped to one playable slice.
