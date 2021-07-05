#' Find available indicator code names in the Wittgenstein Centre Human Capital Data Explorer or UN DESA World Population Prospects
#'
#' @param x Character string on key word or name related to indicator of potential interest.
#' @param source Character string on data base to search. Default `wic` for Wittgenstein Centre Human Capital Data Explorer or `un_desa` for UN DESA World Population Prospects.
#'
#' @return A subset of the wic_indicators data frame with one or more of the `indicator`, `description` or `definition` columns matching the keyword given to `x`. Use the result in the `indicator` column to input to the `get_wcde` function for downloading data. If
#' @export
#'
#' @examples
#' find_indicator("education")
#' find_indicator("migr")
#' find_indicator("fert")
find_indicator <- function(x, source = "wic"){
  if(!source %in% c("wic", "un_desa"))
    stop("source must be one of wic or un_desa")
  if(source == "wic"){
    d <- wcde::wic_indicators %>%
      dplyr::select_if(is.character) %>%
      # across and filter any row not directly possible
      dplyr::filter_all(dplyr::any_vars(
        stringr::str_detect(string = .,
                            pattern = stringr::regex(x, ignore_case = TRUE))
      ))
  }
  if(source == "un_desa"){
    d <- wpp_bulk %>%
      # across and filter any row not directly possible
      dplyr::filter_all(dplyr::any_vars(
        stringr::str_detect(string = .,
                            pattern = stringr::regex(x, ignore_case = TRUE))
      ))
  }
  return(d)
}

