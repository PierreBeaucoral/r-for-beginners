# Design and UX referee report: r-for-beginners (EN/FR Quarto site)

Date: 2026-10-14 · Auditor: independent referee (read/inspect/browse only; no project file modified)
Method: rendered `docs/` served at http://localhost:8765, driven with Playwright (Chromium) at 1366, 768 and 375 px; print media emulated and printed to PDF; computed styles, contrast ratios, tab order and network requests measured in the browser; sources read: `theme.scss`, `assets/course-ui.html`, `slides/slides.scss`, `_quarto*.yml`, selected `.qmd`.
Screenshots: `quality_reports/referee_reports/screens/` (file names are cited below).

## Overall score: 70 / 100 (blocked for "share" gate; commit-level after the two Critical fixes)

On desktop the site does look made by a person. The type pairing (Newsreader / Plex / JetBrains), the cream and cobalt palette, the numbered contents list on the homepage and the session strip work. Text contrast passes AA everywhere I measured: muted text 6.3:1, callout titles 5.7–6.3:1, syntax tokens 4.6–10.8:1. Solution toggles work with Enter and Space, show a focus ring, and switch between Show and Hide in both languages. `lang="fr"` is set on the FR pages.

The score is pulled down by four things:

1. **Phones lose content.** `overflow-x: clip` on `html, body` cuts off tables, inline code and URLs with no way to scroll to them.
2. **Printing breaks.** Every printed code line starts with a URL.
3. **The slide deck loses its fonts.** All four font files return 404.
4. **The "less polished" layer is applied by rule, not by judgement.** Every `p > strong` gets the highlighter, and there are seven variants of the left-rule device. Emphasis stops meaning anything, so the effect reads as a template effect rather than a teacher's hand.

Code is also typeset noticeably smaller than prose (0.68–0.75×), which is the wrong way round for a course where the code is the content.

| Severity | Count |
|---|---|
| Critical | 2 |
| Major | 13 |
| Minor | 17 |

---

## Critical

### C1. Tables, inline code and URLs are clipped on phones, with no way to scroll
- **Where:** `theme.scss:95` `html, body { overflow-x: clip; }`. Measured at 375 px:
  - `/seances/seance-6.html`: the `theme()` constructor table is 483 px wide in a 318 px column, and the "Example" column is cut off (screenshot `s6-table-375.png`).
  - `/seances/seance-4.html`: `table.gt_table` is 372/318 px and a regression table is 512/318 px.
  - `/fr/seances/seance-3.html`: a table is 461/318 px.
  - `/seances/seance-1.html`: inline `code` "File > New Project > New Directory > New Project" and `mean(x, trim = 0, na.rm = FALSE, ...)` run 170 px past the edge. Computed `white-space: pre`, so they cannot wrap.
  - `/resources.html`: `a.uri` links (viridis, r-graph-gallery) run past the edge (`resources-375.png`).
- **Why it matters:** `clip` hides the page-level horizontal scroll, which is what it was meant to do. But none of these elements sits in its own scroll container, so the overflow is simply cut off. On a phone, students lose the "Example" column of a reference table and the end of command strings. There is no visual cue that anything is missing.
- **Fix:**
  ```scss
  main.content table { display: block; max-width: 100%; overflow-x: auto; }   // or wrap: .cell-output-display:has(table){overflow-x:auto}
  .gt_table { display: table; } main.content div:has(> .gt_table) { overflow-x: auto; }
  p code:not(.sourceCode), li code:not(.sourceCode), td code { white-space: normal; overflow-wrap: anywhere; }
  main.content a.uri, main.content a[href^="http"] { overflow-wrap: anywhere; }
  ```
  Keep `overflow-x: clip` only as a last guard. Verify each long session at 375 px.

### C2. Printed notes: every code line is prefixed by its own URL
- **Where:** `theme.scss:310`, `a[href^="http"]::after { content: " (" attr(href) ")" }`. Quarto puts a line anchor on every source line (`<a href="#cb4-1">`), and its JS rewrites that anchor to an absolute `http://…/seance-4.html#cb4-1`. Code-link anchors on function names also match: on `seance-4` there are 290 `http` anchors inside `<pre>`, out of 298 in total.
- **Evidence:** `screens/s4-print.pdf`, pages 3–4. Every line reads `(http://localhost:8765/seances/seance-4.html#cb4-2)  filter(year == 2019, …`, which makes the printed code unusable.
- **Fix:** restrict the rule to prose links:
  ```scss
  @media print {
    a[href^="http"]::after { content: none; }
    main.content :is(p, li) > a[href^="http"]:not(.uri)::after { content: " (" attr(href) ")"; font-size: .8em; color: #555; word-break: break-all; }
  }
  ```

