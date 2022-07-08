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

p <- "_Constant fertility|_Constant mortality|_High|_Instant replacement zero migration|_Instant replacement|_Low|_No change|_Momentum|_Zero migration"
s <- "_Both|_Male|_Female"

d0 <- d %>%
  as_tibble() %>%
  rename(path = 1) %>%
  mutate(size = file_size(path),
         path = as.character(path)) %>%
  filter(!str_detect(string = path, pattern = "zip$"),
         !str_detect(string = path, pattern = "-CSV-data$"),
         str_detect(string = path, pattern = "WPP2022"),
         !str_detect(string = path, pattern = "notes")) %>%
  mutate(wpp = str_extract(string = path, pattern = "\\d{4}"),
         file = str_remove(string = path, pattern = "\\.csv"),
         file = str_remove(string = file, pattern = paste0("(.)*", "WPP", wpp, "_")),
         file_group = str_remove(string = file, pattern = "_Medium|_OtherVariants"),
         file_group = str_remove(string = file_group, pattern = p),
         file_group = str_remove(string = file_group, pattern = s),
         file_group = str_remove(string = file_group, pattern = "_\\d{4}-\\d{4}"))

g <- d0 %>%
  group_by(file_group) %>%
  summarise(size = sum(size))
g
g$summary <- as.vector(14, mode = "list")

#dir_create(paste0("./data-host/WPP2022/", g$file_group))


write_each_column <- function(x, d){
  x0 <- x[[1]]
  for(i in 1:ncol(x0)){
    x1 <- x0 %>%
      select(i)
    if(colnames(x1) %in% c("Sx", "Tx", "Lx")){
      n <- paste0(d, colnames(x1), colnames(x1), ".rds")
    } else{
      n <- paste0(d, colnames(x1), ".rds")
    }
    saveRDS(object = x1, file = n)
  }
}


for(i in 1:nrow(g)){
  # for(i in 1){
  message(i)
  d1 <- d0 %>%
    filter(file_group == g$file_group[i]) %>%
    mutate(
      d = map(.x = path, .f = ~read_csv(file = .x, show_col_types = FALSE)),
      d = map(.x = d,
              .f = function(x = .x){
                x %>%
                  group_by(Variant, VarID) %>%
                  nest()
              })) %>%
    unnest(d)

  d2 <- d1 %>%
    mutate(data = map(.x = data, .f = ~remove_empty(dat = .x, which = "cols")),
           dir = paste0("./data-host/WPP", wpp, "/", file_group, "/", VarID, "/")) %>%
    group_by(dir, wpp, file_group, VarID, Variant) %>%
    summarise(d = list(reduce(data, bind_rows)),
              n = n()) %>%
    # sometimes multiple copies of variants (e.g. medium in demographic indicators)
    mutate(d = map(.x = d, .f = ~distinct(.data = .x)))

  d2 <- d2 %>%
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
           time = map2(.x = data, .y = file_group,
                       .f = function(x = .x, y = .y){
                         if(y != "Demographic_Indicators"){
                           xx <- x %>%
                             select(Time, MidPeriod) %>%
                             distinct() %>%
                             mutate(Time = as.character(Time))
                         }
                         if(y == "Demographic_Indicators"){
                           xx <- x %>%
                             select(Time) %>%
                             distinct() %>%
                             mutate(Time = as.character(Time))
                         }
                         return(xx)
                       }),
           age = map2(.x = data, .y = file_group,
                      .f = function(x = .x, y = .y){
                        if(y != "Demographic_Indicators"){
                          xx <- x %>%
                            select(contains("Age")) %>%
                            distinct() %>%
                            mutate_all(as.character)
                        }
                        if(y == "Demographic_Indicators"){
                          xx <- NULL
                        }
                        return(xx)
                      }),
           sex = map2(.x = data, .y = file_group,
                      .f = function(x = .x, y = .y){
                        if(y != "Demographic_Indicators"){
                          xx <- x %>%
                            select(contains("Sex")) %>%
                            distinct() %>%
                            mutate_all(as.character)
                        }
                        if(y == "Demographic_Indicators"){
                          xx <- NULL
                        }
                        return(xx)
                      })
    )

  d2 <- d2 %>%
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

  # d2 %>%
  #   by_row(~write.csv(.$base, file = paste0(.$dir, "/base.csv"), row.names = FALSE))
  d2 %>%
    by_row(~saveRDS(.$base, file = paste0(.$dir, "/base.rds")))

  d2 %>%
    by_row(~write_each_column(x = .$rest, d = .$dir))

  g$summary[[i]] <- d2 %>%
    select(-data)
}


