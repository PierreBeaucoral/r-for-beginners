"""Fail if a page with R code has no up-to-date frozen results (run in CI before rendering).

CI must not execute the course's R code: reading the .xls file with readxl
crashes R on the Linux runner, and frozen results keep deploys fast. Quarto
stores the MD5 of each page's source in _freeze/<page>/execute-results/html.json;
a mismatch means the page changed after the last `tools/freeze.sh`.
French pages are frozen under <page>.fr/ and must link figures as <page>_files.

Usage: python3 tools/check_freeze.py   (exit 1 with the list of stale pages)
"""
import hashlib
import json
import re
import sys
from pathlib import Path

root = Path(__file__).resolve().parent.parent
problems = []
for qmd in sorted(root.glob("**/*.qmd")):
    rel = qmd.relative_to(root)
    if rel.parts[0] in ("docs", "_extensions", "_freeze") or rel.name.startswith("_"):
        continue
    if not re.search(r"(?m)^```\{r\}", qmd.read_text(encoding="utf-8")):
        continue                                   # no R code: nothing to freeze
    stem = str(rel.with_suffix(""))                # seances/seance-2.fr
    freeze = root / "_freeze" / stem / "execute-results" / "html.json"
    if not freeze.exists():
        problems.append(f"{rel}: no frozen results")
        continue
    data = json.loads(freeze.read_text(encoding="utf-8"))
    if data.get("hash") != hashlib.md5(qmd.read_bytes()).hexdigest():
        problems.append(f"{rel}: changed since it was frozen")
    if stem.endswith(".fr") and f"{Path(stem).name}_files" in json.dumps(data):
        problems.append(f"{rel}: figure links still point to {Path(stem).name}_files")

if problems:
    print("Frozen results are missing or stale. Run tools/freeze.sh and commit _freeze/:")
    print("\n".join(f"  - {p}" for p in problems))
    sys.exit(1)
print("Freeze OK: every page with R code has up-to-date frozen results.")
