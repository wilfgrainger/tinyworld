# TinyWorld v0.1.0 invited-alpha implementation plan

## Contract-first steps

1. Add `AlphaOpsRules` tests for release/channel identity, the eight-player
   recommended cohort boundary, and the four health states: `ready`, `setup`,
   `saving`, and `recovery-required`.
2. Implement `AlphaOpsRules` as a pure shared module.
3. Add `AlphaOpsService` with server-only per-player observation, aggregate
   workspace attributes, bounded polling, and one-shot recovery messaging.
4. Wire lifecycle setup/removal/shutdown in `Main.server.luau`.
5. Label the client HUD as the invited alpha and add a source guard for the
   operational contract.
6. Add the v0.1.0 Studio/evidence guide and progress/README links.
7. Run the full source gate, build with Rojo, exercise the synced place in
   Studio, inspect Output, then commit and push the intentional release set.

## Verification commands

```powershell
luau tests/run.luau
luau-analyze src/shared/*.luau tests/*.luau
$compiler = "C:\Users\wilf6\scoop\apps\luau\current\luau-compile.exe"
Get-ChildItem src/server -Filter *.luau | ForEach-Object { & $compiler $_.FullName > $null }
Get-ChildItem src/client -Filter *.luau | ForEach-Object { & $compiler $_.FullName > $null }
powershell -NoProfile -ExecutionPolicy Bypass -File tests/verify-alpha-ops.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/verify-roblox-materials.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/verify-profile-store.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/verify-social-slice.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/verify-home-slice.ps1
rojo build default.project.json -o .worktrees\tinyworld-v0.1.0.rbxlx
git diff --check
```
