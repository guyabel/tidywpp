% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/find_indicator.R
\name{find_indicator}
\alias{find_indicator}
\title{Find available indicator code names or file groups for UN DESA World Population Prospects data}
\usage{
find_indicator(x, wpp_version = 2022, simple = TRUE)
}
\arguments{
\item{x}{Character string on key word or name related to indicator of potential interest.}

\item{wpp_version}{Integer for WPP version. Default of \code{2022}. All WPP back to 1998 are available.}

\item{simple}{Logical to give simple table without variant or file group information}
}
\value{
A subset of the \link[=wpp_indicators]{wpp_indicators} data frame with one or more of columns matching the keyword given to \code{x}. Use the result in the \code{indicator} column to input to the \link[=get_wpp]{get_wpp()} function for downloading data.
}
\description{
Find available indicator code names or file groups for UN DESA World Population Prospects data
}
\examples{
find_indicator("migration")

find_indicator("sex ratio")

# show variant information
find_indicator("Deaths", simple = FALSE)
}
