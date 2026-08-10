# TinyWorld v0.6.1 Visual Rescue Design

**Status:** Approved product direction, implementation contract in progress  
**Date:** 10 August 2026  
**Release:** v0.6.1 Visual Rescue  
**Baseline:** merged v0.6.0 Target-State Consolidation, commit `45847dec21a4da310a02675b6136235163d047b5`  
**Methods:** Graphite Mountain full-team lifecycle, Superpowers design/TDD/verification, Cave Pony adversarial simplification/audit  
**Reference input:** user screenshots plus the uploaded Claude v0.7.0 Village Life & Visual Craft proposal. Claude's ZIP is reference material, not release authority.

## 1. Mission

For a new or returning TinyWorld player, make ordinary village play look like an intentional, polished Roblox life game rather than a developer prototype, while preserving the v0.6.0 server-authoritative gameplay, persistence, security and release architecture.

The release promise is:

> **The world should explain itself visually before UI explains it with text.**

v0.6.1 is a corrective presentation release. It does not expand the game sideways. It removes prototype visual language, establishes a coherent TinyWorld visual identity, and proves one ordinary-life route in the actual Roblox runtime before merge.

## 2. Visual north star

TinyWorld combines three broad design qualities without copying any existing IP:

- **Brookhaven-style readability:** destinations, roads, houses, shops and vehicles are understandable at a glance; the world is easy to navigate and does not need floating instructional walls.
- **Toca-style tactility:** ordinary objects feel playful, warm, touchable and deliberately designed; interiors contain recognisable life objects rather than abstract geometry.
- **Ready Player One-style wonder:** impossible worlds, portals and secrets provide the visual spectacle and scale contrast; ordinary village life stays grounded enough for the impossible to feel special.

This is inspiration at the level of design principles only. TinyWorld must not copy distinctive characters, props, layouts, buildings, UI, names, logos, artwork or other protected expression.

## 3. Current-state evidence and failures

### Observed screenshots

The user supplied screenshots of the merged v0.6.0 visual state. They show:

- an oversized orange/black top HUD that reads as a website navigation bar rather than a game HUD;
- a large `My World` status panel that exposes internal system categories during ordinary play;
- large floating black information panels throughout the village;
- labels including Home Gate, Home Style, Home Supply, Daily Fountain, Village Fund and Profession Board competing in the player's sightline;
- abstract glowing geometry used where physical landmarks should communicate purpose;
- buildings that read as textured boxes more than authored places;
- primitive character hair/hat geometry and block-like shoes attached to the player avatar.

### Source-confirmed causes

The screenshot failures are not subjective mysteries:

- `CharacterAppearanceBuilder.luau` constructs hair and shoes as welded rectangular `Part`s. This is the direct source of the unacceptable head and foot geometry.
- `AppearanceService.luau` always calls that primitive fallback for completed onboarding and wardrobe state.
- `AuthoredPrefabBuilder.luau` has a shared `makeLabel()` helper that creates dark, always-on-top `BillboardGui` rectangles, up to 360 pixels wide, above player-facing world objects.
- the current world builders use labels frequently enough that the labels become the visual identity instead of supplementing the world.
- the current visual contracts say labels-off recognition is required, but v0.6.0 allowed player-facing source to merge while the real Studio/device recognition evidence stayed PENDING.

That final point is the process root cause. The documentation claimed a stronger quality bar than the merge gate enforced.

## 4. Product decisions

### D1. Ordinary world first, fantasy second

The village and homes use grounded, readable, playful life-sandbox language. Portals and impossible worlds are allowed to break scale, colour and physical expectation.

Normal village life must remain attractive even if the player never enters a portal.

### D2. World-first information hierarchy

The world communicates identity through:

1. silhouette;
2. architecture/object form;
3. material;
4. spatial grouping;
5. animation/light/state;
6. contextual prompt;
7. text detail only when needed.

Permanent floating text is not a substitute for any earlier layer.

### D3. Delete bad character fallback before replacing it

v0.6.1 removes primitive welded hair and shoe geometry from normal play.

Until an approved TinyWorld character asset exists, preserving the player's normal Roblox avatar appearance is better than adding visibly inferior geometry. TinyWorld may retain saved style metadata and body-colour/palette compatibility where it does not destroy the player's existing clothing/accessory appearance, but it must not bolt anonymous blocks onto the avatar.

A future manifest-backed hair/shoe asset may replace the deleted fallback behind the existing appearance definitions and server authority.

### D4. No permanent billboard information walls in ordinary village play

Large always-on-top `BillboardGui` information panels are forbidden for ordinary civic destinations, plot affordances, shops, careers, home controls and rewards.

Allowed uses are narrow:

- short-lived feedback where a toast/prompt cannot serve the same purpose;
- small diegetic labels integrated with a physical sign/board;
- Studio-only diagnostics;
- exceptional fantasy content where floating text is itself the authored effect.

