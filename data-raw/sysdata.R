wpp_var <- read_csv("./build-data/meta/var.csv")
usethis::use_data(wpp_var, overwrite = TRUE, internal = TRUE)

wpp_loc <- read_csv("./build-data/meta/loc.csv")
usethis::use_data(wpp_loc, overwrite = TRUE, internal = TRUE)

wpp_time <- read_csv("./build-data/meta/time.csv")
usethis::use_data(wpp_time, overwrite = TRUE, internal = TRUE)

wpp_age <- read_csv("./build-data/meta/age.csv")
usethis::use_data(wpp_age, overwrite = TRUE, internal = TRUE)

wpp_sex <- read_csv("./build-data/meta/sex.csv")
usethis::use_data(wpp_sex, overwrite = TRUE, internal = TRUE)
