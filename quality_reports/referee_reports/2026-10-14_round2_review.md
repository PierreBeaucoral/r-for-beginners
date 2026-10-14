# Round-2 referee review: r-for-beginners (EN/FR), 2026-10-14

Independent second-round review. I only read and ran things; no project file was modified (this report is the only file created).

**Scope**
- Live site at commit `947e13f`, deployed by the CI run of 12:32 UTC (checked with `gh run list`).
- All 18 EN/FR pages, plus the deck, fetched with curl and converted to text.
- Sources: `seances/*.qmd`, `R/theme_cours.R`, `theme.scss`, `assets/course-ui.html`.
- Data: `data/wdi_panel.csv` and `data/wid_gini.csv`, recomputed in R with CAF `life_exp` set to NA in every year.
- Browser checks: Playwright/Chromium at 1366 px and 375 px, plus print media (A4 PDF).

**Scripts**
- All 12 downloadable scripts (`/scripts/seance-1..6.R` and `/fr/scripts/seance-1..6.R`) were run in fresh scratch projects, with live `data.zip` unzipped and a `.here` marker.
- Each script was run expression by expression, auto-printing like `Rscript`.
- Sessions 2 and 4 (EN and FR) were also run plainly with `Rscript seance-N.R`.
- Result: **12/12 run top to bottom with 0 errors.** The S1 error demos are now wrapped in `try()`. S2 writes all 7 expected files to `output/`.

## Scores

| Dimension | Round 1 | Round 2 | Gate |
|---|---|---|---|
| Content (le fond) | 74 | **86** | Commit (≥ 80), not yet share (≥ 90) |
| Design / UX | 70 | **84** | Commit (≥ 80), not yet share (≥ 90) |

**Content rationale.**
- Every round-1 Critical and Major content finding is fixed in substance.
- I recomputed every number added or changed by the fixes, and all of them match the data:
  - S6: 2.8 / 11.1-year gains, 0.9 / 1.45-year COVID dips, world mean 72.9 → 71.2 → 73.3;
  - S5: Bangladesh +12.6, Sub-Saharan Africa median +11.9, North America / South Asia = 6.7×, 25 low-income countries, medians $2,459 / $49,117, 30 → 3 countries below 55 years, 20 of 22 below 50% electricity, 9.0-year gap in Ex 5.6;
  - S2/S3: WID India overtakes the USA in 2007; WDI Gini India 23.0 vs USA 41.8 (2023); top-10 composition.
- EN and FR numbers agree on every page (multiset comparison of all prose and alt-text numbers).
- The score is held back by:
  - a new **rendering bug that garbles two French sentences** (`nb_dollar()` makes Pandoc read "$ … $" as math);
  - **truncated French figure titles**, including the two figures rebuilt for round-1 C1 and C2;
  - the S4 CAF series being printed **truncated**, so the values the prose quotes are not on screen.

**Design rationale.**
- Phone clipping of tables, code and URLs is gone (0 clipped elements on S1, S6, resources and FR S3 at 375 px).
- Print no longer prefixes code with URLs and uses the full page width.
- Deck fonts load, Google Fonts is gone, and there is a skip link and a mobile TOC.
- Highlighter, left-rule, gt and ggplot styling now follow one system.
- Held back by:
  - the clipped French figures (a ggplot sizing problem that the French text exposes);
  - plotly's y-axis title now cut off;
  - display math still clipped on phones;
  - print still showing "Show solution" buttons.

Counts of new findings: **Critical 0, Major 3, Minor 12.**

---

## 1. Verification of round-1 findings

### Content report (round 1 scored 74)

