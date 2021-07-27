library(tidyverse)

d <- read_csv("./data-host/meta/indicators.csv")
b <- read_csv("./data-raw/wpp_bulk.csv")

b0 <-
  b %>%
  select(contains("column"), url) %>%
  rename(name = 1) %>%
  select(-column_footnote) %>%
  distinct() %>%
  mutate(file_group = str_remove(string = url, pattern = ".*WPP2019_"),
         file_group = str_remove(string = file_group, pattern = ".csv"),
         file_group = str_remove(string = file_group, pattern = "_Medium|_OtherVariants"),
         file_group = str_remove(string = file_group, pattern = "_\\d{4}-\\d{4}")) %>%
  select(-url) %>%
  distinct()

b1 <- b0 %>%
  filter(file_group == "PopulationByAgeSex") %>%
  mutate(file_group = "PopulationByAgeSex_5x5")

b2 <- b0 %>%
  bind_rows(b1)

x <- c("Location", "MidPeriod", "AgeGrpStart", "AgeGrpSpan", "Sex",
       "LocID", "Time", "AgeGrp", "SexID")

d0 <- d %>%
  filter(!col_name %in% x) %>%
  rename(name = col_name) %>%
  distinct() %>%
  left_join(b2)

# check
d0 %>%
  filter(is.na(column_details)) %>%
  distinct(name, file_group)


b3 <- d0 %>%
  distinct(file_group) %>%
  mutate(
    file_group_details =
      c("Fertility indicators, by age, annualy and 5-year periods",
        "Several indicators in 5-year periods",
        "Population by 5-year age groups, every 5 years",
        "Population by 5-year age groups, annualy",
        "Total population by sex, annually",
        "Abridged life tables by sex and both sexes combined providing a set of values showing the mortality experience of a hypothetical group of infants born at the same time and subject throughout their lifetime to the specific mortality rates of a given period",
        "Population interpolated by single age and single year"
      ))


d1 <- d0 %>%
  left_join(b3) %>%
  rename(variant = Variant,
         var_id = VarID,
         details = column_details) %>%
  relocate(name, details, var_id, variant) %>%
  relocate(-wpp) %>%
  mutate(file_group = fct_inorder(file_group)) %>%
  arrange(-wpp, var_id, file_group, name) %>%
  mutate(file_group = as.character(file_group))

wpp_indicators <- d1
usethis::use_data(wpp_indicators, overwrite = TRUE)
