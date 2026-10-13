# Brief — "less arid" pass (2026-10-13)

Read first: `quality_reports/brief_agents.md` (all code rules still apply) and the
shared conventions in `quality_reports/2026-10-13_review.md`. The user's request:
**"make it less arid: more viz, explanation boxes, bold stuff."** Content and
correctness stay; we add visual rhythm. A student skimming the page should see,
every screen or so, a figure, a diagram, a box or a bold key phrase — not a wall
of code + prose.

## Toolkit (use only these, consistently across sessions)

1. **Box vocabulary** (Quarto callouts; titles exactly as below):
   - `::: {.callout-important}` `## Key idea` — the one thing to remember from a section (1–3 sentences). About one per `##` section.
   - `::: {.callout-warning}` `## Common mistake` — a pitfall + how to spot/fix it.
   - `::: {.callout-note}` `## In plain words` — intuition for a concept (an analogy, no jargon).
   - `::: {.callout-note}` `## Why it matters for development economics` — link to a real development question (sparingly: 1–2 per page).
   - `::: {.callout-tip}` stays reserved for **exercises**; collapsed `.callout-note` for **solutions**. Don't change them.
   - Definitions: `::: {.definition}` div (already styled in theme.scss), starting with the term in bold: `**Tidy data**: …`.
   - Optional: `collapse="true"` on long "going further" boxes.
2. **Bold**: bold the key term at its first definition and the single most important clause of a paragraph. Max ~1–2 bold spans per paragraph; never whole sentences in a row. Bold renders in dark blue (theme.scss).
3. **Figures** (ggplot, via the shared theme; every one: title = the message, axes with units, caption per conventions, 8×5):
   - Sessions 1–3 have almost no charts. Add **3–5 figures each** that *show the result* of what was just computed (e.g. after `group_by() |> summarise()`, plot the summary; after a join, plot what the joined data reveals). When ggplot has not been taught yet, put the chart code in a **folded chunk** (`#| code-fold: true` + `#| code-summary: "Show the chart code (taught in Session 5)"`) — this is the ONLY allowed use of code-fold, because the R code the student must learn stays visible.
   - Sessions 4–6 already have charts: add a short `## Reading the chart`-style **"How to read this chart"** note (a `callout-note`, 2–4 bullets) after the 2–3 most important figures, and 1–2 new figures only where a concept is still taught by text alone.
4. **Diagrams**: Quarto renders mermaid natively (` ```{mermaid} `, theme already set). Use for concepts: workflow (script → console → environment), the pipe as a chain of steps, import → clean → analyse → report pipeline, joins (which rows survive), pivot wider/longer. Keep them small (≤ 8 nodes), left-to-right (`flowchart LR`). Side-by-side mini tables (`:::: {layout-ncol=2}`) are also good for before/after (pivot, join).
5. **Section openers**: start each `##` section with one bolded sentence saying what the student will be able to do after it (no new heading).

## Limits
- Do not shorten or remove existing content, exercises or solutions; do not change numbers in text unless an output changed (then re-check them: INV-11).
- No new packages beyond the course list (tidyverse, here, janitor, readxl, writexl, lubridate, scales, WDI, gt, fixest, modelsummary, ggrepel, sf, rnaturalearth, rnaturalearthdata, patchwork, plotly, crosstalk, shiny). Mermaid needs nothing.
- English (only `slides/` are French — not in scope).
- Data from `data/*.csv` via `here()`; CAR 2022 life_exp excluded in any life-expectancy chart (commented filter), as in S5/S6.
- Zero warnings/messages in the rendered page.

## Mandatory checks (from the project root)
Render with anaconda removed from PATH (its pandoc is broken):
`PATH=$(echo "$PATH" | tr ':' '\n' | grep -v anaconda3 | paste -sd: -) quarto render <your file>`
Then: `grep -n "## Warning\|## Error\|/Users/" docs/<your file>.html` → nothing. Look at **every new PNG** in `docs/<...>_files/figure-html/` with the Read tool (no clipped titles/legends, readable text). Check each mermaid block renders (it appears as `<pre class="mermaid` in the HTML; a syntax error shows as an error box in the browser — keep syntax simple: no parentheses or quotes inside node labels unless the label is wrapped in "double quotes").
Edit only your file(s). Final reply (short): counts added (figures / diagrams / boxes), render result, anything you could not do.
