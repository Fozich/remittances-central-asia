# 01_build_panel.R
# Builds a country-year panel for UZB, KGZ, TJK (2009-2024):
#   remit_gdp       remittances received, % of GDP   (dependent variable)
#   rus_gdp_growth  Russian GDP growth, %            (demand for migrant labour)
#   rub_depr        log-change of RUB/USD rate, %    (+ = ruble weaker; remittances
#                                                      sent in rubles buy fewer dollars)

# install.packages(c("WDI", "dplyr", "readr"))  # first run only
library(WDI)
library(dplyr)
library(readr)

remit <- WDI(c("UZ", "KG", "TJ"), "BX.TRF.PWKR.DT.GD.ZS", start = 2008, end = 2025) |>
  rename(remit_gdp = 5)

rus <- WDI("RU", c("NY.GDP.MKTP.KD.ZG", "PA.NUS.FCRF"), start = 2008, end = 2025) |>
  rename(rus_gdp_growth = NY.GDP.MKTP.KD.ZG, rub_usd = PA.NUS.FCRF) |>
  arrange(year) |>
  # 100 * diff(log) approximates the % depreciation of the ruble year on year
  mutate(rub_depr = 100 * (log(rub_usd) - lag(log(rub_usd)))) |>
  select(year, rus_gdp_growth, rub_depr)

panel <- remit |>
  inner_join(rus, by = "year") |>
  filter(!is.na(remit_gdp), !is.na(rub_depr)) |>
  transmute(iso3c, country, year,
            remit_gdp = round(remit_gdp, 2),
            rus_gdp_growth = round(rus_gdp_growth, 2),
            rub_depr = round(rub_depr, 2)) |>
  arrange(iso3c, year)

write_csv(panel, "data/panel.csv")
