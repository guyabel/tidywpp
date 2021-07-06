library(fs)
library(tidyverse)
library(janitor)
library(purrrlyr)

d <- dir_ls(path = "D:\\ADRI\\project\\data-unpd\\wpp\\data-zip-csv", recurse = TRUE)

d0 <- d %>%
  as_tibble() %>%
  rename(path = 1) %>%
  mutate(path = as.character(path)) %>%
  filter(!str_detect(string = path, pattern = "zip$"),
         !str_detect(string = path, pattern = "-CSV-data$"))

d1 <- d0 %>%
  mutate(wpp = str_extract(string = path, pattern = "\\d{4}"),
         file = str_remove(string = path, pattern = "\\.csv"),
         file = str_remove(string = file, pattern = paste0("(.)*", "WPP", wpp, "_")),
         d = map(.x = path, .f = ~read_csv(file = .x)),
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
         data = map(.x = data, .f = ~remove_empty(dat = .x, which = "cols")))

d1 <- d1 %>%
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
  select(wpp, file_group, VarID, col_name) %>%
  unnest(col_name) %>%
  write_csv("./build-data/meta/indicators.csv")

d1 %>%
  select(wpp, file_group, n_row, n_col) %>%
  unnest(c(n_row, n_col)) %>%
  write_csv("./build-data/meta/dim.csv")

d1 %>%
  select(wpp, file_group, contains("Var")) %>%
  distinct() %>%
  write_csv("./build-data/meta/var.csv")

d1 %>%
  select(wpp, loc) %>%
  unnest(loc) %>%
  distinct() %>%
  write_csv("./build-data/meta/loc.csv")

d1 %>%
  select(wpp, file_group, time) %>%
  unnest(time) %>%
  distinct() %>%
  write_csv("./build-data/meta/time.csv")

d1 %>%
  select(wpp, file_group, age) %>%
  unnest(age) %>%
  drop_na() %>%
  distinct() %>%
  write_csv("./build-data/meta/age.csv")

d1 %>%
  select(wpp, file_group, sex) %>%
  unnest(sex) %>%
  drop_na() %>%
  write_csv("./build-data/meta/sex.csv")



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
                    }),
         dir = paste0("./build-data/WPP", wpp, "/", file_group, "/", VarID, "/"))


dir_create(d1$dir)

d1 %>%
  # slice(1) %>%
  by_row(~write.csv(.$base, file = paste0(.$dir, "/base.csv"), row.names = FALSE))

write_each_column <- function(x, d){
  # print(head(x[[1]]))
  xx <- x[[1]]
  for(i in 1:ncol(xx)){
    colname <- names(xx)[i]
    write.csv(xx[,i], paste0(d, "/", colname, ".csv"), row.names = FALSE)
  }
}

d1 %>%
  # slice(1:3) %>%
  by_row(~write_each_column(x = .$rest, d = .$dir))
