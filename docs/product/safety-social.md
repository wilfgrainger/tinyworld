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

Current public trading remains limited to low-value stackable items while the durable journal/recovery protocol is proved in runtime/multiplayer evidence. Unique/high-value furniture or collectible-instance trading remains disabled until that gate passes.

A trade must have:

- known participants;
- immutable agreed offer snapshot;
- offer version;
- fresh confirmation from both participants;
- server ownership re-check immediately before mutation;
- participant inventory mutation isolation during commit/recovery;
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

## World text and child comprehension

v0.6.1 strengthens the distinction between helpful text and visual overload:

- contextual prompts are allowed and encouraged when the player is close enough to act;
- proper names may appear on small physical signs/boards;
- large always-on-top information walls are not a child-safety/accessibility substitute for recognisable places/objects;
- dense instructions belong in intentional panels rather than floating through the play space.

Family playtests should observe whether reducing persistent labels improves or harms comprehension rather than assuming more text is automatically safer.

## Character identity

Meaningful free identity remains a product/safety requirement.

When no approved TinyWorld character asset exists, preserve the player's normal Roblox avatar rather than attaching visually inferior primitive hair/shoe geometry. Saved TinyWorld style preferences may remain server-authoritative without forcing a low-quality rendered fallback.

No paid identity requirement is introduced.

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

Before v1 launch, and when the active release requires it, family/child observation checks:

- a child understands who owns a home;
- privacy/visit behaviour is predictable;
- trade confirmation is understandable;
- purchase-looking UI is not used for free interactions;
- menus do not pressure or shame players;
- reducing floating labels does not make ordinary destinations incomprehensible;
- hero places/objects are understandable from shape/context;
- character presentation feels coherent rather than visibly broken;
- reporting/muting routes are appropriate to any social features present;
- no essential feature requires off-platform communication.

Evidence belongs in the active release acceptance record.