# seems a pain to change github desktop case sensistive settings
# add extra files for capitals
library(fs)
f <- dir_ls("./build-data", recurse = TRUE) %>%
  str_subset("Life_Table") %>%
  str_subset("[A-Z]x.csv")

for(i in 1:length(f)){
  d <- read_csv(file = f[i])
  n <- paste0(names(d), names(d))
  nn <- str_replace(string = f[i], pattern = names(d), replacement = n)
  write_csv(d, file = nn)
}
