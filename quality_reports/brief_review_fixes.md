# Brief: fix the content review (2026-10-14)

An independent referee audited the course: `quality_reports/referee_reports/2026-10-14_content_review.md`. Read it first. Your prompt names the findings you own.

**Fix them in both the EN page and its FR twin (`*.fr.qmd`).** Touch only the files of your session. Do not render the site, do not run git, and do not edit `R/theme_cours.R`, `_quarto*.yml` or the tools.

## Decisions that apply to everyone

1. **CAF life expectancy (finding M3/M4).** This WDI release's Central African Republic life-expectancy series is unreliable in several years: 14.7 in 2009, 40.3 in 2014, 31.5 in 2019, 18.8 in 2022. The course excludes the **whole CAF series** with this exact line, used identically wherever `wdi` is loaded and life expectancy is used:
   ```r
   # CAF life expectancy is unreliable in this WDI release (14.7 in 2009, 18.8 in 2022): exclude every year
   wdi <- wdi |> mutate(life_exp = if_else(iso3c == "CAF", NA_real_, life_exp))
   ```
   - In FR, translate the comment only.
   - This replaces the older one-year exclusions: `year == 2019`, `year == 2022`, and `filter(!(iso3c == "CAF"...))`.
   - Session 4 introduces it: show the series once with `wdi |> filter(iso3c == "CAF") |> select(year, life_exp)`. Sessions 5 and 6 reuse it with one sentence pointing back to Session 4 (S5 §"Check extremes").
   - Rewrite any prose that calls it a one-year glitch.

2. **Numbers in prose (M11).** Inline R expressions must print through the helpers in `R/theme_cours.R` (already sourced by every page):
   - `nb(x, digits)` for plain numbers;
   - `nb_dollar(x)` for dollar amounts;
   - `nb_pct(x, digits)` for values already in percent.

   They print English format on the EN site and French format on the FR site from the same code. So write **the same inline expression in EN and FR**: `` `r nb(r_log, 2)` ``, not `round(...)` or `label_dollar()(...)`. Hand-written French numbers use a decimal comma and a space before `%`.

3. **Recompute, don't guess.** Every number, ranking or pattern you write in prose, a title, `fig-alt` or a caption must come from the data.
   - Run the code from the project root with `Rscript -e '...'` (use `here::here()` paths and `source("R/theme_cours.R")`), and apply the CAF line above first.
   - If a claim in the page is not supported by the data, rewrite it to what the data show.

4. **FR terminology.**
   - Standard deviation of a variable is « écart-type ». Standard error of an estimate is « erreur-type » (robust: « erreur-type robuste »).
   - "caption" (source note under a figure) is « note de source », never « légende ». « Légende » is the legend.
   - « la COVID-19 » everywhere.
   - Durations of life are in « ans ».
   - Every R comment in a FR page must be in French. Code, strings in code and data values stay English, as before.

5. **Income groups (M8).** `income` is the World Bank's **current** classification applied to every year.
   - Where a chart or table uses it, say so once in the page: "income group (current World Bank classification)".
   - Never claim the groups do not overlap in GDP per capita.

## Checks before you finish

- `python3 tools/check_fr_twin.py seances/seance-N.qmd` must print `OK`.
  - Code must stay identical between EN and FR, except comments, display strings (titles, labels, captions) and the `fig-cap`, `fig-alt` and `code-summary` options.
  - If you change code in EN, make the same change in FR.
- Run every code chunk you changed, in order, from a fresh R session, so you know it runs. The simplest way is to `knitr::purl()` the page to a temp file and source it up to your change.
- Re-read your French for leftover English prose.

## Report

Reply in at most 12 lines:
- each finding id → done, or why not;
- every number you changed, old → new;
- the check output.