Destination names belong on buildings, boards, plaques or contextual prompts, not giant black rectangles floating over the street.

### D5. HUD becomes navigation support, not a website header

Normal play keeps only high-value status and intentional access:

- compact coins;
- compact level/progress;
- one current task when useful;
- one compact navigation/journal control;
- short toasts;
- contextual world prompts.

The persistent horizontal navigation bar and permanent `My World` status block are not part of the target HUD.

Deep Home, Wardrobe, Journal, Career, Collection and Places information opens intentionally in one modal owner.

### D6. Native parts remain valid, but hero art has a higher bar

Native Roblox parts are not banned. They are useful when they create a convincing stylised object. The release distinction is semantic:

- **Hero:** player avatar presentation, starter home exterior/interior, Town Hall, Village Shop, Home Store, Courier Depot, fountain, profession/job board, primary vehicle and portal entrances. These must look authored and production-intentional.
- **Interactive supporting:** furniture, parcel props, gardening equipment, shop fixtures and activity equipment. These must be immediately recognisable and tactile.
- **Background:** terrain, fences, simple foliage and distant dressing. Simpler native-part construction is acceptable within performance budgets.

A hero object that still reads as anonymous geometry fails even if every part has a semantic attribute.

### D7. Visual evidence is a merge gate for player-facing work

Claude's uploaded proposal correctly identifies a process defect: source-complete and evidence-pending is not enough for a visual release.

For v0.6.1, a player-facing change is not merge-ready until its PR contains the applicable Studio screenshot/route evidence, or the PR is explicitly restricted to non-player-facing infrastructure.

CI remains unable to prove aesthetics. It can enforce negative contracts and required evidence records, but Studio/device observation decides the visual gate.

### D8. One golden ordinary-life route receives disproportionate attention

The release proves this route:

`spawn -> understand HUD -> identify home -> enter home -> use a recognisable object -> walk to Courier Depot -> complete one visible delivery -> earn coins -> use Home Store -> place an item -> rejoin and see continuity`

This route is the first place TinyWorld must feel coherent from end to end. Other existing systems remain functional but do not expand merely to increase breadth.

## 5. Character target state for v0.6.1

### Required

- no `TinyWorldHairFallback` block construction in normal play;
- no `TinyWorldShoesFallback` block construction in normal play;
- no geometry attached to the avatar solely to simulate hair or shoes without an approved visual asset;
- player's existing Roblox avatar accessories/clothing are preserved by default;
- TinyWorld appearance persistence remains server-authoritative;
- wardrobe UI clearly distinguishes available visual choices from future/unavailable asset-backed choices;
- character setup remains understandable on phone/controller.

### Acceptance

A fresh character screenshot must show no giant head block, primitive hair cap or cuboid shoes. The avatar must look at least as coherent as the player's normal Roblox avatar before TinyWorld styling is applied.

## 6. Village and landmark target state

### Civic destinations

Each must have one dominant visual cue and a physical entrance/interaction zone:

- **Town Hall:** civic roofline/tower or clock cue, steps, windows, plaza relationship.
- **Village Shop:** shopfront, awning, display windows, shelves/crates/counter visible through or near the entrance.
- **Home Store:** furniture/homewares display, room vignette or recognisable homewares storefront.
- **Courier Depot:** parcels, sorting shelves, loading awning, route board and delivery props.
- **Workshop:** open work area, tools/workbench, vehicle silhouette, parts storage.
- **Profession area:** a real jobs/notice board with illustrated/icon-like physical cards, not a floating black paragraph.
- **Daily Fountain:** an actual fountain with water basin/vertical water feature and a nearby contextual prompt, not a glowing reward sphere.
- **Village Fund:** a civic contribution object such as a donation box/plaque/board integrated into Town Hall/plaza, not a floating status panel.

### Buildings

Hero buildings require:

- readable roof silhouette;
- door and window depth;
- facade hierarchy;
- trim/frames/awnings/porch where appropriate;
- at least one small asymmetry or local prop grouping;
- materials that communicate the building rather than arbitrary palette blocks.

## 7. Home and object target state

The starter home should read as a small playable house rather than an empty shell containing interaction markers.

The most-touched objects receive priority:

- bed;
- wardrobe;
- sofa;
- cooker;
- sink;
- bath/shower;
- table/chairs;
- storage;
- garden planter;
- lamp;
- Home Store sample furniture.

An object can be stylised and chunky. It cannot be a coloured block with a label explaining its intended noun.

## 8. UI target state

### Permanent layer

The world should dominate the screen.

- top-left status cluster should be compact and visually quiet;
- task copy should collapse/shorten when no immediate action is needed;
- navigation should be a small icon/control cluster rather than a persistent full-width row;
- no large right-side status dashboard during ordinary play;
- no raw categories such as HOME / COURIER / EXPLORATION presented as telemetry.

