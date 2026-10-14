# Brief: French chart labels + alt text (2026-10-14)

Read `quality_reports/brief_fr_translation.md` first: its style, glossary and typography rules still apply.
You own the EN and FR files of one page and touch nothing else. No rendering, no git.

## Task A: alt text, in both languages

Add a `#| fig-alt:` option to **every chunk that draws a static figure**: ggplot, base plot, map or patchwork.
- Put it right after the `#| label:` line. If the chunk has no label, put it on the first line.
- Skip plotly or htmlwidget chunks, chunks with `eval: false`, and chunks that print only tables or text.

How to write it:
- Write 1 to 2 sentences: what is plotted (axes or encodings), then the main pattern a sighted reader sees.
- Base the pattern on the code, the caption and the surrounding prose. Never invent numbers. Use a number only if the prose or the caption already states it.
- Keep it under about 250 characters. Use straight double quotes around the value, and escape any inner quotes as `\"`.

Put the English alt text in `X.qmd` and the French alt text in `X.fr.qmd`, at the same chunks.

## Task B: French text inside the charts and tables (FR file only)

In `X.fr.qmd`, translate the **display strings** in chart and table code, i.e. the string literals on lines like these:
- `labs(...)` arguments: `title`, `subtitle`, `x`, `y`, `caption`, `colour`/`color`, `fill`, `size`, `tag`
- `ggtitle()` and `annotate(..., label = "...")`
- `gt` functions: `tab_header()`, `tab_source_note()`, `tab_footnote()`, `cols_label()`, `tab_spanner()`
- modelsummary `title =` and `notes =`

Rules:
- **Never** translate data values: filter strings (`"Sub-Saharan Africa"`), factor levels, `labels = c(...)` vectors, column names, file paths, `iso3c` codes.
- Write numbers inside display strings the French way, e.g. "en $ PPA constants de 2021".
- If the French prose quotes an English label you have just translated (e.g. « Log GDP per capita »), update the prose to match.
- Run `python3 tools/check_fr_twin.py X.qmd`. It masks strings **only** on lines it recognises as display lines.
  - If a translation makes it fail, that string sits on a line the checker treats as code. Revert that one string to English. Do **not** move code around to get past the checker.
  - The check must end with `OK`.

## Report

Reply in at most 8 lines:
- the number of fig-alt lines added in EN and in FR (they must be equal);
- the number of display strings translated;
- the check output;
- anything you were unsure about.
