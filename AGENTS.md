# TinyWorld agent guide

## Product north star

TinyWorld is a persistent Roblox life sandbox: **Build your life. Explore impossible worlds. Discover the secrets of TinyWorld.**

Read the active design spec and implementation plan under `docs/superpowers/` before changing gameplay.

## Engineering rules

1. Keep authoritative economy/progression logic on the server.
2. Put deterministic, Roblox-service-free game rules in `src/shared`.
3. Keep files focused; do not build unrelated future systems while implementing a slice.
4. Use test-first development for gameplay rules. Add a failing behavior test before production logic.
5. Do not trust client-supplied coins, XP, levels, prices, ownership, rewards, or trade contents.
6. Never silently replace inaccessible saved data with a fresh profile after a DataStore failure.
7. Prefer clear boring code over framework-heavy abstractions until the game needs them.
8. Do not add pay-to-win mechanics. Premium content may be cosmetic, expressive, convenient, or a bounded variant, but free players must retain equivalent gameplay power.

## Source layout

- `src/shared`: pure Luau domain rules mapped to `ReplicatedStorage/TinyWorld/Shared`.
- `src/server`: server-only Roblox adapters and services mapped to `ServerScriptService/TinyWorld`.
- `src/client`: presentation/input bootstrap mapped to `StarterPlayerScripts/TinyWorld`.
- `tests`: Luau CLI unit tests for pure rules.

## Commit discipline

Use small commits with conventional prefixes (`feat:`, `fix:`, `test:`, `docs:`, `chore:`). Keep PRs scoped to one playable slice.
