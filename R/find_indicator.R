#' Find available indicator code names or file groups for UN DESA World Population Prospects data
#'
#' @param x Character string on key word or name related to indicator of potential interest.
#' @param wpp_version Integer for WPP version. Default of `2022`. All WPP back to 1998 are available.
#' @param simple Logical to give simple table without variant or file group information
#'
#' @return A subset of the [wpp_indicators][tidywpp::wpp_indicators] data frame with one or more of columns matching the keyword given to `x`. Use the result in the `indicator` column to input to the [get_wpp()][tidywpp::get_wpp] function for downloading data.
#' @export
#'
#' @examples
#' find_indicator("migration")
#'
#' find_indicator("sex ratio")
#'
#' # show variant information
#' find_indicator("Deaths", simple = FALSE)
find_indicator <- function(x, wpp_version = 2022, simple = TRUE){
  wpp <- name <- details <- file <- NULL
  d <- tidywpp::wpp_indicators %>%
    dplyr::filter(wpp == wpp_version) %>%
    # across and filter any row not directly possible
    dplyr::filter_at(.vars = dplyr::vars(name, details),
                     .vars_predicate = dplyr::any_vars(
                       stringr::str_detect(
                         string = . ,
                         pattern = stringr::regex(x, ignore_case = TRUE))
                      )
                     )

  if(simple){
    d <- d %>%
      dplyr::select(name, details, file) %>%
      dplyr::distinct()
  }
  return(d)
}

