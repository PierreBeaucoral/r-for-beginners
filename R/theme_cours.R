# ------------------------------------------------------------------
# Shared ggplot theme and palettes for all course figures.
# Usage: source(here::here("R", "theme_cours.R"))
# ------------------------------------------------------------------
suppressPackageStartupMessages(library(ggplot2))

#' Course palette: named colours (consistent with the site).
#' - principal: site blue; accent: red to highlight one element;
#' - gris: context / non-highlighted observations.
pal_cours <- c(principal = "#1f4e79", accent = "#c0392b", gris = "grey65")

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
      plot.margin      = margin(8, 12, 8, 8)
    )
}

# Applied by default to every plot in the session
theme_set(theme_cours())
