# =============================================================================
# 00_prepare_data.R — Builds the course data (run by hand, not at render)
# -----------------------------------------------------------------------------
# Course pages ONLY read the files produced here (data/*.csv), so rendering
# the site needs neither Internet nor the World Bank API. Re-run this script
# to refresh the data, then re-render the site.
#
#   Rscript R/00_prepare_data.R
#
# Outputs:
#   data/wdi_panel.csv      country × year panel (2000-2023), all WDI countries
#   data/wdi_3countries.csv current GDP: United States, China, India (2000-2020)
#   data/wid_gini.csv       cleaned WID Gini (China, India, United States)
#   data.zip                archive students download
# =============================================================================

library(jsonlite)
library(dplyr)
library(readr)
library(stringr)
library(here)

# --- 1. WDI panel: all countries, development indicators ---------------------
indicators <- c(
  gdp            = "NY.GDP.MKTP.CD",     # GDP, current US$
  gdp_pc_ppp     = "NY.GDP.PCAP.PP.KD",  # GDP per capita, PPP, constant 2021 int. $
  population     = "SP.POP.TOTL",        # total population
  life_exp       = "SP.DYN.LE00.IN",     # life expectancy at birth (years)
  gini           = "SI.POV.GINI",        # Gini index (0-100)
  elec_access    = "EG.ELC.ACCS.ZS"      # access to electricity (% of population)
)

# Direct calls to the World Bank API v2. (The WDI package does the same thing,
# and the course teaches it, but WDI 2.7.10 hung on this machine in 2026-10.)
wb_api <- "https://api.worldbank.org/v2/"
get_indicator <- function(code, name) {
  x <- fromJSON(paste0(wb_api, "country/all/indicator/", code,
                       "?date=2000:2023&format=json&per_page=20000"))[[2]]
  tibble(iso3c = x$countryiso3code, year = as.integer(x$date), !!name := x$value)
}
wdi_values <- purrr::imap(indicators, \(code, name) get_indicator(code, name)) |>
  purrr::reduce(full_join, by = c("iso3c", "year"))

countries <- fromJSON(paste0(wb_api, "country?format=json&per_page=400"))[[2]]
countries <- tibble(iso3c = countries$id, country = countries$name,
                    region = str_trim(countries$region$value),
                    income = str_trim(countries$incomeLevel$value))

wdi_brut <- inner_join(countries, wdi_values, by = "iso3c")

wdi_panel <- wdi_brut |>
  filter(region != "Aggregates", !is.na(region)) |>   # drop regional aggregates
  select(country, iso3c, year, region, income, gdp, gdp_pc_ppp,
         population, life_exp, gini, elec_access) |>
  arrange(country, year)

stopifnot(!anyDuplicated(wdi_panel[c("iso3c", "year")]),
          n_distinct(wdi_panel$iso3c) > 200)
write_csv(wdi_panel, here("data", "wdi_panel.csv"))

# --- 2. Running example from the original course: 3 countries, current GDP ---
wdi_3countries <- wdi_panel |>
  filter(iso3c %in% c("USA", "CHN", "IND"), year <= 2020) |>
  select(country, iso3c, year, gdp)
write_csv(wdi_3countries, here("data", "wdi_3countries.csv"))

# --- 3. WID: the raw file has a comment line and multi-line labels; read it
#        properly and recode countries to ISO3 so joins use codes, not names.
wid <- read_delim(here("data", "raw", "WID_Data.csv"), delim = ";",
                  skip = 1, col_names = c("country_wid", "indicator",
                                          "percentile", "year", "gini"),
                  show_col_types = FALSE) |>
  mutate(iso3c = recode(country_wid, China = "CHN", India = "IND", USA = "USA")) |>
  select(iso3c, country_wid, year, gini)

stopifnot(nrow(wid) == 63, !anyNA(wid$gini), setequal(wid$iso3c, c("CHN", "IND", "USA")))
write_csv(wid, here("data", "wid_gini.csv"))

# --- 4. Student archive (no macOS system files) -----------------------------
zip_path <- here("data.zip")
if (file.exists(zip_path)) file.remove(zip_path)
fichiers <- c(list.files(here("data"), pattern = "\\.csv$", full.names = TRUE),
              list.files(here("data", "raw"), full.names = TRUE),
              here("R", "theme_cours.R"))   # shared ggplot theme used by sessions
zip::zip(zip_path, files = sub(paste0(here(), "/"), "", fichiers, fixed = TRUE),
         root = here())   # relative paths in the archive, no setwd()

message("OK: ", nrow(wdi_panel), " WDI rows, ", nrow(wid), " WID rows.")
