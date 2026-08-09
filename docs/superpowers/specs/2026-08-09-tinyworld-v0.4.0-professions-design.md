# TinyWorld v0.4.0 profession expansion design

## Intent

TinyWorld's north star is a world where a young creator can build a life and
eventually a meaningful creative opportunity. v0.0.9 established Courier as a
working profession; v0.3.0 established a home worth expressing. v0.4.0 makes
those existing activities legible as fair, persistent paths without adding an
invisible job menu or a second economy.

## Scope

- Preserve Courier level/XP and the existing delivery route unchanged.
- Add Farmer level/XP. A successful physical Carrot harvest grants Farmer XP
  in addition to the existing global XP and carrot reward.
- Add Designer level/XP. Acquiring a physical home decoration grants Designer
  XP; showcasing an owned physical home grants a smaller Designer XP amount.
- Add a visible Profession Board in the village. Its prompt reports the three
  paths, their levels, and what action advances each one.
- Add a compact HUD career line showing Courier, Farmer, and Designer levels.
- Add schema-v9 fields with safe defaults. Existing profiles retain every
  v0.3 value and start Farmer/Designer at level 1 with zero XP.
- Keep all rewards fair and server-authoritative. v0.4 adds no Robux products,
  paid gates, random rewards, combat power, or new inventory item.
- Preserve the physical-affordance rule: profession progression must point to
  an existing world object and every future item reward must render on the
  Item Chest and name the item in a popup.

## Progression contract

Each profession uses the same transparent threshold shape as Courier:

`XP required = 200 + ((level - 1) * 100)`.

The first release grants 50 Farmer XP per harvest, 50 Designer XP per new
decoration, and 25 Designer XP per showcase. These are identity/progression
signals rather than power multipliers. The HUD and Profession Board expose the
current level and XP; the server message names a level-up when one occurs.

## Architecture and authority

`Profession.luau` remains the pure shared rule module. It gains generic
profession metadata and generic XP application while keeping the existing
`addCourierXp` API for compatibility. `ProfileSchema` normalises the four new
numeric fields. `GardenService` awards Farmer XP only after a successful
server-authoritative harvest. `HomeService` awards Designer XP only after a
successful decoration acquisition or owner-only showcase. `ProfessionService`
owns the physical board prompt and read-only summary message.

`PlayerStateService.sync` replicates the new values, so the existing physical
Item Chest sync listener remains the only inventory presentation path. No
client code decides a profession grant, threshold, reward, or ownership.

## Verification and evidence boundary

The release gate includes red-green profession specs, schema migration tests,
server/client compilation, source guards for the physical board and action
paths, the full existing guard suite, Rojo assembly, and `git diff --check`.
Studio evidence must show the Profession Board, a real garden harvest changing
Farmer progression, a real home decoration/showcase changing Designer
progression, and a stop/rejoin restoring all three careers. A single client
does not prove multiplayer fairness, live-server persistence, or family/device
comprehension; those remain explicit later gates.