---

## Major

### M1. The slide deck's fonts all return 404, so the deck renders in system fonts
- **Where:** `slides/slides.scss:29-36`, `url("../assets/fonts/…")`. The compiled theme lives in `docs/site_libs/revealjs/dist/theme/`, so these URLs resolve to `/site_libs/revealjs/dist/assets/fonts/*.woff2`, and all four return 404. `document.fonts` reports no loaded font. `docs/assets/` does not contain the fonts at all: they were only copied under `site_libs/bootstrap/assets/fonts/`.
- **Why it matters:** the deck claims the same system as the site but projects in Helvetica/SF or Segoe plus a Palatino fallback. On the classroom PC (Windows) it will look different again.
- **Fix:**
  1. Add `assets/fonts/*.woff2` to `project.resources` in `_quarto.yml`.
  2. Then either point the URLs at `url("../../../../assets/fonts/…")` from the compiled CSS, or declare the `@font-face` rules in a plain `slides/fonts.css` loaded with `css:` in the deck YAML. The plain CSS is not moved by the theme compiler, so relative URLs keep working.
  3. Check with a network panel that there are no 404s.

### M2. Title slide is misaligned: the title is left-aligned, the subtitle and author are centred
- **Where:** `slides/slides.scss:38-39`. `.reveal { text-align: left }` and the h1 rule left-align the title, but Quarto's `.quarto-title-block` subtitle and author keep `text-align: center` (`slides-1.png`).
- **Fix:** `.reveal .quarto-title-block :is(.subtitle, .quarto-title-authors, .quarto-title-author, .date) { text-align: left; justify-content: flex-start; }`. Alternatively, centre all three.

### M3. Images without alt text
- `seances/seance-1.qmd:58` (and the FR version): `<img src="../assets/rstudio-panes-labeled.jpeg">` has **no `alt` attribute**. A caption exists, but the figure carries the content the lesson depends on ("the four panes").
  - Fix: append `{fig-alt="Screenshot of RStudio with its four panes labelled: source editor top-left, console bottom-left, environment/history top-right, files/plots/help bottom-right."}`.
- `/slides/atelier-dataviz.html`: 4 of 4 images (`sim-distrib`, `ugly-vs-good`, `wdi-elec`, …) have no `alt`.
  - Fix: add `fig-alt` to each chunk.

### M4. The highlighter is applied by rule, so it has stopped carrying meaning
- **Where:** `theme.scss:262`, `main.content p > strong { background: linear-gradient(… $c-marker …) }`. Session 1 has 36 highlighted runs.
- **What gets highlighted:**
  - Labels: "Also:", "Script of this session:", "Packages utilisés aujourd'hui :", "Check extremes first.", "We use 2019."
  - A UI label: "Run Code" on the playground.
  - Whole sentences: the two-line blockquote "growth, health and inequality, what does the data say about developing countries?" gets blockquote, bold and highlight at once.
  - Five verbs in one line on the homepage: Import, manipulate, describe, visualise, report.
  - See `home-desktop-2.png` and `home-375-mermaid.png`.
- **Inconsistency:** `strong` inside `li` is *not* highlighted (resources and "How to use this site"), so the same semantic element looks different depending on whether it sits in a paragraph or a list.
- **Why it matters:** a real highlighter is selective. Applied automatically, it is exactly the generic "AI template" texture the design wants to avoid, and it competes with headings for attention.
- **Fix:** make it opt-in. Remove the `p > strong` rule. Style `mark` and `.key` (Pandoc `[term]{.key}` or `==term==` via a filter), and use it about 3–6 times per session, for defined terms only. Keep `strong` as weight 600 with no background.

### M5. Code is typeset much smaller than prose, and smaller still inside solutions
- **Measured on `seance-1`:**
  - Prose: 19 px.
  - Code in source blocks and output: 14.3 px (0.75×).
  - Code inside solutions: **12.9 px** (0.68×).
  - The webR editor on the playground uses 19 px, so code size is also inconsistent across the site.
- **Cause:** `theme.scss:140` `pre code, code { font-size: .86em; }` compounds with Bootstrap's `pre { font-size: .875em }`, and inside callouts with Quarto's `.callout-body { font-size: .9rem }`.
- **Why it matters:** for beginners, the code is the primary text. JetBrains Mono has a larger x-height than Plex, but 12.9 px against 19 px prose is still a step down that makes `<-`, `|>` and `==` hard to read on a projector or a laptop.
- **Fix:**
  ```scss
  pre { font-size: .84rem; }          // ≈16px, one place
  pre code { font-size: inherit; }    // stop compounding
  .callout pre { font-size: .84rem; } // solutions same as body code
  p code, li code, td code { font-size: .86em; }
  ```

