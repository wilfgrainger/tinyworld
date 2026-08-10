# v0.6.1 Visual Rescue acceptance

**Release:** v0.6.1  
**Profile schema:** 11  
**Status:** active corrective release; merge blocked until required player-facing visual evidence is observed.

## Evidence rule for this release

Automated source/build evidence and observed Roblox visual/runtime evidence remain different classes.

Unlike v0.6.0, required player-facing visual rows may be `NOT RUN` while this PR is draft, but **the release may not become merge-ready while those rows remain NOT RUN/PENDING**.

A FAIL is useful evidence. It creates a bounded fix; it is never converted to PASS by source inspection.

## Release/product contract

- [ ] Canonical authority identifies v0.6.1 Visual Rescue as the active release.
- [ ] Profile schema remains 11 with no migration introduced by this release.
- [ ] v0.6.0 remains a merged historical baseline rather than current release authority.
- [ ] Current durable docs define Brookhaven-level readability, Toca-style tactile warmth and Ready Player One-style fantasy contrast as broad inspiration only, while requiring original TinyWorld expression.
- [ ] Active implementation-agent guidance is tool-neutral rather than Codex-mandatory.
- [ ] Historical release/spec/plan records remain clearly historical where they are not rewritten.

## Prototype-removal contract

### Character

- [ ] `CharacterAppearanceBuilder.luau` primitive fallback is removed from normal runtime.
- [ ] No `TinyWorldHairFallback` geometry is created.
- [ ] No `TinyWorldShoesFallback` geometry is created.
- [ ] AppearanceService preserves the player's normal Roblox avatar/clothing/accessories when no approved TinyWorld character asset exists.
- [ ] Appearance preference persistence and server-side ID validation remain intact.

### World labels

- [ ] Ordinary village builders do not create large always-on-top BillboardGui information panels.
- [ ] Home Gate, Home Style, Home Supply, Daily Fountain, Village Fund and Profession Board are not presented as floating prototype information walls.
- [ ] Destination proper names, where text is useful, are integrated into physical signs/boards rather than floating over the street.
- [ ] Contextual ProximityPrompt text remains local, short and action-oriented.

### HUD

- [ ] Permanent full-width website-style status/navigation chrome is absent.
- [ ] Permanent developer/system category dashboard is absent from normal play.
- [ ] Normal HUD is limited to compact coins/level/current-task/navigation/toast information.
- [ ] Home/Wardrobe/Journal launch controls form one coherent compact navigation surface rather than competing large independent buttons.
- [ ] Deep panels use a warm/light information surface by default rather than large near-black slabs.

## Hero visual contract

Each required hero must pass silhouette, scale, material and feedback checks with explanatory labels hidden:

- [ ] player character presentation;
- [ ] Town Hall;
- [ ] Village Shop;
- [ ] Home Store;
- [ ] Courier Depot;
- [ ] daily fountain;
- [ ] profession/jobs board;
- [ ] starter-home exterior;
- [ ] starter-home interior key objects;
- [ ] Tiny Bike / primary ordinary travel object;
- [ ] Giant Kitchen entrance;
- [ ] Moonlit Meadow entrance.

Semantic `TinyWorldArtRole` attributes do not satisfy this section by themselves.

## Golden route

The release must be observed end to end on the exact candidate:

- [ ] Spawn with no critical Output error.
- [ ] Player understands the compact HUD without a telemetry/dashboard explanation.
- [ ] Player identifies their home without a floating information wall.
- [ ] Player enters the home.
- [ ] Player uses at least one recognisable home object.
- [ ] Player identifies and reaches Courier Depot.
- [ ] A parcel is physically visible/recognisable.
- [ ] Player completes a delivery with visible feedback.
- [ ] Server-authoritative reward is received.
- [ ] Player identifies and uses Home Store.
- [ ] Player buys one furniture item using the existing server-owned price path.
- [ ] Player places the item physically.
- [ ] Rejoin preserves the expected home/item state.

## Automated gates

| Gate | Status | Evidence |
| --- | --- | --- |
| Pure Luau tests | NOT RUN | exact workflow/run to be recorded |
| Shared Luau analysis | NOT RUN | exact workflow/run to be recorded |
| StyLua check | NOT RUN | exact workflow/run to be recorded |
| Recursive server/client compile | NOT RUN | exact workflow/run to be recorded |
| Release authority | NOT RUN | `tests/verify-release-authority.sh` |
| v0.6.1 visual source contract | NOT RUN | `tests/verify-v0.6.1-visual-contract.sh` |
| Release contract | NOT RUN | `scripts/verify-release-contract.sh` |
| Build contract | NOT RUN | `tests/build-contract.sh` |
| Rojo candidate build | NOT RUN | exact workflow/run to be recorded |
| Traceability manifest/artifact | NOT RUN | exact artifact/hash to be recorded |

