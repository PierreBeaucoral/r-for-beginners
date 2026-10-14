# Content review (le fond): independent referee, 2026-10-14

Scope: index, resources, playground, sessions 1-6 (EN, plus FR twins), the rendered output in `docs/` and `docs/fr/`, `data/*.csv`, `R/00_prepare_data.R`, and the downloadable scripts. I read and ran things only. No project file was modified.

Method:
- Read every EN session source in full.
- Read FR sessions 1, 4 and 6 in full; spot-checked FR 2, 3 and 5, plus index, resources and playground.
- Converted every rendered page to text and checked each number stated in prose, title and alt text against the printed output.
- Recomputed the disputed claims from `data/wdi_panel.csv` and `data/wid_gini.csv`.
- Viewed the key PNGs.
- Ran all six `docs/scripts/seance-N.R` top to bottom in a scratch copy of the project, one expression at a time.

## Overall score: 74 / 100 (Blocked: below 80)

Rationale:
- **What works.** The pedagogical architecture is strong: objectives, timed sections, "how to read this chart" boxes, collapsed solutions and N everywhere. The econometric explanations are mostly correct and unusually honest:
  - log-level reading per 1% / 10% / doubling;
  - robust SEs do not fix bias;
  - the cross-country gradient is not a within-country effect;
  - same-sample comparison of models;
  - countries are not random draws.
- **Numbers.** Almost every number written in prose matches the rendered output, and EN/FR numbers agree.
- **Scripts.** All six scripts run end to end; only the intended S1 error demos fail.
- **What sinks the score:**
  - two charts whose title, alt text and reading guide teach the wrong reading of the very chart shown (S4 boxplot, S6 free scales);
  - four more titles or alt texts that the data do not support;
  - a silent bug (`caption = src`);
  - an `identical()` that prints `FALSE` right after "exactly as it is";
  - a Central African Republic (CAF) clean-up that is right in S4/S5 but leaks back in S6 and in the report template;
  - an unexplained clash between the WDI and WID Gini measures;
  - systematic FR problems: untranslated comments, English number formatting in French prose, and SD/SE terminology merged.

Counts: **Critical 2, Major 13, Minor 28**.

Line numbers refer to the EN `.qmd`. FR twins have identical line counts, so the same line number applies to `*.fr.qmd` unless stated otherwise.

---

## CRITICAL

### C1. S4: the boxplot claim "less dispersion among richer countries" is false, and the table printed just above contradicts it
- **Where:**
  - `seances/seance-4.qmd:233` (alt: "become narrower for richer groups");
  - `:241` (title "Richer countries live longer, with less dispersion");
  - `:251` ("the box shrinks for richer groups, so life expectancy varies much less among high-income countries");
  - same in `seance-4.fr.qmd:233/241/251`.
- **What is wrong:** the `by-income` output at `:218-229` shows the opposite pattern:

  | Income group | IQR | SD |
  |---|---|---|
  | Low | 5.04 | 3.93 |
  | Lower-middle | 7.84 | 5.44 |
  | Upper-middle | 5.42 | 3.87 |
  | High | 5.99 | 4.45 |

  The low-income group is the *least* dispersed. High income is more dispersed than both low and upper-middle income.
- **Why it matters:** this is a lesson on how to read a boxplot. Students are told to see something that is not there, and the contradicting numbers are on screen at the same time. Any student who compares the table with the text will catch it.
- **Fix:**
  - Title: "Richer countries live longer; spread is similar across groups (widest in lower-middle income)".
  - Rewrite the third bullet: "compare box sizes: they are similar; the lower-middle-income group is the most heterogeneous".
  - Rewrite the alt text in EN and FR.

### C2. S6: the free-scales chart is titled the opposite of what it shows
- **Where:** `seances/seance-6.qmd:167` (alt "every region looks like a steady climb") and `:177` (title "Free y-axes: every region looks like a steady climb"); FR same lines.
- **What is wrong:** in the rendered PNG (`seance-6_files/figure-html/unnamed-chunk-4-1.png`), Europe & Central Asia and North America show a dramatic COVID crash. With free y-axes a 1.5-year dip fills half the panel. Free scales magnify the dip; they do not hide it. The title and alt text describe a chart that was not drawn. The warning at `:207` ("a small change looks as large as a big one") is the correct lesson, but the figure title contradicts it.
- **Why it matters:** this is the one chart meant to teach how free scales mislead, and its own caption misleads.
- **Fix:**
  - Title: "Free y-axes: North America's 3-year gain looks as large as Africa's 11-year gain".
  - Alt text: "Each panel has its own y-axis; small gains and the COVID dip in Europe and North America look as large as Sub-Saharan Africa's 11-year rise."

