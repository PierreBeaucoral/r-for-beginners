"""Check that a French twin (X.fr.qmd) keeps the R code of its English source (X.qmd).

Usage: python3 tools/check_fr_twin.py seances/seance-1.qmd [...]
Compares, between X.qmd and X.fr.qmd: fenced blocks (R code minus comments, minus the
strings of display-label lines (labs, titles, captions...), minus the translatable
options fig-cap / fig-alt / code-summary; mermaid and {=html} skipped; others verbatim),
inline `r ...` expressions, {#sec-...} ids and the sequence of ::: div classes.
Prints OK or the first mismatches; exit code 1 on mismatch.
"""
import re
import sys
from pathlib import Path

TRANSLATABLE = re.compile(r"#\|\s*(fig-cap|fig-alt|code-summary)\s*:")
# Lines that only set text shown to the reader (chart and table labels): their string
# literals may be translated. Data values (filters, factor levels) are on other lines.
DISPLAY = re.compile(r"\b(labs|ggtitle|annotate|tab_header|tab_source_note|tab_footnote|cols_label|"
                     r"tab_spanner|title|subtitle|caption|x|y|colour|color|fill|size|tag|label|"
                     r"notes|name)\s*[=(]")
# Calls whose whole argument list is display text, even when it spans several lines
DISPLAY_CALL = re.compile(r"\b(labs|ggtitle|tab_header|tab_source_note|tab_footnote|cols_label|tab_spanner)\(|\bnotes\s*=\s*c\(")
# Labels that only rename things for display: the replacement of str_replace(pattern, "label")
# (the pattern itself stays checked) and the names of a list of models ("(1) All" = m1)
REPLACEMENT = re.compile(r'(str_replace\(\s*"(?:[^"\\]|\\.)*",\s*)"(?:[^"\\]|\\.)*"')
MODEL_NAME = re.compile(r'"(?:[^"\\]|\\.)*"(\s*=\s*m\w*\b)')
# Named label vectors (coef_rename = c("var" = "Label", ...)): the label is translatable, the name is not
NAMED_CALL = re.compile(r"\bcoef_(rename|map)\s*=\s*c\(")
NAMED_VALUE = re.compile(r'(=\s*)"(?:[^"\\]|\\.)*"')
STRING = re.compile(r'"(?:[^"\\]|\\.)*"|\'(?:[^\'\\]|\\.)*\'')


def strip_comment(line):
    """Remove an R comment from a code line, ignoring '#' inside quotes or backticks."""
    quote = None
    i = 0
    while i < len(line):
        c = line[i]
        if quote:
            if c == "\\":
                i += 1
            elif c == quote:
                quote = None
        elif c in "\"'`":
            quote = c
        elif c == "#":
            return line[:i].rstrip()
        i += 1
    return line.rstrip()


def parse(path):
    """Return (blocks, prose) where blocks = [(info, normalised lines)]."""
    blocks, prose, cur, fence, info = [], [], None, None, None
    for line in Path(path).read_text(encoding="utf-8").splitlines():
        if cur is None:
            m = re.match(r"^(`{3,})(.*)$", line)
            if m:
                fence, info, cur = m.group(1), m.group(2).strip(), []
            else:
                prose.append(line)
            continue
        if re.match(rf"^{fence}`*\s*$", line):
            blocks.append((info, cur))
            cur = None
            continue
        cur.append(line)
    out = []
    for info, lines in blocks:
        if info in ("{mermaid}", "{=html}"):  # prose inside: translated
            out.append((info, []))
            continue
        if info in ("{r}", "r", "{webr}"):
            norm, skipping, depth, ndepth = [], False, 0, 0
            for ln in lines:
                if ln.startswith("#|"):
                    if TRANSLATABLE.match(ln):
                        skipping = True
                        continue
                    if skipping and re.match(r"#\|\s{2,}", ln):
                        continue
                    skipping = False
                    norm.append(ln.rstrip())
                    continue
                skipping = False
                s = strip_comment(ln)
                s = REPLACEMENT.sub(r'\1"…"', s)
                lab = re.search(r"\blabels\s*=\s*c\(", s)   # legend labels: c(value = "Label")
                if lab:
                    s = s[:lab.end()] + NAMED_VALUE.sub(r'\1"…"', s[lab.end():])
                nstart = NAMED_CALL.search(s)
                if ndepth > 0 or nstart:
                    seg = s[nstart.end():] if nstart and ndepth == 0 else s
                    head = s[:len(s) - len(seg)]
                    s = head + NAMED_VALUE.sub(r'\1"…"', seg)
                    plain = STRING.sub('""', seg)
                    ndepth = max(0, (ndepth or 1) + plain.count("(") - plain.count(")"))
                s = MODEL_NAME.sub(r'"…"\1', s)
                masked = STRING.sub('""', s)          # parens inside strings don't count
                start = DISPLAY_CALL.search(s)
                if depth > 0 or DISPLAY.search(s) or start:
                    s = STRING.sub('"…"', s)
                if depth > 0:
                    depth = max(0, depth + masked.count("(") - masked.count(")"))
                elif start:
                    tail = STRING.sub('""', s[start.start():])
                    depth = max(0, tail.count("(") - tail.count(")"))
                if s:
                    norm.append(s)
            out.append((info, norm))
        elif info == "":   # plain blocks (folder trees): structure verbatim, # comments translatable
            out.append((info, [strip_comment(ln) for ln in lines]))
        else:
            out.append((info, [ln.rstrip() for ln in lines]))
    return out, "\n".join(prose)


def check(en_path):
    """Compare one English file with its .fr.qmd twin; return a list of problems."""
    fr_path = Path(str(en_path)[: -len(".qmd")] + ".fr.qmd")
    if not fr_path.exists():
        return [f"missing {fr_path}"]
    (eb, ep), (fb, fp) = parse(en_path), parse(fr_path)
    probs = []
    if len(eb) != len(fb):
        probs.append(f"fenced blocks: {len(eb)} EN vs {len(fb)} FR")
    for k, ((ei, el), (fi, fl)) in enumerate(zip(eb, fb)):
        if ei != fi:
            probs.append(f"block {k}: header {ei!r} vs {fi!r}")
        elif el != fl:
            diff = next((a, b) for a, b in zip(el + ["<end>"], fl + ["<end>"]) if a != b)
            probs.append(f"block {k} ({ei}): EN {diff[0]!r} | FR {diff[1]!r}")
    for name, pat in [("inline r", r"`r [^`]+`"), ("section ids", r"\{#sec-[^}\s]+"),
                      ("divs", r"(?m)^:::+\s*\{[^}]*\}")]:
        a, b = re.findall(pat, ep), re.findall(pat, fp)
        if a != b:
            probs.append(f"{name} differ: EN-only {sorted(set(a) - set(b))[:5]} "
                         f"FR-only {sorted(set(b) - set(a))[:5]} (counts {len(a)}/{len(b)})")
    return probs


if __name__ == "__main__":
    bad = False
    for f in sys.argv[1:]:
        probs = check(f)
        bad |= bool(probs)
        print(f"{f}: " + ("OK" if not probs else "\n  " + "\n  ".join(probs[:15])))
    sys.exit(1 if bad else 0)
