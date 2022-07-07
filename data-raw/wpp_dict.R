library(countrycode)
library(tidyverse)

wpp_dict <- tidywpp:::wpp_loc %>%
  filter(LocID < 900) %>%
  select(-wpp) %>%
  distinct()

old_names <-
wpp_dict %>%
  # group_by(ISO3_code) %>%
  # group_by(Location) %>%
  group_by(LocID) %>%
  mutate(n = n()) %>%
  filter(n > 1) %>%
  arrange(LocID) %>%
  slice(1) %>%
  pull(Location)

wpp_dict <- wpp_dict %>%
  filter(!(Location %in% old_names))

# wpp_dict <- tibble(
#   country.name.en = codelist$country.name.en,
#   country.name.en.regex = codelist$country.name.en.regex,
#   iso3n = codelist$iso3n,
#   iso2c = codelist$iso2c,
#   iso3c = codelist$iso3c,
#   area  = ifelse(codelist$un.region.name == "Americas",
#                  codelist$un.regionsub.name,
#                  codelist$un.region.name),
#   region = ifelse(codelist$un.regionsub.name %in% c("Sub-Saharan Africa", "Latin America and the Caribbean"),
#                   codelist$un.regionintermediate.name,
#                   codelist$un.regionsub.name)
# ) %>%
#   mutate(  region = ifelse(region == "South-eastern Asia", "South-Eastern Asia", region))

usethis::use_data(wpp_dict, overwrite = TRUE)