---

## MAJOR

### M1. S5: `caption = src` refers to an object that does not exist, so the step-5 figure has no source
- **Where:** `seances/seance-5.qmd:179` (and FR `:179`); also `docs/scripts/seance-5.R:60`.
- **What is wrong:** `src` is not defined anywhere. It is a leftover from the removed `ttl()`/`cap()` helpers. R silently finds `dplyr::src`, a function, and ggplot drops the caption. The rendered `layer-5-1.png` has no caption, while the text at `:162` says "Step 5. Labels and theme: … the source."
- **Why it matters:** the finished "model" figure fails the course's own checklist. Students copying it carry a reference to a database function they will never understand.
- **Fix:** `caption = "Source: World Bank, World Development Indicators (WDI), 2022."` (FR: "Source : Banque mondiale, …").

### M2. S2: `identical(wid_gini, wid_back)` prints `[1] FALSE` right after ".rds stores one R object exactly as it is"
- **Where:** `seances/seance-2.qmd:342-348` (FR same); rendered `docs/seances/seance-2.html` shows `FALSE`.
- **What is wrong:** `read_csv()` attaches a `problems` external pointer. It does not survive `saveRDS()`, so `identical()` is `FALSE` while `all.equal()` is `TRUE` (verified).
- **Why it matters:** the demo appears to prove the opposite of the point being made, with no comment.
- **Fix (either one):**
  - use `all.equal(wid_gini, wid_back)` with the comment "TRUE: same values, types and names";
  - or read with `read_csv(...) |> as_tibble()` and keep `identical()`.

### M3. CAF clean-up is incomplete: the whole CAF life-expectancy series is corrupt, and S6 time series still use it
- **Where:**
  - `seances/seance-6.qmd:109-112` (`trend_region` drops only CAF 2022);
  - `:435-438` (`life_world`);
  - `seances/seance-5.qmd:381-383` (Ex 5.2, medians over 2000-2023);
  - S5 drops CAF 2022 only, S4 drops 2019 only.
- **What is wrong:** the CAF series in `wdi_panel.csv` reads:

  | Year | 2008 | 2009 | 2013 | 2014 | 2017 | 2018 | 2019 | 2021 | 2022 | 2023 |
  |---|---|---|---|---|---|---|---|---|---|---|
  | Life expectancy | 49.9 | **14.7** | 49.5 | **40.3** | **45.2** | 52.3 | **31.5** | **40.3** | **18.8** | 57.4 |

  The course presents 2019 and 2022 as isolated one-year glitches ("a drop of 20 years in one year, then a rebound", S4:73). Yet 2009 = 14.7 is more absurd than either.
- **Effect on S6** (unweighted Sub-Saharan Africa mean, recomputed):
  - the series includes a spurious dip in 2009 (57.6 → 57.4; −0.91 years vs without CAF);
  - 2019 is depressed by 0.66 years;
  - 2021 is depressed by 0.47 years.

  The panel titled "despite a COVID-19 dip" therefore mixes a COVID signal with CAF artefacts.
- **Inconsistent mechanisms:**
  - S4 and S5 set the value to NA (`mutate(... NA_real_)`);
  - S6 setup drops the CAF row (`filter(!(iso3c == "CAF"))`);
  - S6 trends drop the CAF-2022 row only;
  - index drops CAF entirely.
- **Why it matters:** the teaching point ("check extremes, exclude explicitly and say so") is good, but the data contradict "isolated artefact". The S6 regional series silently carry several such values.
- **Fix:**
  - State once (S4 §1) that this WDI vintage's CAF life-expectancy series is unreliable in several years. Show the series in one line: `wdi |> filter(iso3c == "CAF") |> select(year, life_exp)`.
  - Exclude CAF `life_exp` for all years with one documented `mutate()`, used identically in S4, S5 and S6, or add a flag column in `R/00_prepare_data.R` and document it.
  - Update S4:73 and S5:61 wording accordingly.

