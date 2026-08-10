# TinyWorld v0.6.1 Visual Rescue Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace TinyWorld's prototype visual language with a coherent world-first life-sandbox presentation, remove the unacceptable primitive avatar fallback, make civic destinations and the starter-home route readable without floating information walls, and require real visual evidence before the release is merge-ready.

**Architecture:** Preserve v0.6.0 server authority, profile schema 11, content definitions, placement, RemoteGuard, trade recovery and Rojo release architecture. The work stays inside existing builder/client boundaries: delete bad fallback rendering, strengthen authored native-part hero objects, reduce permanent UI, and update canonical quality/release contracts. Do not introduce a new UI/game framework or external runtime dependency.

**Tech Stack:** Luau, Roblox native UI/parts, Rojo 7.7.0, Luau CLI, StyLua 2.5.2, shell release/source guards, GitHub Actions.

## Global Constraints

- Release is exactly `0.6.1`, name `Visual Rescue`, profile schema remains exactly `11`.
- Visual direction is Brookhaven-level readability + Toca-style tactile warmth + Ready Player One-style wonder, expressed as original TinyWorld design rather than copied IP.
- Ordinary village life remains grounded/readable; portals carry the strongest fantasy/glow/scale break.
- No primitive welded Part hair or shoe fallback in normal play.
- Preserve the player's normal Roblox avatar appearance when no approved TinyWorld character asset exists.
- No large always-on-top BillboardGui information walls in ordinary village play.
- Labels supplement physical form; they do not explain anonymous geometry.
- Normal HUD contains compact status, one useful task, intentional navigation, short toasts and contextual prompts. No permanent full-width website-style navigation/status bar.
- Hero objects include player presentation, starter home, Town Hall, Village Shop, Home Store, Courier Depot, fountain, profession/jobs board, primary vehicle and portal entrances.
- Player-facing visual changes require Studio screenshot/route evidence in the release PR before merge-ready status.
- Preserve server authority, RemoteGuard, persistence, DEV/LIVE isolation, trade recovery, placement authority and no-pay-to-win rules.
- No new profile schema, portal world, trading class, monetisation system, UI framework or external runtime dependency.
- Historical release records remain historical. Active documentation becomes v0.6.1 and agent-neutral.

---

### Task 1: Make v0.6.1 the release authority and add fail-closed visual contracts

**Files:**
- Modify: `config/release.json`
- Modify: `.github/workflows/release-authority.yml`
- Replace: `tests/verify-v0.6.0-release-authority.sh` with `tests/verify-release-authority.sh`
- Create: `tests/verify-v0.6.1-visual-contract.sh`
- Modify: `scripts/verify-release-contract.sh`
- Modify: `.github/workflows/rojo-build.yml`
- Modify: `src/shared/VisualQualityRules.luau`
- Modify: `tests/VisualQualityRules.spec.luau`
- Modify: `tests/run.luau` only if the current visual-quality spec is not already registered

**Interfaces:**
- `config/release.json.productVersion == "0.6.1"`
- `config/release.json.releaseName == "Visual Rescue"`
- `config/release.json.profileSchema == 11`
- artifact is `TinyWorld-v0.6.1.rbxlx`
- `VisualQualityRules.MAX_RESIDENT_HOMES == 16`
- `VisualQualityRules.TOAST_DURATION_SECONDS == 3`
- `VisualQualityRules.NEIGHBOURHOOD_COUNT == 4`
- `VisualQualityRules.MAX_ORDINARY_BILLBOARD_WIDTH == 0`
- `VisualQualityRules.ALLOW_PRIMITIVE_CHARACTER_FALLBACK == false`

- [ ] **Step 1: Expand the failing visual-quality spec**

Update `tests/VisualQualityRules.spec.luau` so it contains these assertions in addition to the existing recognisability checks:

```lua
TestUtil.equal(VisualQualityRules.MAX_ORDINARY_BILLBOARD_WIDTH, 0)
TestUtil.isFalse(VisualQualityRules.ALLOW_PRIMITIVE_CHARACTER_FALLBACK)
TestUtil.equal(VisualQualityRules.HERO_VISUAL_EVIDENCE_REQUIRED, true)
```

- [ ] **Step 2: Run the focused test and confirm RED**

Run:

```sh
luau tests/VisualQualityRules.spec.luau
```

If this repository only executes specs through the bundle, run:

```sh
luau tests/run.luau
```

Expected: FAIL because the three new constants do not exist.

- [ ] **Step 3: Add the minimal shared constants**

Add to `src/shared/VisualQualityRules.luau`:

