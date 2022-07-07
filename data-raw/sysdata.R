library(tidyverse)
wpp_var <- read_csv("./data-host/meta/var.csv") %>%
  select(-file_group) %>%
  distinct()

library(wpp2019)
data("UNlocations")

d0 <- read_csv("./data-host/meta/loc.csv")
d1 <- UNlocations %>%
  select(country_code, reg_name, area_name) %>%
  as_tibble()
d2 <- read_csv("I:\\ADRI\\project\\data-unpd\\wpp\\data-zip-csv\\WPP2022-CSV-data/WPP2022_Demographic_Indicators_Medium.csv") %>%
  distinct(LocID, ISO3_code, ISO2_code)

wpp_loc <- d0 %>%
  left_join(d1, by = c("LocID" = "country_code")) %>%
  mutate(reg_name = case_when(
    LocID %in% c(124, 840, 60, 304, 666) ~ "Northern America",
    LocID %in% c(36, 554) ~ "Australia and New Zealand",
    TRUE ~ reg_name
  )) %>%
  select(-LocTypeID, -LocTypeName) %>%
  left_join(d2)

wpp_loc %>%
  filter(LocID < 900, is.na(reg_name) | is.na(ISO3_code)) %>%
  # filter(LocID < 900, reg_name == "") %>%
  select(-wpp) %>%
  distinct()

wpp_loc <- wpp_loc %>%
  mutate(
    reg_name = case_when(
      Location == "Netherlands Antilles" ~ "Caribbean",
      Location == "Serbia and Montenegro" ~ "Southern Europe",
      Location == "Sudan (Former)" ~ "Southern Europe",
      # Location == "Channel Islands" ~ "Southern Europe",
      Location == "Pitcairn" ~ "Polynesia",
      Location == "Guernsey" ~ "Northern Europe",
      Location == "Jersey" ~ "Northern Europe",
      Location == "Kosovo (under UNSC res. 1244)" ~ "Southern Europe",
      TRUE ~ reg_name
    ),
    area_name = case_when(
      Location == "Netherlands Antilles" ~ "Latin America and the Caribbean",
      Location == "Serbia and Montenegro" ~ "Europe",
      Location == "Sudan (Former)" ~ "Europe",
      # Location == "Channel Islands" ~ "Southern Europe",
      Location == "Pitcairn" ~ "Oceania",
      Location == "Guernsey" ~ "Europe",
      Location == "Jersey" ~ "Europe",
      Location == "Kosovo (under UNSC res. 1244)" ~ "Europe",
      TRUE ~ area_name
    ),
    ISO3_code = case_when(
      Location == "Netherlands Antilles" ~ "ANT",
      Location == "Serbia and Montenegro" ~ "SCG",
      Location == "Sudan (Former)" ~ "SUD",
      Location == "Channel Islands" ~ "CHI",
      Location == "Pitcairn" ~ "PCN",
      # Location == "Namibia" ~ "NAM",
      TRUE ~ ISO3_code
    ),
    ISO2_code = case_when(
      Location == "Netherlands Antilles" ~ "AN",
      Location == "Serbia and Montenegro" ~ "CS",
      Location == "Sudan (Former)" ~ "SU",
      # Location == "Channel Islands" ~ "CHI",
      Location == "Pitcairn" ~ "PN",
      Location == "Namibia" ~ "NA",
      TRUE ~ ISO2_code
    )
  )

wpp_loc %>%
  filter(LocID < 900, is.na(reg_name) | is.na(ISO3_code) | is.na(ISO2_code)) %>%
  # filter(LocID < 900, reg_name == "") %>%
  select(-wpp) %>%
  distinct()

wpp_time <- read_csv("./data-host/meta/time.csv") %>%
  rename(file = file_group)
wpp_age <- read_csv("./data-host/meta/age.csv") %>%
  rename(file = file_group)
wpp_sex <- read_csv("./data-host/meta/sex.csv") %>%
  rename(file = file_group)


usethis::use_data(wpp_var, wpp_loc, wpp_time, wpp_age, wpp_sex,
                  overwrite = TRUE, internal = TRUE)
