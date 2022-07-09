#' Download UN DESA WPP data
#'
#' @description Downloads data on demographic indicators in UN DESA WPP. Requires a working internet connection.
#'
#' @param indicator Character string based on the `name` column in the [wpp_indicators][tidywpp::wpp_indicators] data frame or `pop`. Represents the variables to be downloaded.
#' @param indicator_file Character string based on the `file` column in the [wpp_indicators][tidywpp::wpp_indicators] data frame . Represents the file group to download data from. Needed for obtaining indicators that are available with different levels of granularities (such as `Births` in overall population or `Births` by mothers age group).
#' @param pop_age Character string for population age groups if `indicator` is set to `pop`. Defaults to no age groups `total`, but can be set to `single` or `five`.
#' @param pop_sex Character string for population sexes if `indicator`is set to `pop`. Defaults to no sex `total`, but can be set to `male`, `female`, `both` or `all`.
#' @param pop_freq Character string for frequency of population data if `indicator` is set to `pop`. Defaults to `annual`, but in a some (exceptional cases) can be set to `five`.
#' @param pop_date Character string for frequency of population data if `indicator` is set to `pop`. Defaults to `jul1` (July 1st), but for WPP2022 can be set to `jan1` for population at beginning of year or `jan1-dec31` for exposure population.
#' @param variant_id Numeric value(s) based on the `var_id` column in the [wpp_indicators][tidywpp::wpp_indicators] data frame. Note, past data is in the `"Medium" (2)` variant only.
#' @param wpp_version Integer for WPP version. Default of `2019`. All WPP back to 1998 are available.
#' @param clean_names Logical to indicate if column names should be cleaned
#' @param fct_age Logical to indicate if `AgeGrp` column be converted to a factor.
#' @param drop_id_cols Logical to indicate if `VarId`, `LocID`, `MidPeriod`, `AgeGrpStart`, `AgeGrpSpan` and `SexID` columns to be removed.
#' @param tidy_pop_sex Logical to indicate if columns for sex specific population data should be stacked into single population column with an accompanying new sex column.
#' @param add_regions Logical to indicate if to add a `reg_name` and `area_name` columns for countries (where `LocID` is less than 900)
#' @param add_iso_codes Logical to indicate if to add a `iso3` and `iso2` columns for ISO 3 and 2 letter country codes (where `LocID` is less than 900)
#' @param messages Logical to not suppress printing of messages.
#' @param server Character string for location to download data from. Default of `github`.
#'
#' @md
#' @return A [tibble][tibble::tibble-package] with downloaded data in tidy format
#'
#' @details Indicators must use the name corresponding to the `name` column in in the [wpp_indicators][tidywpp::wpp_indicators] data frame.
#' The [find_indicator()][tidywpp::find_indicator] function can be used to look up the indicator code and availability by variants
#'
#' There are 114 different indicators in WPP data (starting from 1998). See the full \href{https://github.com/guyabel/tidywpp#indicator-list}{table} of the different indicators available in each WPP.
#'
#' The `variant_id` argument must be one or more numbers from the `var_id` column in the [wpp_indicators][tidywpp::wpp_indicators] data frame.
#' Not all indicators area available in all variants. Use the [find_indicator()][tidywpp::find_indicator] function to check availability.
#' There are 14 different variants in WPP data (starting from 1998).
#'
#' | var_id|variant             |
#' |------:|:-------------------|
#' |      2|Medium              |
#' |      3|High                |
#' |      4|Low                 |
#' |      5|Constant fertility  |
#' |      6|Instant replacement |
#' |      7|Zero migration      |
#' |      8|Constant mortality  |
#' |      9|No change           |
#' |     10|Momentum            |
#' |     16|Instant replacement zero migration |
#' |    202|Median PI (BHM median in WPP2015)         |
#' |    203|Upper 80 PI         |
#' |    204|Lower 80 PI         |
#' |    206|Upper 95 PI         |
#' |    207|Lower 95 PI         |
#'
#' @export
#'
#' @examples
#' \donttest{
#' # single indicator from medium variant of latest WPP
#' get_wpp(indicator = "TFR")
#'
#' # single indicator from multiple variants of latest WPP
#' get_wpp(indicator = "TFR", variant_id = c(2, 3, 4))
#'
#' # some indicators appear in multiple file groups, for example Births
#' # represents total number of births in the country in the
#' # Demographic_Indicators file (chosen by default)
#' get_wpp(indicator = "Births")
#'
#' # specify indicator_file to get number of births by mothers 5-year age group
#' get_wpp(indicator = c("Births", "ASFR"),
#'         indicator_file = "Fertility_by_Age5",
#'         drop_id_cols = TRUE)
#'
#' # PopTotal, PopMale and PopFemale indicators are in many WPP files with
#' # a wide range granularity. Set indicator = "pop" and use the pop_sex,
#' # pop_age, pop_freq and pop_date to get desired data from the appropriate
#' # indicator_file...
#'
#' # when using indicator = "pop" get_wpp() defaults to annual total population
#' # (summed over age and sex)
#' get_wpp(indicator = "pop")
#'
#' # use pop_sex to get specific sexes (or both or all)
#' get_wpp(indicator = "pop", pop_sex = "male")
#'
#' # use pop_age to specify age groups
#' get_wpp(indicator = "pop", pop_sex = "both", pop_age = "five")
#'
#' # use pop_date to specify populations at start of year (rather than mid-year)
#' get_wpp(indicator = "pop", pop_sex = "female", pop_age = "five", pop_date = "jan1")
#'
#' # tidy sex into a single column and drop id columns
#' get_wpp(indicator = "pop", pop_sex = "both", pop_age = "five",
#'         tidy_pop_sex = TRUE, drop_id_cols = TRUE)
#'
#' # alternatively use indicator_file to select the desired version of population indicator(s)
#' get_wpp(indicator = c("PopTotal", "PopMale", "PopFemale"), indicator_file =  "TotalPopulationBySex")
#'
#' # clean column names
#' get_wpp(indicator = c("SRB", "NetMigrations", "PopGrowthRate"),
#'         clean_names = TRUE, drop_id_cols = TRUE)
#' }
get_wpp <- function(indicator = NULL,
                    indicator_file = NULL,
                    pop_age = c("total", "single", "five"),
                    pop_sex = c("total", "both", "male", "female", "all"),
                    pop_freq = c("annual", "five"),
                    pop_date = c("jul1", "jan1", "jan1-dec31"),
                    variant_id = 2,
                    wpp_version = 2022,
                    clean_names = FALSE,
                    fct_age = TRUE,
                    drop_id_cols = FALSE,
                    tidy_pop_sex = FALSE,
                    add_regions = FALSE,
                    add_iso_codes = FALSE,
                    messages = TRUE,
                    server = c("github", "local")
                    ){
  # indicator = c("PopTotal", "SRB")
  # indicator = c("GrowthRate", "IMR")
  # indicator_file = NULL;
  # indicator = "pop"; pop_age = "total"; pop_sex = "both"; pop_freq = "annual"; pop_date = "1jul"
  # pop_age = "five"
  # variant_id = 2;
  # wpp_version = 2022;
  # clean_names = TRUE; fct_age = TRUE;
  # drop_id_cols = TRUE; tidy_pop_sex = TRUE
  # messages = TRUE
  # add_regions = FALSE; add_iso = FALSE; server = "github"
  # load("./R/sysdata.rda")
  wpp <- variant <- MidPeriod <- AgeGrp <- NULL
  vv <- wpp_var %>%
    dplyr::filter(wpp == wpp_version)

  if(!any(variant_id  %in% vv$VarID))
    stop("variant_id not avialable in wpp_version")

  if(indicator[1] == "pop"){
    pop_age <- match.arg(pop_age)
    pop_sex <- match.arg(pop_sex)
    pop_freq <- match.arg(pop_freq)
    pop_date <- match.arg(pop_date)
    if(pop_sex == "total")
      indicator <- c(indicator, "PopTotal")
    if(pop_sex == "both")
      indicator <- c(indicator, "PopMale", "PopFemale")
    if(pop_sex == "male")
      indicator <- c(indicator, "PopMale")
    if(pop_sex == "female")
      indicator <- c(indicator, "PopFemale")
    if(pop_sex == "all")
      indicator <- c(indicator, "PopTotal", "PopMale", "PopFemale")
    if(pop_age == "total")
      g <- "TotalPopulationBySex"
    if(pop_age == "single")
      g <- "PopulationBySingleAgeSex"
    if(pop_age == "five")
      g <- "PopulationByAge5GroupSex"
    if(pop_freq == "five")
      g <- "PopulationByAgeSex_5x5"
    if(pop_date == "jan1" & pop_age == "five")
      g <- "Population1JanuaryByAge5GroupSex"
    if(pop_date == "jan1" & pop_age == "single")
      g <- "Population1JanuaryBySingleAgeSex"
    if(pop_date == "jan1-dec31" & pop_age == "five")
      g <- "PopulationExposureByAge5GroupSex"
    if(pop_date == "jan1-dec31" & pop_age == "single")
      g <- "PopulationExposureBySingleAgeSex"

    indicator <- indicator[!indicator == "pop"]
  }

  ii <- indicator[!indicator %in% tidywpp::wpp_indicators$name]
  if(length(ii) > 0)
    message(paste0("Ignoring ", ii, ". Indicator name not in wpp_indicators"))

  # indicator = "Births"; indicator_file = NULL
  if(indicator[1] != "pop"){
    g <- tidywpp::wpp_indicators %>%
      {if(is.null(indicator_file)) . else dplyr::filter(., file == indicator_file)} %>%
      dplyr::filter(name %in% indicator,
                    var_id %in% variant_id,
                    wpp == wpp_version) %>%
      dplyr::pull(file0) %>%
      unique()

    if(length(g) > 1){
      g <- g[1]
      message(paste("Indicator(s) appears in more than one file.\n\nOnly downloading indicator(s) from file:", g, "\n\nNeed multiple get_wpp() calls to get indicators in different files. See ?wpp_indicators and ?find_indicators for more information on files."))
    }
  }

# build url address to download from
  name <- file0 <- var_id <- NULL
  d0 <- tibble::tibble(
    name = "base",
    file0 = g,
    var_id = variant_id
  )

  d1 <- tidywpp::wpp_indicators %>%
    dplyr::filter(name %in% indicator,
                  var_id %in% variant_id,
                  wpp == wpp_version,
                  file0 == g) %>%
    dplyr::select(-dplyr::contains("details"), -variant, -wpp) %>%
    dplyr::bind_rows(d0, .) %>%
    dplyr::arrange(var_id) %>%
    tidyr::fill(file0, .direction = "up")

  name2 <- u <- i <- NULL

  location <- "https://raw.githubusercontent.com/guyabel/tidywpp/main/data-host/WPP"
  # location <- "https://github.com/guyabel/tidywpp/raw/main/data-host/"
                # https://github.com/guyabel/tidywpp/blob/main/data-host/ ?raw=true
  server <- match.arg(server)
  if(server == "local")
    location <- "./data-host/WPP"

  pb <- progress::progress_bar$new(total = nrow(d1))
  pb$tick(0)

  d1 <- d1 %>%
    dplyr::mutate(
      name2 = ifelse(name %in% c("Sx", "Tx", "Lx"), paste0(name, name), name),
      u = paste0(
        location, wpp_version, "/", file0, "/", var_id, "/", name2, ".rds"
      ),
      i = purrr::map(
        .x = u,
        .f = ~{
          pb$tick()
          readr::read_rds(file = .x)
        })) %>%
    # keep file group for later matching
    dplyr::group_by(var_id, file0) %>%
    dplyr::summarise(dplyr::bind_cols(i), .groups = "drop_last") %>%
    dplyr::ungroup()

  pb$terminate()

  v <- wpp_var %>%
    dplyr::filter(wpp == wpp_version) %>%
    dplyr::select(dplyr::starts_with("Var"))

  reg_name <- area_name <- ISO3_code <- ISO2_code <- NULL
  l <- wpp_loc %>%
    dplyr::filter(wpp == wpp_version) %>%
    dplyr::select(-wpp) %>%
    {if(!add_regions) dplyr::select(., -area_name, -reg_name) else .} %>%
    {if(!add_iso_codes) dplyr::select(., -ISO3_code, -ISO2_code) else .}

  Time <- MidPeriod <- NULL
  y <- wpp_time %>%
    dplyr::filter(wpp == wpp_version,
                  file == g) %>%
    dplyr::select(-wpp, -file) %>%
    {if(g == "Demographic_Indicators") dplyr::select(., -MidPeriod) else .} %>%
    dplyr::mutate(Time = ifelse(
      stringr::str_detect(string = Time, pattern = "-"),
      yes = Time, no = as.integer(Time))
    )

  a <- AgrGrp <- NULL
  fct_age2 <- fct_age
  if(any(stringr::str_detect(names(d1), "Age"))){
    a <- wpp_age %>%
      dplyr::filter(wpp == wpp_version,
                    file == g) %>%
      dplyr::select(dplyr::contains("Age"))

    if(stringr::str_detect(string = g, pattern = "SingleAge|Age1") &
       a$AgeGrp %>%
         stringr::str_detect(pattern = "[:punct:]|[:symbol:]", negate = TRUE) %>%
         all()
      ){
      a$AgeGrp <- as.numeric(a$AgeGrp)
      fct_age2 <- FALSE
    }
  }

  s <- NULL
  if(any(stringr::str_detect(names(d1), "Sex"))){
    s <- wpp_sex %>%
      dplyr::filter(wpp == wpp_version,
                    file == g) %>%
      dplyr::select(dplyr::contains("Sex"))
  }

  d1 %>%
    dplyr::select(-file0) %>%
    dplyr::rename(VarID = var_id) %>%
    dplyr::left_join(v, by = "VarID") %>%
    dplyr::left_join(l, by = "LocID") %>%
    dplyr::left_join(y, by = "Time") %>%
    {if(is.null(a)) . else dplyr::left_join(., a, by = "AgeGrp")} %>%
    {if(is.null(s)) . else dplyr::left_join(., s, by = "SexID")} %>%
    dplyr::relocate(dplyr::contains("Loc"), dplyr::contains("Var"), Time, MidPeriod, dplyr::contains("Age"), dplyr::contains("Sex")) %>%
    {if(fct_age2 & !is.null(a)) dplyr::mutate(., AgeGrp = forcats::fct_inorder(AgeGrp)) else .} %>%
    {if(drop_id_cols) dplyr::select(., -dplyr::any_of(c("MidPeriod", "AgeGrpStart", "AgeGrpSpan", "LocID", "SexID", "VarID"))) else .} %>%
    {if(tidy_pop_sex & stringr::str_detect(string = g, pattern = "Pop")) tidyr::pivot_longer(data = ., cols = dplyr::contains("Pop"), names_to = "Sex", values_to = "Pop", names_prefix = "Pop") else .} %>%
    {if(clean_names) janitor::clean_names(.) else .}
}
