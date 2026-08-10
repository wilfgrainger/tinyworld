from pathlib import Path

replacements = {
    "HOME GATE": "FRONT GATE",
    "HOME STYLE": "HOME LOOKS",
    "HOME SUPPLY": "HOME STORE",
    "DAILY FOUNTAIN": "VILLAGE FOUNTAIN",
    "VILLAGE FUND": "COMMUNITY POT",
    "PROFESSION BOARD": "VILLAGE JOBS",
    "Home Supply": "Home Store",
    "Village Fund": "Community Pot",
    "Profession Board": "Village Jobs",
}

changed = 0
for root_name in ("src/server", "src/client"):
    for path in Path(root_name).rglob("*.luau"):
        text = path.read_text(encoding="utf-8")
        updated = text
        for old, new in replacements.items():
            updated = updated.replace(old, new)
        if updated != text:
            path.write_text(updated, encoding="utf-8")
            changed += 1

print(f"runtime prototype-copy cleanup touched {changed} files")
