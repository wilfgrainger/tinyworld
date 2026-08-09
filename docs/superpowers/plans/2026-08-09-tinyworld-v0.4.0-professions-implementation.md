# TinyWorld v0.4.0 profession expansion implementation plan

1. Write failing shared specs for generic profession thresholds, Farmer and
   Designer XP grants, invalid profession names, level-up carryover, and
   schema-v9 migration/defaults.
2. Implement the smallest generic `Profession` rule API and schema fields while
   preserving Courier behavior and all existing profile values.
3. Add the physical Profession Board builder/service and replicate the three
   career values into the existing HUD.
4. Wire Farmer XP to successful garden harvests and Designer XP to successful
   decoration acquisition/showcase actions. Keep all messages and saves
   server-authoritative; do not add item rewards.
5. Add source guards proving the board, HUD, profile migration, physical
   action paths, and the existing Item Chest invariant remain wired.
6. Run the full Luau/analysis/compile/guard/Rojo/diff gate, then exercise the
   synced Studio route and stop/rejoin evidence.
7. Commit the complete release intentionally and push `main`; verify local HEAD
   equals `origin/main` before proceeding to v0.5.0.