Automated PASS does not satisfy any visual row below.

## Studio single-client visual evidence

All rows start `NOT RUN` and block merge-ready status until observed against the exact candidate.

| View / route | Status | Evidence |
| --- | --- | --- |
| Player character front/side, no primitive head/foot add-ons | NOT RUN | |
| Normal HUD, world visually dominant | NOT RUN | |
| Village centre, labels hidden | NOT RUN | |
| Town Hall, labels hidden | NOT RUN | |
| Village Shop, labels hidden | NOT RUN | |
| Home Store, labels hidden | NOT RUN | |
| Courier Depot, labels hidden | NOT RUN | |
| Daily fountain, labels hidden | NOT RUN | |
| Profession/jobs board | NOT RUN | |
| Starter home exterior | NOT RUN | |
| Starter home interior + key objects | NOT RUN | |
| Tiny Bike | NOT RUN | |
| Giant Kitchen entrance | NOT RUN | |
| Moonlit Meadow entrance | NOT RUN | |
| Full golden route | NOT RUN | |
| Output contains no unresolved critical errors | NOT RUN | |

## Benchmark evidence

Required exact-candidate evidence lives under `docs/quality/benchmarks/v0.6.1/`:

- `01-character-front.png`
- `02-normal-hud.png`
- `03-village-centre-labels-off.png`
- `04-town-hall.png`
- `05-village-shop.png`
- `06-home-store.png`
- `07-courier-depot.png`
- `08-daily-fountain.png`
- `09-starter-home-exterior.png`
- `10-starter-home-interior.png`
- `11-giant-kitchen-entrance.png`
- `12-moonlit-meadow-entrance.png`

Do not add generated placeholder images to satisfy this list.

## Device/accessibility/performance evidence

Required on at least one agreed phone for the golden route:

- [ ] portrait UI does not clip or dominate the screen;
- [ ] landscape UI does not clip or dominate the screen;
- [ ] touch targets remain >=44x44 effective pixels;
- [ ] modal close/save/place actions remain reachable;
- [ ] controller focus is verified for Home/Wardrobe/Journal where used;
- [ ] sustained mobile target >=30 FPS or the miss is recorded as FAIL;
- [ ] memory target <=500 MB or the miss is recorded as FAIL;
- [ ] useful spawn target <=15 seconds or the miss is recorded as FAIL.

## Gameplay/security regression

- [ ] profile migration/future-version protections remain green;
- [ ] DEV/LIVE DataStore separation remains green;
- [ ] Home Store price/ownership authority remains green;
- [ ] furniture placement authority remains green;
- [ ] trade transaction/recovery tests remain green;
- [ ] RemoteGuard tests remain green;
- [ ] no production credential or fake Roblox ID is introduced;
- [ ] no automatic LIVE publish surface is introduced.

## Graphite Mountain review

Before ready-for-review status, the actual branch diff receives one reconciled review covering:

- [ ] Delivery Chair: scope, outcome, acceptance and release claim;
- [ ] Architecture Lead: preserved boundaries and smallest coherent implementation;
- [ ] Engineering Lead: complete golden route and maintainability;
- [ ] Platform and Safety Lead: security/persistence/build/recovery regression;
- [ ] Adversarial Strategy Lead: IP imitation risk, misleading quality claims and metric gaming;
- [ ] Customer Advocate: labels-off comprehension, child/family readability and phone/controller usability.

Blocking findings must be fixed or explicitly rejected with evidence.

## Cave Pony final audit

- [ ] no avoidable visual framework/dependency was introduced;
- [ ] no new text layer merely replaces deleted text walls;
- [ ] no duplicate UI navigation system remains;
- [ ] no hero object is accepted only because metadata calls it authored;
- [ ] no test/evidence claim is stronger than what actually ran;
- [ ] no smaller root-cause deletion was left obvious.

## Merge-ready rule

v0.6.1 is **not merge-ready** until:

1. all automated gates are PASS;
2. prototype-removal rows are PASS;
3. required Studio visual rows are PASS;
4. golden route is PASS;
5. phone/controller rows required by the route are PASS or the user explicitly accepts a documented blocker;
6. Graphite Mountain has no blocking finding;
7. Cave Pony has no blocking finding.

No merge is authorised by this acceptance file.