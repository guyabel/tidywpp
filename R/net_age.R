# library(tidywpp)
# library(tidyverse)
# library(janitor)
# library(readxl)
#
# p <- get_wpp(indicator = "PopTotal", clean_names = TRUE, local = TRUE)
# b <- get_wpp(indicator = "Births", clean_names = TRUE, drop_id_cols = TRUE, local = TRUE) %>%
#   rename(period = time) %>%
#   group_by(location, period) %>%
#   summarise(births = sum(births))
# n <- get_wpp(indicator = "NetMigrations", clean_names = TRUE, drop_id_cols = TRUE, local = TRUE)
#
# # find_indicator(x = "births")
# # find_indicator(x = "Deaths")
# d <- read_excel(path = "I:/ADRI/project/data-unpd/wpp/data-raw/wpp2019/WPP2019_EXCEL_FILES/Mortality/WPP2019_MORT_F04_1_DEATHS_BY_AGE_BOTH_SEXES.xlsx",
#                 # /WPP2017_EXCEL_FILES/mortality/WPP2017_MORT_F04_1_DEATHS_BY_AGE_BOTH_SEXES.xlsx",
#                 skip = 16, na = "\U2026") %>%
#   clean_names() %>%
#   select(-(1:4), -type, -parent_code) %>%
#   pivot_longer(cols = starts_with("x"), names_to = "age_grp", values_to = "deaths", names_prefix = "x") %>%
#   mutate(time = str_sub(string = period, end = 4),
#          time = as.integer(time),
#          age_grp = str_replace(string = age_grp, pattern = "_", replacement = "-"),
#          age_grp = ifelse(age_grp == "95", "95+", age_grp),
#          age_grp = fct_inorder(age_grp))
#
# x <- p %>%
#   filter(time %in% seq(1950, 2020, 5),
#          loc_id < 900) %>%
#   select(-var_id, -age_grp_start, -age_grp_span, -mid_period, -variant) %>%
#   mutate(
#     age_grp = as.character(age_grp),
#     age_grp = ifelse(age_grp %in% c("95-99","100+"), "95+", age_grp),
#     age_grp = fct_inorder(age_grp)
#   ) %>%
#   group_by(loc_id, location, time, age_grp) %>%
#   summarise(pop = sum(pop_total)) %>%
#   left_join(d, by = c("time" = "time", "age_grp" = "age_grp", "loc_id" = "country_code")) %>%
#   group_by(location, age_grp) %>%
#   mutate(pop_new = lead(pop, order_by = time)) %>%
#   group_by(location, time) %>%
#   mutate(pop_next = lead(pop_new, order_by = age_grp),
#          pop_new = ifelse(age_grp == "0-4", pop_new, 0)) %>%
#   left_join(b) %>%
#   mutate(births = ifelse(age_grp == "0-4", births, 0)) %>%
#   replace_na(list(pop_next = 0)) %>%
#   mutate(net = pop_next - pop + deaths - births + pop_new)
#
# x %>%
#   filter(location == "China") %>%
#   # write_csv("temp2.csv")
#   group_by(location, period) %>%
#   summarise(net = sum(net, na.rm = TRUE))
#
# n %>%
#   filter(location == "China")
#
# # x %>%
# #   group_by(location, period) %>%
# #   summarise(pop_start = sum(pop),
# #             births = sum(births),
# #             deaths = sum(deaths)) %>%
# #   mutate(pop_end = lead(pop_start),
# #          net = pop_end - pop_start + deaths - births)
# # n
#
# x %>%
#   # filter(location == "China") %>%
#   filter(location == "United Kingdom") %>%
#   ggplot(mapping = aes(x = age_grp, y = net, colour = time, group = time)) +
#   geom_line()
#
# x %>%
#   filter(location == "China") %>%
#   ggplot(mapping = aes(x = age_grp, y = net/pop, colour = time, group = time)) +
#   geom_line()