### M6. No table of contents at all below 768 px on 26,000–31,000 px pages
- **Where:** all session pages. At 375 px, `#quarto-margin-sidebar` is `display:none` and Quarto renders no "On this page" toggle, because the site has no sidebar. Session 6 is about 31,000 px tall, roughly 40 phone screens, and the only navigation is the session strip at the top and "Back to top".
- **Fix:** in `assets/course-ui.html`, on load, when `matchMedia('(max-width: 767.98px)')` matches, clone `#TOC` into a `<details class="toc-mobile"><summary>On this page / Sur cette page</summary>…</details>` after `#title-block-header`. Hide it with CSS at ≥768 px. Use `toc-title` for the label.

### M7. Print layout: wasted column, folded code stays hidden, wrong toggle label
- **Wasted column:** `screens/s4-print.pdf`. The text column stays at about 600 px of an A4 page, because the Quarto page grid keeps the margin-sidebar column after `#quarto-margin-sidebar` is hidden, leaving about 30% of each page empty. Session 4 prints to 28 pages.
- **Folded code:** `<details>` code folds ("Show the chart code (taught in Session 5)", 3 per page) print closed, so the code is missing from printed notes.
- **Toggle label:** solutions do print (good), but each one is headed by the button text "Show solution", in a bordered button.
- **Fix:**
  ```scss
  @media print {
    #quarto-content, .page-columns { display: block !important; }
    main.content { max-width: none !important; width: 100% !important; }
    .callout-header[data-bs-toggle="collapse"] { border: 0 !important; background: none !important; }
    details::details-content { content-visibility: visible; display: block; }   /* Chromium 131+ */
  }
  ```
  Add `window.addEventListener('beforeprint', () => document.querySelectorAll('details').forEach(d => d.open = true));` to `course-ui.html` for other browsers. For the label, set `data-print-label="Solution"` in JS and use `::before { content: attr(data-print-label) }` with the title hidden in print.

### M8. The Mermaid "chain" diagram is costly, unreadable on phones, off-palette and unnamed
- **Where:** homepage "Where we are going" (also loaded on session pages that use Mermaid).
- **Cost:** `quarto-diagram/mermaid.min.js` is **2.7 MB** for six boxes and five arrows.
- **Phones:** at 375 px the SVG is scaled to 28% of its 1,148 px viewBox, so its 16 px labels render at about 4.4 px (`home-375-mermaid.png`).
- **Off-palette:** the `neutral` theme draws grey boxes in a different font, foreign to the cream and cobalt system.
- **Unnamed:** the SVG has no `aria-label`, `<title>` or `<desc>`.
- **Fix:** replace it with an `<ol class="chain">` in HTML: six items, CSS arrows (`li + li::before { content: "→" }`), `display:flex; flex-wrap:wrap`. That is zero JS, readable at every width and themed by the site. If Mermaid is kept, add `accTitle`/`accDescr` and `themeVariables` built from the palette.

### M9. Plotly legend overlaps the x-axis title
- **Where:** `/seances/seance-6.html`, "Interactivity with plotly" (`s6-plotly-desktop.png`). The horizontal legend's first row is drawn over "GDP per capita, PPP (2021 int. $, log scale)".
- **Fix:** in R, `ggplotly(p_int, tooltip = "label") |> layout(legend = list(orientation = "h", x = 0, y = -0.3), margin = list(b = 140))`, or put the legend on the right for this one chart.

### M10. Third-party Google Fonts request on every page, against the stated self-hosting
- **Where:** the compiled `bootstrap-*.min.css` starts with `@import "https://fonts.googleapis.com/css2?family=Source+Sans+Pro…"`, which the cosmo theme injects. `document.fonts` lists 21 Source Sans Pro faces, none of them used.
- **Why it matters:** it is a render-blocking request to Google from every student's browser. That is a privacy issue for an EU university (it has been ruled an unlawful IP transfer in DE). It also contradicts `theme.scss:73` "no request to Google from students' browsers".
- **Fix:** add `$web-font-path: false;` in `/*-- scss:defaults --*/`.

