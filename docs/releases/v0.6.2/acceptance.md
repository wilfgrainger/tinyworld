# v0.6.2 Village Life & Visual Craft acceptance

**Release:** v0.6.2  
**Profile schema:** 11  
**Status:** active release; automated/source evidence and observed player-facing evidence are separate.

## Release contract

- [ ] canonical authority identifies v0.6.2 Village Life & Visual Craft;
- [ ] schema remains 11 with no new migration;
- [ ] the previous v0.7.0 Village Life scope is absorbed into v0.6.2;
- [ ] v0.7.0 is reserved for the family/girls review;
- [ ] no new framework, Wally dependency, fake Roblox ID, production credential or automatic LIVE publish path is introduced;
- [ ] existing trade journal/mutation-lock and DEV/LIVE protections remain intact.

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

## Automated gates

| Gate | Status | Evidence |
| --- | --- | --- |
| Pure Luau specs | NOT RUN | exact final workflow/run to be recorded |
| Shared Luau analysis | NOT RUN | exact final workflow/run to be recorded |
| StyLua | NOT RUN | exact final workflow/run to be recorded |
| Recursive runtime compile | NOT RUN | exact final workflow/run to be recorded |
| Release authority | NOT RUN | `tests/verify-release-authority.sh` |
| v0.6.2 source contract | NOT RUN | `tests/verify-v0.6.2-source-contract.sh` |
| Repository/current-version audit | NOT RUN | exact current audit to be recorded |
| Shell build contract | NOT RUN | `tests/build-contract.sh` |
| Release contract | NOT RUN | `scripts/verify-release-contract.sh` |
| Rojo candidate build | NOT RUN | exact final workflow/run to be recorded |
| Traceability artifact/manifest | NOT RUN | exact artifact/hash to be recorded |

Automated PASS never satisfies the player-facing rows below.

## Studio single-client evidence

All rows begin `NOT RUN` and remain so until observed against the exact candidate.

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

## Merge-ready rule

v0.6.2 is not player-facing merge-ready until automated gates and required observed Studio/device rows are satisfied or an explicit documented exception is approved. A green automated PR may still be visually unaccepted.

No merge is authorised by this file.