```lua
VisualQualityRules.MAX_ORDINARY_BILLBOARD_WIDTH = 0
VisualQualityRules.ALLOW_PRIMITIVE_CHARACTER_FALLBACK = false
VisualQualityRules.HERO_VISUAL_EVIDENCE_REQUIRED = true
```

Do not add a generalized policy framework. These constants exist because the current defects are real release blockers.

- [ ] **Step 4: Replace the version-specific authority guard with one current-release guard**

Create `tests/verify-release-authority.sh` that reads `config/release.json` rather than hard-coding the version in the filename. It must:

```sh
product_version="$(jq -er '.productVersion' config/release.json)"
release_name="$(jq -er '.releaseName' config/release.json)"
profile_schema="$(jq -er '.profileSchema' config/release.json)"
[[ "$product_version" == "0.6.1" ]] || fail "productVersion must be 0.6.1"
[[ "$release_name" == "Visual Rescue" ]] || fail "releaseName must be Visual Rescue"
[[ "$profile_schema" == "11" ]] || fail "profile schema must remain 11"
```

It must require v0.6.1 in `README.md`, `AGENTS.md`, `docs/README.md`, `docs/progress.md` and `docs/roadmap/roadmap.md`, require links to the v0.6.1 roadmap and acceptance record, and reject those canonical files declaring v0.6.0 as current/active.

Delete `tests/verify-v0.6.0-release-authority.sh` after the workflow points to the generic guard.

- [ ] **Step 5: Add the v0.6.1 visual source guard in RED form**

Create `tests/verify-v0.6.1-visual-contract.sh` with fail-closed checks that currently fail:

```sh
#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

fail() { echo "FAIL: $1" >&2; exit 1; }

[[ -f docs/releases/v0.6.1/acceptance.md ]] || fail "missing v0.6.1 acceptance"
[[ -f docs/roadmap/v0.6.1-visual-rescue.md ]] || fail "missing v0.6.1 roadmap"

if grep -Fq 'TinyWorldHairFallback' src/server/CharacterAppearanceBuilder.luau 2>/dev/null; then
  fail "primitive hair fallback still exists"
fi
if grep -Fq 'TinyWorldShoesFallback' src/server/CharacterAppearanceBuilder.luau 2>/dev/null; then
  fail "primitive shoe fallback still exists"
fi
if grep -Fq 'CharacterAppearanceBuilder' src/server/AppearanceService.luau; then
  fail "AppearanceService still depends on primitive character builder"
fi

for path in src/server/AuthoredPrefabBuilder.luau src/server/WorldBuilder.luau src/server/HomePrefabBuilder.luau; do
  if grep -Fq 'AlwaysOnTop = true' "$path"; then
    fail "$path still creates always-on-top ordinary world labels"
  fi
done

for forbidden in 'HOME GATE' 'HOME STYLE' 'HOME SUPPLY' 'DAILY FOUNTAIN' 'VILLAGE FUND' 'PROFESSION BOARD'; do
  if grep -RFiq "$forbidden" src/server src/client; then
    fail "prototype floating-copy token remains in runtime source: $forbidden"
  fi
done

echo "PASS: v0.6.1 prototype visual mechanisms are absent"
```

- [ ] **Step 6: Run the new visual guard and confirm RED for the actual defects**

Run:

```sh
bash tests/verify-v0.6.1-visual-contract.sh
```

Expected: FAIL on the primitive character fallback and/or always-on-top billboard mechanism.

- [ ] **Step 7: Update release/build metadata and workflow names**

Update `config/release.json`, `scripts/verify-release-contract.sh`, `.github/workflows/rojo-build.yml` and `.github/workflows/release-authority.yml` to use `0.6.1`, `Visual Rescue`, `TinyWorld-v0.6.1.rbxlx`, and `tests/verify-release-authority.sh`. Preserve `contents: read` and credential-free build behaviour.

- [ ] **Step 8: Run authority/release focused checks**

Run:

```sh
bash tests/verify-release-authority.sh
bash scripts/verify-release-contract.sh
luau tests/run.luau
```

Expected: authority may remain RED until Task 2 creates the v0.6.1 canonical release docs; pure Luau must be GREEN.

- [ ] **Step 9: Commit**

```sh
git add config .github/workflows scripts tests src/shared/VisualQualityRules.luau
git commit -m "test: make visual quality a v0.6.1 release contract"
```

---

### Task 2: Reconcile every active Markdown contract with v0.6.1

