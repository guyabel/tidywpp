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
#' There are 114 different indicators in WPP data (starting from 1998)
#'
#' |topic      |name                   |details                                                                                                            |unit                                                  |file                                |wpp                                                                    |
#' |:----------|:----------------------|:------------------------------------------------------------------------------------------------------------------|:-----------------------------------------------------|:-----------------------------------|:----------------------------------------------------------------------|
#' |Fertility  |ASFR                   |Age-specific fertility rate                                                                                        |births per 1,000 women                                |Fertility_by_Age1                   |2022                                                                   |
#' |Fertility  |ASFR                   |Age-specific fertility rate                                                                                        |births per 1,000 women                                |Fertility_by_Age5                   |1998, 2000, 2002, 2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019, 2022 |
#' |Fertility  |Births                 |Births                                                                                                             |thousands                                             |Demographic_Indicators              |1998, 2000, 2002, 2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019, 2022 |
#' |Fertility  |Births                 |Births                                                                                                             |thousands                                             |Fertility_by_Age1                   |2022                                                                   |
#' |Fertility  |Births                 |Births                                                                                                             |thousands                                             |Fertility_by_Age5                   |1998, 2000, 2002, 2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019, 2022 |
#' |Fertility  |Births1519             |Births by women aged 15 to 19                                                                                      |thousands                                             |Demographic_Indicators              |2022                                                                   |
#' |Fertility  |CBR                    |Crude Birth Rate                                                                                                   |births per 1,000 population                           |Demographic_Indicators              |1998, 2000, 2002, 2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019, 2022 |
#' |Fertility  |MAC                    |Mean Age Childbearing                                                                                              |years                                                 |Demographic_Indicators              |1998, 2000, 2002, 2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019, 2022 |
#' |Fertility  |NNR                    |Net Reproduction Rate                                                                                              |surviving daughters per woman                         |Demographic_Indicators              |2022                                                                   |
#' |Fertility  |NRR                    |Net reproduction rate                                                                                              |surviving daughters per woman                         |Demographic_Indicators              |1998, 2000, 2002, 2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019       |
#' |Fertility  |PASFR                  |Percentage age-specific fertility rate                                                                             |percentage                                            |Fertility_by_Age1                   |2022                                                                   |
#' |Fertility  |PASFR                  |Percentage age-specific fertility rate                                                                             |percentage                                            |Fertility_by_Age5                   |1998, 2000, 2002, 2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019, 2022 |
#' |Fertility  |SRB                    |Sex Ratio at Birth                                                                                                 |males per 100 female births                           |Demographic_Indicators              |1998, 2000, 2002, 2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019, 2022 |
#' |Fertility  |TFR                    |Total Fertility Rate                                                                                               |live births per woman                                 |Demographic_Indicators              |1998, 2000, 2002, 2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019, 2022 |
#' |Migration  |CNMR                   |Net Migration Rate                                                                                                 |per 1,000 population                                  |Demographic_Indicators              |1998, 2000, 2002, 2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019, 2022 |
#' |Migration  |NetMigrations          |Net Number of Migrants                                                                                             |thousands                                             |Demographic_Indicators              |1998, 2000, 2002, 2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019, 2022 |
#' |Mortality  |ax                     |Average number of years lived (nax) between ages x and x+n by those dying in the interval                          |years                                                 |Life_Table_Abridged                 |2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019, 2022                   |
#' |Mortality  |ax                     |Average number of years lived (nax) between ages x and x+n by those dying in the interval                          |years                                                 |Life_Table_Complete                 |2022                                                                   |
#' |Mortality  |CDR                    |Crude Death Rate                                                                                                   |deaths per 1,000 population                           |Demographic_Indicators              |1998, 2000, 2002, 2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019, 2022 |
#' |Mortality  |Deaths                 |Total Deaths                                                                                                       |thousands                                             |Demographic_Indicators              |1998, 2000, 2002, 2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019, 2022 |
#' |Mortality  |DeathsFemale           |Female Deaths                                                                                                      |thousands                                             |Demographic_Indicators              |1998, 2000, 2002, 2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019, 2022 |
#' |Mortality  |DeathsMale             |Male Deaths                                                                                                        |thousands                                             |Demographic_Indicators              |1998, 2000, 2002, 2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019, 2022 |
#' |Mortality  |dx                     |Number of deaths, (ndx), between ages x and x+n                                                                    |hypothetical cohort persons                           |Life_Table_Abridged                 |2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019, 2022                   |
#' |Mortality  |dx                     |Number of deaths, (ndx), between ages x and x+n                                                                    |hypothetical cohort persons                           |Life_Table_Complete                 |2022                                                                   |
#' |Mortality  |ex                     |Expectation of life (ex) at age x, i.e., average number of years lived subsequent to age x by those reaching age x |years                                                 |Life_Table_Abridged                 |2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019, 2022                   |
#' |Mortality  |ex                     |Expectation of life (ex) at age x, i.e., average number of years lived subsequent to age x by those reaching age x |years                                                 |Life_Table_Complete                 |2022                                                                   |
#' |Mortality  |IMR                    |Infant Mortality Rate                                                                                              |infant deaths per 1,000 live births                   |Demographic_Indicators              |1998, 2000, 2002, 2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019, 2022 |
#' |Mortality  |InfantDeaths           |Infant Deaths, under age 1                                                                                         |thousands                                             |Demographic_Indicators              |2022                                                                   |
#' |Mortality  |LBsurvivingAge1        |Live births Surviving to Age 1                                                                                     |thousands                                             |Demographic_Indicators              |2022                                                                   |
#' |Mortality  |LE15                   |Life Expectancy at Age 15, both sexes                                                                              |years                                                 |Demographic_Indicators              |2022                                                                   |
#' |Mortality  |LE15Female             |Female Life Expectancy at Age 15                                                                                   |years                                                 |Demographic_Indicators              |2022                                                                   |
#' |Mortality  |LE15Male               |Male Life Expectancy at Age 15                                                                                     |years                                                 |Demographic_Indicators              |2022                                                                   |
#' |Mortality  |LE65                   |Life Expectancy at Age 65, both sexes                                                                              |years                                                 |Demographic_Indicators              |2022                                                                   |
#' |Mortality  |LE65Female             |Female Life Expectancy at Age 65                                                                                   |years                                                 |Demographic_Indicators              |2022                                                                   |
#' |Mortality  |LE65Male               |Male Life Expectancy at Age 65                                                                                     |years                                                 |Demographic_Indicators              |2022                                                                   |
#' |Mortality  |LE80                   |Life Expectancy at Age 80, both sexes                                                                              |years                                                 |Demographic_Indicators              |2022                                                                   |
#' |Mortality  |LE80Female             |Female Life Expectancy at Age 80                                                                                   |years                                                 |Demographic_Indicators              |2022                                                                   |
#' |Mortality  |LE80Male               |Male Life Expectancy at Age 80                                                                                     |years                                                 |Demographic_Indicators              |2022                                                                   |
#' |Mortality  |LEx                    |Life Expectancy at Birth, both sexes                                                                               |years                                                 |Demographic_Indicators              |1998, 2000, 2002, 2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019, 2022 |
#' |Mortality  |LExFemale              |Female Life Expectancy at Birth                                                                                    |years                                                 |Demographic_Indicators              |1998, 2000, 2002, 2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019, 2022 |
#' |Mortality  |LExMale                |Male Life Expectancy at Birth                                                                                      |years                                                 |Demographic_Indicators              |1998, 2000, 2002, 2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019, 2022 |
#' |Mortality  |lx                     |Number of survivors, (lx), at age                                                                                  |hypothetical cohort persons                           |Life_Table_Abridged                 |2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019, 2022                   |
#' |Mortality  |lx                     |Number of survivors, (lx), at age                                                                                  |hypothetical cohort persons                           |Life_Table_Complete                 |2022                                                                   |
#' Mortality  |Lx                     |Number of person-years lived, (nLx), between ages x and x+n                                                        |years                                                 |Life_Table_Abridged                 |2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019, 2022                   |
#' |Mortality  |Lx                     |Number of person-years lived, (nLx), between ages x and x+n                                                        |years                                                 |Life_Table_Complete                 |2022                                                                   |
#' |Mortality  |mx                     |Central death rate, nmx, for the age interval (x, x+n)                                                             |rate                                                  |Life_Table_Abridged                 |2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019, 2022                   |
#' |Mortality  |mx                     |Central death rate, nmx, for the age interval (x, x+n)                                                             |rate                                                  |Life_Table_Complete                 |2022                                                                   |
#' |Mortality  |px                     |Probability of surviving, (npx), for an individual of age x to age x+n                                             |probability                                           |Life_Table_Abridged                 |2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019, 2022                   |
#' |Mortality  |px                     |Probability of surviving, (npx), for an individual of age x to age x+n                                             |probability                                           |Life_Table_Complete                 |2022                                                                   |
#' |Mortality  |Q0040                  |Mortality before Age 40, both sexes                                                                                |deaths under age 40 per 1,000 live births             |Demographic_Indicators              |2022                                                                   |
#' |Mortality  |Q0040Female            |Female mortality before Age 40                                                                                     |deaths under age 40 per 1,000 female live births      |Demographic_Indicators              |2022                                                                   |
#' |Mortality  |Q0040Male              |Male mortality before Age 40                                                                                       |deaths under age 40 per 1,000 male live births        |Demographic_Indicators              |2022                                                                   |
#' |Mortality  |Q0060                  |Mortality before Age 60, both sexes                                                                                |deaths under age 60 per 1,000 live births             |Demographic_Indicators              |2022                                                                   |
#' |Mortality  |Q0060Female            |Female mortality before Age 60                                                                                     |deaths under age 60 per 1,000 female live births      |Demographic_Indicators              |2022                                                                   |
#' |Mortality  |Q0060Male              |Male mortality before Age 60                                                                                       |deaths under age 60 per 1,000 male live births        |Demographic_Indicators              |2022                                                                   |
#' |Mortality  |Q1550                  |Mortality between Age 15 and 50, both sexes                                                                        |deaths under age 50 per 1,000 alive at age 15         |Demographic_Indicators              |2022                                                                   |
#' |Mortality  |Q1550Female            |Female mortality between Age 15 and 50                                                                             |deaths under age 50 per 1,000 females alive at age 15 |Demographic_Indicators              |2022                                                                   |
#' |Mortality  |Q1550Male              |Male mortality between Age 15 and 50                                                                               |deaths under age 50 per 1,000 males alive at age 15   |Demographic_Indicators              |2022                                                                   |
#' |Mortality  |Q1560                  |Mortality between Age 15 and 60, both sexes                                                                        |deaths under age 60 per 1,000 alive at age 15         |Demographic_Indicators              |2022                                                                   |
#' |Mortality  |Q1560Female            |Female mortality between Age 15 and 60                                                                             |deaths under age 60 per 1,000 females alive at age 15 |Demographic_Indicators              |2022                                                                   |
#' |Mortality  |Q1560Male              |Male mortality between Age 15 and 60                                                                               |deaths under age 60 per 1,000 males alive at age 15   |Demographic_Indicators              |2022                                                                   |
#' |Mortality  |Q5                     |Under-five Mortality Rate                                                                                          |deaths under age 5 per 1,000 live births              |Demographic_Indicators              |1998, 2000, 2002, 2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019, 2022 |
#' |Mortality  |qx                     |Probability of dying (nqx), for an individual between age x and x+n                                                |probability                                           |Life_Table_Abridged                 |2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019, 2022                   |
#' |Mortality  |qx                     |Probability of dying (nqx), for an individual between age x and x+n                                                |probability                                           |Life_Table_Complete                 |2022                                                                   |
#' |Mortality  |Sx                     |Survival ratio (nSx) corresponding to proportion of the life table population in age group                         |proportion                                            |Life_Table_Abridged                 |2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019, 2022                   |
#' |Mortality  |Sx                     |Survival ratio (nSx) corresponding to proportion of the life table population in age group                         |proportion                                            |Life_Table_Complete                 |2022                                                                   |
#' |Mortality  |Tx                     |Person-years lived, (Tx), above age x                                                                              |years                                                 |Life_Table_Abridged                 |2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019, 2022                   |
#' |Mortality  |Tx                     |Person-years lived, (Tx), above age x                                                                              |years                                                 |Life_Table_Complete                 |2022                                                                   |
#' |Mortality  |Under5Deaths           |Deaths under age 5                                                                                                 |thousands                                             |Demographic_Indicators              |2022                                                                   |
#' |Population |DoublingTime           |Population Annual Doubling Time                                                                                    |years                                                 |Demographic_Indicators              |2022                                                                   |
#' |Population |GrowthRate             |Average annual rate of population change                                                                           |percentage                                            |Demographic_Indicators              |1998, 2000, 2002, 2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019       |
#' |Population |MedianAgePop           |Median Age, as of 1 July                                                                                           |years                                                 |Demographic_Indicators              |2022                                                                   |
#' |Population |NatChange              |Natural Change, Births minus Deaths                                                                                |thousands                                             |Demographic_Indicators              |2022                                                                   |
#' |Population |NatChangeRT            |Rate of Natural Change                                                                                             |per 1,000 population                                  |Demographic_Indicators              |2022                                                                   |
#' |Population |NatIncr                |Rate of natural increase                                                                                           |per 1,000 population                                  |Demographic_Indicators              |1998, 2000, 2002, 2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019       |
#' |Population |PopChange              |Population Change                                                                                                  |thousands                                             |Demographic_Indicators              |2022                                                                   |
#' |Population |PopDensity             |Population Density, as of 1 July                                                                                   |persons per square km                                 |Demographic_Indicators              |2022                                                                   |
#' |Population |PopDensity             |Population Density, as of 1 July                                                                                   |persons per square km                                 |TotalPopulationBySex                |2019, 2022                                                             |
#' |Population |PopFemale              |Female population for the individual age                                                                           |percentage                                            |PopulationBySingleAgeSex_Percentage |2022                                                                   |
#' |Population |PopFemale              |Female population for the individual age                                                                           |thousands                                             |Population1JanuaryBySingleAgeSex    |2022                                                                   |
#' |Population |PopFemale              |Female population for the individual age                                                                           |thousands                                             |PopulationBySingleAgeSex            |2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019, 2022                   |
#' |Population |PopFemale              |Female population for the individual age                                                                           |thousands                                             |PopulationExposureBySingleAgeSex    |2022                                                                   |
#' |Population |PopFemale              |Female population in the age group                                                                                 |percentage                                            |PopulationByAge5GroupSex_Percentage |2022                                                                   |
#' |Population |PopFemale              |Female population in the age group                                                                                 |thousands                                             |Population1JanuaryByAge5GroupSex    |2022                                                                   |
#' |Population |PopFemale              |Female population in the age group                                                                                 |thousands                                             |PopulationByAge5GroupSex            |1998, 2000, 2002, 2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019, 2022 |
#' |Population |PopFemale              |Female population in the age group                                                                                 |thousands                                             |PopulationByAgeSex_5x5              |1998, 2000, 2002, 2004, 2006, 2008, 2010, 2012, 2015, 2017             |
#' |Population |PopFemale              |Female population in the age group                                                                                 |thousands                                             |PopulationExposureByAge5GroupSex    |2022                                                                   |
#' |Population |PopFemale              |Total female population                                                                                            |thousands                                             |TotalPopulationBySex                |2000, 2002, 2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019, 2022       |
#' |Population |PopGrowthRate          |Population Growth Rate                                                                                             |percentage                                            |Demographic_Indicators              |2022                                                                   |
#' |Population |PopMale                |Male population for the individual age                                                                             |percentage                                            |PopulationBySingleAgeSex_Percentage |2022                                                                   |
#' |Population |PopMale                |Male population for the individual age                                                                             |thousands                                             |Population1JanuaryBySingleAgeSex    |2022                                                                   |
#' |Population |PopMale                |Male population for the individual age                                                                             |thousands                                             |PopulationBySingleAgeSex            |2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019, 2022                   |
#' |Population |PopMale                |Male population for the individual age                                                                             |thousands                                             |PopulationExposureBySingleAgeSex    |2022                                                                   |
#' |Population |PopMale                |Male population in the age group                                                                                   |percentage                                            |PopulationByAge5GroupSex_Percentage |2022                                                                   |
#' |Population |PopMale                |Male population in the age group                                                                                   |thousands                                             |Population1JanuaryByAge5GroupSex    |2022                                                                   |
#' |Population |PopMale                |Male population in the age group                                                                                   |thousands                                             |PopulationByAge5GroupSex            |1998, 2000, 2002, 2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019, 2022 |
#' |Population |PopMale                |Male population in the age group                                                                                   |thousands                                             |PopulationByAgeSex_5x5              |1998, 2000, 2002, 2004, 2006, 2008, 2010, 2012, 2015, 2017             |
#' |Population |PopMale                |Male population in the age group                                                                                   |thousands                                             |PopulationExposureByAge5GroupSex    |2022                                                                   |
#' |Population |PopMale                |Total male population                                                                                              |thousands                                             |TotalPopulationBySex                |2000, 2002, 2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019, 2022       |
#' |Population |PopSexRatio            |Population Sex Ratio, as of 1 July                                                                                 |males per 100 females                                 |Demographic_Indicators              |2022                                                                   |
#' |Population |PopTotal               |Total population for the individual age                                                                            |percentage                                            |PopulationBySingleAgeSex_Percentage |2022                                                                   |
#' |Population |PopTotal               |Total population for the individual age                                                                            |thousands                                             |Population1JanuaryBySingleAgeSex    |2022                                                                   |
#' |Population |PopTotal               |Total population for the individual age                                                                            |thousands                                             |PopulationBySingleAgeSex            |2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019, 2022                   |
#' |Population |PopTotal               |Total population for the individual age                                                                            |thousands                                             |PopulationExposureBySingleAgeSex    |2022                                                                   |
#' |Population |PopTotal               |Total population in the age group                                                                                  |percentage                                            |PopulationByAge5GroupSex_Percentage |2022                                                                   |
#' |Population |PopTotal               |Total population in the age group                                                                                  |thousands                                             |Population1JanuaryByAge5GroupSex    |2022                                                                   |
#' |Population |PopTotal               |Total population in the age group                                                                                  |thousands                                             |PopulationByAge5GroupSex            |1998, 2000, 2002, 2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019, 2022 |
#' |Population |PopTotal               |Total population in the age group                                                                                  |thousands                                             |PopulationByAgeSex_5x5              |1998, 2000, 2002, 2004, 2006, 2008, 2010, 2012, 2015, 2017             |
#' |Population |PopTotal               |Total population in the age group                                                                                  |thousands                                             |PopulationExposureByAge5GroupSex    |2022                                                                   |
#' |Population |PopTotal               |Total population, both sexes                                                                                       |thousands                                             |TotalPopulationBySex                |1998, 2000, 2002, 2004, 2006, 2008, 2010, 2012, 2015, 2017, 2019, 2022 |
#' |Population |TPopulation1Jan        |Total Population, as of 1 January                                                                                  |thousands                                             |Demographic_Indicators              |2022                                                                   |
#' |Population |TPopulation1July       |Total Population, as of 1 July                                                                                     |thousands                                             |Demographic_Indicators              |2022                                                                   |
#' |Population |TPopulationFemale1July |Female Population, as of 1 July                                                                                    |thousands                                             |Demographic_Indicators              |2022                                                                   |
#' |Population |TPopulationMale1July   |Male Population, as of 1 July                                                                                      |thousands                                             |Demographic_Indicators              |2022                                                                   |
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
#' get_wpp(indicator = c("Births", "ASFR"), indicator_file = "Fertility_by_Age5", drop_id_cols = TRUE)
#'
#' # PopTotal, PopMale and PopFemale indicators are in many WPP files with
#' # a wide range granularity. Set indicator = "pop" and use the pop_sex,
#' # pop_age, pop_freq and pop_date to get desired data from the appropriate
#' # indicator_file...
#'
#' # when using indicator = "pop" get_wpp() defaults to annual total population (summed over age and sex)
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
#' get_wpp(indicator = c("SRB", "NetMigrations", "PopGrowthRate"), clean_names = TRUE, drop_id_cols = TRUE)
#' }
get_wpp <- function(indicator = NULL,
                    indicator_file = NULL,
                    pop_age = c("total", "single", "five"),
                    pop_sex = c("total", "both", "male", "female", "all"),
                    pop_freq = c("annual", "five"),
                    pop_date = c("jul1", "jan1", "jan1-dec31"),
                    #' @param fertility_age Character string for age groups if `indicator` is set to `ASFR`, `PASFR` or `Births`. Defaults to `five` year age groups, but can be set to `single` for WPP2022.
                    #' @param life_table_age Character string for age groups if `indicator` is from life table. Defaults to `abridged` for five year age groups, but can be set to `complete` for single years for WPP2022.
                    # fertility_age = c("five", "single"),
                    # life_table_age = c("abridged", "complete"),
                    variant_id = 2,
                    wpp_version = 2022,
                    clean_names = FALSE,
                    fct_age = TRUE,
                    drop_id_cols = FALSE,
                    tidy_pop_sex = FALSE,
                    add_regions = FALSE,
                    add_iso = FALSE,
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

  if(any(indicator == "pop")){
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

  ii <- indicator[!indicator %in% wpp_indicators$name]
  if(length(ii) > 0)
    message(paste0("Ignoring ", ii, ". Indicator name not in wpp_indicators"))

  # indicator = "Births"; indicator_file = NULL
  if(!any(indicator %in% c("PopMale", "PopFemale", "PopTotal"))){
    g <- tidywpp::wpp_indicators %>%
      {if(is.null(indicator_file)) . else filter(., file == indicator_file)} %>%
      dplyr::filter(name %in% indicator,
                    var_id %in% variant_id,
                    wpp == wpp_version) %>%
      dplyr::pull(file) %>%
      unique()

    if(length(g) > 1){
      g <- g[1]
      message(paste("Indicator(s) appears in more than one file.\n\nOnly downloading indicator(s) from file:", g, "\n\nNeed multiple get_wpp() calls to get indicators in different files. See ?wpp_indicators and ?find_indicators for more information on files."))
    }
  }

# build url address to download from
  name <- file <- var_id <- NULL
  d0 <- tibble::tibble(
    name = "base",
    file = g,
    var_id = variant_id
  )

  d1 <- tidywpp::wpp_indicators %>%
    dplyr::filter(name %in% indicator,
                  var_id %in% variant_id,
                  wpp == wpp_version,
                  file == g) %>%
    dplyr::select(-dplyr::contains("details"), -variant, -wpp) %>%
    dplyr::bind_rows(d0, .) %>%
    dplyr::arrange(var_id)

  name2 <- u <- i <- NULL

  pb <- progress::progress_bar$new(total = nrow(d1))
  pb$tick(0)

  location <- "https://raw.githubusercontent.com/guyabel/tidywpp/main/data-host/WPP"
  server <- match.arg(server)
  if(server == "local")
    location <- "./data-host/WPP"

  d1 <- d1 %>%
    dplyr::mutate(
      name2 = ifelse(name %in% c("Sx", "Tx", "Lx"), paste0(name, name), name),
      u = paste0(location,
                 wpp_version, "/", file, "/", var_id, "/", name2,
                 ".rds"),
                 # ".csv"),
      i = purrr::map(
        .x = u,
        .f = ~{
          pb$tick()
          readr::read_rds(file = .x)
          # readr::read_csv(file = .x, col_types = readr::cols(),
          #                 guess_max = 1e1, progress = FALSE)
        })) %>%
    # keep file group for later matching
    dplyr::group_by(var_id, file) %>%
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
    {if(!add_iso) dplyr::select(., -ISO3_code, -ISO2_code) else .}

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
    dplyr::select(-file) %>%
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