### M11. Keyboard users press Tab 21 times before reaching content, with no skip link
- **Measured on `seance-1`:** 8 navbar stops, then 12 TOC links (the TOC comes before `<main>` in the DOM), and only then the session strip and the first content link. No skip link is present.
- **Fix:** add `<a class="skip-link" href="#quarto-document-content">Skip to content</a>` as the first element of `<body>` (via `include-before-body`). Style it visually hidden until `:focus-visible`. Translate it for FR.

### M12. R output is styled outside the design system and looks pasted onto the page
- **gt tables** (`s4-gt-desktop.png`): white background, `system-ui` font, `#333` text and grey striping on a cream page. These are the only white rectangles on the site besides the figures.
- **ggplot figures:** white or grey panel, in-figure titles in Arial or Helvetica (the homepage Preston curve, all session figures), on cream paper.
- **Plotly:** default font, white background.
- **Why it matters:** about half the visual surface of each session is R output, and none of it uses the site's palette or type, so the craft stops at the prose.
- **Fix:**
  - CSS: `.gt_table { font-family: inherit !important; color: inherit !important; background: transparent !important; } .gt_table .gt_row { background: transparent !important; }`.
  - Figures: in `R/theme_cours.R`, set `plot.background = element_rect(fill = "#fcfaf6", colour = NA)` and `base_family = "IBM Plex Sans"`, and use `knitr::opts_chunk$set(dev = "ragg_png")` so the font is embedded.
  - Plotly: `layout(paper_bgcolor = "#fcfaf6", plot_bgcolor = "#fcfaf6", font = list(family = "IBM Plex Sans"))`.

### M13. The left rule is overused, so it no longer signals anything
- **Seven variants on one page:**
  - `blockquote`: 2 px accent (`theme.scss:116`)
  - `.section-goal`: 2 px accent (172)
  - `.objectifs`: 2 px accent on a filled box with 4 px radius, which bends the rule ends (153)
  - callouts: 3 px in the role colour (281)
  - `.callout-important`: 3 px plus a filled tint (290)
  - solution body: 2 px accent (208)
  - `.cell-output pre`: 2 px grey (145)
- **Nesting:** in an exercise, a green rule (exercise) sits above a blue rule (solution) that contains a grey rule (output), three nested levels in about 300 px (`s1-toggle-open.png`). The section goal and the blockquote are visually identical to each other.
- **Fix:** give each role one distinct device:
  - Callouts keep the coloured left rule.
  - `.section-goal` becomes a plain small-caps line with no rule, for example `font-variant: all-small-caps; color: var(--color-muted)`.
  - `.cell-output` gets no rule; use an indent and a `#>` gutter colour instead.
  - Remove `border-radius` from `.objectifs`.

---

## Minor

- **m1. Inline code chips disappear in the objectives box.** `theme.scss:143` gives inline code `background: var(--color-paper-2)`, which is the same colour as `.objectifs` (153). Only the 0.3 em side padding remains visible, and it reads as stray spaces before punctuation: "`dplyr` :", "filter , select , arrange ,", "here::here() ." (`fr-s3-desktop.png`, `s1-desktop.png`). Fix: `.objectifs code { background: var(--color-paper-3); }` and reduce the padding to `.08em .2em`.
- **m2. Reduced motion is only partly honoured.** `html { scroll-behavior: smooth }` (from `smooth-scroll: true`) stays smooth under `prefers-reduced-motion: reduce`. The deck keeps `transition: fade`. Fix: `@media (prefers-reduced-motion: reduce) { html { scroll-behavior: auto !important; } }`. For the deck, set `transition: none`, or apply it conditionally in JS.
- **m3. The session strip leaves an orphan "6" at 375 px** (`s1-375.png`). The strip wraps to two lines, 82 px tall. Fix: below 400 px, hide `.session-nav-label` or set `min-width: 1.8rem; gap: .2rem`.
- **m4. Navbar issues.**
  - On session pages, nothing marks "Sessions" as the current section.
  - The language switch is a one-item dropdown: two clicks to change language, and it sits on a different baseline from the nav links (y≈30 vs 37).
  - Its targets are absolute production URLs, so the switch always leaves a local or preview copy.
  - The FR "Atelier dataviz" link (`_quarto-fr.yml:28`) is absolute too, and it opens a new tab because of `link-external-newwindow`.
  - Fix: style `.navbar .dropdown:has(.dropdown-item.active) > .nav-link` like the active link; render the switch as a direct link to the other language; make the atelier link `../slides/atelier-dataviz.qmd`.
