#' Information on bulk files for UN DESA World Population Prospects
#'
#' A data set containing the indicator codes and details on UN DESA WPP bulk files to enable quick downloading into R.
#'
#' @format A data frame with 11 rows and 6 variables, including:
#' \describe{
#'   \item{indicator}{Short name of indicator to be used in the `indicator` argument of the `get_undesa_wpp()` function}
#'   \item{variant}{Variants in bulk data}
#'   \item{file}{file title}
#'   \item{details}{Details of data in file}
#'   \item{columns_name}{Indicator name in WPP bulk file}
#'   \item{columns_details}{Details on indicator in WPP bulk file}
#'   \item{url}{URL of bulk CSV}
#' }
#' @source \url{https://population.un.org/wpp/Download/Standard/CSV/}
"wpp_bulk"
