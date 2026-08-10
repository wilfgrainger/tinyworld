# TinyWorld data model

## Authority

`ProfileSchema.luau` defines the current normalized profile. `ProfileMigrations.luau` owns version transitions. ProfileStore must migrate before normalization.

Current schema: **v11**.

v0.6.1 Visual Rescue does not introduce a profile migration.

## v11 compatibility bridge

v11 adds scalable structures while retaining legacy vertical-slice fields so jobs, gardens, routes, transport and other compatibility paths do not break during the transition.

### Generic stack inventory

`inventoryStacks[itemId] = quantity`

Use for common resources/keepsakes. Quantities are non-negative integers and server-mutated.

### Unique instances

`inventoryInstances[uuid] = { itemId, metadata }`

Use only when identity is needed. Metadata is bounded to simple persistent values. Unknown definitions are discarded by normalization rather than becoming executable content.

### Furniture ownership

`ownedFurniture[furnitureId] = quantity`

Definitions contain display/price/art metadata. Profiles contain ownership only.

### Furniture placements

`furniturePlacements[placementId] = { furnitureId, instanceId?, x, y, z, rotation }`

Coordinates are canonical home-local coordinates decided by the server. Placement count is capped at 60. Clients may request a world/local transform; the server owns conversion, snapping, overlap/bounds validation and persistence.

### Character expression preferences

`savedOutfits[outfitId] = { hair, top, bottom, shoes, accessory }`

`activeOutfitId` selects the player's current **TinyWorld style preference**.

That persisted preference is not a guarantee that every field has a currently approved rendered asset. v0.6.1 deliberately preserves the player's Roblox avatar instead of rendering primitive Part hair/shoes while approved TinyWorld character assets are absent. Future approved assets may consume the saved preference without a schema change.

Production Roblox assets are manifest-driven and are not embedded in profile data.

### Discovery

- `discoveredWorlds[worldId] = true`
- `keepsakes[keepsakeId] = quantity`

Portal definitions own reward metadata.

## Legacy compatibility

v11 retains:

- `inventory` for the five vertical-slice resources;
- `homeItems` for the four original essentials;
- profession/progression/route/transport/garden fields.

Generic Inventory dual-writes the legacy five stack fields during v11. Remove legacy fields only in a future explicitly designed migration after every consumer has moved.

## Migration rules

- Current version: 11.
- Unknown future version: fail closed.
- v10 -> v11: deterministic, idempotent, copies rather than deletes legacy state.
- v1-v9: normalized to the last supported legacy shape, then migrated to v11.
- A migration may never silently discard a newer schema it does not understand.
- Migration tests use representative legacy, malformed and future-version profiles.

## Persistence envelope

ProfileStore persists a profile plus an expiring session lease while owned by a server. Saves use `UpdateAsync`. Load/save/heartbeat/release all verify the lease and migration safety.

DEV and LIVE use different namespaces:

- `TinyWorld_DEV_PlayerProfile_v11`
- `TinyWorld_LIVE_PlayerProfile_v11`

Studio defaults to DEV. LIVE selection must be explicit.

## Data ownership

Client presentation attributes are mirrors, not authority. A client may never author coins, XP, price, reward, ownership, trade contents or final placement state.

Visual rescue may change how a saved preference is presented without changing profile authority or silently rewriting saved data.