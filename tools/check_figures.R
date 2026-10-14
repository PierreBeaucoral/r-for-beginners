# Flag figures whose text runs off the image: pixels that contrast with the
# background in the outer columns of a PNG mean a title, label or caption was
# cut by the image border (typically a long French title not wrapped).
# Usage: Rscript tools/check_figures.R   (checks every frozen figure, EN and FR)
files <- Sys.glob(c("_freeze/*/figure-*/*.png", "_freeze/*/*/figure-*/*.png"))
cut_off <- vapply(files, function(f) {
  img <- png::readPNG(f)
  lum <- if (length(dim(img)) == 3) 0.2126 * img[, , 1] + 0.7152 * img[, , 2] + 0.0722 * img[, , 3] else img
  w <- ncol(lum)
  bg <- lum[1, 1]                      # the figure's own background (cream, white or dark)
  edge <- lum[, c(1:2, (w - 3):w)]
  sum(abs(edge - bg) > 0.35) > 3       # a few contrasting pixels on the border = cut text
}, logical(1))
if (any(cut_off)) {
  cat("Text touches the image edge (probably cut) in:\n", paste0("  - ", files[cut_off], collapse = "\n"), "\n")
  quit(status = 1)
}
cat("Figures OK:", length(files), "PNG checked, no text cut at the edges.\n")
