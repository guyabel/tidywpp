library(tidyverse)
wpp_var <- read_csv("./build-data/meta/var.csv") %>%
  select(-file_group) %>%
  distinct()

library(wpp2019)
data("UNlocations")
d0 <- read_csv("./build-data/meta/loc.csv")
d1 <- UNlocations %>%
  select(country_code, reg_name, area_name) %>%
  as_tibble()
wpp_loc <- d0 %>%
  left_join(d1, by = c("LocID" = "country_code")) %>%
  mutate(reg_name = case_when(
    LocID %in% c(124, 840, 60, 304, 666) ~ "Northern America",
    LocID %in% c(36, 554) ~ "Australia and New Zealand",
    TRUE ~ reg_name
  ))
wpp_loc %>%
  filter(LocID < 900, reg_name == "") %>%
  select(-wpp) %>%
  distinct()

wpp_time <- read_csv("./build-data/meta/time.csv")
wpp_age <- read_csv("./build-data/meta/age.csv")
wpp_sex <- read_csv("./build-data/meta/sex.csv")


usethis::use_data(wpp_var, wpp_loc, wpp_time, wpp_age, wpp_sex,
                  overwrite = TRUE, internal = TRUE)
