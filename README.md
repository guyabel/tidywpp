
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tidywpp

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/tidywpp)](https://CRAN.R-project.org/package=tidywpp)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/guyabel/tidywpp/workflows/R-CMD-check/badge.svg)](https://github.com/guyabel/tidywpp/actions)
<!-- badges: end -->

Download past and current versions of the UN DESA World Population
Prospects data into R. See the [pkgdown
site](https://github.com/guyabel/tidywpp) for full details.

## Installation

<!-- You can install the released version of tidywpp from [CRAN](https://CRAN.R-project.org) with: -->
<!-- ``` r -->
<!-- install.packages("tidywpp") -->
<!-- ``` -->

Install the developmental version with:

``` r
library(devtools)
install_github("guyabel/tidywpp", ref = "main")
```

## Benefits

Data downloaded using tidywpp is in
[tidy](https://vita.had.co.nz/papers/tidy-data.pdf) form, and hence does
not require any major manipulations for use in popular modelling and
visualisation functions in R.

``` r
library(tidywpp)
#> Suggested citation for WPP2022 data: United Nations, Department of Economic and Social Affairs, Population Division (2022). World Population Prospects 2022, Online Edition. Rev. 1
d <- get_wpp(indicator = "pop", pop_age = "single", pop_sex = "both", tidy_pop_sex = TRUE, drop_id_cols = TRUE)
d
#> # A tibble: 8,693,070 × 6
#>    Location Variant  Time AgeGrp Sex       Pop
#>    <chr>    <chr>   <dbl> <fct>  <chr>   <dbl>
#>  1 World    Medium   1950 0      Male   41782.
#>  2 World    Medium   1950 0      Female 39929.
#>  3 World    Medium   1950 1      Male   37134.
#>  4 World    Medium   1950 1      Female 35539.
#>  5 World    Medium   1950 2      Male   34054.
#>  6 World    Medium   1950 2      Female 32655.
#>  7 World    Medium   1950 3      Male   31959.
#>  8 World    Medium   1950 3      Female 30610.
#>  9 World    Medium   1950 4      Male   29718.
#> 10 World    Medium   1950 4      Female 28497.
#> # … with 8,693,060 more rows
```

``` r
library(tidyverse)
library(ggpol)
library(gganimate)
g <- d %>%
  filter(Location == "World") %>%
  mutate(pop = ifelse(Sex == "Male", -Pop/1e3, Pop/1e3),
         sex = fct_rev(Sex),
         age = as.numeric(AgeGrp) - 1) %>%
  ggplot(mapping = aes(x = pop, y = age))+
  geom_col(orientation = "y") +
  facet_share(facets = "sex", scales = "free_x") +
  scale_x_continuous(labels = abs) +
  theme_bw() +
  transition_time(time = Time) +
  labs(x = "Population (millions)", y = "", 
       title = 'WPP2022 World Population Medium Variant {round(frame_time)}')

animate(g, width = 15, height = 15, units = "cm", res = 200, 
        renderer = gifski_renderer(), nframes = n_distinct(d$Time))

anim_save(filename = "wpp2022_med.gif")
```

<img src="https://raw.githubusercontent.com/guyabel/tidywpp/main/wpp2022_med.gif" width="600px" height="600px" />

## Disclaimer

This package is in no way officially related to, or endorsed by, UN
DESA.
