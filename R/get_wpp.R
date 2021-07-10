#' Download UN DESA WPP data
#'
#' @description Downloads data on demographic indicators in UN DESA WPP. Requires a working internet connection.
#'
#' @param indicator Character string based on the `name` column in the [wpp_indicators][tidywpp::wpp_indicators] data frame. Represents the variables to be downloaded.
#' @param indicator_file_group Character string based on the `file_group` column in the [wpp_indicators][tidywpp::wpp_indicators] data frame . Represents the file group to download data from. Only needed for obtaining different granularities of population data.
#' @param variant_id Numeric value(s) based on the `var_id` column in the [wpp_indicators][tidywpp::wpp_indicators] data frame. Note, past data is in the `"Medium" (2)` variant only.
#' @param wpp_version Integer for WPP version. Default of `2019`. All WPP back to 1998 are available.
#' @param clean_names Logical to indicate if column names should be cleaned
#' @param fct_age Logical to indicate if `AgeGrp` column be converted to a factor.
#' @param drop_id_cols Logical to indicate if `VarId`, `LocID`, `MidPeriod`, `AgeGrpStart`, `AgeGrpSpan` and `SexID` columns to be removed.
#' @param tidy_pop_sex Logical to indicate if columns for sex specific population data should be stacked into single population column with an accompanying new sex column.
#' @param add_regions Logical to indicate if to add a `reg_name` and `area_name` columns for countries (where `LocID` is less than 900)
#' @param messages Logical to not suppress printing of messages.
#'
#' @md
#' @return A [tibble][tibble::tibble-package] with downloaded data in tidy format
#'
#' @details Indicators must use the name corresponding to the `name` column in in the [wpp_indicators][tidywpp::wpp_indicators] data frame.
#' The [find_indicator()][tidywpp::find_indicator] function can be used to look up the indicator code and availability by variants
#' There are 35 different indicators in WPP data (starting from 1998)
#'
#' |name          |details                                                                                                                        |file_group               |
#' |:-------------|:------------------------------------------------------------------------------------------------------------------------------|:------------------------|
#' |ASFR          |Age-specific fertility rate (births per 1,000 women)                                                                           |Fertility_by_Age         |
#' |ax            |Average number of years lived (nax) between ages x and x+n by those dying in the interval                                      |Life_Table               |
#' |Births        |Number of births, both sexes combined (thousands)                                                                              |Fertility_by_Age         |
#' |Births        |Number of births, both sexes combined (thousands)                                                                              |Period_Indicators        |
#' |CBR           |Crude birth rate (births per 1,000 population)                                                                                 |Period_Indicators        |
#' |CDR           |Crude death rate (deaths per 1,000 population)                                                                                 |Period_Indicators        |
#' |CNMR          |Net migration rate (per 1,000 population)                                                                                      |Period_Indicators        |
#' |Deaths        |Number of deaths, both sexes combined (thousands)                                                                              |Period_Indicators        |
#' |DeathsFemale  |Number of female deaths (thousands)                                                                                            |Period_Indicators        |
#' |DeathsMale    |Number of male deaths (thousands)                                                                                              |Period_Indicators        |
#' |dx            |Number of deaths, (ndx), between ages x and x+n                                                                                |Life_Table               |
#' |ex            |Expectation of life (ex) at age x, i.e., average number of years lived subsequent to age x by those reaching age x             |Life_Table               |
#' |GrowthRate    |Average annual rate of population change (percentage)                                                                          |Period_Indicators        |
#' |IMR           |Infant mortality rate, q(1), for both sexes combined (infant deaths per 1,000 live births)                                     |Period_Indicators        |
#' |LEx           |Life expectancy at birth for both sexes combined (years)                                                                       |Period_Indicators        |
#' |LExFemale     |Female life expectancy at birth (years)                                                                                        |Period_Indicators        |
#' |LExMale       |Male life expectancy at birth (years)                                                                                          |Period_Indicators        |
#' |lx            |Number of survivors, (lx), at age (x) for 100000 births                                                                        |Life_Table               |
#' |Lx            |Number of person-years lived, (nLx), between ages x and x+n                                                                    |Life_Table               |
#' |MAC           |Female mean age of childbearing (years)                                                                                        |Period_Indicators        |
#' |mx            |Central death rate, nmx, for the age interval (x, x+n)                                                                         |Life_Table               |
#' |NatIncr       |Rate of natural increase (per 1,000 population)                                                                                |Period_Indicators        |
#' |NetMigrations |Net number of migrants, both sexes combined (thousands)                                                                        |Period_Indicators        |
#' |NRR           |Net reproduction rate (surviving daughters per woman)                                                                          |Period_Indicators        |
#' |PASFR         |Percentage age-specific fertility rate                                                                                         |Fertility_by_Age         |
#' |PopDensity    |Population per square kilometre (thousands)                                                                                    |TotalPopulationBySex     |
#' |PopFemale     |Female population in the age group (thousands)                                                                                 |PopulationByAgeSex       |
#' |PopFemale     |Total female population (thousands)                                                                                            |TotalPopulationBySex     |
#' |PopFemale     |Female population for the individual age (thousands)                                                                           |PopulationBySingleAgeSex |
#' |PopFemale     |Female population in the age group (thousands)                                                                                 |PopulationByAgeSex_5x5   |
#' |PopMale       |Male population in the age group (thousands)                                                                                   |PopulationByAgeSex       |
#' |PopMale       |Total male population (thousands)                                                                                              |TotalPopulationBySex     |
#' |PopMale       |Male population for the individual age (thousands)                                                                             |PopulationBySingleAgeSex |
#' |PopMale       |Male population in the age group (thousands)                                                                                   |PopulationByAgeSex_5x5   |
#' |PopTotal      |Total population in the age group (thousands)                                                                                  |PopulationByAgeSex       |
#' |PopTotal      |Total population, both sexes (thousands)                                                                                       |TotalPopulationBySex     |
#' |PopTotal      |Total population for the individual age (thousands)                                                                            |PopulationBySingleAgeSex |
#' |PopTotal      |Total population in the age group (thousands)                                                                                  |PopulationByAgeSex_5x5   |
#' |px            |Probability of surviving, (npx), for an individual of age x to age x+n                                                         |Life_Table               |
#' |Q5            |Under-five mortality, 5q0, for both sexes combined (deaths under age five per 1,000 live births)                               |Period_Indicators        |
#' |qx            |Probability of dying (nqx), for an individual between age x and x+n                                                            |Life_Table               |
#' |SRB           |Sex ratio at birth (male births per female births)                                                                             |Period_Indicators        |
#' |Sx            |Survival ratio (nSx) corresponding to proportion of the life table population in age group (x, x+n) who are alive n year later |Life_Table               |
#' |TFR           |Total fertility (live births per woman)                                                                                        |Period_Indicators        |
#' |Tx            |Person-years lived, (Tx), above age x                                                                                          |Life_Table               |

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
#' # multiple population indicators from single variant of latest WPP
#' get_wpp(indicator = c("PopTotal", "PopMale", "PopFemale"))
#'
#' # there are multiple population indicators in the WPP with different levels of granularity
#' # use indicator_file_group to select the desired version of population indicator(s)
#' get_wpp(indicator = c("PopTotal", "PopMale", "PopFemale"), indicator_file_group =  "TotalPopulationBySex")
#'
#' # tidy sex into a single column and drop id columns
#' get_wpp(indicator = c("PopMale", "PopFemale"), indicator_file_group =  "TotalPopulationBySex",
#'         tidy_pop_sex = TRUE, drop_id_cols = TRUE)
#'
#' # clean column names
#' get_wpp(indicator = c("SRB", "NetMigrations", "GrowthRate"), clean_names = TRUE, drop_id_cols = TRUE)
#' }
get_wpp <- function(indicator = NULL,
                    indicator_file_group = NULL,
                    variant_id = 2,
                    wpp_version = 2019,
                    clean_names = FALSE,
                    fct_age = TRUE,
                    drop_id_cols = FALSE,
                    tidy_pop_sex = FALSE,
                    add_regions = FALSE,
                    messages = TRUE
                    ){
  # indicator = c("PopTotal", "SRB")
  # indicator = c("PopTotal", "PopMale", "PopFemale")
  # indicator = "PopTotal";
  # indicator = c("PopMale", "PopFemale"); indicator_file_group = "PopulationBySingleAgeSex"
  # indicator_file_group = NULL;
  # variant_id = 2;
  # wpp_version = 2019;
  # clean_names = TRUE; fct_age = TRUE;
  # drop_id_cols = TRUE; tidy_pop_sex = TRUE
  # messages = TRUE
  # load("./R/sysdata.rda")
  wpp <- variant <- MidPeriod <- AgeGrp <- NULL
  vv <- wpp_var %>%
    dplyr::filter(wpp == wpp_version)

  if(!any(variant_id  %in% vv$VarID))
    stop("variant_id not avialable in wpp_version")

  ii <- indicator[!indicator %in% tidywpp::wpp_indicators$name]
  if(length(ii) > 0)
    message(paste0("Ignoring ", ii, ". Indicator name not in wpp_indicators"))

  # work out file group for the indicator(s)
  g <- indicator_file_group
  if(is.null(g)){
    f <- tidywpp::wpp_indicators %>%
      dplyr::filter(name %in% indicator,
                    var_id %in% variant_id,
                    wpp == wpp_version) %>%
      dplyr::select(file_group, name) %>%
      dplyr::distinct()

    g <- f %>%
      dplyr::slice(1) %>%
      dplyr::select(file_group) %>%
      dplyr::pull()

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
  name <- file_group <- var_id <- NULL
  d0 <- tibble::tibble(
    name = "base",
    file_group = g,
    var_id = variant_id
  )

  d1 <- tidywpp::wpp_indicators %>%
    dplyr::filter(name %in% indicator,
                  var_id %in% variant_id,
                  wpp == wpp_version,
                  file_group == g) %>%
    dplyr::select(-dplyr::contains("details"), -variant, -wpp) %>%
    dplyr::bind_rows(d0, .) %>%
    dplyr::arrange(var_id)

  name2 <- u <- i <- NULL

  pb <- progress::progress_bar$new(total = nrow(d1))
  pb$tick(0)

  d1 <- d1 %>%
    dplyr::mutate(
      name2 = ifelse(name %in% c("Sx", "Tx", "Lx"), paste0(name, name), name),
      u = paste0("https://raw.githubusercontent.com/guyabel/tidywpp/main/build-data/WPP",
                 wpp_version, "/", file_group, "/", var_id, "/", name2, ".csv"),
      i = purrr::map(
        .x = u,
        .f = ~{
          pb$tick()
          readr::read_csv(file = .x, col_types = readr::cols(),
                          guess_max = 1e1, progress = FALSE)
        })) %>%
    # keep file group for later matching
    dplyr::group_by(var_id, file_group) %>%
    dplyr::summarise(dplyr::bind_cols(i), .groups = "drop_last") %>%
    dplyr::ungroup()

  pb$terminate()

  v <- wpp_var %>%
    dplyr::filter(wpp == wpp_version) %>%
    dplyr::select(dplyr::starts_with("Var"))

  reg_name <- area_name <- NULL
  l <- wpp_loc %>%
    dplyr::filter(wpp == wpp_version) %>%
    dplyr::select(-wpp) %>%
    {if(!add_regions) dplyr::select(., -area_name, -reg_name) else .}

  Time <- NULL
  y <- wpp_time %>%
    dplyr::filter(wpp == wpp_version,
                  file_group == g) %>%
    dplyr::select(-wpp, -file_group) %>%
    dplyr::mutate(Time = ifelse(
      stringr::str_detect(string = Time, pattern = "-"),
      yes = Time, no = as.integer(Time))
    )

  a <- AgrGrp <- NULL
  fct_age2 <- fct_age
  if(any(stringr::str_detect(names(d1), "Age"))){
    a <- wpp_age %>%
      dplyr::filter(wpp == wpp_version,
                    file_group == g) %>%
      dplyr::select(dplyr::contains("Age"))

    if(g == "PopulationBySingleAgeSex"){
      a$AgeGrp <- as.numeric(a$AgeGrp)
      fct_age2 <- FALSE
    }
  }

  s <- NULL
  if(any(stringr::str_detect(names(d1), "Sex"))){
    s <- wpp_sex %>%
      dplyr::filter(wpp == wpp_version,
                    file_group == g) %>%
      dplyr::select(dplyr::contains("Sex"))
  }

  d1 %>%
    dplyr::select(-file_group) %>%
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