**Files:**
- Create: `docs/roadmap/v0.6.1-visual-rescue.md`
- Create: `docs/releases/v0.6.1/acceptance.md`
- Modify: `README.md`
- Modify: `AGENTS.md`
- Modify: `docs/README.md`
- Modify: `docs/progress.md`
- Modify: `docs/product/vision.md`
- Modify: `docs/product/target-state-v1.md`
- Modify: `docs/product/art-direction.md`
- Modify: `docs/product/core-loop.md`
- Modify: `docs/product/experience-pillars.md`
- Modify: `docs/product/homes.md`
- Modify: `docs/product/ui-ux.md`
- Modify: `docs/product/village.md`
- Modify: `docs/product/content-catalog.md`
- Modify: `docs/engineering/architecture.md`
- Modify: `docs/engineering/asset-pipeline.md`
- Modify: `docs/engineering/production-engineering.md`
- Modify: `docs/engineering/tooling.md`
- Modify: `docs/engineering/world-content-pipeline.md`
- Modify: `docs/quality/accessibility-mobile.md`
- Modify: `docs/quality/definition-of-done.md`
- Modify: `docs/quality/playtesting.md`
- Modify: `docs/quality/release-evidence-template.md`
- Modify: `docs/quality/visual-quality-bar.md`
- Modify: `docs/roadmap/roadmap.md`
- Review without rewriting historical facts: every other tracked `*.md` file

**Interfaces:**
- Canonical documentation precedence: current v0.6.1 acceptance -> v1 target state -> durable contracts -> v0.6.1 roadmap/design/plan -> historical records.
- Historical v0.6.0/v0.5.x files retain their original claims as history and are not called current.
- Active agent guidance is implementation-agent-neutral rather than Codex-specific.

- [ ] **Step 1: Create the v0.6.1 roadmap from the approved design**

The roadmap must define four bounded workstreams:

```text
A. Prototype removal: avatar blocks, floating information walls, HUD/dashboard chrome.
B. Hero visual rebuild: civic destinations, fountain/jobs board, starter home, primary touched props.
C. Golden route: spawn -> home -> courier -> coins -> Home Store -> placement -> rejoin.
D. Evidence and benchmarks: labels-off screenshots, Studio route, phone/controller checks.
```

It must explicitly cut new worlds, new schema, trading expansion, monetisation and catalogue-count growth.

- [ ] **Step 2: Create the v0.6.1 acceptance record with no visual evidence loophole**

The acceptance record must distinguish automated and observed evidence, but unlike v0.6.0 it must state:

```text
A player-facing row may be NOT RUN while the PR is draft, but the release cannot become merge-ready while required visual rows are NOT RUN/PENDING.
```

Required visual rows: character, normal HUD, village centre labels-off, each primary civic destination labels-off, starter-home exterior/interior, golden route, phone layout, controller focus.

- [ ] **Step 3: Update root authority files**

`README.md`, `AGENTS.md`, `docs/README.md`, `docs/progress.md` and `docs/roadmap/roadmap.md` must identify v0.6.1 as active and v0.6.0 as merged historical baseline.

- [ ] **Step 4: Strengthen art/UI/village durable rules**

Add exact rules to the durable docs:

- no primitive avatar hair/shoe blocks;
- preserve normal Roblox avatar when no approved TinyWorld asset exists;
- no large always-on-top ordinary-world information panels;
- diegetic signage plus contextual prompts;
- hero objects have a higher craft requirement than background fallback;
- gold/orange is an accent, not a full-screen UI field;
- ordinary village grounded/readable, portals fantastical;
- player-facing visual evidence is required before merge-ready status.

- [ ] **Step 5: Make target-state execution guidance agent-neutral**

Rename the active `Codex execution contract` section in `docs/product/target-state-v1.md` to `Implementation-agent execution contract` and replace tool-specific wording that implies Codex is mandatory. Preserve the evidence/authority rules.

Historical v0.6.0 Codex remediation notes remain historical and may still say Codex because that is what happened.

- [ ] **Step 6: Audit every remaining Markdown file line-by-line**

For each tracked `*.md` not edited above, classify every current-sounding statement as one of:

```text
current authority
historical record
future roadmap
example/reference
```

Change only statements that are objectively misleading under the v0.6.1 authority model. Do not rewrite historical records to modern style merely for consistency.

- [ ] **Step 7: Run documentation/release guards**

Run:

```sh
bash tests/verify-release-authority.sh
bash scripts/verify-release-contract.sh
bash tests/verify-v0.6.1-visual-contract.sh
```

Expected: release authority becomes GREEN. Visual guard remains RED until Tasks 3 and 4 remove the runtime mechanisms.

- [ ] **Step 8: Commit**