| ID | Round-1 finding | Status | Evidence (live site / source) |
|---|---|---|---|
| C1 | S4 boxplot "less dispersion among richer" | **FIXED** (EN) / see N2 (FR) | Title: "the spread is similar across groups". The reading box computes IQRs inline (7.8 vs 5.0-6.0), matching `by_inc`. Alt text matches. The FR title is clipped in the PNG (N2). |
| C2 | S6 free-scales title opposite of chart | **FIXED** (EN) / see N2 (FR) | Title and alt: "North America's 3-year gain looks as large as Africa's 11-year gain". Recomputed gains: 2.76 and 11.1. Prose dips of 0.89 (NA) and 1.45 (ECA) are correct. The FR title is clipped (N2). |
| M1 | `caption = src` | **FIXED** | `seance-5.qmd:180` has a literal source caption. No `src` is left. |
| M2 | `identical()` prints FALSE | **FIXED** | `all.equal(wid_gini, wid_back)  # TRUE…` renders `[1] TRUE`. |
| M3 | CAF clean-up incomplete | **FIXED** | One identical `mutate(... NA_real_)` line in S3, S4, S5, S6 and on the index, plus prose in S4:80 and S5:63. The S6 trends now exclude CAF in every year. |
| M4 | S6 report template reintroduces CAF | **FIXED** | `seance-6.qmd:893-894` adds the exclusion line in the template. |
| M5 | S2 WID alt text and imputation | **FIXED** | The alt text says India overtakes the USA in 2007 (verified: 0.576 vs 0.564). New paragraph on the interpolated India series and the US 2020 jump. |
| M6 | Two Gini measures never reconciled | **FIXED** | Callout "Two Ginis that are not comparable" in S3. The S4 "Measurement and selection" bullet now mentions consumption- vs income-based surveys. Numbers verified. |
| M7 | Ex 5.3 "mostly Europe and the Gulf" | **FIXED** | "Nine of the ten richest countries are small economies or financial centres; the United States is the exception". Top 10 verified. |
| M8 | Income groups labelled as historical | **FIXED** | "(current World Bank classification)" in S3, S4, S5 and S6 text, axes and captions. "By construction" removed. S5:588 states the overlap with inline numbers. *Side-effect:* two EN figures are now clipped (N10). |
| M9 | SCIM `value` mixes units | **FIXED** | "This summary is meaningless…", `unit_code`/`frequency` kept, `count(measure, unit_code, frequency)` shown. 1,167,777 matches the output. |
| M10 | FR comments in English | **FIXED** | Every comment in the 6 FR scripts is French. Only the commented-out Shiny UI strings remain English (N12). |
| M11 | FR numbers in English format | **PARTLY (REGRESSED in 2 places)** | `nb()` / `nb_pct()` give "0,86", "31 %", "5,65" correctly. But `nb_dollar()` in FR produces "26 480 $ … 16 895 $", which Pandoc turns into **inline math** (N1). The modelsummary/tinytable regression table in FR S4 still prints "0.734", "(2.146)". |
| M12 | FR SD/SE merged; grammar | **FIXED** | "erreur-type" for SE throughout, with an explicit SD/SE definition at `seance-4.fr.qmd:469`. "dont toute explication doit rendre compte" and "63 pays-années issus" are corrected. No "quelles que soient". |
| M13 | S5 pacing | **FIXED** | Sections sum to 180 min, "exercises included". The Ex 5.5 annotation and Ex 5.6 are marked "Optional: going further". `map_int` is replaced by three `length(unmatched())` lines. |

### Design report (round 1 scored 70)

| ID | Round-1 finding | Status | Evidence |
|---|---|---|---|
| C1 | Tables, code and URLs clipped at 375 px | **FIXED** (residual: display math, N8) | 0 clipped elements on index, resources, S1, S6 and FR S3. The gt and tinytable tables scroll. `document.scrollWidth` = 375. Display equations in S4 are still cut (N8). |
| C2 | Printed code lines prefixed by URLs | **FIXED** | Print media: 0 of 294 `pre a[href^=http]` have `::after` content. The A4 PDF of FR S4 shows clean code. |
| M1 | Deck fonts 404 | **FIXED** | No 4xx responses. Newsreader and IBM Plex Sans report `loaded`. |
| M2 | Title slide alignment | **FIXED** | Title, subtitle and author are all `text-align:left`, `justify-content:flex-start`. |
| M3 | Images without alt | **FIXED** | 0 `<img>` without alt on the pages checked. All 4 deck images have French alt text. The S1 RStudio screenshot has `fig-alt`. |
| M4 | Highlighter by rule | **FIXED** | Opt-in only (`.definition` first term, `mark`). S1 has 3 highlighted terms (Function, Vector, Data frame); the index has 0 of 19 `strong`. |
| M5 | Code smaller than prose | **FIXED** (acceptable) | Code is 16.6 px and solutions 16.0 px, against 20.9 px prose (0.80× / 0.76×, was 0.75× / 0.68×). The compounding is gone. |
| M6 | No TOC below 768 px | **FIXED** | `details.toc-mobile` is shown at 375 px, labelled "On this page" / "Sur cette page". |
| M7 | Print: wasted column, folded code, toggle label | **PARTLY** | The column is fixed (main = 100% width) and a `details` rule plus a `beforeprint` handler were added. But each solution still prints a "Show solution" / "Afficher la solution" heading (N9). |
| M8 | Mermaid chain | **FIXED** | Replaced by `<ol class="chain" aria-label=…>`. No mermaid.js is loaded on the index. |
| M9 | Plotly legend over the x title | **PARTLY** | The overlap is gone. But `margin = list(b = 120)` plus the 4-row legend squash the panel to about 170 px, and the y-axis title is cut off at the top ("Life expectancy at birth (year") (N4). |
| M10 | Google Fonts request | **FIXED** | `$web-font-path: false`. No googleapis requests. (New third-party script, see N6.) |
| M11 | No skip link | **FIXED** | `.skip-link` is the first body element: "Skip to content" / "Aller au contenu". |
| M12 | R output off-system | **PARTLY** | gt tables inherit font and colour with a transparent background. ggplot PNGs have a `#fcfaf6` paper background. The plotly plot area is still white with the default font (N4). |
| M13 | Left rule overused | **FIXED** | `.section-goal` and `.cell-output pre` have no left border. `.objectifs` radius is 0, and its inline code chip is now distinct (`#ede9e1` on `#f5f2ec`). |

