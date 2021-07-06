#' Download UN DESA WPP data
#'
#' @description Downloads data on demographic indicators in UN DESA WPP. Requires a working internet connection.
#'
#' @param indicator Character string based on the `name` column in the `wpp_indicators` data frame. Represents the variables to be downloaded.
#' @param file_group Character string based on the `file_group` column in the `wpp_indicators` data frame . Represents the file group to download data from. Only needed for obtaining different granularities of population data.
#' @param variant_id Numeric value(s) based on the `var_id` column in the `wpp_indicators` data frame. Note, past data is in the `"Medium" (2)` variant only.
#' @param wpp_version Integer for WPP version. Default of `2019`. All WPP back to 1998 are available.
#' @param clean_names Logical to indicate if column names should be cleaned
#' @param fct_age Logical to indicate if `AgeGrp` column be converted to a factor.
#' @param drop_id_cols Logical to indicate if `VarId`, `LocID`, `MidPeriod`, `AgeGrpStart`, `AgeGrpSpan` and `SexID` columns to be removed.
#' @param tidy_pop_sex Logical to indicate if columns for sex specific population data should be stacked into single population column with new sex indicator column.
#' @param messages Logical to not suppress printing of messages.
#'
#' @return A tibble with downloaded data in tidy format
#'
#' @details
#'
#'
#' @export
#'
#' @examples
get_wpp <- function(indicator = NULL,
                    indicator_file_group = NULL,
                    variant_id = 2,
                    wpp_version = 2019,
                    clean_names = FALSE,
                    fct_age = TRUE,
                    drop_id_cols = FALSE,
                    tidy_pop_sex = FALSE,
                    messages = TRUE){
  # indicator = c("PopTotal", "SRB")
  # indicator = c("PopTotal", "PopMale", "PopFemale")
  # indicator = "PopTotal";
  # indicator_file_group = NULL;
  # variant_id = 2;
  # wpp_version = 2019;
  # clean_names = TRUE; fct_age = TRUE;
  # drop_id_cols = TRUE; tidy_pop_sex = TRUE
  # messages = TRUE
  vv <- wpp_var %>%
    filter(wpp == wpp_version)

  if(!any(variant_id  %in% vv$VarID))
    stop("variant_id not avialable in wpp_version")

  # work out file group for the indicator(s)
  g <- indicator_file_group
  if(is.null(g)){
    f <- wpp_indicators %>%
      filter(name %in% indicator,
             var_id %in% variant_id,
             wpp == wpp_version) %>%
      select(file_group, name) %>%
      distinct()

    g <- f %>%
      slice(1) %>%
      select(file_group) %>%
      pull()

    # if(length(unique(f$file_group)) > 1)
    #   message(paste("Indicators from more than one file group.\n\nOnly downloading indicators in:", g, "\n\nNeed multiple get_wpp() calls to get indicators in different file groups. See ?wpp_indicators and ?find_indicators for more information on file groups."))

    gg <- unique(f$file_group)
    if(length(gg) > 1 & messages){
      message(paste0("Downloading from ", gg[1]))
      for(i in 2:length(gg)){
        message(paste0("Also available in: ", gg[i]))
      }
      message("Use indicator_file_group to get alternative measures")
    }
  }

  # build url address to download from
  d0 <- tibble(
    name = "base",
    file_group = g,
    var_id = variant_id
  )

  d1 <- wpp_indicators %>%
    filter(name %in% indicator,
           var_id %in% variant_id,
           wpp == wpp_version,
           file_group == g) %>%
    select(-contains("details"), -variant, -wpp) %>%
    bind_rows(d0, .) %>%
    arrange(var_id) %>%
    mutate(u = paste0("https://raw.githubusercontent.com/guyabel/tidywpp/main/build-data/WPP",
                       wpp_version, "/", file_group, "/", var_id, "/", name, ".csv"),
           i = map(.x = u, .f = ~read_csv(file = .x, col_types = readr::cols(), guess_max = 1e1))) %>%
    # keep file group for later matching
    dplyr::group_by(var_id, file_group) %>%
    dplyr::summarise(dplyr::bind_cols(i), .groups = "drop_last") %>%
    dplyr::ungroup()

  v <- wpp_var %>%
    filter(wpp == wpp_version) %>%
    select(starts_with("Var"))

  l <- wpp_loc %>%
    filter(wpp == wpp_version) %>%
    select(-wpp)

  y <- wpp_time %>%
    filter(wpp == wpp_version,
           file_group == g) %>%
    select(-wpp, -file_group) %>%
    mutate(Time = ifelse(str_detect(string = Time, pattern = "-"),
                         yes = Time, no = as.integer(Time)))

  a <- NULL
  if(any(str_detect(names(d1), "Age"))){
    a <- wpp_age %>%
      filter(wpp == wpp_version,
             file_group == g) %>%
      select(contains("Age"))
  }

  s <- NULL
  if(any(str_detect(names(d1), "Sex"))){
    s <- wpp_sex %>%
      filter(wpp == wpp_version,
             file_group == g) %>%
      select(contains("Sex"))
  }

  d1 %>%
    select(-file_group) %>%
    rename(VarID = var_id) %>%
    left_join(v, by = "VarID") %>%
    left_join(l, by = "LocID") %>%
    left_join(y, by = "Time") %>%
    {if(is.null(a)) . else left_join(., a, by = "AgeGrp")} %>%
    {if(is.null(s)) . else left_join(., s, by = "SexID")} %>%
    relocate(contains("Loc"), contains("Var"), Time, MidPeriod, contains("Age"), contains("Sex")) %>%
    {if(fct_age & !is.null(a)) dplyr::mutate(., AgeGrp = forcats::fct_inorder(AgeGrp)) else .} %>%
    {if(drop_id_cols) dplyr::select(., -dplyr::any_of(c("MidPeriod", "AgeGrpStart", "AgeGrpSpan", "LocID", "SexID", "VarID"))) else .} %>%
    {if(tidy_pop_sex & str_detect(string = g, pattern = "Pop")) tidyr::pivot_longer(data = ., cols = contains("Pop"), names_to = "Sex", values_to = "Pop", names_prefix = "Pop") else .} %>%
    {if(clean_names) janitor::clean_names(.) else .}
}
# single indicator from medium variant of latest WPP
get_wpp(indicator = "TFR")

# single indicator from multiple variants of latest WPP
get_wpp(indicator = "TFR", variant_id = c(2, 3, 4))

# multiple population indicators from single variant of latest WPP
get_wpp(indicator = c("PopTotal", "PopMale", "PopFemale"))

# as multiple granularities of population in WPP, there are multiple population indicators.
# use indicator indicator_file_group to select version of population indicator(s)
get_wpp(indicator = c("PopTotal", "PopMale", "PopFemale"), indicator_file_group =  "TotalPopulationBySex")

# tidy sex into a single column and drop id columns
get_wpp(indicator = c("PopMale", "PopFemale"), indicator_file_group =  "TotalPopulationBySex",
        tidy_pop_sex = TRUE, drop_id_cols = TRUE)

# clean column names
get_wpp(indicator = c("SRB", "NetMigrations", "GrowthRate"), clean_names = TRUE, drop_id_cols = TRUE)

# old life table
get_wpp(indicator = c("qx", "lx", "dx", "Tx", "ex"), wpp_version = 2010, drop_id_cols = TRUE)
