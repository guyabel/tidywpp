library(tidyverse)
wpp_var <- read_csv("./build-data/meta/var.csv") %>%
  select(-file_group) %>%
  distinct()

wpp_loc <- read_csv("./build-data/meta/loc.csv")
wpp_time <- read_csv("./build-data/meta/time.csv")
wpp_age <- read_csv("./build-data/meta/age.csv")
wpp_sex <- read_csv("./build-data/meta/sex.csv")

usethis::use_data(wpp_var, wpp_loc, wpp_time, wpp_age, wpp_sex,
                  overwrite = TRUE, internal = TRUE)
