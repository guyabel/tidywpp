library(tidyverse)
library(readxl)

d <- read_excel(path = "data-raw/un_bulk.xlsx")

d0 <- d %>%
  rename(sub_group = 2,
         details = 8) %>%
  fill(ind) %>%
  group_by(ind) %>%
  fill(sub_group, file1_name, file2_name, file1_url, file2_url) %>%
  select(-3) %>%
  drop_na(details) %>%
  group_by(ind) %>%
  mutate(file_title = details[1]) %>%
  filter(file_title != details,
         !str_detect(string = details, pattern = "not published for probabilistic projections")) %>%
  separate(col = details, into = c("column_name", "column_details"), sep = ": ") %>%
  pivot_longer(file1_name:file2_url, names_to = c("file", "type"), names_sep = "_") %>%
  drop_na(value) %>%
  pivot_wider(names_from = type, values_from = value) %>%
  rename(file_name = name,
         file_url = url,
         file_group = sub_group) %>%
  mutate(file = str_remove(file, "file")) %>%
  ungroup() %>%
  mutate(#ind = ifelse(ind == "pop_age1_sex" & file == 1, "pop_age1_sex_past", ind),
         #ind = ifelse(ind == "pop_age1_sex" & file == 2, "pop_age1_sex_future", ind),
         variant = word(file_name),
         variant = str_to_lower(variant),
         details2 = str_remove(string = file_name,
                               pattern = word(file_name, end = 2)),
         details2 = str_remove(string = details2,
                               pattern = "\\s*\\([^\\)]+\\)$"),
         column_footnote = ifelse(str_detect(string = column_name, pattern = " \\*"), "not published for probabilistic projections", ""),
         column_name = str_remove(string = column_name, pattern = " \\*")) %>%
  relocate(-contains("column")) %>%
  relocate(ind, variant)

d1 <- d0 %>%
  mutate(details = paste(file_title, str_to_sentence(details2))) %>%
  select(-file, -file_name, -file_title, -details2) %>%
  rename(file = file_group,
         url = file_url,
         indicator = ind) %>%
  relocate(-contains("column_")) %>%
  relocate(-url)
  # group_by(indicator, variant, file, details, url) %>%
  # nest(.key = "file_columns") %>%
  # ungroup()

write_csv(x = d1, file = "./data-raw/wpp_bulk.csv")
# wpp_bulk <- d1
# usethis::use_data(wpp_bulk, overwrite = TRUE)


# d1$file_columns[[1]]


#   h <- read_html("https://population.un.org/wpp/Download/Standard/CSV/")
#
# h %>%
#   html_nodes("a") %>%
#   print(n = 50)
#   html_attrs("href")
#   html_table()
