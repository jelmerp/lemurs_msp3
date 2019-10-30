setwd('/home/jelmer/Dropbox/sc_lemurs/radseq/')
library(tidyverse)

bc <- read.delim('analyses/man_sp3/bamcomp.txt', sep = ' ', header = FALSE, as.is = TRUE)

ID <- gsub('.*(mspp0.*):Nr', '\\1', bc$V1)
type <- ifelse(grepl('refMur', bc$V1), 'map2sp3', 'map2mmur')
nreads <- as.integer(bc$V6)
filtered <- ifelse(grepl('input', bc$V5), 'pre-filter', 'post-filter')
df <- data.frame(ID, type, filtered, nreads)

