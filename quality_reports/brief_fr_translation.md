# Brief: French version of the R course (babelquarto)

Date: 2026-10-14. The site is now bilingual with `babelquarto`. English stays the main language. Each page `X.qmd` gets a French twin `X.fr.qmd` in the same folder, and an EN/FR switch in the navbar connects the two versions.

**Your job:** write the French twin of the file(s) you are assigned. Never modify the English `.qmd`. Don't render, don't touch `_quarto*.yml`, don't run git.

## The rule in one line

Translate everything a student *reads*. Keep everything R *executes* or *prints* in English.

## Translate into French

- The YAML `title`, `subtitle` and `description`.
- Headings (keep their `{#sec-...}` ids exactly as they are), paragraphs, lists and tables of prose.
- Callout bodies and callout titles. Use these fixed titles:
  - "In plain words" → « En clair »
  - "Session objectives" → « Objectifs de la séance »
  - Translate other recurring titles consistently within the page.
- The content of `.definition` and `.objectifs` divs.
- Image alt text and captions.
- These chunk options only: `#| fig-cap:`, `#| fig-alt:`, `#| code-summary:`.
- `{mermaid}` diagram labels (keep node ids and syntax) and the visible text of `{=html}` blocks (keep tags, classes, links).
- **R code comments** (the text after `#` in R chunks, but NOT `#|` option lines). Keep the comment on the same line, in the same position. The code itself on that line stays identical.
- Time estimates, such as "≈ 15 min".

## Keep verbatim (English)

- **All R code**, character for character, except the comments: function names, arguments, object names, column names, strings (including `labs()` titles and axis labels, filter values like `"Sub-Saharan Africa"`), file paths, and `#| label:` and every other option not listed above.
- Inline R `` `r ...` ``: copy it unchanged.
- Inline code in prose (`` `here::here()` ``, `` `NA` ``, `` `wdi_panel.csv` ``): unchanged.
- R error and warning messages quoted in the text. R prints them in English; the setup sets `LANGUAGE = "en"`. You may add a French gloss right after, e.g. *(« objet introuvable »)*.
- RStudio menu paths and button labels (`Tools > Global Options`, `Environment` pane, `Knit`/`Render`), and keyboard shortcuts.
- ```` ```markdown ```` / ```` ```{{r}} ```` example blocks, and plain ``` blocks: copy them unchanged.
- Package names, dataset names (WDI, WID), URLs.

## Glossary

This follows usage in utilitR and guide-R:

| English | French |
|---|---|
| package | package (un package) |
| data frame / tibble | data frame / tibble (le data frame, "tableau de données" once at first mention) |
| vector / object / function / argument | vecteur / objet / fonction / argument |
| missing value | valeur manquante (`NA`) |
| pipe | pipe (le pipe `|>`) |
| join | jointure |
| script / console / chunk | script / console / bloc de code (chunk) |
| tidy data | données *tidy* (rangées) |
| GDP per capita | PIB par habitant |
| life expectancy | espérance de vie |
| common thread | fil rouge |
| session | séance |
| workshop | atelier |
| PPP | PPA (parité de pouvoir d'achat) |
| low/middle/high income | revenu faible / intermédiaire / élevé |

## Style

- Address the reader as **vous**. The French atelier does the same. The register is friendly but academic.
- Write natural French, not a calque. Keep the same sentence-level structure, bold terms and order, so that the two versions stay paragraph-aligned.
- French typography:
  - Use « guillemets » with spaces inside.
  - Put a space before `:` `;` `?` `!`.
  - Use a decimal comma in prose: 1,5. Use a thin or normal space for thousands: 1 000 millions.
  - **Never** leave "1,000" (English thousands) in French prose.
  - Inline R output is the one exception and keeps R's point.
- Countries and regions in prose go into French (États-Unis, Chine, Inde, Afrique subsaharienne). Regions inside code stay in English.

## Links

- Links between pages (`seance-2.qmd`, `../resources.html`, `#sec-...`) stay as they are. babelquarto maps them to the French pages.
- `../slides/atelier-dataviz.qmd`, the workshop, exists only once (in French) at the site root. Replace it with `https://pierrebeaucoral.github.io/r-for-beginners/slides/atelier-dataviz.html`.
- External resources that are in English: add « (en anglais) » the first time they appear.

## Self-check before you finish

Run this check:

```
python3 tools/check_fr_twin.py seances/seance-N.qmd
```

It must print `OK`. It checks that the R chunks, ignoring comments and the three translatable options, the inline R, the section ids and the number of fenced blocks and divs are identical to the English file. Fix every mismatch it reports. Then re-read your French once for leftover English sentences.
