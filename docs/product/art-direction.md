# Art direction

## Target

TinyWorld uses a warm, storybook-like Roblox-native style: simple shapes, readable proportions, tactile materials, soft colour families, and enough asymmetry to feel authored. v0.5.2 uses native parts because no approved mesh bundle exists; native construction is a production fallback, not permission to use anonymous interaction boxes.

## Recognizable-object contract

A key player-facing object must remain recognizable when its label is hidden. It passes only when all four dimensions are present:

- **Silhouette:** the outline communicates the object's category and purpose.
- **Scale:** proportions make sense beside an avatar and nearby architecture.
- **Material:** colour and surface treatment support the identity rather than acting as arbitrary coding.
- **Feedback:** prompts, motion, light, sound, or state changes acknowledge interaction.

Labels supplement these dimensions; they never substitute for them.

## Composition and palette

- Use warm neutrals for buildings, greens and earth tones for landscape, and restrained accent colours for destinations.
- Reserve glow and saturation for wonder, selected state, and short-lived feedback.
- Prefer roofs, awnings, windows, steps, shelves, tools, planting, and local clutter over flat signs.
- Maintain landmark visibility above residential rooflines and create clear paths between destinations.
- Use seeded, bounded variants. Unseeded randomness is not allowed in authored world placement.

## Physical safety

Decoration parts are anchored, non-collidable, non-touching, and non-queryable. Only explicit interaction anchors are queryable. Stable ground and plot surfaces remain the collision foundation.

## Replacement boundary

Every authored model carries a named art role and physical-affordance contract. Future approved meshes may replace a model behind the prefab boundary without changing service ownership or gameplay wiring.

## v0.5.2 premium-feel quality gate

“Premium” means observable craft here; it is not monetisation, paid access, or a new gameplay system. The release passes only when every check below passes:

- **Authored silhouettes — Pass:** homes, civic destinations, bike, boat, and touched objects communicate their category from shape with labels hidden. **Fail:** a sign or colour is needed to explain a generic block.
- **Quality materials — Pass:** wood, brick, slate, glass, fabric, metal, water, and foliage are used where their physical qualities support the object. **Fail:** arbitrary colour coding or anonymous SmoothPlastic dominates a primary object.
- **Composed lighting — Pass:** daylight, shadow, restrained glow, warm windows, and readable contrast guide the eye without washing out silhouettes. **Fail:** uniform flat light or saturated neon carries the composition.
- **Tactile feedback — Pass:** an interaction acknowledges input with bounded motion, light, object state, sound, or a short toast. **Fail:** only text or a database value changes.
- **Restrained UI — Pass:** normal play contains the compact HUD, contextual prompts, and short-lived feedback. **Fail:** telemetry walls or raw replicated state occupy the play view.
- **No arbitrary coloured cubes — Pass:** every player-facing part has a recognizable art or physical-affordance role. **Fail:** a coloured cube exists only to encode a verb or destination.
- **Labels-off child-recognition test — Pass:** the exact release route records an uncoached child recognizing the required objects and destinations. **Fail:** any required category depends on labels, telemetry, or coaching.
