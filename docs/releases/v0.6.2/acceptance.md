# v0.6.2 Village Life & Visual Craft acceptance

**Release:** v0.6.2  
**Profile schema:** 11  
**Status:** final automated/source candidate evidenced; observed Studio/device evidence remains NOT RUN.

## Release contract

- [ ] canonical authority identifies v0.6.2 Village Life & Visual Craft;
- [ ] schema remains 11 with no new migration;
- [ ] the previous v0.7.0 Village Life scope is absorbed into v0.6.2;
- [ ] v0.7.0 is reserved for the family/girls review;
- [ ] no new framework, Wally dependency, fake Roblox ID, production credential or automatic LIVE publish path is introduced;
- [ ] existing trade journal/mutation-lock and DEV/LIVE protections remain intact.

These rows require the combination of source evidence and any relevant runtime observation. Automated evidence below records only what actually ran.

## Village Life contract

### Courier

- [ ] Courier has four bounded destinations: Village Shop, Town Hall, Home Store and Workshop;
- [ ] destination is selected by the server;
- [ ] carried parcel is physically represented;
- [ ] wrong destination does not mutate reward/progress;
- [ ] correct delivery grants only server-owned reward, XP and route progress.

### Gardener

- [ ] player-facing activity is Gardener while persisted profession remains Farmer-compatible;
- [ ] plant/water/grow/harvest remains server-authoritative;
- [ ] crop state is visible in world;
- [ ] prototype/debug wording is absent from normal garden copy.

### Designer

- [ ] successful new authoritative placement records `home_design` route progress;
- [ ] move/store/rejected/preview paths do not record `home_design`;
- [ ] no repeatable raw Designer XP is added to every placement.

### Village Explorer

- [ ] player-facing route is Village Trail / Village Explorer;
- [ ] landmark visits are server-observed;
- [ ] claim remains idempotent and server-owned;
- [ ] no schema-breaking persisted-field rename is introduced.

## Claude visual-craft contract

- [ ] sixteen-home village cap remains explicit;
- [ ] ordinary HUD remains compact/world-first;
- [ ] primitive avatar fallback remains absent;
- [ ] ordinary floating information walls remain absent;
- [ ] primitive Part-built ambient cats/birds are absent;
- [ ] no replacement creature is accepted without approved provenance and Studio evidence;
- [ ] native-part/semantic metadata alone cannot certify hero visual quality;
- [ ] Town Hall, Village Shop, Home Store, Courier Depot, Workshop and Market/Trading Post are reviewed labels-off;
- [ ] ordinary interactions use understandable physical objects rather than generic information kiosks where the existing builder supports them;
- [ ] one hero home completes the required physical interaction route;
- [ ] real exact-candidate screenshots are required for visual acceptance.

## Automated candidate evidence

**Implementation source head:** `62ee24015811971121b3576a227dfa47da94b270`  
**PR merge-test/build commit:** `e198c1cc3c667c0f117bdcfaa0410f8904ffc964`

| Gate | Status | Evidence |
| --- | --- | --- |
| Pure Luau specs | PASS | workflow `31417881706`; 36 specs |
| Shared Luau analysis | PASS | workflow `31417881706`, `luau-analyze src/shared/*.luau tests/*.luau` |
| StyLua | PASS | workflow `31417881706`, `stylua --check src tests` |
| Recursive runtime compile | PASS | workflow `31417881706`, server + client `luau-compile` |
| Release authority | PASS | workflow `31417881452`, canonical v0.6.2/schema 11 guard |
| v0.6.2 source contract | PASS | workflow `31417881452`, including canonical activities, varied Courier routes, Designer route, distinct six civic destinations, Home Store authority, 80+ content contract, safe visiting, durable Trading Post, ambient motion and Claude asset-state guards |
| Repository/current-version audit | PASS | workflow `31417881452`; 235 tracked text files / 34,231 lines, 0 active markers |
| Shell build contract | PASS | Rojo workflow `31417880388` |
| Release contract | PASS | Rojo workflow `31417880388` |
| Rojo candidate build | PASS | Rojo workflow `31417880388` |
| Traceability artifact/manifest | PASS | artifact `9074126257`; archive digest `sha256:1823e18e529e6b52b720ecda91d805ae466c2011da4c95a5122c742e8a94af86` |

Candidate artifact:

- `TinyWorld-v0.6.2.rbxlx`
- SHA-256 `35b3367172db54d2bfb283c2d647e20e2f3ae769982a2001761de4e0644a8734`
- manifest product version `0.6.2`
- manifest release name `Village Life & Visual Craft`
- manifest schema `11`
- manifest Rojo `7.7.0`
- manifest build timestamp `2026-08-10T18:12:27Z`

The artifact hash above was independently recomputed from the downloaded GitHub Actions artifact and matches `release.json` exactly.

Automated PASS never satisfies the player-facing rows below.

## Studio single-client evidence

All rows remain `NOT RUN` until observed against the exact candidate. Use `docs/v0.6.2-village-life-visual-craft-test.md`.

| View / journey | Status | Evidence |
| --- | --- | --- |
| Player avatar, no primitive add-ons | NOT RUN | |
| Normal HUD, world visually dominant | NOT RUN | |
| Village centre, labels hidden | NOT RUN | |
| Town Hall, labels hidden | NOT RUN | |
| Village Shop, labels hidden | NOT RUN | |
| Home Store, labels hidden | NOT RUN | |
| Courier Depot, labels hidden | NOT RUN | |
| Workshop, labels hidden | NOT RUN | |
| Market / Trading Post, labels hidden | NOT RUN | |
| Carried parcel appearance | NOT RUN | |
| Correct vs wrong Courier destination behavior | NOT RUN | |
| Gardener plant/water/grow/harvest | NOT RUN | |
| Village Trail route | NOT RUN | |
| Starter home exterior | NOT RUN | |
| Starter home sit/rest | NOT RUN | |
| Starter home kitchen/water/light interaction | NOT RUN | |
| Starter home storage/open-close interaction | NOT RUN | |
| Home Store buy + placement | NOT RUN | |
| Rejoin preserves placement | NOT RUN | |
| Full golden route | NOT RUN | |
| Output has no unresolved critical error | NOT RUN | |

## Device / accessibility / performance evidence

- [ ] phone portrait UI does not clip or dominate;
- [ ] phone landscape UI does not clip or dominate;
- [ ] effective touch targets remain >=44x44 pixels;
- [ ] modal close/save/place actions remain reachable;
- [ ] controller focus is verified for relevant Home/Style/Journal flows;
- [ ] sustained mobile target >=30 FPS or miss recorded as FAIL;
- [ ] memory target <=500 MB or miss recorded as FAIL;
- [ ] useful spawn target <=15 seconds or miss recorded as FAIL.

## Golden route

The exact candidate must be observed end to end:

`spawn -> understand village -> home -> physical home interaction -> Courier pickup -> assigned delivery -> reward -> Home Store -> buy -> place -> rejoin`

A FAIL is evidence and creates a bounded fix. It is never converted to PASS from source inspection.

## Green-PR boundary

The requested v0.6.2 implementation execution may stop when the pushed PR's exact head has all required automated workflows green. That state is **automated/source green**, not player-facing visual acceptance.

## Merge-ready rule

v0.6.2 is not player-facing merge-ready until automated gates and required observed Studio/device rows are satisfied or an explicit documented exception is approved. A green automated PR may still be visually unaccepted.

No merge is authorised by this file.
