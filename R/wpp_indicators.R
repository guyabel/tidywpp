#' WPP indicators
#'
#' Data set containing the indicator names, details and available variants starting from WPP1998.
#'
#' @format A data frame with 2742 rows and 7 variables, including:
#' \describe{
#'   \item{name}{Short name of indicator. Can be passed to `get_wpp()`}
#'   \item{details}{Brief description of indicator.}
#'   \item{unit}{Unit of measurement for indicator.}
#'   \item{var_id}{ID of available variants for the indicator}
#'   \item{variant}{Name of available variants for the indicator}
#'   \item{wpp}{WPP version of the indicator}
#'   \item{topic}{Broad topic of inidicator}
#'   \item{file_group}{Harmonised group (over WPP) to which the indicator belongs. Indicators in different groups need to downloaded separately with `get_wpp()`}
#'   \item{file_group0}{Published group to which the indicator belongs. Indicators in different groups need to downloaded separately with `get_wpp()`}
#'   \item{file_group_details}{Brief description on the file group}
#' }
#' @source \url{https://population.un.org/wpp/Download/Standard/CSV/}
"wpp_indicators"
