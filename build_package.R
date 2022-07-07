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


usethis::use_github_action_check_standard()
usethis::use_github_action("pkgdown")
usethis::use_github_actions_badge()


cranlogs::cranlogs_badge(package_name = "tidywpp", summary = "grand-total")



library(tidyverse)
library(tidywpp)
wpp_indicators %>%
  group_by_at(c(7, 1:3, 8)) %>%
  summarise(wpp = paste(unique(wpp), collapse = ", ")) %>%
  arrange(topic, name) %>%
  knitr::kable() %>%
  write_lines('temp.md')

wpp_indicators %>%
  select(contains("var")) %>%
  distinct() %>%
  arrange(var_id) %>%
  knitr::kable() %>%
  write_lines('temp.md')

file.remove("temp.md")
