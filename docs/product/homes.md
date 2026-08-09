# Homes

## Home promise

A TinyWorld home is a playable life space and the strongest long-term system in the game, not a room-shaped menu. Its exterior communicates ownership/welcome; its interior supports recognisable rooms, useful objects, storage, expression and visible persistent change.

## Room taxonomy

The target home system supports:

- bedroom;
- kitchen/dining;
- bathroom;
- living/social;
- storage/utility;
- garden/outdoor expression.

Higher home tiers may expand floor area/room relationships, but ordinary starter-home life must already feel complete enough to play.

## Catalogue

The v1 floor is at least 80 home/furnishing entries across:

- bedroom;
- kitchen;
- bathroom;
- living;
- storage;
- garden;
- decoration;
- lighting.

At least 20 entries have meaningful interactions. `FurnitureDefinitions.luau` is the canonical definition layer; the profile stores ownership/placement state rather than duplicated display metadata.

## Placement model

v0.6.0 uses bounded free placement with 90-degree rotation snapping rather than exposing arbitrary unrestricted CFrames.

The player may:

1. acquire/own a furniture item;
2. enter placement mode;
3. preview locally;
4. rotate;
5. confirm;
6. receive server validation/final transform;
7. later move or store/remove the placement.

The server verifies:

- item/definition exists and is placeable;
- player owns the furniture/home;
- request numbers are finite;
- transform is inside home bounds;
- placement budget is available;
- overlap/collision policy passes;
- request rate passes.

Only the canonical server transform is saved.

## Placement limits/performance

Initial persistent budget: **60 placed furniture entries per home**.

That limit may change only with measured device/performance evidence. Hero furniture prefabs should remain below the general model budget and avoid unnecessary query/touch/collision parts.

## Persistence

Profile schema v11 stores:

- `ownedFurniture` quantities;
- `furniturePlacements` by stable placement ID;
- optional unique `inventoryInstances` only where identity matters.

Furniture-only changes mutate/re-render only the affected model. Shell/tier/theme rebuilds may rebuild the house, but persisted furniture is re-rendered afterward.

## Interaction verbs

Reusable home verbs include:

- sit;
- rest/sleep;
- open/close;
- switch on/off;
- store/retrieve;
- cook;
- wash;
- bathe/shower;
- plant;
- water;
- harvest;
- read/play;
- dress/change;
- display/collect;
- place/decorate;
- craft/create.

Not every furniture item gets a one-off service branch. Definition metadata maps it to reusable physical behaviour.

## Ownership and guests

Homeowner:

- purchase/own/place/move/store furniture;
- change theme/privacy;
- use owner-only storage/progression interactions.

Visitor:

- sees the same server-replicated home/furniture;
- may observe and use explicitly guest-safe ambience/seating;
- cannot mutate layout, inventory, currency, privacy or progression.

Privacy remains Open/Friends/Private and is checked server-side.

## Storage

Storage is a real interaction concept tied to authoritative inventory. A chest/cabinet may open visually without economic mutation; moving items into/out of inventory requires server-owned rules. Do not create arbitrary client containers that can duplicate items.

## Character expression

Wardrobe interaction is part of home life. Free saved outfits/hair presets remain meaningful without requiring paid identity content. Production Roblox assets must use the approved asset manifest.

## Acquisition

The Home Store owns furniture acquisition. Clients request IDs only. The server resolves stock/price/unlock, decrements coins and grants ownership.

Items sold as physical furniture must be placeable/visible rather than existing solely as a menu badge.

## Visual rules

Doors, beds, tables, chairs, wardrobes, appliances, baths/showers, shelves, garden tools and storage must communicate their function from silhouette/scale/material. Prompts attach to semantic anchors.

A mesh may replace a native prefab only behind the same gameplay/anchor contract.

## Evidence

v0.6.0 runtime acceptance requires Studio evidence for:

- buy furniture;
- place/rotate;
- reject invalid/overlapping/out-of-bounds placement;
- save/rejoin retains layout;
- move/store/remove;
- shell/theme rebuild retains placements;
- two-client visitor replication/read-only behaviour;
- phone/controller placement ergonomics;
- representative high-placement-count performance.

Source implementation alone does not mark those routes PASS.