### M4. S6 Quarto report template reintroduces the CAF 18.8 value
- **Where:** `seances/seance-6.qmd:893-894` (template setup), `:899-901` (inline mean), Ex 6.5 (`:933-937`).
- **What is wrong:** `wdi_2022 <- wdi |> filter(year == 2022) |> drop_na(gdp_pc_ppp, life_exp)` keeps CAF = 18.8. The student's first reproducible report would therefore state a mean over 199 countries that includes the artefact (72.79 vs 73.06), and plot the outlier the course spent S5 removing.
- **Why it matters:** this is the capstone of "numbers computed, not typed". It silently undoes S5's data-hygiene lesson.
- **Fix:** add the same exclusion line, with its one-line comment, to the template.

### M5. S2: WID chart alt text is wrong, and the series' obvious imputation is not flagged
- **Where:** `seances/seance-2.qmd:283` (alt "Inequality rises in China and India and the USA stays at a higher level"); `:280` ("if the import is right, the series should look like inequality data, not like noise").
- **What is wrong:**
  - **Alt text:** India overtakes the USA around 2007 and is the highest from 2010 to 2020 (0.634 vs 0.620 in 2020). The USA rises from 0.55 to 0.62; it does not "stay".
  - **Imputed series:** India's series is a straight line from 2000 to 2011 and perfectly flat from 2014 to 2020 (WID interpolation/imputation; India has few surveys). The USA jumps from 0.58 to 0.62 in 2020.
- **Why it matters:** the page explicitly says "a chart is also a check". The chart shows tell-tale signs of interpolated, non-annual data, and the course does not use them. For development economists this is the key data-quality lesson about inequality series.
- **Fix:**
  - Correct the alt text (EN/FR).
  - Add two sentences: "India's line is perfectly straight before 2011 and flat after 2014: these are WID interpolations, not yearly measurements. Check the WID metadata before reading year-to-year changes."
  - Optionally change the title to "…rose in all three countries; India's series is largely imputed".

### M6. Two different Gini measures with opposite rankings, never reconciled
- **Where:**
  - S1:430-468 and playground:50 (WDI Gini, 0-100);
  - S2:214-298 and S3:563-665 (WID Gini, 0-1, pre-tax national income);
  - S4:589-667 (WDI Gini in regressions).
- **What is wrong:**
  - **WDI** puts India at 23.0-25.5 (consumption-based survey), far below the USA at 41.8 (income). On this measure India is the least unequal of the three.
  - **WID** puts India at 0.634, the most unequal of the three.
  - **S4** pools consumption- and income-based WDI Ginis in one regressor without comment.
- **Why it matters:** a development-economics student will notice India flipping from most to least unequal. Consumption vs income Gini, and survey vs national-accounts distribution, is core course material, and the S4 bullet "Measurement and selection" (`:704`) misses it.
- **Fix:**
  - Add one callout in S3 after the join, or in S4 §5: "WDI Gini = household-survey Gini, often consumption-based in low-income countries (India), 0-100; WID = pre-tax national income among adults, 0-1. They are not comparable, and they rank India differently."
  - Add "mixes consumption- and income-based surveys" to S4:704.

### M7. S5 Ex 5.3: title and alt text misdescribe the ten richest countries
- **Where:** `seances/seance-5.qmd:489` (alt) and `:501` (title "The richest countries are small economies, mostly in Europe and the Gulf").
- **What is wrong:** the top 10 in 2022 are:
  - Europe (4): Luxembourg, Ireland, Norway, Switzerland;
  - Gulf (1): Qatar;
  - East Asia (2): Singapore, Brunei;
  - territories (2): Bermuda, Cayman Islands;
  - the United States, which is not a small economy.

  "Mostly Europe and the Gulf" is 5/10.
- **Fix:** "Nine of the ten richest countries are small economies or financial centres; the United States is the exception." Update the alt text to match.

### M8. Income groups are today's World Bank classification, but are labelled as 2019/2022 groups and used for 2000
- **Where:**
  - `R/00_prepare_data.R:46-49` (the `incomeLevel` from the `country` endpoint is the *current* classification, applied to all years);
  - S1:444/461 ("…2019 (%)");
  - S4:236 and the `by-income` tables;
  - S5:459/570;
  - S6:136-157 (`facet_grid(income ~ year)` for 2000 and 2022).
- **What is wrong:** a country is shown in its 2025 group in 2000. S5:570 says groups "barely overlap, by construction", but:
  - classification uses GNI per capita (Atlas, current US$), not GDP PPP;
  - the 2022 ranges overlap substantially: the low-income maximum (4,579) is above the upper-middle-income minimum (3,816), and the lower-middle-income maximum (16,360) is above the high-income minimum (12,019).