```sh
git add README.md AGENTS.md docs
git commit -m "docs: make visual rescue the active TinyWorld contract"
```

---

### Task 3: Delete the primitive character fallback

**Files:**
- Delete: `src/server/CharacterAppearanceBuilder.luau`
- Modify: `src/server/AppearanceService.luau`
- Modify: `src/server/OnboardingService.luau`
- Modify: `src/client/Appearance.client.luau`
- Modify: `src/shared/AppearanceDefinitions.luau` only where UI metadata must stop promising unavailable rendered hair/shoes
- Modify: `tests/ContentDefinitions.spec.luau` if its assertions assume every appearance definition is visually rendered by a native fallback
- Add focused source assertions to: `tests/verify-v0.6.1-visual-contract.sh`

**Interfaces:**
- Appearance persistence remains `savedOutfits` + `activeOutfitId` under profile schema 11.
- `AppearanceService` remains the server authority for accepted style IDs and persistence.
- No runtime module creates `TinyWorldHairFallback` or `TinyWorldShoesFallback`.
- Existing Roblox character accessories/clothing are not destroyed by TinyWorld appearance application.

- [ ] **Step 1: Confirm RED guard names the current character failure**

Run:

```sh
bash tests/verify-v0.6.1-visual-contract.sh
```

Expected: FAIL because `CharacterAppearanceBuilder` and primitive fallback markers exist.

- [ ] **Step 2: Remove the primitive builder dependency from AppearanceService**

Delete:

```lua
local CharacterAppearanceBuilder = require(script.Parent:WaitForChild("CharacterAppearanceBuilder"))
```

and delete:

```lua
CharacterAppearanceBuilder.apply(character, hairId, outfitId)
```

Do not replace it with another primitive geometry builder.

- [ ] **Step 3: Preserve the player's existing Roblox avatar**

Keep server-side style validation/persistence, but make visible application conservative. `applyLook()` may retain the existing body-colour palette assignment only if it does not delete Shirt, Pants, Accessory, HairAccessory or layered clothing instances. It must not destroy or replace those objects.

Add this explicit comment above the visible application boundary:

```lua
-- v0.6.1 visual rescue: preserve the player's Roblox avatar until an
-- approved TinyWorld character asset can replace it through the asset pipeline.
```

- [ ] **Step 4: Delete CharacterAppearanceBuilder.luau**

Remove the file completely. Cave Pony rationale: deletion is safer and smaller than inventing another native-part haircut system.

- [ ] **Step 5: Make wardrobe copy honest**

Change the wardrobe hint from promising rendered hair/shoes that no longer exist. Use:

```text
Save a TinyWorld style. Your Roblox avatar stays intact while TinyWorld character assets are being upgraded.
```

Hair/style buttons may remain as persisted future-facing preferences only if the UI labels them clearly as style preferences rather than showing fake preview claims. If that is confusing in Studio, hide the hair row for v0.6.1 and retain the saved data untouched.

- [ ] **Step 6: Update onboarding comment/copy**

Remove the comment claiming AppearanceService writes hair/shoe fallbacks. Do not change onboarding validation or saved fields.

- [ ] **Step 7: Run focused and broad proof**

Run:

```sh
bash tests/verify-v0.6.1-visual-contract.sh
luau tests/run.luau
luau-analyze src/shared/*.luau tests/*.luau
stylua --check src tests
find src/server -type f -name '*.luau' -print0 | xargs -0 luau-compile >/dev/null
find src/client -type f -name '*.luau' -print0 | xargs -0 luau-compile >/dev/null
```

Expected: character portion of visual guard GREEN; remaining billboard checks may still be RED.

- [ ] **Step 8: Commit**

```sh
git add -A src/server src/client src/shared tests
git commit -m "fix: remove primitive character hair and shoes"
```

---

### Task 4: Remove floating information walls and build diegetic destination cues

**Files:**
- Modify: `src/server/AuthoredPrefabBuilder.luau`
- Modify: `src/server/WorldBuilder.luau`
- Modify: `src/server/HomePrefabBuilder.luau`
- Modify: `src/server/HomeService.luau`
- Modify: `src/server/BoundaryBuilder.luau` where ordinary world billboard copy exists
- Modify: `src/server/LivingWorldBuilder.luau` where ordinary village billboard copy exists
- Modify: `src/server/PhysicalItemService.luau` where persistent item labels exceed contextual needs
- Modify: `src/server/GardenService.luau` only where permanent billboard text is used as the object identity
- Modify: `tests/verify-v0.6.1-visual-contract.sh`

