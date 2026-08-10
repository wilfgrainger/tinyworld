# TinyWorld safety and social contract

TinyWorld is designed for children/families as well as older sandbox players. Social features are therefore deliberately bounded, physical and server-authoritative.

## Home visits

Every home has one of three server-owned privacy states:

- **Open:** other players may visit;
- **Friends:** Roblox friendship must be verified server-side;
- **Private:** only the homeowner may enter through the visit route.

Visitors are read-only by default. They may look, sit or observe where the interaction is explicitly guest-safe, but may not:

- move/store furniture;
- spend the owner's currency;
- change appearance/home style;
- remove inventory;
- change privacy;
- trigger owner-only progression.

## Trading

Trading is opt-in, two-party and server-owned.

v0.6.0 keeps public trading limited to low-value stackable items while the durable journal/recovery protocol is proven. Unique/high-value furniture or collectible-instance trading remains disabled until recovery evidence exists.

A trade must have:

- known participants;
- immutable agreed offer snapshot;
- offer version;
- fresh confirmation from both participants;
- server ownership re-check immediately before mutation;
- transaction ID and audit/recovery record;
- idempotent completion;
- timeout/cancel path.

Clients never submit a final inventory state.

## Text and communication

- Do not build custom unfiltered chat.
- Any player-authored name/text displayed to others must use Roblox text filtering appropriate to the surface.
- Do not log free-form player text in analytics/security diagnostics.
- Avoid designs that encourage moving conversation to private external channels.
- If future social text features expand, moderation/report/mute behaviour must be designed before implementation.

## Purchases

TinyWorld has no pay-to-win target state.

Before monetisation exists, a separate approved design must cover:

- child/family appropriateness;
- real Roblox product identifiers;
- receipt idempotency;
- retries/refunds;
- clear pricing;
- equivalent gameplay power for free players.

Do not add fake IDs or coercive purchase prompts.

## Personal data

Store only game state required to deliver the experience. Do not collect sensitive real-world information. Display names are game presentation, filtered before persistence, and are not evidence of a player's legal identity.

## Abuse boundaries

Every client-to-server mutation must enforce relevant combinations of:

- type/shape validation;
- size/range limits;
- allow-listed IDs;
- rate limit;
- distance/context check;
- ownership/permission check;
- server price/reward lookup;
- persistence/session safety.

Malformed or hostile client requests must not create currency, items, progression or arbitrary world state.

## Family playtest criteria

Before v1 launch, family/child observation must check:

- a child understands who owns a home;
- privacy/visit behaviour is predictable;
- trade confirmation is understandable;
- purchase-looking UI is not used for free interactions;
- menus do not pressure or shame players;
- reporting/muting routes are appropriate to any social features present;
- no essential feature requires off-platform communication.

Evidence belongs in the active release acceptance record.