- **Why it matters:** this is mislabelled data in a development-economics course. Countries graduate between groups, and the S6 2000-vs-2022 facet is misleading.
- **Fix:**
  - Say once (S3 §factors or S4 §1): "`income` is the World Bank's current classification (FY2026), applied to every year".
  - Relabel the axes "income group (current classification)".
  - Drop "by construction" from S5:570.
  - Optionally, use the historical classification file (OGHIST) in the prep script.

### M9. S2: SCIM `value` mixes units and frequencies, and the page summarises it without comment
- **Where:** `seances/seance-2.qmd:124-126` (`summary(scim$Value)`), `:147-154` ("drop the French duplicates and the empty columns").
- **What is wrong:** `value` mixes:
  - USD billions (CXML/CXMLSA);
  - national-currency billions (NCML/NCMLSA; Indonesia 2022-Q3 = 1,167,777 billion rupiah);
  - percentage changes (GPSA/GYSA);
  - monthly and quarterly frequencies.

  The printed summary (mean 3,879; max 1,167,777) is meaningless. The `select()` also drops non-empty, non-duplicate columns (`frequency`, `unit_code`, `power_code`) while claiming to drop only duplicates and empty columns.
- **Why it matters:** the section's key idea is "an import that runs without an error is not an import that worked". Then it averages rupiah, dollars and percentages without blinking.
- **Fix:** after `summary()`, add "This summary is meaningless: `value` mixes dollars, national currencies and growth rates (see `count(scim, measure, unit_code)`)". Also keep `unit_code` and `frequency` in the `select()`, or say why they are dropped.

### M10. FR twins: many R comments left in English, against the stated design rule
- **Where:**
  - `seances/seance-1.fr.qmd:160-162, 183-188, 194-195, 225, 326, 333, 361-363, 369-371, 381-385, 394-395, 432, 434` (≈25 lines, e.g. `# subtraction`, `# integer division`, `# typo in the name`, `# missing commas`, `# millions to persons`, `# share of the total`, `# na.rm = TRUE: drop NAs before computing`);
  - folder-tree comments `seance-1.fr.qmd:87-91` and `seance-2.fr.qmd:61-65` ("the course data", "everything YOU produce");
  - `seance-2.fr.qmd:24, 230, 238, 253, 276, 374, 382, 383, 503` (`# naive attempt`, `# hide the long path`, `# the comment line`, `# Same numbers? …`, `# needs Internet`, `# ISO-2 codes`, `# new_name = indicator code`, `# backticks: accent and dash in the name`).
- **Why it matters:** S1 is the first page French students see. Half its comments are English and the other half French. The downloadable FR scripts inherit this.
- **Fix:** translate them. `check_fr_twin.py` already ignores comments, so code identity is unaffected.

### M11. FR prose prints numbers in English format
- **Where (rendered `docs/fr/`):**
  - S3 FR:273 ("65%");
  - S4 FR:139 ("la moyenne ($26,480) … médiane ($16,895)"), :310 ("(31%) … (38.1%)"), :382/390 ("0.86", "[0.81, 0.89]"), :479-487 ("5.65", "0.056"), :665-667 ("5.27 à 5.31", "0.014", "0.14 année(s)"), :783 ("75.8 années … 12.5 années … [10.9, 14.2]");
  - S6 FR:467 ("72.8 à 71.2 ans").
- **What is wrong:** inline `r` expressions print "." decimals, "," thousands, "$" before the number and no space before "%". Hand-written French in the same pages uses "5,5 fois" and "100 %". Also, "années" for durations of life is less natural than "ans".
- **Fix:**
  - Add a helper to `R/theme_cours.R`, e.g. `nb <- function(x, d = 1) { fr <- identical(rmarkdown::metadata$lang, "fr"); formatC(x, format = "f", digits = d, decimal.mark = if (fr) "," else ".", big.mark = if (fr) " " else ",") }`, plus a matching `dollar()` helper.
  - Use it in both languages, so code identity holds.

### M12. FR S4 merges standard deviation and standard error; grammar errors
- **Where:**
  - `seance-4.fr.qmd:458/466/566/666/676/794` ("écarts-types robustes");
  - `:657` ("**Écart-type** (entre parenthèses…) : l'incertitude sur le coefficient");
  - `:770` ("le dénominateur est son écart-type").