**Interfaces:**
- `ProximityPrompt` remains the contextual action boundary.
- Ordinary destination identity is carried by physical prefab form and optional diegetic signage.
- Ordinary-world builders contain no `AlwaysOnTop = true` billboard information panels.

- [ ] **Step 1: Inventory all BillboardGui construction**

Run:

```sh
grep -RFn 'BillboardGui' src/server src/client
```

Classify each occurrence as ordinary persistent, contextual/temporary, Studio-only, or fantasy-specific. The default decision for ordinary persistent labels is deletion.

- [ ] **Step 2: Delete `AuthoredPrefabBuilder.makeLabel()`**

Remove the helper that creates a dark always-on-top 62px BillboardGui. Remove its ordinary civic/collectible call sites where the object and prompt already communicate identity.

Do not replace it one-for-one with another floating label helper.

- [ ] **Step 3: Add one local diegetic sign helper only where a physical sign is actually needed**

Inside `AuthoredPrefabBuilder.luau`, add a physical sign helper with no always-on-top behaviour:

```lua
local function makeDiegeticSign(parent: Instance, name: string, position: Vector3, text: string): Part
    local board = makeDecoration(
        parent,
        name,
        Vector3.new(7, 3, 0.5),
        position,
        VisualTheme.Colors.timberDark,
        Enum.Material.WoodPlanks,
        "diegetic-sign"
    )
    local surface = Instance.new("SurfaceGui")
    surface.Face = Enum.NormalId.Front
    surface.AlwaysOnTop = false
    surface.LightInfluence = 1
    surface.Parent = board
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = VisualTheme.Colors.paper
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = surface
    return board
end
```

Use it for a short building/job-board name only when architecture alone cannot carry the proper noun. Do not use it for prices, instructions, status paragraphs or feature lists.

- [ ] **Step 4: Replace the profession text wall with a physical jobs board**

The profession area must include a timber frame, 3-4 card/plaque shapes and small visual category cues. The single contextual prompt may say `Choose a job` / `Village Jobs`. Do not render `Courier · Farmer · Designer` as a floating paragraph over the world.

- [ ] **Step 5: Replace Daily Fountain abstraction with an actual fountain**

Use a basin, central pedestal/spout and water/glass elements. Attach the existing daily reward prompt to a subtle interaction anchor at the fountain edge. Remove any floating reward description that is only explaining the mechanic.

- [ ] **Step 6: Integrate Home Supply/Home Style/Home Gate into physical places**

Home Store interactions belong on the store counter/showroom/door. Home access/privacy/style interactions belong on the house gate/doorbell/wardrobe/catalogue object. Delete runtime copy tokens that present these as floating system labels.

- [ ] **Step 7: Keep portal/fantasy labels exceptional and minimal**

Where portal-world content genuinely benefits from a magical name reveal, use short authored treatment. Do not reintroduce the generic black billboard helper.

- [ ] **Step 8: Run the visual contract**

Run:

```sh
bash tests/verify-v0.6.1-visual-contract.sh
grep -RFn 'AlwaysOnTop = true' src/server src/client
```

Expected: no ordinary-world blocker remains. Any remaining occurrence must be demonstrably Studio-only, transient or fantasy-specific and documented in the guard allow-list.

- [ ] **Step 9: Run runtime syntax/format checks**

```sh
stylua --check src tests
find src/server -type f -name '*.luau' -print0 | xargs -0 luau-compile >/dev/null
find src/client -type f -name '*.luau' -print0 | xargs -0 luau-compile >/dev/null
```

- [ ] **Step 10: Commit**

```sh
git add src/server tests/verify-v0.6.1-visual-contract.sh
git commit -m "feat: replace floating system labels with world cues"
```

---

### Task 5: Reset the permanent HUD and modal visual language

**Files:**
- Modify: `src/client/Main.client.luau`
- Modify: `src/client/Appearance.client.luau`
- Modify: `src/client/FurniturePlacement.client.luau`
- Modify: `src/client/UiTokens.luau`
- Modify: `src/client/PanelFactory.luau` if the shared panel default is still visually heavy
- Modify: `src/client/UiScaleRules.luau` only for concrete phone/short-screen layout needs
- Modify: `tests/verify-v0.6.1-visual-contract.sh`
- Modify: `tests/FurnitureUiRules.spec.luau` only for any changed deterministic layout calculation

**Interfaces:**
- Permanent HUD: compact status stack + one journal/navigation button + optional task chip.
- Home and Wardrobe entry controls are visually integrated into one compact navigation cluster rather than competing independent large text buttons.
- Modal surfaces default to `UiTokens.Colors.Paper`/`PaperSoft` with `Ink` text.
- `ModalController` remains the single ownership mechanism.

