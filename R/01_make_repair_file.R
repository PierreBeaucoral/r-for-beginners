# ------------------------------------------------------------------
# Builds data/raw/repair_me.csv, the messy file of the Session 3
# "Repair this analysis" exercise (and used in Session 2).
# Real World Bank values (data/wdi_panel.csv) for six countries, 2015 and
# 2019, with four problems planted on purpose:
#   1. gdp_pc_ppp stored as text with a thousands separator ("2,967.7")
#   2. inconsistent country labels ("Kenya", " kenya", "KENYA ")
#   3. a duplicated country-year (Ghana 2019 appears twice)
#   4. a missing life expectancy written "n/a" (Benin 2015)
# plus ISO numeric codes with leading zeros ("004").
# What each reader shows (readr 2.2): base read.csv() exposes everything (GDP as
# text, codes as 4, spaces kept); read_csv() quietly copes with some of it
# (parses "2,967.7", keeps "004" as text, trims spaces) but still shows the case
# variants, "n/a" (life_exp read as text) and the duplicate. Session 2 uses that
# contrast; Session 3's exercise reads every column as text and repairs it all.
# Run from the project root: Rscript R/01_make_repair_file.R
# ------------------------------------------------------------------
suppressPackageStartupMessages({ library(dplyr); library(readr); library(here) })

iso_num <- c(AFG = "004", AGO = "024", BGD = "050", BEN = "204", GHA = "288", KEN = "404")

clean <- read_csv(here("data", "wdi_panel.csv"), show_col_types = FALSE) |>
  filter(iso3c %in% names(iso_num), year %in% c(2015, 2019)) |>
  transmute(country, iso_num = iso_num[iso3c], year,
            gdp_pc_ppp = round(gdp_pc_ppp, 1), life_exp = round(life_exp, 1)) |>
  arrange(country, year)

messy <- clean |>
  mutate(
    gdp_pc_ppp = formatC(gdp_pc_ppp, format = "f", digits = 1, big.mark = ","),        # 1: text
    life_exp   = if_else(country == "Benin" & year == 2015, "n/a", as.character(life_exp)), # 4: "n/a"
    country    = case_when(                                                             # 2: labels
      country == "Kenya" & year == 2015 ~ " kenya",
      country == "Kenya" & year == 2019 ~ "KENYA ",
      .default = country)
  ) |>
  bind_rows(filter(clean, country == "Ghana", year == 2019) |>                          # 3: duplicate
              mutate(gdp_pc_ppp = formatC(gdp_pc_ppp, format = "f", digits = 1, big.mark = ","),
                     life_exp = as.character(life_exp)))

write_csv(messy, here("data", "raw", "repair_me.csv"), na = "")
stopifnot(nrow(messy) == 13)
message("OK: data/raw/repair_me.csv (13 rows, 12 country-years once repaired)")