Round-1 minors were not all re-audited. Those I saw:
- **Fixed:** S1 scripts no longer stop; "1 = one person receives all income"; `year` cast in the Ex 3.4 solution; "codes are far more stable"; Ex 4.4 same-sample comparison; the duplicate S6 heading is gone; COVID gender is unified ("la COVID-19"); "note de source" replaces "légende"; the open-toggle opacity is now 1.
- **Still open:** the homepage `<title>` repeats itself ("R for data analysis – R for data analysis: beginner level"); the French deck's `<title>` starts with the English site name; the language switch is still a one-item dropdown with absolute URLs.

---

## 2. New findings (introduced by, or exposed by, the fixes)

### MAJOR

#### N1. FR `nb_dollar()` produces "$…$", which Pandoc renders as math: two French sentences are garbled
- **Where:**
  - `R/theme_cours.R:71-73` (`paste0(nb(x, digits), " $")`);
  - used at `seances/seance-4.fr.qmd:145` and `seances/seance-5.fr.qmd:588`.
- **Evidence.**
  - Live HTML: `la moyenne (26 480 <span class="math inline">\() est bien supérieure à la médiane (16 895 \)</span>)`.
  - MathJax renders it as "(26 480 )𝑒𝑠𝑡𝑏𝑖𝑒𝑛𝑠𝑢𝑝é𝑟𝑖𝑒𝑢𝑟𝑒à𝑙𝑎𝑚é𝑑𝑖𝑎𝑛𝑒(16 895)": both dollar signs vanish and the words run together in math italics (screenshot `scratchpad/fr-s4-dollar-math.png`).
  - At 375 px the math span is 750 px wide and is clipped mid-sentence.
  - Same bug in FR S5: "Le pays à faible revenu le plus riche (4 579 $) est plus riche que … (3 816 $)".
  - The EN pages are unaffected: there "$" comes before the digits.
- **Why it matters:**
  - It is the sentence that teaches "mean > median, so right-skewed". It sits on the page that was fixed for number formatting.
  - Any future FR sentence with two `nb_dollar()` calls will break the same way.
- **Fix:** escape the sign in the FR branch: `paste0(nb(x, digits), " \\$")`. Inline R output is re-read as Markdown, so `\$` gives a literal dollar. Alternatively write "dollars PPA". Then grep the rendered `docs/fr/**/*.html` for `math inline` and keep only the intended ones (FR S4 should have the same count as EN S4).