- [ ] **Step 1: Add HUD source assertions to the visual guard**

Require absence of the oversized patterns and presence of the compact container names:

```sh
grep -Fq 'StatusCluster' src/client/Main.client.luau || fail "compact StatusCluster missing"
grep -Fq 'GameNav' src/client/Main.client.luau || fail "compact GameNav missing"
if grep -Fq 'UDim2.new(1, -208, 0, 44)' src/client/Main.client.luau; then
  fail "full-width level bar still present"
fi
```

Also require Home/Wardrobe launch buttons to use the shared navigation surface rather than two unrelated 112px bottom buttons. Implement this with an explicit small shared bind/registration seam, not by creating a UI framework.

- [ ] **Step 2: Restructure Main.client into a compact status cluster**

Use a fixed/max-width top-left stack rather than a screen-width level bar:

```lua
local statusCluster = Instance.new("Frame")
statusCluster.Name = "StatusCluster"
statusCluster.Position = UDim2.fromOffset(12, 12)
statusCluster.Size = UDim2.fromOffset(250, 94)
statusCluster.BackgroundTransparency = 1
statusCluster.Parent = gui
```

Place a coin pill and short level/progress row inside it. Make the task chip hidden/collapsed when copy is empty or informational rather than actionable.

- [ ] **Step 3: Build a compact GameNav surface**

Create a small bottom/right navigation cluster with icon-like short labels for Journal, Home and Wardrobe. Do not use a full-width top row. Reuse existing activation callbacks through BindableEvent/module registration or relocate the three launch buttons into a common ScreenGui while preserving modal ownership.

Prefer the smallest seam that avoids duplicating Home/Wardrobe panels.

- [ ] **Step 4: Lighten modal surfaces**

Ensure `PanelFactory` uses `Paper` or `PaperSoft` body surfaces, dark text, restrained strokes and one accent. Avoid near-black panel bodies for Home/Wardrobe/Journal ordinary information.

- [ ] **Step 5: Preserve accessibility/input**

Keep >=44px targets, touch `Activated`, explicit controller selectability/focus, safe-area behaviour and short-screen scrolling. Do not shrink controls merely to make screenshots cleaner.

- [ ] **Step 6: Run focused UI tests/source guards**

```sh
luau tests/FurnitureUiRules.spec.luau
bash tests/verify-v0.6.1-visual-contract.sh
find src/client -type f -name '*.luau' -print0 | xargs -0 luau-compile >/dev/null
stylua --check src/client tests
```

- [ ] **Step 7: Commit**

```sh
git add src/client tests
git commit -m "feat: make the world dominate the TinyWorld HUD"
```

---

### Task 6: Raise hero buildings and the starter home above fallback quality

**Files:**
- Modify: `src/server/AuthoredPrefabBuilder.luau`
- Modify: `src/server/HomePrefabBuilder.luau`
- Modify: `src/server/HomeService.luau`
- Modify: `src/server/FurniturePrefabBuilder.luau`
- Modify: `src/server/BikeBuilder.luau`
- Modify: `src/server/VillageSceneryBuilder.luau` only for approach composition/landscape support
- Modify: `src/server/VisualTheme.luau`
- Modify: `src/shared/VisualPalette.luau`
- Modify: `tests/verify-v0.6.1-visual-contract.sh`
- Reuse existing v0.5.2 prefab/home/physical-affordance guards where still applicable

**Interfaces:**
- Existing service-facing prompt/anchor return fields remain unchanged.
- Hero prefabs gain visual detail without moving gameplay authority into art builders.
- Decoration remains anchored/non-touch/non-query unless it is an interaction anchor.

- [ ] **Step 1: Audit each hero prefab against four dimensions**

For Town Hall, Village Shop, Home Store, Courier Depot, starter home, bike and fountain record in code review notes whether silhouette, scale, material and feedback are each present. Do not accept semantic attributes as evidence for a missing dimension.

- [ ] **Step 2: Improve Town Hall**

Retain service anchors. Add a visibly civic roof/crown/tower element, framed windows, entrance steps, door depth and small plaza dressing. Remove any dependence on a floating label for recognition.

- [ ] **Step 3: Differentiate Village Shop and Home Store**

Village Shop: awning, produce/box shelving, counter/window stock.  
Home Store: furniture vignette/display window, lamp/chair/table silhouette, warmer homewares palette.

The buildings must not be the same box with different text.

- [ ] **Step 4: Improve Courier Depot**

Use loading awning, stacked parcels, sorting shelves, route board, handcart/bike adjacency and a distinct depot entrance. Keep pickup/delivery prompt anchors exactly where services expect them.