- **m5. Duplicate empty heading.** `seances/seance-6.qmd:247` (and FR:247) has an `### How theme() works` that holds only the section goal, then "Before and after", then a second `### How theme() works` at line 289. Move the goal under line 289 and delete line 247.
- **m6. `page-navigation: true` (`_quarto.yml:32`) has no effect** because there is no sidebar, so no prev/next is rendered. "Next: Session 2" is a plain prose line at the bottom of a 26,000 px page. Give it weight with a `.next-session` block (serif, accent, arrow), or generate one in `course-ui.html` from the session list it already builds.
- **m7. The open solution button looks washed out.** It inherits Quarto's `.callout-header` `opacity: .85`, so the cobalt fill renders pale (`s1-toggle-open.png`). Add `opacity: 1` to `.callout-header[data-bs-toggle="collapse"]`.
- **m8. Dead or contradicted CSS** that will confuse the next edit:
  - h2 border at 102–103 is cancelled at 274.
  - `.card-tile:nth-child(-n+2)` at 227 is reversed at 277, which makes 230 redundant.
  - The callout header tints at 181–184 are overridden by `transparent !important` at 283.
  - The `.num` size at 226 is overridden at 295.
  - The comment "major-third scale on an 18px root" (97) contradicts `$font-size-root: 19px` (48).
- **m9. Two callout styles.** `.callout-important` gets a filled tint (`theme.scss:290`) while the stated rule is "open callouts (left rule only)". "To do at home" on the homepage is a large pale-blue slab. Pick one style.
- **m10. The paper grain does nothing useful.** `body::before` sits at `z-index: 2000` and opacity 0.045 above every element, including text, focus rings and dropdowns. It is imperceptible on most displays, so it adds nothing, but it still lies over content. Either drop it, or put it behind the content: `z-index: -1` on a `position: relative` body with a transparent `main`.
- **m11. The playground is visually off-system.**
  - Without a TOC its column starts at x=247 instead of 174.
  - The editor font is 19 px against 14.3 px for static code.
  - The editor header bar and line-number gutter are white, off the cream palette.
  - The "R Code", "Start Over" and "Run Code" labels and the "Downloading webR" toast stay in English on `/fr/` (acknowledged in the text).
- **m12. Page titles.** The homepage `<title>` repeats itself: "R for data analysis – R for data analysis: beginner level". The French deck's title starts with the English site name.
- **m13. Resources links.** `/resources.html` uses bare URLs as link text, which is noisy and the cause of the mobile overflow in C1. External links open new windows with no indication. Use the titles as link text, and drop `link-external-newwindow` or add an icon or `aria-describedby` "opens in new tab".
- **m14. Heading order.** The TOC title "On this page" is an `h2` that precedes the page `h1` in the DOM (Quarto default). Homepage card titles are `h3` inside `<a>`. Minor for screen-reader outlines.
- **m15. The hamburger keeps a heavy dark square outline after a mouse click** (`navbar-375-open.png`; Bootstrap `.navbar-toggler:focus` box-shadow). Fix: `.navbar-toggler:focus:not(:focus-visible) { box-shadow: none; }`.
- **m16. The objectives box at 375 px** (`.objectifs` padding plus `ul` padding) leaves about 250 px of text measure. Reduce `ul { padding-left: 1.1rem }` inside `.objectifs` on small screens.
- **m17. webR cost.**
  - First visit to `/playground.html`: about 8 MB (webr.r-wasm.org 2.9 MB, repo.r-wasm.org 4.5 MB for knitr, evaluate, rlang, htmltools…). Ready about 3 s on a fast local link.
  - The PostMessage channel is used because GitHub Pages sends no COOP/COEP headers, so there is no SharedArrayBuffer.
  - It is acceptable, but on student mobile data it should be stated ("about 10 MB download"). Only preload packages that the exercises actually use.

---

## Checks that passed (for calibrating the score)

- Contrast is AA or better everywhere measured: body 16:1, muted 6.3:1, callout titles 5.7–6.3:1, links on the important tint 6.3:1, syntax tokens down to 4.6:1 (`at`) on code background. The highlighter background keeps ink at 13.8:1.
- Solution toggles: `role=button`, `tabindex=0`, `aria-expanded` updates, Enter and Space both work, a 3 px accent focus ring shows, and the label switches between "Show solution" and "Hide solution" or "Afficher" and "Masquer la solution".
- `lang="fr"` is set on `/fr/*` and on the deck. The session strip follows the page language, and `aria-current="page"` is correct.
- No page-level horizontal scroll at 375 or 768 px, but only because of the clipping described in C1.
- Print hides the navbar, TOC, session strip and footer, shows every solution, and removes the grain.
- Every figure except the ones listed in M3 has a descriptive, content-bearing `fig-alt`, in both languages.
