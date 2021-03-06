##
## build0 - convert and separate files in CSV zips for WPP1998 to WPP2019
##          into format for downloading - simultaneously
## build1 - convert and separate files in CSV zips for WPP2022
##          into format for downloading - files to big to do all at once
##

library(fs)
library(tidyverse)
library(janitor)
library(purrrlyr)

d <- dir_ls(path = "I:\\ADRI\\project\\data-unpd\\wpp\\data-zip-csv", recurse = TRUE)

d0 <- d %>%
  as_tibble() %>%
  rename(path = 1) %>%
  mutate(path = as.character(path)) %>%
  filter(!str_detect(string = path, pattern = "zip$"),
         !str_detect(string = path, pattern = "-CSV-data$"),
         !str_detect(string = path, pattern = "WPP2022"))

d1 <- d0 %>%
  mutate(wpp = str_extract(string = path, pattern = "\\d{4}"),
         file = str_remove(string = path, pattern = "\\.csv"),
         file = str_remove(string = file, pattern = paste0("(.)*", "WPP", wpp, "_")),
         d = map(.x = path, .f = ~read_csv(file = .x, show_col_types = FALSE)),
         d = map(.x = d,
                 .f = function(x = .x){
                   x %>%
                     group_by(Variant, VarID) %>%
                     nest()
                 })) %>%
  unnest(d)

d1 <- d1 %>%
  mutate(file_group = str_remove(string = file, pattern = "_Medium|_OtherVariants"),
         file_group = str_remove(string = file_group, pattern = "_\\d{4}-\\d{4}"),
         data = map(.x = data, .f = ~remove_empty(dat = .x, which = "cols")),
         dir = paste0("./data-host/WPP", wpp, "/", file_group, "/", VarID, "/"))

# unify file groups with separate past and future
d1 <- d1 %>%
  # slice(406:408) %>%
  group_by(dir, wpp, file_group, VarID, Variant) %>%
  summarise(d = list(reduce(data, bind_rows)),
            n = n()) %>%
  mutate(d = map(.x = d, .f = ~distinct(.data = .x)))

d1 <- d1 %>%
  ungroup() %>%
  rename(data = d) %>%
  mutate(col_name = map(.x = data, .f = ~colnames(.x)),
         n_row = map_dbl(.x = data, .f = ~nrow(.x)),
         n_col = map_dbl(.x = data, .f = ~ncol(.x)),
         loc = map(.x = data,
                   .f = function(x = .x){
                     x %>%
                       select(starts_with("Loc")) %>%
                       distinct()
                   }),
         time = map(.x = data,
                   .f = function(x = .x){
                     x %>%
                       select(Time, MidPeriod) %>%
                       distinct() %>%
                       mutate(Time = as.character(Time))
                   }),
         age = map(.x = data,
                    .f = function(x = .x){
                      x %>%
                        select(contains("Age")) %>%
                        distinct() %>%
                        mutate_all(as.character)
                    }),
         sex = map(.x = data,
                    .f = function(x = .x){
                      x %>%
                        select(contains("Sex")) %>%
                        distinct()
                    }),
         )

# d2$var_col[[96]] %>%
#   filter(name == "SRB")

##
## meta
##
d1 %>%
  select(wpp, file_group, contains("Var"), col_name) %>%
  unnest(col_name) %>%
  write_excel_csv("./data-host/meta/wpp0/indicators.csv")

d1 %>%
  select(wpp, file_group, contains("Var"), n_row, n_col, n) %>%
  rename(n_original_files = n) %>%
  write_excel_csv("./data-host/meta/wpp0/dim.csv")

d1 %>%
  select(wpp, file_group, contains("Var")) %>%
  distinct() %>%
  write_excel_csv("./data-host/meta/wpp0/var.csv")

d1 %>%
  select(wpp, loc) %>%
  unnest(loc) %>%
  distinct() %>%
  write_excel_csv("./data-host/meta/wpp0/loc.csv")

d1 %>%
  select(wpp, file_group, time) %>%
  unnest(time) %>%
  distinct() %>%
  write_excel_csv("./data-host/meta/wpp0/time.csv")

d1 %>%
  select(wpp, file_group, age) %>%
  unnest(age) %>%
  drop_na() %>%
  distinct() %>%
  write_excel_csv("./data-host/meta/wpp0/age.csv")

d1 %>%
  select(wpp, file_group, sex) %>%
  unnest(sex) %>%
  drop_na() %>%
  distinct() %>%
  write_excel_csv("./data-host/meta/wpp0/sex.csv")



##
## write columns to single files
##
d1 <- d1 %>%
  mutate(base = map(.x = data,
                   .f = function(x = .x){
                     x %>%
                       select(one_of("LocID", "Time", "AgeGrp", "SexID"))
                   }),
         rest = map(.x = data,
                    .f = function(x = .x){
                      x %>%
                      # d1$data[[1]] %>%
                        select(-one_of("Location", "MidPeriod", "AgeGrpStart", "AgeGrpSpan", "Sex")) %>%
                        select(-one_of("LocID", "Time", "AgeGrp", "SexID"))
                    }))


# https://stackoverflow.com/questions/68269482/how-to-create-two-different-csv-files-with-the-same-name-but-one-uses-a-upper-ca
# dir_create(d1$dir)

d1 %>%
  by_row(~saveRDS(.$base, file = paste0(.$dir, "/base.rds")))

# x = d1$rest[[100]]
# d = d1$dir[[100]]
write_each_column <- function(x, d){
  # print(head(x[[1]]))
  x0 <- x[[1]]
  for(i in 1:ncol(x0)){
    x1 <- x0 %>%
      select(i)
    # n <- paste0(d, colnames(x1), ".csv")

    # seems a pain to change github desktop case sensitive settings
    # add extra files for capitals
    if(colnames(x1) %in% c("Sx", "Tx", "Lx")){
      n <- paste0(d, colnames(x1), colnames(x1), ".rds")
    } else{
      n <- paste0(d, colnames(x1), ".rds")
    }
    # write_excel_csv(x1, file = n)
    saveRDS(object = x1, file = n)
  }
}

d1 %>%
  # filter(file_group == "Life_Table") %>%
  # slice(373) %>%
  by_row(~write_each_column(x = .$rest, d = .$dir))