##
## meta
##
g %>%
  select(summary) %>%
  unnest() %>%
  select(wpp, file_group, contains("Var"), col_name) %>%
  unnest(col_name) %>%
  write_csv("./data-host/meta/wpp1/indicators.csv")

g %>%
  select(summary) %>%
  unnest() %>%
  select(wpp, file_group, contains("Var"), n_row, n_col, n) %>%
  rename(n_original_files = n) %>%
  write_csv("./data-host/meta/wpp1/dim.csv")

g %>%
  select(summary) %>%
  unnest() %>%
  select(wpp, file_group, contains("Var")) %>%
  distinct() %>%
  write_csv("./data-host/meta/wpp1/var.csv")

g %>%
  select(summary) %>%
  unnest() %>%
  select(wpp, loc) %>%
  unnest(loc) %>%
  distinct() %>%
  write_csv("./data-host/meta/wpp1/loc.csv")

g %>%
  select(summary) %>%
  unnest() %>%
  select(wpp, file_group, time) %>%
  unnest(time) %>%
  distinct() %>%
  write_csv("./data-host/meta/wpp1/time.csv")

g %>%
  select(summary) %>%
  unnest() %>%
  select(wpp, file_group, age) %>%
  unnest(age) %>%
  drop_na() %>%
  distinct() %>%
  write_csv("./data-host/meta/wpp1/age.csv")

g %>%
  select(summary) %>%
  unnest() %>%
  select(wpp, file_group, sex) %>%
  unnest(sex) %>%
  drop_na() %>%
  distinct() %>%
  write_csv("./data-host/meta/wpp1/sex.csv")

##
## unite meta files
##
f <- dir_ls(path = "./data-host/meta", recurse = TRUE)

for(i in c("age", "dim", "indicators", "loc", "time", "sex", "var")){
  f %>%
    str_subset(pattern = i) %>%
    as_tibble() %>%
    mutate(d = map(.x = value, .f = ~read_csv(file = .x))) %>%
    {if(i == "time") mutate(., d = map(.x = d, .f = function(x = .x){mutate(x, Time = as.character(Time))})) else .} %>%
    select(-value) %>%
    unnest() %>%
    write_csv(paste0("./data-host/meta/",i,".csv"))
}


##
## delete empty directories (had copied and pastes directories variants to set up)
##
# d <-
dir_info(path = "./data-host/", recurse = TRUE) %>%
  mutate(s = as.numeric(size),
         p = as.character(path),
         p = str_remove(string = p, pattern = "\\.\\.")) %>%
  separate(col = p, into = c("d0", "d1", "d2", "d3", "d4", "d5"), remove = FALSE,
           extra = "merge", fill = "right", sep = "\\/")  %>%
  as_tibble() %>%
  select(-(3:4)) %>%
  filter(str_detect(string = p , pattern = "meta", negate = TRUE)) %>%
  group_by(d2, d3, d4) %>%
  mutate(n = n()) %>%
  filter(n == 1,
         !is.na(d4)) %>%
  pull(path) %>%
  dir_delete()

# delete all csv
# dir_info(path = "./data-host/", recurse = TRUE) %>%
#   filter(str_detect(string = path, "data-host/WPP"),
#          str_detect(string = path, ".csv")) %>%
#   pull(path) %>%
#   file_delete()