- **What is wrong:** "écart-type" is used both for the SD of a variable (§2) and for the standard error of an estimator. The SD/SE confusion is the classic beginner error. The English keeps them apart; the French erases the distinction. Standard French usage is "erreur-type (robuste)" or "écart-type de l'estimateur".
- **Grammar errors in the same file:**
  - `:466` "quelles que soient les écarts-types" → "quels que soient";
  - `:556` "l'ampleur de l'écart que toute explication doit rendre compte" → "dont toute explication doit rendre compte";
  - `:738` "63 pays-années issues de 3 pays" → "issus".
- **Fix:** use "erreur-type" (SE) vs "écart-type" (SD) throughout S4 FR (and S6 FR if used), and add a one-line definition. Correct the three errors.

### M13. S5 pacing is unrealistic for true beginners
- **Where:** `seances/seance-5.qmd` durations at `:75, 205, 299, 408, 512, 618, 790`, plus 5 min at `:49`.
- **What is wrong:**
  - Section times sum to 190 min. Unlike S4 and S6, it never says exercises are included, and none of the six exercises is marked optional.
  - Ex 5.5 asks for `st_point_on_surface()` and `geom_label_repel(stat = "sf_coordinates")`.
  - `map_int()` with a `\(x)` lambda (`:666`) is used without explanation.
- **Why it matters:** with sf maps for first-timers this session runs well past 3 hours, and the lesson that slips is maps, the hardest part.
- **Fix:**
  - State "exercises included" and make the sums reach about 180.
  - Mark Ex 5.5 (annotation part) and Ex 5.6 as "Optional: going further".
  - Replace `map_int` with three explicit `length(unmatched("…"))` lines.

---

## MINOR

1. **S1:483-490, 416, 569.** The "rounded 2020 values" are an older WDI vintage. US GDP is 20,894 bn vs 21,375 in `data/wdi_3countries.csv`; India's population is 1,380 m vs 1,403. Students meet the other numbers in S2. The conclusions (6.1×, ≈33×, 89 %) survive. Fix: round the course data values, or say "rounded, earlier WDI release".
2. **S1:410, 413, 456.** French spacing in the English page ("89 %", `paste0(…, " %")`). EN style is "89%".
3. **S1:149 vs `docs/scripts/seance-1.R:73, 81`.** The script stops at `gdp_chinaa + 1` and `feols(...)` when run top to bottom (verified: 2 errors), contradicting "a script should run from top to bottom". Fix: in `tools/make_scripts.R`, also comment out chunks with `#| error: true`, or wrap them in `try()`.
4. **S1:20-27.** The very first chunk needs `tidyverse`, `here` and `theme_cours.R` before installation and packages are taught on that page. Add "Did the 'Before the first session' steps on the home page? If not, do them first."
5. **S2:158.** Promises "we will use dates properly in session 3"; S3 contains no dates material. Remove the promise or add a short lubridate block to S3.
6. **S2:280.** "1 = one person owns everything" describes wealth. The chart is income: "1 = one person receives all income".
7. **S3:770-772.** The Ex 3.4 solution leaves `year` as `<chr>` (rendered), contradicting the warning at S3:494-497. Add `mutate(year = as.integer(year))`.
8. **S3:628, S5:690.** "Codes do not change" / "Codes are stable" is overstated. S5's own output shows Kosovo with a non-standard code, and ISO codes do change (ROM→ROU, ZAR→COD). Say "codes are far more stable than names; still run `anti_join()`".
9. **S4:310.** Prose "median (31%)" vs the gt table "30.9" (from `round(30.95, 1)`). Use `sprintf("%.1f", …)` or the helper from M11.
10. **S4:550.** "slope = gain per unit of log GDP" while the plotted axis is log10. Add: "a tenfold income difference ≈ β·ln10 ≈ 13 years".
11. **S4:714-724.** Ex 4.4 compares `m_ctrl` (N = 197) with `m1` (N = 198), the comparison the session just warned against. Re-estimate `m1` on `filter(cs, !is.na(elec_access))` and compare (5.65 → 4.44 either way).
12. **S4:736-738.** "test 'Asia vs America'" and "p-values *were* therefore far too optimistic" refer to an analysis that no longer exists in the course. Rephrase in the conditional.
13. **S4:73.** "As in Session 5" is a forward reference, since S4 precedes S5. Use "as we will do again in Session 5".
14. **S4:630-635.** The stars legend renders twice: modelsummary adds it automatically and `notes` repeats it. Drop it from `notes`.
15. **S4:619-625 (FR).** Regression table row labels stay English on the FR page ("Log GDP per capita", "Constant", "Region:"). Under the design rule, table labels should be French. Make `nice_names` strings translatable (whitelist them in `check_fr_twin.py`).
16. **S5:322, 345.** India is highlighted as having "gained nine years… more than Brazil or China", but Bangladesh (a grey line in the same chart) gained 12.6. Either highlight Bangladesh or say "India and Bangladesh gained the most".
17. **S5:687.** "Drops… small, poor or fragile states", but the printed unmatched list is Channel Islands, Gibraltar and Kosovo (two rich territories). Soften the claim to fit the output.
18. **S5:779.** The Ex 5.5 title is about "< 20 %" access, but the map bins are <50/50-80/80-99/99-100. The claim cannot be read off the figure. Add a "< 20 %" bin or retitle.
19. **S5:773 (FR).** The legend level "No data" stays English on the French map. It is a created label, not a data value.
20. **S6:247 and 289.** The heading "How `theme()` works" appears twice. The first holds only the section goal and "Before and after". Rename the first "Themes in practice".
21. **S6:630 vs 644-660.** The text says the tooltip uses the `text` aesthetic with `tooltip = "text"`; the code uses `label` / `tooltip = "label"`. Align `:630` with the code.
22. **S6:610, 615, 618.** "Text at least 12 pt at final size" vs recommended `base_size` 11-12 (axis text = 0.8 × base ≈ 9 pt). State the rule for titles/labels, or raise `base_size` to 14-15 for Word.
23. **S6:373.** The comment "(it is a function-like object…)" is wrong: a theme is a list.
24. **FR terminology.**
    - "le COVID-19" (S4 FR:71, S5 FR:47) vs "la COVID-19" (S6 FR:53): pick one.
    - "légende" is used for caption (S6 FR:367, 488, 662, 955; S5 FR:818 "la source dans la légende"), which a checklist reader will confuse with the legend. Use "note de source" / "légende de la figure".
