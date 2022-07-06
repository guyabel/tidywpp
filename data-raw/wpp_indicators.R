library(tidyverse)
library(janitor)

d <- read_csv("./data-host/meta/indicators.csv")
b <- read_csv("./data-raw/wpp_bulk.csv")
n <- read_csv("I:\\ADRI\\project\\data-unpd\\wpp\\data-zip-csv\\WPP2022-CSV-data\\WPP2022_Demographic_Indicators_notes.csv")

b0 <- b %>%
  select(indicator, column_name, column_details) %>%
  rename(name = column_name,
         indicator_name = column_details)

n0 <- n %>%
  rename(name = 3) %>%
  clean_names() %>%
  select(-1)

n1 <- b0 %>%
  filter(!(name %in% n0$name)) %>%
  distinct() %>%
  separate(col = indicator_name, sep = "\\(", into = c("indicator_name", "unit")) %>%
  mutate(
    indicator_name = ifelse(indicator == "life_table", paste0(indicator_name, "(", unit), indicator_name),
    unit = ifelse(indicator == "life_table", NA, str_sub(string = unit, end = -2)),
    unit = case_when(
      name == "PASFR" ~ "percentage",
      name %in% c("ex", "ax", "Tx", "Lx") ~ "years",
      name == "Sx" ~ "proportion",
      name == "mx" ~ "rate",
      name %in% c("Lx", "lx", "dx") ~ "hypothetical cohort persons",
      name %in% c("qx", "px") ~ "probability",
      TRUE ~ unit
    ),
    topic = case_when(
      indicator == "life_table" ~ "Mortality",
      indicator == "fertility" ~ "Fertility",
      str_detect(string = indicator, pattern = "pop") ~ "Population",
      name == "NRR" ~ "Fertility",
      TRUE ~ "Population"
    )
  ) %>%
  select(-indicator)

n2 <- n0 %>%
  bind_rows(n1)

x <- c("Location", "MidPeriod", "AgeGrpStart", "AgeGrpSpan", "Sex",
       "LocID", "Time", "AgeGrp", "SexID")
x <- c(x, "SortOrder", "Notes", "ISO3_code", "ISO2_code", "SDMX_code",
       "LocTypeID", "LocTypeName", "ParentID")

d0 <- d %>%
  clean_names() %>%
  rename(name = col_name) %>%
  left_join(n2) %>%
  filter(!name %in% x) %>%
  mutate(unit = ifelse(str_detect(string = file_group, pattern = "Percent"), "percentage", unit)) %>%
  rename(file_group0 = file_group) %>%
  mutate(file_group = case_when(
    file_group0 == "Life_Table" ~ "Life_Table_Abridged",
    file_group0 == "Fertility_by_Age" ~ "Fertility_by_Age5",
    file_group0 == "PopulationByAgeSex" ~ "PopulationByAge5GroupSex",
    TRUE ~ file_group0
  ))

# taken from table in csv download page
b3 <- d0 %>%
  distinct(file_group) %>%
  mutate(
    file_group_details =
      c("Fertility indicators, by 5-year age, annualy and 5-year periods",
        "Several indicators in 5-year periods",
        "Population on 01 July by 5-year age groups, annualy",
        "Population on 01 July by 5-year age groups, every 5 years",
        "Total population on 01 July by sex, annually",
        "Abridged life tables by sex and both sexes combined providing a set of values showing the mortality experience of a hypothetical group of infants born at the same time and subject throughout their lifetime to the specific mortality rates of a given period",
        "Population on 01 July interpolated by single age and single year",
        "Demographic Indicators",
        "Fertility indicators, by single age, annualy",
        "Single age life tables up to age 100",
        "Population on 01 January, by 5-year age groups",
        "Population on 01 January, by single age",
        "Percentage of population on 01 July, by 5-year age groups",
        "Percentage of population on 01 July, by single age",
        "Population exposure (01 Jan - 31 Dec), by 5-year age groups",
        "Population exposure (01 Jan - 31 Dec), by single age"
      ))
table(d0$file_group0, d0$wpp)
table(d0$file_group, d0$wpp)

wpp_indicators <- d0 %>%
  rename(details = indicator_name) %>%
  relocate(name, details, unit, var_id, variant, wpp, topic, file_group, file_group0) %>%
  left_join(b3)

usethis::use_data(wpp_indicators, overwrite = TRUE)


# d <- read_csv("./data-host/meta/indicators.csv")
# b <- read_csv("./data-raw/wpp_bulk.csv")
#
# b0 <-
#   b %>%
#   select(contains("column"), url) %>%
#   rename(name = 1) %>%
#   select(-column_footnote) %>%
#   distinct() %>%
#   mutate(file_group = str_remove(string = url, pattern = ".*WPP2019_"),
#          file_group = str_remove(string = file_group, pattern = ".csv"),
#          file_group = str_remove(string = file_group, pattern = "_Medium|_OtherVariants"),
#          file_group = str_remove(string = file_group, pattern = "_\\d{4}-\\d{4}")) %>%
#   select(-url) %>%
#   distinct()
#
# b1 <- b0 %>%
#   filter(file_group == "PopulationByAgeSex") %>%
#   mutate(file_group = "PopulationByAgeSex_5x5")
#
# b2 <- b0 %>%
#   bind_rows(b1)
#
# x <- c("Location", "MidPeriod", "AgeGrpStart", "AgeGrpSpan", "Sex",
#        "LocID", "Time", "AgeGrp", "SexID")
#
# d0 <- d %>%
#   filter(!col_name %in% x) %>%
#   rename(name = col_name) %>%
#   distinct() %>%
#   left_join(b2)
#
# # check
# d0 %>%
#   filter(is.na(column_details)) %>%
#   distinct(name, file_group)
#
#
# b3 <- d0 %>%
#   distinct(file_group) %>%
#   mutate(
#     file_group_details =
#       c("Fertility indicators, by age, annualy and 5-year periods",
#         "Several indicators in 5-year periods",
#         "Population by 5-year age groups, every 5 years",
#         "Population by 5-year age groups, annualy",
#         "Total population by sex, annually",
#         "Abridged life tables by sex and both sexes combined providing a set of values showing the mortality experience of a hypothetical group of infants born at the same time and subject throughout their lifetime to the specific mortality rates of a given period",
#         "Population interpolated by single age and single year"
#       ))
#
#
# d1 <- d0 %>%
#   left_join(b3) %>%
#   rename(variant = Variant,
#          var_id = VarID,
#          details = column_details) %>%
#   relocate(name, details, var_id, variant) %>%
#   relocate(-wpp) %>%
#   mutate(file_group = fct_inorder(file_group)) %>%
#   arrange(-wpp, var_id, file_group, name) %>%
#   mutate(file_group = as.character(file_group))
#
# wpp_indicators <- d1
# usethis::use_data(wpp_indicators, overwrite = TRUE)
