# TinyWorld v0.3.0 home expression design

## Intent

The original TinyWorld brief makes the home more than a purchased tier: it is
where a player builds a life, expresses a style, and eventually shows friends
what they made. v0.0.9 established the first functional interior with a bed,
kitchen counter, wardrobe, and creative desk. v0.3.0 deepens that promise with
a small, persistent expression layer while keeping the slice bounded enough to
test and safe enough for a child-led alpha.

## Scope

- Add three free home styles: Meadow, Harbor, and Sunset. A player can cycle
  them at a village Home Style board; the current style is visible in the HUD,
  on the interior style banner, and in the house accent dressing.
- Add six concrete decorative collection pieces: Lantern Nook, Story Book
  Stack, Meadow Seed Shelf, Seashell Display, Woodland Bench, and Portal
  Painting. The first two use fair coin prices, the next three use materials
  earned through existing play, and Portal Painting requires one completed
  portal plus a fair coin price. There are no Robux products or paid gates.
- Add three bounded interior zones—Rest, Make, and Showcase—using rugs,
  dividers, and authored object positions. This is an authored room layout,
  not an unrestricted placement editor.
- Add an owner-only Home Showcase plaque. It records a persistent showcase
  count and gives a direct confirmation message without awarding power or
  currency. Visitors still use the existing privacy/visit rules.
- Add profile schema version 8 with normalisation for `homeTheme`,
  `homeDecor`, and `homeShowcaseCount`. Older profiles retain all v0.2 data and
  receive Meadow style with an empty décor collection.
- Extend the HUD and source guards so the expression state is legible and
  protected from accidental regression.
- Enforce the physical-affordance rule across the existing item loop: collected
  inventory is represented on the player's visible Item Chest, growing carrots
  are represented in the garden bed, and reward/collection messages name the
  concrete object. A profile count alone is not an acceptable player-facing
  representation of an item.

## Architecture and authority

`HomeExpressionRules` is a pure shared module containing the style catalog,
decor catalog, acquisition preflight/mutation, counts, and showcase counter.
`HomeService` remains the single server boundary for prompts, profile mutation,
rebuilds, saves, and messages. `PlotService` consumes the selected style only
for exterior accent dressing. All visible décor is rebuilt from the normalized
profile when a plot is assigned or changed, so rejoining cannot create a
client-only home.

Decor acquisition is one-at-a-time through a Home Gallery prompt. Every item is
bounded to one owned copy. Resource costs are deducted atomically with the
ownership mutation; missing resources, insufficient coins, an unmet portal
milestone, unknown items, and duplicate ownership fail closed. Style changes
are free and cycle deterministically. Showcase increments are owner-only and
persist through the existing coalescing ProfileStore queue.

## Visual direction

The room remains a warm, authored storybook interior rather than a generic
black-box UI. Existing functional furniture stays visible. Rugs and low
dividers make the Rest/Make/Showcase zones read at a glance; each decoration is
a named, coloured Roblox object with a distinct silhouette. Style banners use
the existing semantic palette and stay within the established material allow
list. No runtime scenery generation or unbounded part placement is introduced.

The Item Chest is a bounded, authored display rather than a second inventory
UI. It shows each non-empty resource as a named object and count, refreshes
from the server profile sync, and has an owner-only inspection prompt. Garden
beds similarly rebuild their crop silhouette from the server garden stage.
This keeps the rule true after rejoin and after any service grants or consumes
an item without adding client-owned state.

## Verification and evidence boundary

The release gate will include red-green shared-rule specs, profile migration
tests, server/client compilation, expression/home/material source guards, Rojo
assembly, and `git diff --check`. A Rojo-synced Studio route will exercise the
style board, at least two décor acquisitions, visible rebuild, showcase prompt,
stop/rejoin persistence, and Output inspection. A single client cannot prove
two-client visitor behavior, published-place parity, scale, or family/device
desirability; those remain explicit later gates.