#### N2. Eleven French figures have titles, axis titles or captions that run off the image
- **Cause:** French strings are about 20% longer and are not wrapped. Detected by scanning every live PNG for ink in the last 4 pixel columns, then checked visually (`scratchpad/edge_sheet.png`).
- **Titles cut at the right edge:**

  | Figure | Source | Where the title is cut |
  |---|---|---|
  | Homepage hero | `index.fr.qmd:96` | "…avec des rendements décrois" |
  | S2 WID chart | `seance-2.fr.qmd:297` | "…et aux États-Unis" |
  | S2 coverage chart | `seance-2.fr.qmd:434` | "…pas l'indice de" |
  | S3 | `seance-3.fr.qmd:657` | "…surtout avant 2" |
  | **S4 boxplot, the round-1 C1 figure** | `seance-4.fr.qmd:249` | "…la dispersion est proche d'un", so the corrected message is cut in half |
  | S4 | `seance-4.fr.qmd:366` | "…entre deux variable" |
  | S4 | `seance-4.fr.qmd:429` | "…le lien s'inflé" |
  | **S6 free scales, the round-1 C2 figure** | `seance-6.fr.qmd:178` | "…paraissent valoir les 11 ans de l'Afriq" |

- **Axis titles cut:** S3 `seance-3.fr.qmd:246` and `:390` ("…2020 (ans").
- **Caption cut:** S6 `seance-6.fr.qmd:454` ("…pondérée par la populati").
- **Why it matters:**
  - The homepage hero is the first image a French visitor sees.
  - The two figures rebuilt to fix the round-1 Criticals now show a truncated message in French.
  - The course's own capstone checklist says a figure must stand alone.
- **Fix:**
  - Wrap every title and caption with `str_wrap(…, 60)` / `str_wrap(…, 95)`, as S5 already does. Or set `plot.title.position = "plot"` and `plot.title = element_text(...)` with `ggtext::element_textbox_simple()` in `theme_cours()`, so wrapping is automatic in both languages.
  - Shorten the FR titles where possible.
  - Add the edge-ink check (a 15-line Python or `magick` script) to `tools/` and run it before each push.

#### N3. S4 prints the CAF series truncated, so the values the prose quotes are not on screen
- **Where:** `seances/seance-4.qmd:76-80` (FR same lines).
- **Evidence:**
  - The output stops at `10  2009  14.7` / `# ℹ 14 more rows`.
  - The next paragraph quotes "52.3 in 2018 then 31.5 in 2019, 18.8 in 2022 then 57.4 in 2023". None of these values is visible, in the browser or in print.
  - The lesson is "look at the whole series".
- **Fix:** `wdi |> filter(iso3c == "CAF") |> select(year, life_exp) |> print(n = Inf)`. Or `filter(iso3c == "CAF", year >= 2007)` to fit the screen. A small line chart of the series would make the artefacts obvious at a glance.

### MINOR

- **N4. Plotly chart (S6 "Interactivity", `seance-6.qmd:653-654`).**
  - The fix for round-1 M9 shrinks the plot area to about 170 px. The rotated y-axis title is clipped at the top: it ends "(year" (`scratchpad/s6-plotly-wide.png`).
  - The plot area is still white with plotly's default font (round-1 M12, plotly part).
  - Fix: `layout(height = 520, legend = list(orientation = "h", x = 0, y = -0.25), margin = list(b = 140, t = 60), paper_bgcolor = "#fcfaf6", plot_bgcolor = "#fcfaf6", font = list(family = "IBM Plex Sans"))`. Or shorten the y label to "Life expectancy (years)".
- **N5. EN figures clipped after the M8 relabelling.**
  - S5 Ex 5.1 (`seance-5.qmd:277-291`): the legend title "Income group (current World Bank classification)" pushes the 2-row legend off the right edge ("Lower middle incom", "Upper middle incom"). The FR twin has the same problem.
  - S6 `facet_grid` figure (`seance-6.qmd:157`): the caption is cut at "…(current World Bank classificati".
  - Fix: `str_wrap()` on the caption. Put the legend at the bottom with `nrow = 2` and a shorter title ("Income group*", with the footnote in the caption).
- **N6. Unpinned third-party script on S4.**
  - `modelsummary` now emits tinytable, which loads `https://cdn.jsdelivr.net/gh/vincentarelbundock/tinytable@main/inst/tinytable.js` and `.css`.
  - That is a moving `@main` branch: code changes upstream can alter or break the page without any commit here, and it partly undoes the round-1 M10 "no third-party requests" goal. MathJax 4 and a cdnjs polyfill also load from CDNs, but those are expected.
  - Fix: `options(tinytable_html_portable = TRUE)` before the table, or `output = "gt"` in `modelsummary()`.