### Panels

Home, Wardrobe and Journal surfaces use:

- warm light surfaces rather than near-black slabs as the default panel body;
- dark text on light panels where contrast allows;
- one accent colour at a time;
- rounded containers and clear spacing;
- icons/thumbnail silhouettes where they reduce text dependence;
- responsive phone/controller layout and one modal owner.

Orange/gold remains an accent, not the dominant full-screen colour.

## 9. Portal contrast

Portals and impossible worlds may use richer colour, glow, giant scale and strange geometry because they are the fantasy contrast.

Even there:

- glow is restrained enough to preserve shape;
- labels do not replace authored entrances;
- each world must have a distinct silhouette/visual rule;
- ordinary village materials should not become magical everywhere merely for consistency.

## 10. Documentation authority reset

v0.6.1 becomes the active release on its branch.

The following canonical entrypoints must be updated:

- `README.md`;
- `AGENTS.md`;
- `docs/README.md`;
- `docs/progress.md`;
- `docs/roadmap/roadmap.md`;
- `docs/product/vision.md`;
- `docs/product/target-state-v1.md`;
- `docs/product/art-direction.md`;
- `docs/product/ui-ux.md`;
- `docs/product/village.md`;
- `docs/product/homes.md`;
- `docs/quality/visual-quality-bar.md`;
- `docs/quality/definition-of-done.md`;
- `docs/quality/playtesting.md`;
- `docs/quality/release-evidence-template.md`;
- active engineering/build docs where v0.6.0 is called current.

Historical release/spec/plan records remain historical facts. They are not rewritten to pretend their old scope was v0.6.1. If a historical document uses language that can still be mistaken for current authority, the canonical index must make precedence unambiguous.

The active target-state execution section becomes agent-neutral. It must not require Codex specifically when ChatGPT or another authorised implementation agent is doing the work.

## 11. Engineering invariants

v0.6.1 does not rewrite the v0.6.0 game architecture.

Preserve:

- profile schema 11;
- explicit migration/fail-closed persistence;
- DEV/LIVE namespace separation;
- server authority for economy/progression/ownership/placement/trade/rewards;
- RemoteGuard boundaries;
- content-definition layers;
- home placement persistence;
- trade journal/recovery protections;
- no pay-to-win;
- no invented Roblox IDs;
- no production credentials;
- exact-artifact release evidence.

No framework, package manager or new external runtime dependency is justified by this visual rescue.

## 12. Verification model

### Automated source/build

Automated checks should prove:

- primitive character hair/shoe fallback is absent from normal-play construction;
- prohibited permanent world billboard helper/pattern is absent from ordinary civic/plot paths;
- visual release authority points to v0.6.1/schema 11;
- shared rules, tests, analysis, formatting and recursive compilation pass;
- release/build contract and Rojo artifact pass;
- existing security/persistence/gameplay tests remain green.

### Studio single-client

Required before visual release approval:

- fresh spawn screenshot;
- player character front/side screenshot;
- normal-play HUD screenshot;
- village-centre labels-off screenshot;
- each primary civic destination labels-off screenshot;
- starter-home exterior/interior screenshot;
- golden-route observation notes;
- no critical Output errors.

### Device

At least one agreed phone route must verify:

- HUD does not dominate the screen;
- touch targets remain reachable;
- modal layout does not clip;
- golden route remains at or above the existing 30 FPS target;
- memory/load evidence remains within or explicitly reports against existing budgets.

## 13. Scope cuts

v0.6.1 does not add:

- new portal worlds;
- new profile schema;
- new trading classes;
- monetisation;
- a new UI framework;
- a new runtime package/dependency;
- large new gameplay systems;
- catalogue growth merely to increase counts.

Existing gameplay may receive a small correction only when required to make the golden route coherent or preserve behaviour during the visual reset.

## 14. Release exit criteria

v0.6.1 is release-ready only when:

1. the primitive character hair/shoe fallback is removed from normal play;
2. permanent black billboard information walls are removed from the ordinary village;
3. HUD no longer resembles a full-width website navigation/status dashboard;
4. primary civic destinations and starter home are recognisable labels-off;
5. the golden route works end to end;
6. applicable player-facing PRs contain real Studio visual evidence;
7. phone/controller acceptance is recorded for the golden route;
8. canonical documentation consistently identifies v0.6.1 and the new visual contract;
9. all automated repository/build/security regression gates are green;
10. a Cave Pony final audit finds no simpler root-cause deletion or obvious prototype visual mechanism left in the release path.

## 15. Release philosophy

v0.6.0 proved that TinyWorld can accumulate systems quickly. v0.6.1 proves that the player should actually want to inhabit them.

No amount of semantic metadata can turn an ugly block into finished art. No amount of text can make an unreadable world intuitive. The release succeeds when the world itself carries the explanation.