25. **`resources.fr.qmd:20`.** English "and" and ":" without the French space.
26. **`seance-1.fr.qmd:96`.** "directeur de thèse" for Master students → "directeur de mémoire".
27. **S3:142-150.** A redundant chunk: the previous chunk (`:132-140`) already shows `select()` after `mutate()`. Merge them, or show the version without `select()` first.
28. **`slides/atelier-dataviz.qmd` (speaker notes, "Montrer l'incertitude").** The CI of the difference is given as "environ [-0,1 ; 2,9]". From the stated CIs, SE_diff ≈ 0.80, so the CI ≈ [-0,2 ; 3,0]. The conclusion is unchanged.

---

## Specific questions from the brief

- **Session 1 alt texts.** "89 %" checks out: 45.2 % + 44.2 % = 89.4 % on the page's values, still 89 % on current WDI. "About six times" checks out: 63,124 / 10,410 = 6.06. Both are supported. The "≈ thirty-three" (32.6) and "5.5×" (5.50) claims also check out.
- **Session 4 econometrics.**
  - Correct: the log-level reading; R² = r²; the intercept non-interpretation; robust SEs are "valid under heteroskedasticity, do not fix OVB"; same-sample comparison; the non-independence / population-not-sample caveat; the spurious-regression point.
  - Problems: C1, M6, M12 (FR), Minor 10-12.
- **CAF handling.** It is well explained locally: explicit, the raw file is not edited, and N is reported. It is incomplete globally (M3, M4), and the "isolated one-year artefact" narrative is contradicted by the series.
- **Scripts.**
  - `docs/scripts/seance-1..6.R` all run top to bottom with `here()` paths in a fresh project. The only failures are the two intended S1 error demos (Minor 3).
  - The S5 script carries the `src` bug (M1).
  - Chunk order is correct.
  - Non-evaluated chunks are correctly commented out by `knitr::purl`. The WDI API, `ggsave` and the Shiny app are commented, so the scripts write only to `output/` (S2 writes).
- **FR fidelity.**
  - No mismatched numbers between EN and FR prose (line-by-line digit comparison of all pages).
  - The translation of S1, S4 and S6 is natural and faithful overall.
  - The problems are untranslated comments (M10), number formatting (M11), SD/SE terminology and three grammar errors in S4 (M12), and Minor 15, 19, 24-26.
