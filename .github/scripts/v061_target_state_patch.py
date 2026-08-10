from __future__ import annotations

from pathlib import Path

path = Path("docs/product/target-state-v1.md")
text = path.read_text(encoding="utf-8")


def replace_once(old: str, new: str, name: str) -> None:
    global text
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"{name}: expected one match, found {count}")
    text = text.replace(old, new, 1)


def replace_first(old: str, new: str, name: str) -> None:
    global text
    count = text.count(old)
    if count < 1:
        raise SystemExit(f"{name}: expected at least one match, found 0")
    text = text.replace(old, new, 1)


replace_once(
    "**Baseline inherited:** v0.5.3 Production Engineering Foundation and v0.5.2 Village Soul product/presentation acceptance",
    "**Baseline inherited:** v0.6.0 Target-State Consolidation, with v0.6.1 Visual Rescue as the active corrective presentation layer",
    "baseline",
)
replace_once(
    "The target is **not** a rewrite. TinyWorld should preserve its current server-authoritative architecture, deterministic shared rules, leased ProfileStore, prefab and interaction-anchor boundaries, release-evidence discipline, deterministic sixteen-home village, recognizable-object visual contract, compact HUD, and credential-free Rojo build foundation.\n\nThe next phase must deepen the game rather than replace the engineering model.",
    "The target is **not** a rewrite. TinyWorld should preserve its current server-authoritative architecture, deterministic shared rules, leased ProfileStore, prefab and interaction-anchor boundaries, release-evidence discipline, deterministic sixteen-home village, recognisable-object visual contract, compact HUD, and credential-free Rojo build foundation.\n\nv0.6.1 adds a corrective visual rule to that foundation: ordinary village life must be readable from physical form and context, hero presentation must not degrade into primitive fallback geometry, and required player-facing visual evidence must be observed before a visual release becomes merge-ready.\n\nThe next phase must deepen the game rather than replace the engineering model.",
    "purpose visual correction",
)
replace_once(
    "- no pay-to-win;\n- no anonymous interaction geometry;\n- no essential feature that exists only as menu text.",
    "- no pay-to-win;\n- no anonymous interaction geometry;\n- no primitive avatar add-on used merely because approved character art is absent;\n- no ordinary village destination whose primary identity is a floating information wall;\n- no essential feature that exists only as menu text.",
    "v1 non-negotiables",
)
replace_once(
    "Keep the current philosophy: compact HUD, journal, contextual prompts, and short toasts.\n\nThe Journal should become the intentional deep-information surface rather than expanding the permanent HUD.",
    "Keep the current philosophy: compact HUD, journal, contextual prompts, and short toasts. The 3D world remains the primary information surface.\n\nDo not use a full-width website-style navigation/header or permanent system-dashboard panel in ordinary play. Home, Wardrobe, Journal and other deep surfaces should open intentionally through one coherent compact navigation surface and one modal owner.\n\nThe Journal should become the intentional deep-information surface rather than expanding the permanent HUD.",
    "UI target",
)
replace_once(
    "Use Roblox-safe asset ownership and moderation rules. Do not create a paid identity tax.",
    "Use Roblox-safe asset ownership and moderation rules. Do not create a paid identity tax. When no approved TinyWorld character asset exists, preserve the player's normal Roblox avatar rather than bolting primitive Part hair or shoes onto it. Saved preferences may remain future-facing without forcing visibly inferior geometry.",
    "character target",
)
replace_once(
    "Native-part authored prefabs remain a valid fallback and prototyping tool, but production art should progressively move toward:\n\n- stylised authored meshes for hero objects;\n- richer furniture silhouettes;\n- original props;\n- animation where it adds tactile quality;\n- restrained VFX;\n- positional sound;\n- small ambient motion.\n\nDo not turn everything into Neon.",
    "Native-part authored prefabs remain a valid production medium and prototyping tool only when the resulting object meets its visual tier. Hero content includes player character presentation, starter home, civic destinations, primary vehicles and portal landmarks. A hero fallback that still reads as anonymous placeholder geometry fails even if semantic metadata calls it authored.\n\nWhen an approved asset is unavailable, preserving a coherent Roblox-native/default presentation is better than inventing a visibly inferior fallback.\n\nProduction art should progressively move toward:\n\n- stylised authored meshes or convincing native-part compositions for hero objects;\n- richer furniture silhouettes;\n- original props;\n- animation where it adds tactile quality;\n- restrained VFX;\n- positional sound;\n- small ambient motion.\n\nLarge always-on-top information walls are not an art fallback. Proper names may use small physical signs; actions remain contextual.\n\nDo not turn everything into Neon.",
    "visual asset target",
)
replace_once(
    "TinyWorld may borrow broad design qualities such as warmth, readability, tactile play, and adventurous contrast. It must not reproduce identifiable characters, locations, props, logos, UI layouts, names, or distinctive visual expression from another game or film.",
    "TinyWorld may borrow broad design qualities such as Roblox life-sandbox readability, tactile warmth, and adventurous contrast. Team shorthand is Brookhaven-level readability + Toca-style tactile warmth + Ready Player One-style wonder. Those are design-principle references only; TinyWorld must not reproduce identifiable characters, locations, buildings, props, logos, UI layouts, names, or distinctive visual expression from another game or film.",
    "visual inspiration",
)
replace_once(
    "| **v0.6.0** | Home Life Foundation | Home becomes a real sandbox with a scalable item/furniture model and placement |\n| **v0.7.0** | Village Life | Shops, careers, routines, and shared village activities become satisfying |",
    "| **v0.6.0** | Target-State Consolidation | Merged scalable home/content/data/security/UI/world foundation |\n| **v0.6.1** | Visual Rescue | Remove prototype presentation, establish world-first visual language, and prove one golden ordinary-life route |\n| **v0.7.0** | Village Life | Shops, careers, routines, and shared village activities become satisfying on the v0.6.1 visual baseline |",
    "release train",
)
replace_once(
    "commit\n  -> CI tests\n  -> Rojo artifact\n  -> release manifest + SHA\n  -> publish exact artifact to DEV\n  -> runtime/device evidence\n  -> explicit human approval\n  -> promote exact approved artifact to LIVE",
    "commit\n  -> CI tests\n  -> Rojo artifact\n  -> release manifest + SHA\n  -> required Studio/device visual evidence for player-facing changes\n  -> publish exact artifact to DEV when configured/approved\n  -> published runtime/multiplayer/device evidence\n  -> explicit human approval\n  -> promote exact approved artifact to LIVE",
    "release process",
)
replace_first(
    "The game should look intentional even when every label is hidden.",
    "The game should look intentional even when explanatory labels are hidden. For player-facing visual releases from v0.6.1 onward, required Studio/device visual rows may be NOT RUN while a PR is draft but block merge-ready status until observed.",
    "evidence rule",
)
replace_once(
    "- not a clone of Toca Boca, Ready Player One, Disney Dreamlight Valley, or another existing IP.",
    "- not a clone of Brookhaven, Toca Boca, Ready Player One, Disney Dreamlight Valley, or another existing IP.",
    "anti-goal inspiration",
)
replace_once(
    "- use labels to explain unclear 3D objects;\n- use anonymous neon rings or cubes as finished content;\n- conflate successful CI with a good Roblox experience.",
    "- use labels to explain unclear 3D objects;\n- use large always-on-top ordinary-world information walls as a substitute for visual design;\n- attach primitive block hair or shoes to the player merely to demonstrate character customisation;\n- use anonymous neon rings, spheres or cubes as finished content;\n- conflate successful CI with a good Roblox experience.",
    "anti-goal mechanisms",
)
replace_once("## Codex execution contract", "## Implementation-agent execution contract", "execution heading")
replace_once("A Codex implementation must:", "An implementation agent must:", "execution actor")
replace_once(
    "The repository should let a fresh Codex understand exactly what to build without reconstructing the product vision from historical chats.",
    "The repository should let a fresh authorised implementation agent understand exactly what to build without reconstructing the product vision from historical chats.",
    "definition actor",
)

path.write_text(text, encoding="utf-8")
print("target-state visual rescue patch applied")
