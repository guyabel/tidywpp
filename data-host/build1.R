##
## build0 - convert and separate files in CSV zips for WPP1998 to WPP2019
##          into format for downloading simultaneously
## build1 - convert single character indicator file names into two characters
## build2 - convert and separate files in CSV zips for WPP2022
##          into format for downloading - too big files to do all at once
##

# seems a pain to change github desktop case sensitive settings
# add extra files for capitals
library(fs)
f <- dir_ls("./data-host", recurse = TRUE) %>%
  str_subset("Life_Table") %>%
  str_subset("[A-Z]x.csv")

for(i in 1:length(f)){
  d <- read_csv(file = f[i])
  n <- paste0(names(d), names(d))
  nn <- str_replace(string = f[i], pattern = names(d), replacement = n)
  write_csv(d, file = nn)
}
