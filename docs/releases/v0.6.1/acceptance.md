# v0.6.1 Visual Rescue acceptance

**Release:** v0.6.1  
**Profile schema:** 11  
**Status:** automated/source candidate green; merge blocked until required player-facing visual evidence is observed.

## Evidence rule for this release

Automated source/build evidence and observed Roblox visual/runtime evidence remain different classes.

Unlike v0.6.0, required player-facing visual rows may be `NOT RUN` while this PR is draft, but **the release may not become merge-ready while those rows remain NOT RUN/PENDING**.

A FAIL is useful evidence. It creates a bounded fix; it is never converted to PASS by source inspection.

## Verified implementation candidate

The automated evidence below belongs to the implementation candidate, not to this later evidence-only documentation commit.

- **Source branch SHA:** `a63e99fab79bf91653c5467504f7d7cea1ae8dea`
- **GitHub PR merge-ref SHA tested/built:** `67402fac9fabc83a6f39ab657e4fe3bad8c766f2`
- **Luau workflow:** `31402629294`
- **Release Authority workflow:** `31402629480`
- **Rojo workflow:** `31402629382`
- **Rojo artifact ID:** `9068273355`
- **Artifact archive digest:** `sha256:ee1e2acf9343b6e8b14a03efbce0c7425bf01007f06a95dd7be8d71e415b5de8`
- **Built `TinyWorld-v0.6.1.rbxlx` size:** `612354` bytes
- **Built `TinyWorld-v0.6.1.rbxlx` SHA-256:** `f452f20e265ba2644d9de8f62f40293d30b58b27bfcc1f045f00690cdb7c97af`
- **Release manifest version/name/schema:** `0.6.1` / `Visual Rescue` / `11`
- **Repository line audit:** 225 tracked files, 225 text files, 32,258 text lines, 0 active TODO/FIXME/HACK/PLACEHOLDER markers.

GitHub pull-request workflows check out the generated merge ref, while the workflow metadata records the source branch head. Both identifiers are retained above so the evidence is not presented as if they were the same commit.

## Release/product contract

- [x] Canonical authority identifies v0.6.1 Visual Rescue as the active release.
- [x] Profile schema remains 11 with no migration introduced by this release.
- [x] v0.6.0 remains a merged historical baseline rather than current release authority.
- [x] Current durable docs define Brookhaven-level readability, Toca-style tactile warmth and Ready Player One-style fantasy contrast as broad inspiration only, while requiring original TinyWorld expression.
- [x] Active implementation-agent guidance is tool-neutral rather than Codex-mandatory.
- [x] Historical release/spec/plan records remain clearly historical where they are not rewritten.

## Prototype-removal contract

### Character

- [x] `CharacterAppearanceBuilder.luau` primitive fallback is removed from normal runtime.
- [x] No `TinyWorldHairFallback` geometry is created.
- [x] No `TinyWorldShoesFallback` geometry is created.
- [x] AppearanceService preserves the player's normal Roblox avatar/clothing/accessories when no approved TinyWorld character asset exists.
- [x] Appearance preference persistence and server-side ID validation remain intact.

### World labels

- [x] Ordinary village builders do not create large always-on-top BillboardGui information panels.
- [x] Home Gate, Home Style, Home Supply, Daily Fountain, Village Fund and Profession Board are not presented as floating prototype information walls.
- [x] Destination proper names, where text is useful, are integrated into physical signs/boards rather than floating over the street.
- [x] Contextual ProximityPrompt text remains local, short and action-oriented.

### HUD

- [x] Permanent full-width website-style status/navigation chrome is absent.
- [x] Permanent developer/system category dashboard is absent from normal play.
- [x] Normal HUD is limited to compact coins/level/current-task/navigation/toast information.
- [x] Home/Wardrobe/Journal launch controls form one coherent compact navigation surface rather than competing large independent buttons.
- [x] Deep panels use a warm/light information surface by default rather than large near-black slabs.

These prototype-removal rows are source/contract assertions. They do **not** assert that the resulting rendered composition looks good until the Studio rows below are observed.

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

