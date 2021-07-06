#' Download UN DESA WPP data
#'
#' @description Downloads data on demographic indicators in UN DESA WPP. Requires a working internet connection.
#'
#' @param indicator Character string based on the `name` column in the `wpp_indicators` data frame. Represents the variables to be downloaded.
#' @param file_group Character string based on the `file_group` column in the `wpp_indicators` data frame . Represents the file group to download data from. Most likely to be need for obtaining different granularities of population data.
#' @param variant Character string from based on the `variant` column in the `wpp_indicators` data frame. Note, past data is in the `"Medium"` variant only.
#' @param wpp Integer for WPP version. Default of `2019`. All WPP back to 1998 are available.
#' @param clean_names Logical to indicate if column names should be cleaned
#' @param fct_age Logical to indicate if `AgeGrp` column be converted to a factor.
#' @param tidy_sex Logical to indicate if columns for sex specific population data should be stacked into single population column with new sex indicator column.
#'
#' @return A tibble with downloaded data in tidy format
#' @export
#'
#' @examples
get_wpp <- function(indicator = NULL,
                    file_group = NULL,
                    variant = "Medium",
                    wpp = 2019,
                    clean_names = FALSE,
                    fct_age = TRUE){
  # indicator = c("PopTotal", "SRB")
  # indicator = c("PopTotal", "PopMale", "PopFemale")
  # indicator = "PopTotal";
  # file_group = NULL;
  # variant = "All";
  # wpp = 2019;
  # clean_names = TRUE; fct_age = TRUE;
  if(!(variant %in% wpp_var$Variant | variant %in% wpp_var$VarID))
    stop("variant must be either Medium or All")

  fg <- file_group
  if(is.null(fg)){
    f <- wpp_indicators %>%
      filter(name == indicator,
             variant == variant
             wpp == wpp) %>%
      select(file_group, name) %>%
      distinct()

    fg <- f %>%
      slice(1) %>%
      select(file_group) %>%
      pull()

    if(length(unique(f$name)) > 1)
      message(paste("Indicators from more than one file group.\n\nOnly downloading indicators in:", fg, "\n\nNeed multiple get_wpp() calls to get indicators in different file groups. See ?wpp_indicators and ?find_indicators for more information on file groups."))

    g <- unique(f$file_group)
    if(length(g) > 1){
      message(paste0("Downloading from ", g[1], "."))
      for(i in 2:length(g)){
        message(paste0("Also available in: ", g[i],"."))
      }
    }
  }
  ff <- wpp_indicators %>%
    filter(wpp == wpp,
           file_group == fg) %>%
    {if(variant == "Medium")  filter(., variant == "Medium") else .} %>%
    distinct(file) %>%
    pull(file)

  d0 <- tibble(indicator = "base", file = ff)
  d <-
    tibble(indicator = f %>%
                filter(file_group == fg) %>%
                pull(name),
              file = ff) %>%
    bind_rows(d0, .) %>%
    mutate(u0 = paste0("https://raw.githubusercontent.com/guyabel/tidywpp/main/build-data/WPP",
                       wpp, "/", file, "/"),
           u1 = paste0(u0, indicator, ".csv"),
           i = map(.x = u1, .f = ~read_csv(file = .x, col_types = readr::cols(), guess_max = 1e1))) %>%
    dplyr::group_by(file) %>%
    dplyr::summarise(dplyr::bind_cols(i), .groups = "drop_last") %>%
    dplyr::ungroup() %>%
    dplyr::select(-file)

  v <- wpp_var %>%
    filter(wpp == wpp,
           file %in% ff) %>%
    select(starts_with("Var"))

  l <- wpp_loc %>%
    filter(wpp == wpp) %>%
    select(-wpp)

  y <- wpp_time %>%
    filter(wpp == wpp,
           file %in% ff) %>%
    select(-wpp, -file) %>%
    mutate(Time = ifelse(str_detect(string = Time, pattern = "-"),
                         yes = Time, no = as.integer(Time)))

  a <- NULL
  if(any(str_detect(names(d), "Age"))){
    a <- wpp_age %>%
      filter(wpp == wpp,
             file %in% ff) %>%
      select(-wpp, -file)
  }

  s <- NULL
  if(any(str_detect(names(d), "Sex"))){
    s <- wpp_sex %>%
      filter(wpp == wpp,
             file %in% ff) %>%
      select(-wpp, -file)
  }

  d %>%
    left_join(v, by = "VarID") %>%
    left_join(l, by = "LocID") %>%
    left_join(y, by = "Time") %>%
    {if(is.null(a)) . else left_join(., a, by = "AgeGrp")} %>%
    {if(is.null(s)) . else left_join(., s, by = "SexID")} %>%
    relocate(contains("Loc"), contains("Var"), Time, MidPeriod, contains("Age"), contains("Sex")) %>%
    {if(clean_names) janitor::clean_names(.) else .} %>%
    {if(fct_age & !is.null(a)) dplyr::mutate(., age = forcats::fct_inorder(age)) else .}
}

# get_wpp(indicator = "TFR", variant = "Medium")
# get_wpp(indicator = "ASFR", clean_names = TRUE)
# get_wpp(indicator = "TFR", clean_names = TRUE)