- [ ] **Step 5: Improve starter-home exterior/interior**

Exterior: pitched roof, framed windows, door/porch, chimney/planter asymmetry.  
Interior priority: bed, wardrobe, sofa, cooker, sink, bath/shower, table/chairs, storage, lamp and garden planter.

Use grouped parts and shape choices so each reads at avatar distance. Avoid adding dozens of detail parts to background surfaces.

- [ ] **Step 6: Improve the Tiny Bike**

Preserve vehicle service/mounting contract. Ensure frame, two wheels, handlebar, saddle and front/rear relationship read clearly. Remove any textual badge used as the primary visual proof that the bike exists or is mounted.

- [ ] **Step 7: Perform palette/material/Neon audit**

Ordinary village:

```text
wood, brick, slate, glass, metal, fabric-like colour blocks, water and foliage
```

Reserve Neon for portal magic, selection and brief feedback. Gold/orange remains accent only. Keep the current warm TinyWorld palette but reduce large fields of saturated accent colour.

- [ ] **Step 8: Run visual and regression guards**

```sh
bash tests/verify-v0.6.1-visual-contract.sh
luau tests/run.luau
luau-analyze src/shared/*.luau tests/*.luau
stylua --check src tests
find src/server -type f -name '*.luau' -print0 | xargs -0 luau-compile >/dev/null
```

Run existing v0.5.2 physical/prefab guards if PowerShell is available; otherwise record them as environment-limited rather than passing.

- [ ] **Step 9: Commit**

```sh
git add src tests
git commit -m "feat: raise TinyWorld hero objects above fallback quality"
```

---

### Task 7: Make the golden ordinary-life route visually coherent without expanding systems

**Files:**
- Modify only as evidence requires: `src/server/JobService.luau`, `src/server/RouteService.luau`, `src/server/HomeStoreService.luau`, `src/server/PhysicalItemService.luau`, `src/client/Main.client.luau`
- Modify deterministic rule modules/tests only if a route bug requires it
- Create: `docs/v0.6.1-visual-rescue-test.md`
- Modify: `docs/releases/v0.6.1/acceptance.md`

**Interfaces:**
- Golden route is exactly:

```text
spawn -> understand HUD -> identify home -> enter home -> use a recognisable object
-> walk to Courier Depot -> visible parcel delivery -> earn coins -> Home Store
-> buy/place one item -> rejoin -> see continuity
```

- [ ] **Step 1: Write the exact Studio route before changing gameplay**

Create `docs/v0.6.1-visual-rescue-test.md` with numbered actions, expected visible result, Output check, labels-off checkpoints and evidence file naming for every step.

- [ ] **Step 2: Run the route in Studio when available and record FAIL/PASS honestly**

Do not change gameplay pre-emptively. Every route failure becomes one bounded fix. Visual confusion counts as a failure even if the server action technically succeeds.

- [ ] **Step 3: Fix only route blockers**

Examples of allowed route fixes:

- parcel is invisible/unrecognisable;
- destination feedback is missing;
- player cannot identify Home Store after labels are hidden;
- purchased furniture cannot be found/placed through the visible flow;
- task copy gives the wrong next action.

Do not expand other careers or add systems merely because this file is open.

- [ ] **Step 4: Re-run exact route after each correction**

Use the same profile reset/state and record commit SHA. Do not substitute source inspection for the run.

- [ ] **Step 5: Commit**

```sh
git add src docs/v0.6.1-visual-rescue-test.md docs/releases/v0.6.1/acceptance.md tests
git commit -m "fix: make the v0.6.1 golden route coherent"
```

---

### Task 8: Add visual benchmarks and evidence-with-PR discipline

**Files:**
- Create directory: `docs/quality/benchmarks/v0.6.1/`
- Create: `docs/quality/benchmarks/v0.6.1/README.md`
- Add observed screenshots only after they are actually captured
- Modify: `docs/releases/v0.6.1/acceptance.md`
- Modify: `docs/quality/release-evidence-template.md`
- Modify: `docs/quality/visual-quality-bar.md`

**Interfaces:**
- Benchmark README names required views and capture conditions.
- Screenshot files are evidence, not generated placeholders.

- [ ] **Step 1: Create benchmark capture contract**

Require these views:

```text
01-character-front.png
02-normal-hud.png
03-village-centre-labels-off.png
04-town-hall.png
05-village-shop.png
06-home-store.png
07-courier-depot.png
08-daily-fountain.png
09-starter-home-exterior.png
10-starter-home-interior.png
11-giant-kitchen-entrance.png
12-moonlit-meadow-entrance.png
```

