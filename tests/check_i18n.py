#!/usr/bin/env python3
"""Static checks for contents/code/i18n.mjs:
- every key used via tr("...") in the code exists,
- every entry has a German and an English text,
- both texts use the same placeholders (%1, %2, ...).
"""
import pathlib
import re
import sys

root = pathlib.Path(__file__).resolve().parent.parent
source = (root / "contents/code/i18n.mjs").read_text(encoding="utf-8")

entries = {}
for m in re.finditer(r'^\s*"([\w.]+)":\s*\[(.*?)\],?\s*$', source, re.M | re.S):
    texts = re.findall(r'"((?:[^"\\]|\\.)*)"', m.group(2))
    entries[m.group(1)] = texts

failures = []
for key, texts in entries.items():
    joined = [t for t in texts]
    if len(joined) < 2:
        failures.append(f"{key}: expected German and English text")
        continue
    # multi-line entries are concatenated strings; compare placeholders over all parts
    half = len(joined) // 2
    de, en = "".join(joined[:half]), "".join(joined[half:])
    if sorted(set(re.findall(r"%\d", de))) != sorted(set(re.findall(r"%\d", en))):
        failures.append(f"{key}: placeholders differ between German and English")

used = set()
for path in (root / "contents").rglob("*"):
    if path.suffix not in (".qml", ".mjs") or "lib" in path.parts:
        continue
    text = path.read_text(encoding="utf-8")
    used |= set(re.findall(r'\btr\(\s*"([\w.]+)"', text))
    used |= set(re.findall(r'I18n\.tr\([^,]+,\s*"([\w.]+)"', text))

for key in sorted(used - set(entries)):
    failures.append(f"{key}: used in the code but missing in i18n.mjs")

for f in failures:
    print("FAIL " + f)
print(f"{'FAIL' if failures else 'PASS'} i18n: {len(entries)} entries, {len(used)} keys used")
sys.exit(1 if failures else 0)
