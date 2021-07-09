library(usethis)
create_tidy_package(path = "Github/tidywpp")
# usethis::use_badge()
usethis::use_pipe()
usethis::use_tibble()
usethis::use_build_ignore(c("tests", "build-data", "build_package.R", "data-raw"))

roxygen2::roxygenise()

usethis::use_spell_check()

library(tidyverse)
library(tidywpp)
wpp_indicators %>%
  select(1:2, file_group) %>%
  distinct() %>%
  arrange(name) %>%
  knitr::kable() %>%
  write_lines('temp.md')

wpp_indicators %>%
  select(contains("var")) %>%
  distinct() %>%
  knitr::kable() %>%
  write_lines('temp.md')

file.remove("temp.md")