The README must record commit SHA, viewport/device, graphics level, whether labels/prompts were hidden, and whether the image is benchmark or diagnostic evidence.

- [ ] **Step 2: Do not fabricate screenshots**

If Studio/device access is unavailable, leave required image rows explicitly NOT RUN and keep the PR draft/not merge-ready.

- [ ] **Step 3: Capture/commit real evidence when available**

Only commit screenshots produced by the exact branch candidate. The acceptance record links each file and records PASS/FAIL against the visual-quality contract.

- [ ] **Step 4: Run Cave Pony audit on the actual diff**

Rank findings by impact. Specifically search for:

- new generic visual abstractions;
- text used to rescue weak geometry;
- unnecessary parts/effects;
- duplicate UI systems;
- new dependencies/files without present need;
- evidence claims stronger than checks that ran.

Apply the smallest root correction for every validated blocker.

- [ ] **Step 5: Commit**

```sh
git add docs/quality docs/releases/v0.6.1/acceptance.md
git commit -m "docs: bind v0.6.1 visual quality to observed evidence"
```

---

### Task 9: Full repository line-by-line review and release verification

**Files:**
- Review: every tracked repository file
- Modify only validated defects discovered during the review

**Interfaces:**
- No merge or LIVE publish is authorised by this plan.
- Result is a release candidate PR with explicit residual evidence state.

- [ ] **Step 1: Build a tracked-file audit ledger**

Classify every file into:

```text
release/build
canonical docs
historical docs
shared rules/data
server authority/services
server visual builders
client presentation/input
tests/guards
assets/config
```

Read every tracked text file line-by-line. Binary/generated artifacts are verified by provenance/hash rather than pretending to inspect source lines.

- [ ] **Step 2: Review every Markdown file for authority/visual contradictions**

Search for `current`, `active`, `v0.6.0`, `Codex`, `fallback`, `label`, `Billboard`, `premium`, `visual`, `PENDING`, `Studio` and all named inspirations. Confirm each occurrence is current truth or clearly historical.

- [ ] **Step 3: Review every player-facing source path**

Search all `src/client` and visual builder/service files for:

```text
BillboardGui
AlwaysOnTop
TextScaled
Neon
Part
makeLabel
status
HOME
SUPPLY
STYLE
FUND
PROFESSION
hair
shoe
fallback
```

A match is not automatically a defect, but every match gets context review.

- [ ] **Step 4: Run complete automated verification**

```sh
luau tests/run.luau
luau-analyze src/shared/*.luau tests/*.luau
stylua --check src tests
find src/server -type f -name '*.luau' -print0 | xargs -0 luau-compile >/dev/null
find src/client -type f -name '*.luau' -print0 | xargs -0 luau-compile >/dev/null
bash tests/verify-release-authority.sh
bash tests/verify-v0.6.1-visual-contract.sh
bash scripts/verify-release-contract.sh
bash tests/build-contract.sh
bash scripts/build.sh
git diff --check
```

Record exact results. A missing local tool is NOT RUN, not PASS.

- [ ] **Step 5: Inspect exact branch diff against merged v0.6.0**

Confirm there is no unrelated gameplay architecture rewrite, security regression, schema change, secret, fake Roblox ID, dependency addition or accidental LIVE publishing surface.

- [ ] **Step 6: Graphite Mountain integrated review**

Apply the six accountable lenses to the actual diff:

- Delivery Chair: scope, release promise, evidence and ownership.
- Architecture Lead: preserved boundaries and smallest coherent design.
- Engineering Lead: complete player path and maintainability.
- Platform and Safety Lead: CI, persistence/security regression, recovery and release integrity.
- Adversarial Strategy Lead: clone/IP risk, misleading claims, shortcuts that game the visual metric.
- Customer Advocate: labels-off comprehension, child/family readability, phone/controller usability.

Return one reconciled finding list, not six persona transcripts.

- [ ] **Step 7: Cave Pony final audit**

Delete or simplify anything added merely to make the plan look sophisticated. Retain only code/docs/tests that protect a current requirement.

- [ ] **Step 8: Final acceptance verdict**

The PR may be marked ready only if:

```text
automated gates: PASS
primitive avatar fallback: absent
ordinary floating information walls: absent
canonical docs: v0.6.1 coherent
Studio visual evidence: PASS for required views
phone/controller evidence: PASS or explicitly accepted release blocker
Cave Pony blockers: zero
Graphite Mountain blockers: zero
```

Do not merge as part of this task unless the user separately authorises merge after reviewing the evidence.