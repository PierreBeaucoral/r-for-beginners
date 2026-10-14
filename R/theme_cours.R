# ------------------------------------------------------------------
# Shared ggplot theme and palettes for all course figures.
# Usage: source(here::here("R", "theme_cours.R"))
# ------------------------------------------------------------------
suppressPackageStartupMessages(library(ggplot2))

#' Course palette: named colours (consistent with the site).
#' - principal: site blue; accent: red to highlight one element;
#' - gris: context / non-highlighted observations.
pal_cours <- c(principal = "#1e539e", accent = "#c0392b", gris = "grey65")

#' Categorical palette (Okabe-Ito, colour-blind safe) for the
#' World Bank regions. Names are the English labels of the
#' `region` column; colours are fixed so that a region keeps
#' the same colour across charts.
#' Note: 7 regions, 7 Okabe-Ito colours (black excluded).
pal_regions <- c(
  "East Asia & Pacific"        = "#0072B2",
  "Europe & Central Asia"      = "#56B4E9",
  "Latin America & Caribbean"  = "#009E73",
  "Middle East, North Africa, Afghanistan & Pakistan" = "#E69F00",  # WB label since 2024
  "North America"              = "#999999",
  "South Asia"                 = "#CC79A7",
  "Sub-Saharan Africa"         = "#D55E00"
)

#' Course theme, based on theme_minimal().
#' @param base_size Base font size (default 14).
#' @return A ggplot2 `theme` object.
theme_cours <- function(base_size = 14) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title.position   = "plot",
      plot.caption.position = "plot",
      plot.title    = element_text(face = "bold", hjust = 0, size = rel(1.15)),
      plot.subtitle = element_text(colour = "grey35", hjust = 0),
      plot.caption  = element_text(colour = "grey40", size = rel(0.75), hjust = 0),
      axis.title    = element_text(colour = "grey25"),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(colour = "grey88"),
      legend.position  = "bottom",
      legend.title     = element_text(face = "bold"),
      plot.margin      = margin(8, 12, 8, 8),
      plot.background  = element_rect(fill = "#fcfaf6", colour = NA)   # same paper as the site
    )
}

# Applied by default to every plot in the session
theme_set(theme_cours())

# ------------------------------------------------------------------
# Numbers written in the text of the course pages (inline `r ...`).
# The French site is rendered with the Quarto profile "fr" (babelquarto),
# so the same code prints 0.86 / $26,480 / 31% in English and
# 0,86 / 26 480 $ / 31 % in French. Students do not need these helpers.
# ------------------------------------------------------------------

#' Language of the page being rendered: "fr" or "en" (default, e.g. in RStudio).
course_lang <- function() {
  if ("fr" %in% strsplit(Sys.getenv("QUARTO_PROFILE"), ",")[[1]]) "fr" else "en"
}

#' Number for prose: nb(0.8567, 2) gives "0.86" (EN) or "0,86" (FR).
nb <- function(x, digits = 1) {
  fr <- course_lang() == "fr"
  formatC(x, format = "f", digits = digits,
          big.mark = if (fr) " " else ",", decimal.mark = if (fr) "," else ".")
}

#' Dollar amount for prose: "$26,480" (EN) or "26 480 $" (FR).
#' The $ is escaped (\\$) because two plain $ in one paragraph are read as math.
nb_dollar <- function(x, digits = 0) {
  if (course_lang() == "fr") paste0(nb(x, digits), " \\$") else paste0("\\$", nb(x, digits))
}

#' Percentage for prose (x already in percent): "31%" (EN) or "31 %" (FR).
nb_pct <- function(x, digits = 0) {
  if (course_lang() == "fr") paste0(nb(x, digits), " %") else paste0(nb(x, digits), "%")
}
