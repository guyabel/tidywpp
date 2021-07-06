#' WPP indicators
#'
#' Data set containing the indicator names, details and available variants from WPP1998 onwards.
#'
#' @format A data frame with 2766 rows and 7 variables, including:
#' \describe{
#'   \item{name}{Short name of indicator. Can be passed to `get_wpp()`}
#'   \item{details}{Brief description of indicator.}
#'   \item{variant}{Availabile variants for the indicator}
#'   \item{file}{File of the variant (not important for the user)}
#'   \item{file_group}{Group to which the indicator belongs. Indicators in different groups need to downloaded seperatly with `get_wpp()`}
#'   \item{file_group_details}{Brief description on the file group}
#'   \item{wpp}{WPP version of the indicator}
#' }
#' @source \url{http://dataexplorer.wittgensteincentre.org/wcde-v2/}
"wic_indicators"
