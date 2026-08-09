# TinyWorld v0.5.0 Traversal Expansion Design

**Date:** 2026-08-09  
**Status:** Approved working design under the standing v0.5-v1.0 release GO  
**Branch target:** `main`  
**Product:** TinyWorld persistent Roblox life sandbox

## Goal

Make traversal create a real destination story. The existing Tiny Bike remains a
fair, visible movement upgrade; v0.5 adds a physical Tiny Boat at the Sea Dock
that carries a player to a physical Tidepool Cove and back.

The slice continues to express the north star:

> Build your life. Explore impossible worlds. Discover the secrets of TinyWorld.

The sea is already part of the village boundary. v0.5 turns that boundary from
scenery into a small, readable journey without introducing a second economy,
combat, or a large new world system.

## Non-negotiable physical-affordance invariant

Anything the player receives or interacts with must exist in the world or be
presented immediately on screen.

- An inventory item must be represented by a physical pickup, a visible object
  on the player's Item Chest/table, or an immediate named reward popup. The
  authoritative inventory count remains server-owned.
- A vehicle must have a visible server-created model and a physical prompt or
  seat. A profile flag alone is never the player-facing experience.
- A destination must have a visible approach, a physical arrival space, and a
  physical return interaction. A teleport message without a world destination
  is not sufficient.
- A purchase or ownership state must name the physical object that can be used.
- Decorative geometry remains non-interactive unless it is deliberately made a
  gameplay surface with a server-owned prompt.

Existing reward paths continue to use `PhysicalItemService`, sync listeners,
and named `PlayerStateService.message` calls. v0.5 adds a source guard that
checks new and existing item reward paths continue to satisfy this invariant.

## Player experience

1. The player visits the existing Sea Dock, which now has a clear `TINY BOAT`
   sign and a real boat model beside the dock.
2. Before ownership, the physical dock prompt says that the boat costs 600
   coins. The server validates the purchase. A player without enough coins is
   told the exact remaining action and receives no ownership state.
3. After purchase, the player boards the boat through its physical prompt. The
   boat model and the player move together to the physical Tidepool Cove.
4. Tidepool Cove is a small, bounded island beyond the village sea belt. It has
   a dock, a beacon, a short story sign, and a physical `Return to Sea Dock`
   prompt. The boat remains visible there while the player explores.
5. Returning moves the same boat model back to the Sea Dock and clears the
   session-only mounted state. Rejoining never leaves the player stranded in
   the cove: boat-active state is reset on the next session, while ownership is
   preserved.
6. The HUD reports `Tiny Bike` and `Tiny Boat` states without hiding existing
   inventory, home, profession, portal, route, social, or goal information.

The cove provides atmosphere and a destination story in this release. It does
not grant a new item, currency, XP, or premium advantage. If a later release
adds a cove collectible, it must be a physical pickup and use the Item Chest
presentation before the reward is considered complete.

## Architecture

### Shared rules and profile

- Add `TraversalRules.luau` with the boat price, purchase validation, mount/
  return transitions, and movement/session constants.
- Extend `ProfileSchema` from version 9 to version 10 with `ownsTinyBoat` and
  `boatActive`. `ownsTinyBoat` persists; `boatActive` is a session mount flag
  reset on initial apply, respawn, return, and player removal.
- Preserve all existing fields and normalize malformed/missing v10 fields to
  safe defaults.

### Physical world

- Extend `BoundaryBuilder` with a bounded `TidepoolCove` model outside the sea
  belt and a dock/return prompt. The island is built once per server using the
  existing capacity-aware layout and visual budget discipline.
- Add a focused `BoatBuilder` that creates a named hull, seat, oars, mast, sail,
  dock marker, and physical mount prompt. Decorative boat parts are anchored
  and non-colliding; the seat/prompt is the only interaction surface.
- The cove and boat use Roblox-native primitives and existing semantic palette
  tokens. No third-party assets or external backend are introduced.

### Server authority

- Add `BoatService` to own boat models, prompt connections, purchase state,
  travel transitions, respawn cleanup, and player cleanup.
- `BoatService` uses `ProfileStore`, `PlayerStateService`, and the shared
  `TraversalRules`. It never trusts client attributes for ownership or travel.
- The service teleports only between the server-created Sea Dock and Tidepool
  Cove CFrames. Each endpoint is a physical model with a prompt.
- Existing `TransportService` remains the owner of the Tiny Bike. The two
  services share no mutable state beyond the profile fields and HUD sync.

### Client presentation

- Update the v0.5 title/eyebrow and compress the transport line to include both
  authoritative states. Do not add client-side prices, rewards, ownership, or
  travel decisions.
- Keep the reward popup and Item Chest refresh behavior unchanged for all
  existing items.

## Failure and safety behavior

- A boat purchase is atomic in the shared rule function: insufficient coins or
  existing ownership leaves both coins and ownership unchanged.
- Boarding requires ownership, a loaded profile, and a live character. A
  failed precondition emits a clear popup and does not mutate the session flag.
- A player already in the cove cannot start a second travel session. The
  return prompt is the only route back during that session.
- Respawn, `PlayerRemoving`, and `BindToClose` cleanup clear `boatActive`, stop
  transient connections, and destroy or re-park the boat model without stale
  duplicate models.
- A saved profile never gains a boat merely because a client saw a prompt or
  set an attribute. The server owns the purchase mutation and save request.

## Testing and evidence

### Pure rule tests

- Purchase succeeds at exactly 600 coins and removes only 600 coins.
- Purchase fails below 600 coins without changing the profile.
- A second purchase is rejected without changing coins.
- Mount requires ownership and is idempotently rejected when already mounted.
- Return clears the session flag and is safe when already parked.
- Profile v9 data migrates with `ownsTinyBoat=false` and `boatActive=false`.

### Source and compile guards

- `verify-traversal.ps1` checks the builder/service/world contracts, named
  physical dock/cove/boat objects, authoritative state attributes, and the
  physical-affordance reward contract.
- Luau CLI tests, Luau analysis, server/client compilation, material safety,
  bike, home, portal, living-world, and item-reward guards remain green.

### Studio route

- Start Rojo from the repository root and connect the current Studio place.
- Play with a profile having at least 600 coins, visit the physical Sea Dock,
  buy the boat, board it, confirm the visible Tidepool Cove arrival, return via
  the physical cove prompt, stop, rejoin, and confirm boat ownership persists
  while the boat is parked at the Sea Dock.
- Verify the Item Chest and at least one existing item reward path in the same
  source revision. A command-bar teleport may be used only as a documented
  positioning aid; it is not normal-route evidence.
- Stop with Output visible and record source/runtime warnings separately from
  source exceptions. Publish only the Rojo-synced source after the commit is
  pushed.

## Scope boundary

v0.5 does not add cars, planes, combat, pets, a new currency, gamepasses,
Robux products, random rewards, or a second portal world. v0.6 remains the fair
cosmetic economy release; v0.7 remains live content tooling. This slice is
complete only when the boat is a real in-world object, the cove is a real
in-world destination, and the existing item-affordance invariant remains
source-guarded.
