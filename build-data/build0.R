library(fs)
library(tidyverse)
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
         d = map(.x = path, .f = ~read_csv(file = .x)))

d2 <- d1 %>%
  mutate(col_names = map(.x = d, .f = ~colnames(.x)),
         n_row = map(.x = d, .f = ~nrow(.x)),
         n_col = map(.x = d, .f = ~ncol(.x)),
         loc = map(.x = d,
                   .f = function(x = .x){
                     x %>%
                       select(starts_with("Loc")) %>%
                       distinct()
                   }),
         var = map(.x = d,
                   .f = function(x = .x){
                     x %>%
                       select(starts_with("Var")) %>%
                       distinct()
                   }),
         time = map(.x = d,
                   .f = function(x = .x){
                     x %>%
                       select(Time, MidPeriod) %>%
                       distinct() %>%
                       mutate(Time = as.character(Time))
                   }),
         age = map(.x = d,
                    .f = function(x = .x){
                      x %>%
                        select(contains("Age")) %>%
                        distinct() %>%
                        mutate_all(as.character)
                    }),
         sex = map(.x = d,
                    .f = function(x = .x){
                      x %>%
                        select(contains("Sex")) %>%
                        distinct()
                    })
         )

d2 %>%
  select(wpp, file, col_names) %>%
  unnest(col_names) %>%
  write_csv("./build-data/meta/varibles.csv")

d2 %>%
  select(wpp, file, n_row, n_col) %>%
  unnest(c(n_row, n_col)) %>%
  write_csv("./build-data/meta/dim.csv")

d2 %>%
  select(wpp, loc) %>%
  unnest(loc) %>%
  distinct() %>%
  write_csv("./build-data/meta/loc.csv")

d2 %>%
  select(wpp, file, time) %>%
  unnest(time) %>%
  distinct() %>%
  write_csv("./build-data/meta/time.csv")

d2 %>%
  select(wpp, file, age) %>%
  unnest(age) %>%
  drop_na() %>%
  distinct() %>%
  write_csv("./build-data/meta/age.csv")

d2 %>%
  select(wpp, file, sex) %>%
  unnest(sex) %>%
  drop_na() %>%
  write_csv("./build-data/meta/sex.csv")

d2 <- d2 %>%
  mutate(base = map(.x = d,
                   .f = function(x = .x){
                     x %>%
                       select(one_of("LocID", "VarID", "Time", "AgeGrp", "Sex"))
                   }),
         rest = map(.x = d,
                    .f = function(x = .x){
                      x %>%
                        select(-one_of("Location", "Variant", "MidPeriod", "AgeGrpStart", "AgeGrpSpan", "Sex")) %>%
                        select(-one_of("LocID", "VarID", "Time", "AgeGrp", "SexID"))
                    })
  )

# build directories
d2 <- d2 %>%
  mutate(dir = paste0("./build-data/WPP", wpp, "/",file))
dir_create(d2$dir)

# save files
# d2 <- d2 %>%
#   mutate(base_file = paste0(dir, "/base.csv"))
#
d2 %>%
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

d2 %>%
  # slice(1:3) %>%
  by_row(~write_each_column(x = .$rest, d = .$dir))
