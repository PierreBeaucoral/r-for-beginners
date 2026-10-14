# Brief: skills for working independently (2026-10-14)

The course already covers the tools: projects, indexing, missing values, factors, joins, visualisation and reports. What's missing is the **habits that let a beginner work alone**. You add those to one session, in **EN and in its FR twin** (`*.fr.qmd`). Your prompt says which session and which items.

## House style (match the existing pages)

- **Section opener:**
  - a `## Heading` (with a `{#sec-...}` id if you add a top-level section);
  - then the goal box:
    ```
    ::: {.section-goal}
    [≈ N min]{.duration} After this section you can …
    :::
    ```
  - FR: `[≈ N min]{.duration} Après cette section, vous saurez …`
  - then short paragraphs.
- **Boxes:**
  - `::: {.callout-note}` with `## In plain words` / « En clair » for explanations;
  - `::: {.callout-important}` with `## Key idea` / « Idée clé »;
  - `::: {.callout-warning}` with `## Common mistake` / « Erreur fréquente »;
  - `::: {.callout-tip}` with `## Exercise N.x: …` / « Exercice N.x : … »;
  - `::: {.callout-note collapse="true"}` with `## Show solution` / « Afficher la solution ».
  - Look at an existing exercise in your session and copy its exact markup.
- **Bold** only on new key terms. Short sentences. Everyday examples drawn from the course data (WDI panel, the three countries US/China/India, GDP per capita).
- **Code that errors on purpose** needs `#| error: true`.
  - Warnings and messages are hidden site-wide (`warning: false`, `message: false`). A chunk that must SHOW a warning or message needs `#| warning: true` or `#| message: true`.
  - Console states that cannot run in a document, such as the `+` prompt, go in a plain fenced block (```` ``` ````) with no `{r}`. That block must be identical in EN and FR except for `#` comments.
- **Numbers:**
  - Never type a number you didn't compute. Run the code (`Rscript` from the project root, with `source("R/theme_cours.R")`) and paste what R prints.
  - In prose, use inline R with the helpers: `` `r nb(x, 1)` ``, `nb_dollar()`, `nb_pct()`.
- **Data:**
  - Real files only: `data/wdi_panel.csv`, `data/wdi_3countries.csv`, `data/raw/*`.
  - The messy exercise file is `data/raw/repair_me.csv`. Read `R/01_make_repair_file.R` for what it contains and why. Do not edit it.
  - Remember the course rule: CAF life expectancy is excluded (see the line used in sessions 3–6) wherever `life_exp` from `wdi_panel.csv` is summarised.
- **Pacing:**
  - Add the minutes of your new sections to the session's stated total, or say which existing part becomes "Optional: going further".
  - A beginner session should stay around 3 hours.
- **"Packages used today":** if you use a new package (e.g. `lubridate`, `stringr` — both in tidyverse), make sure it is loaded in the setup chunk of *both* languages.

## French twin rules (unchanged)

- Prose, R comments, chart and table labels are in French. R code, data values, column names and R messages stay English.
- Use « vous », French typography (« », space before `: ; ? !`, decimal comma in prose) and the glossary in `quality_reports/brief_fr_translation.md`.
- `python3 tools/check_fr_twin.py seances/seance-N.qmd` must print OK. Code must be identical apart from comments and display strings.

## Checks before you finish

1. Purl the page (`knitr::purl`) and run it top to bottom in a fresh R session, from the project root, for EN and for FR (`QUARTO_PROFILE=fr`). Only `error: true` chunks may fail.
2. Run the twin check.
3. Do **not** run `quarto render`, `tools/freeze.sh` or git. The orchestrator renders and freezes afterwards.

## Report

Reply in at most 12 lines:
- sections added, with their headings and minutes;
- exercises added;
- the check output;
- anything you could not do.