Semantic `TinyWorldArtRole` attributes do not satisfy this section by themselves. Source review found multi-part authored silhouettes for the major civic/home/travel objects, but none is promoted to PASS without the required Studio views.

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
| Pure Luau tests | PASS | workflow `31402629294`; 35 specs |
| Shared Luau analysis | PASS | workflow `31402629294` |
| StyLua check | PASS | workflow `31402629294` |
| Recursive server/client compile | PASS | workflow `31402629294` |
| Release authority | PASS | workflow `31402629480`; `tests/verify-release-authority.sh` |
| v0.6.1 visual source contract | PASS | workflow `31402629480`; `tests/verify-v0.6.1-visual-contract.sh` |
| Release contract | PASS | workflow `31402629382`; `scripts/verify-release-contract.sh` |
| Build contract | PASS | workflow `31402629382`; `tests/build-contract.sh` |
| Rojo candidate build | PASS | workflow `31402629382` |
| Traceability manifest/artifact | PASS | artifact `9068273355`; hashes recorded above |

Automated PASS does not satisfy any visual row below.

The PowerShell build contract was corrected to the same v0.6.1 metadata in this candidate, but it was not executed by the Linux workflow and is not being used as evidence for the PASS row above; the executed shell contract is the evidence for that row.

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

- [x] profile migration/future-version protections remain green.
- [x] DEV/LIVE DataStore separation remains green.
- [x] Home Store price/ownership authority remains green.
- [x] furniture placement authority remains green.
- [x] trade transaction/recovery tests remain green.
- [x] RemoteGuard tests remain green.
- [x] no production credential or fake Roblox ID is introduced.
- [x] no automatic LIVE publish surface is introduced.

Evidence: the 35-spec Luau suite is green on the candidate and the release/repository guards pass. This section records deterministic/source regressions only, not published-runtime behaviour.

## Graphite Mountain review

The actual candidate diff was reviewed sequentially through the Graphite Mountain lenses; no claim is made that separate subagents ran.

- [x] Delivery Chair: v0.6.1 remains a bounded visual-rescue release; v0.7.0 gameplay expansion is deferred.
- [x] Architecture Lead: server authority/profile schema remain intact; one small shared `GameNav` replaces competing launch controls without a UI framework.
- [ ] Engineering Lead: source/build/maintainability review is clean, but the complete golden route remains NOT RUN in Studio.
- [x] Platform and Safety Lead: persistence/security/build/release regression gates are green; workflows are read-only and no publishing credential/action was added.
- [x] Adversarial Strategy Lead: inspiration is documented as design principles only; original TinyWorld expression is mandatory and visual claims remain evidence-bounded.
- [ ] Customer Advocate: source copy/structure is improved and onboarding is honest, but labels-off comprehension and phone/controller usability remain NOT RUN.

The remaining Graphite Mountain blockers are observed product evidence, not a known source defect.

## Cave Pony final audit

- [x] no avoidable visual framework/dependency was introduced;
- [x] no new text layer merely replaces deleted text walls;
- [x] no duplicate UI navigation system remains;
- [x] no hero object is accepted only because metadata calls it authored;
- [x] no test/evidence claim is stronger than what actually ran;
- [x] no smaller source-level root-cause deletion is currently obvious.

Cave Pony source/diff audit found and corrected two late issues before this evidence snapshot: stale setup-goal copy/debug contrast, then a dormant v0.6.0 build-contract test that was not in CI. Visual acceptance still remains with Studio rather than being inferred from this audit.

## Merge-ready rule

v0.6.1 is **not merge-ready** until:

1. all automated gates are PASS;
2. prototype-removal rows are PASS;
3. required Studio visual rows are PASS;
4. golden route is PASS;
5. phone/controller rows required by the route are PASS or the user explicitly accepts a documented blocker;
6. Graphite Mountain has no blocking finding;
7. Cave Pony has no blocking finding.

Current state: rules 1, 2 and the source-level Cave Pony audit are satisfied. Rules 3, 4, 5 and the observation-dependent Graphite Mountain findings remain open.

No merge is authorised by this acceptance file.