- **N7. FR regression table numbers keep English decimals** ("0.734", "(2.146)", "R2", "Num.Obs."), next to a French prose that now uses commas. Fix: `options(modelsummary_format_numeric_latex = …)` / `fmt = fmt_decimal(digits = 3)` with `decimal.mark = ","` when `course_lang() == "fr"`, and translate the `gof_map` labels.
- **N8. Display equations are clipped at 375 px (S4, EN and FR).**
  - The multiple-regression equation is 553 px wide in a 318 px column with `overflow: visible`. The `html { overflow-x: clip }` guard cuts it after "+ γ Gini_i +".
  - The correlation formula overflows by 52 px.
  - Fix: `mjx-container[display="true"] { overflow-x: auto; max-width: 100%; }`. Or break the equation with `\begin{aligned}`.
- **N9. Print still shows the toggle label.**
  - Every printed solution is headed "Afficher la solution" / "Show solution" (A4 PDF of FR S4: 5 occurrences).
  - Fix: in `@media print`, hide `.callout-title-container` text and show `::before { content: "Solution" }`. Or set a `data-print-label` from `course-ui.html`.
- **N10. `hreflang` alternate links 404.**
  - Every EN and FR page declares `<link rel="alternate" hreflang="fr" href=".../fr/seances/seance-1.fr.html">`, which returns 404. The `.fr.html` suffix is not stripped; this is a babelquarto artefact. The EN deck also points to a non-existent `/fr/slides/atelier-dataviz.fr.html`.
  - Search engines will flag it. Fix: post-process in `tools/` (sed `.fr.html` → `.html`), or report it upstream.
- **N11. FR naming and wording inconsistencies.**
  - The CAF comment reads "de la **CAF**" in S3, S5 and S6 but "de la **RCA**" in S4 and on the index. It has three wordings: "n'est pas fiable… on exclut", "est peu fiable… exclure" (S5:67), and "on l'exclut, toutes années" (index).
  - S3 FR:481 "year est revenue" vs :779 "year revient".
  - The y-axis label of the index hero is "(années)", against "(ans)" everywhere else.
  - Fix: one canonical comment, copied verbatim. Use "RCA" in French prose, keep `"CAF"` in code.
- **N12. FR Shiny example (S6 FR, commented code) keeps English UI strings:** "WDI explorer", "Region", "All", "X-axis", "Y-axis", "Year", "vs", and the variable labels "Life expectancy (years)" etc. Under the design rule these are labels, not data values: translate them. Keep `"All"` only if it is matched against data.
- **N13. Stale CI comment.** `.github/workflows/publish.yml:50` says "les pages *.fr.qmd ré-exécutent leur R à chaque rendu", but commit `140928b` freezes the FR pages, and line 25 says no R code runs in CI. Fix the comment, or a future maintainer will un-freeze FR again (the failed run of `079d410` shows what happens then).
- **N14. French thousands separator and "%" use plain spaces.** `nb()` and `nb_pct()` use `" "`, so "26 480" and "31 %" can break across lines on phones. Use `" "` (narrow no-break space) for `big.mark` and before "%" / "$".
- **N15. Two titles still say the same thing twice.** `<title>` of the homepage ("R for data analysis – R for data analysis: beginner level") and of the FR deck ("R for data analysis: beginner level – Visualisation graphique") (round-1 m12, still open). Fix: `pagetitle:` on `index.qmd`; `title-prefix: ""` or a French `pagetitle` in `slides/atelier-dataviz.qmd`.

---

## 3. Checks that passed

- **Scripts.** 12/12 run end to end with 0 errors (EN and FR, all six sessions), with paths via `here()` and outputs only under `output/`. `data.zip` holds the CSVs, `SCIM.xlsx` and `R/theme_cours.R`; the EN and FR copies are byte-identical.
- **Links.** All 252 internal URLs (pages, figures, scripts, `data.zip`, `site_libs`) return 200, apart from the `hreflang` targets in N10. FR pages serve their own figures (FR and EN PNGs differ and carry French labels).
- **Numbers.** EN and FR prose and alt-text numbers agree on all 9 page pairs; the only differences are notation (ln(1{,}1)) and spelled-out numbers ("un an et demi").
- **French prose.** No English prose is left in the FR page bodies, apart from book titles and quoted file content. The SD/SE distinction is now explicit and correct.
- **Phone layout.** At 375 px, no page-level horizontal scroll. Skip link and mobile TOC are present in both languages, and the session pager is present.
- **Deck.** No 404s, fonts self-hosted, French alt text on all images.
