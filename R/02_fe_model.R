# 02_fe_model.R
# Country fixed-effects regression of remittance inflows on Russian
# macro conditions. Country FE absorb level differences (Tajikistan
# receives far more than Uzbekistan); identification comes from
# within-country variation over time.
#
# No year FE: the regressors are common shocks (identical for every
# country in a given year), so year dummies would absorb them entirely.

# install.packages(c("fixest", "readr"))  # first run only
library(fixest)
library(readr)

panel <- read_csv("data/panel.csv")

# Baseline: full sample
m1 <- feols(remit_gdp ~ rus_gdp_growth + rub_depr | iso3c,
            data = panel, vcov = "hetero")

# Robustness: drop 2022. Russia contracted that year, yet remittances
# spiked (transfers around the mobilization), which works against the
# labour-demand channel and masks the relation.
m2 <- feols(remit_gdp ~ rus_gdp_growth + rub_depr | iso3c,
            data = subset(panel, year != 2022), vcov = "hetero")

etable(m1, m2,
       headers = c("Full sample", "Excl. 2022"),
       digits = 3)
