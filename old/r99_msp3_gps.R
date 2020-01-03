library(tidyverse)

gps.file.in <- '/home/jelmer/Dropbox/sc_lemurs/radseq/metadata/msp3/msp3.samples.gps.txt'
gps.file.out <- '/home/jelmer/Dropbox/sc_lemurs/radseq/metadata/msp3/msp3.samples.gps2.txt'

gps <- read.delim(gps.file.in) %>%
  mutate(sp.loc = paste0(Species, '_', Locality)) %>%
  select(sp.loc, GPS_SN, GPS_EO) %>%
  rename(latitude = GPS_SN, longitude = GPS_EO) %>%
  distinct(sp.loc, .keep_all = TRUE) %>%
  na.omit()

write.table(gps, gps.file.out, sep = '\t', quote = FALSE, row.names = FALSE)
