# Shared brief — "R for data analysis: beginner level" rebuild (Master GPE, CERDI)

Project: `/Users/pierrebeaucoral/Documents/Pro/Cours GPE/r-for-beginners/`
Template to imitate (same author, already live): `/Users/pierrebeaucoral/Documents/Pro/ATER/Cours MACRO 1 AES/macro1-aes/`
(Quarto `type: website`, `output-dir: docs`, `freeze: auto`, CI to GitHub Pages).
Old course (content source, DO NOT modify): `/Users/pierrebeaucoral/Documents/Pro/Cours GPE/CoursR_reveal.qmd`
and `CoursR.Rmd`, `GPE_Graphiques.qmd` in the same folder.

## Audience and format
- Master GPE students (development economics), **complete R beginners**.
- **Language: ENGLISH** for the R course (as the original). Only `slides/atelier-dataviz.qmd` is in French (it was French originally).
- 6 sessions of 3 hours. One Quarto web page **per session**: `seances/seance-1.qmd` … `seance-6.qmd`.
- Direct tone, short sentences, no filler. Keep good explanations from the old course; fix what is wrong.

## Template for each session page
1. YAML: `title: "Session N: …"`, `subtitle:` (one line). Code is visible (the code IS the content: **never code-fold**).
2. Objectives box at the top:
   ```
   ::: {.objectifs}
   Session objectives
   - …
   :::
   ```
3. `##` sections, each with an indicative duration in its intro line (e.g. "≈ 30 min").
4. Exercises: `::: {.callout-tip}` titled `## Exercise N.k` (task), immediately followed by a **collapsed** solution:
   ````
   ::: {.callout-note collapse="true"}
   ## Solution
   ```{r}
   ...
   ```
   :::
   ````
5. End of page: `## Key takeaways` (5–7 bullets) + link to the next session.

## Data (already produced by `R/00_prepare_data.R`; NEVER call an API at render time)
Always read with `here::here("data", ...)`. Never `setwd()`, never absolute paths, never write into `data/`.
- `data/wdi_panel.csv` — country × year panel 2000–2023, ~217 countries. Columns:
  `country, iso3c, year, region, income, gdp` (current US$), `gdp_pc_ppp` (constant 2021 PPP $),
  `population, life_exp` (years), `gini` (0–100, many NAs), `elec_access` (% of population).
  `region` / `income` = World Bank categories.
- `data/wdi_3countries.csv` — `country, iso3c, year, gdp` for USA/CHN/IND 2000–2020 (WDI names: "United States", "China", "India").
- `data/wid_gini.csv` — `iso3c, country_wid, year, gini` (0–1), CHN/IND/USA, 21 years each. `country_wid` is "USA" where WDI says "United States": a **teaching example** of the join-on-names trap (join on `iso3c`, check with `anti_join`). The old course silently lost the US here — show that bug explicitly.
- `data/raw/WID_Data.csv` — malformed raw file (comment line, multi-line labels): example of a hard import (`read_delim(..., delim = ";", skip = 1, col_names = ...)`).
- `data/raw/SCIM.csv`, `data/raw/SCIM.xls` — OECD trade data (long format, FR/EN duplicated columns, `TIME` like "2022-Q2").
- Exercise outputs: into `output/` (create with `dir.create(here::here("output"), showWarnings = FALSE)`), or `#| eval: false` chunks.

## Running thread
One development question runs through the course: **"Growth, health and inequality: what do the data say about developing countries?"**
Sessions 1–2 start from 3 countries (USA, China, India), then switch to **all countries** (cross-section) as soon as we do statistics or charts. No `mtcars`.
Session 6 ends with the **figure for the "note au ministre"** (policy brief to a minister) that the French dataviz workshop prepares.

## Code rules (blocking)
- tidyverse, native pipe `|>`. `library()` calls at the top of the page.
- No deprecated/superseded functions: no `aes_string`, `top_n`, `geom_errorbarh`, `transmute`, `geom_bar(stat = "identity")` (→ `geom_col`), `size=` for lines (→ `linewidth`).
- Never name objects `sum`, `mean`, `summary`, `data`, or reuse `df` with two meanings.
- `set.seed()` once if anything random.
- **Zero warnings / messages shown** in the rendered page: fix the cause (`na.rm = TRUE`, `group =`, …); use `#| warning: false` only for an unavoidable, commented warning.
- Charts: shared theme `source(here::here("R", "theme_cours.R"))` (provides `theme_cours()` applied via `theme_set`, palettes `pal_cours` and `pal_regions`). Every figure: **title = the message**, axes with units, `caption` with the source ("Source: World Bank, WDI"), readable numbers (`scales::label_number`, `label_dollar`; never `1e+13`). Size via `#| fig-width: 8` `#| fig-height: 5`.
- Statistics: honesty. No implied causality. State limitations (pooling, non-independent observations, omitted variables).

## Mandatory checks before handing back
1. From the project root: `quarto render seances/seance-N.qmd` (or your file) → must succeed.
2. `grep -n "Warning\|Error" docs/seances/seance-N.html` → nothing unexpected.
3. Re-read your .qmd once, critically: any number quoted in the text must match the actual output.
4. Edit **only your files**; do not touch `_quarto.yml`, `theme.scss`, `R/`, `data/` (report needs in your reply).
5. Final reply: files written, render result, notable choices, remaining issues. Short.
