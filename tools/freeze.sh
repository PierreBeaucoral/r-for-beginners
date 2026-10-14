#!/usr/bin/env bash
# Refresh _freeze/ for every page with R code, in both languages, so that CI
# (babelquarto::render_website) re-runs no R at all. Run it after editing any
# page, then commit _freeze/. Why: some code (readxl on .xls) crashes R on the
# Linux CI runner, and frozen results also keep deploys fast.
#
# French pages are rendered with the "fr" profile, so nb() helpers print
# French numbers. Rendering X.fr.qmd stores figure links under X.fr_files/,
# but babelquarto renders the French page as X.qmd (figures in X_files/):
# the last step rewrites those links, otherwise every French figure 404s.
set -euo pipefail
cd "$(dirname "$0")/.."
export PATH=$(echo "$PATH" | tr ':' '\n' | grep -v anaconda3 | paste -sd: -)   # broken anaconda pandoc

pages=(index seances/seance-1 seances/seance-2 seances/seance-3 seances/seance-4 seances/seance-5 seances/seance-6 slides/atelier-dataviz)
for p in "${pages[@]}"; do
  quarto render "$p.qmd" --profile en --quiet
  [ -f "$p.fr.qmd" ] && quarto render "$p.fr.qmd" --profile fr --quiet
done

for json in _freeze/*.fr/execute-results/html.json _freeze/*/*.fr/execute-results/html.json; do
  [ -f "$json" ] || continue
  page=$(basename "$(dirname "$(dirname "$json")")" .fr)        # e.g. seance-2
  sed -i.bak "s/${page}\.fr_files/${page}_files/g" "$json" && rm "$json.bak"
done
echo "Freeze refreshed (EN + FR). Commit _freeze/."
