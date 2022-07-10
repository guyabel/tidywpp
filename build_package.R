library(usethis)
create_tidy_package(path = "Github/tidywpp")
# usethis::use_badge()
usethis::use_pipe()
usethis::use_tibble()
usethis::use_build_ignore(c("tests", "data-host", "build_package.R", "data-raw"))

roxygen2::roxygenise(clean = TRUE)

devtools::check(run_dont_test = FALSE)

usethis::use_spell_check()
usethis::use_release_issue()
usethis::use_citation()
usethis::use_package()
usethis::use_tidy_thanks()
usethis::use_vignette(name = "tidywpp")

usethis::use_github_action_check_standard()
usethis::use_github_action("pkgdown")
usethis::use_github_actions_badge()


cranlogs::cranlogs_badge(package_name = "tidywpp", summary = "grand-total")


library(fontawesome)
library(tidyverse)
library(tidywpp)
unique(wpp_indicators$file)
f <- c("Demographic_Indicators",
"Fertility_by_Age5",
"Fertility_by_Age1",
"Life_Table_Abridged",
"Life_Table_Complete",
"TotalPopulationBySex",
"PopulationByAgeSex_5x5",
"PopulationByAge5GroupSex",
"PopulationBySingleAgeSex",
"Population1JanuaryByAge5GroupSex",
"Population1JanuaryBySingleAgeSex",
"PopulationExposureByAge5GroupSex",
"PopulationExposureBySingleAgeSex",
"PopulationByAge5GroupSex_Percentage",
"PopulationBySingleAgeSex_Percentage")

wpp_indicators %>%
  select(topic, name, details, unit, file, wpp) %>%
  mutate(exists = 1,
         wpp = paste0("WPP", wpp)) %>%
  pivot_wider(names_from = wpp, values_from = exists, values_fn = {sum}) %>%
  mutate(across(contains("WPP"), ~ ifelse(is.na(.x), as.character(fa("fas fa-square", )), as.character(fa("fas fa-check-square"))))) %>%
  mutate(file = factor(file, levels = f)) %>%
  arrange(topic, name, file) %>%
  filter(topic == unique(topic)[1]) %>%
  select(-topic) %>%
  knitr::kable(
    align = c("llllcccccccccccc"),
    col.names = str_replace_all(string = colnames(.), pattern = "WPP", replacement = "WPP ")
  ) %>%
  write_lines('temp.md')

wpp_indicators %>%
  group_by_at(c(7, 1:3, 8)) %>%
  summarise(wpp = paste(unique(wpp), collapse = ", ")) %>%
  arrange(topic, name, file) %>%
  knitr::kable() %>%
  write_lines('temp.md')

wpp_indicators %>%
  select(contains("var")) %>%
  distinct() %>%
  arrange(var_id) %>%
  knitr::kable() %>%
  write_lines('temp.md')

file.remove("temp.md")
