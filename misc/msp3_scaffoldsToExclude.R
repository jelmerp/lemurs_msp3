rm(list = ls())
setwd('/home/jelmer/Dropbox/sc_lemurs/')
library(tidyverse)

scafs.intervals.file <- 'singlegenomes/seqdata/ref/mnor/Mnor.scaffolds.intervals.txt'
scafs.df <- read.delim(scafs.intervals.file, header = FALSE, as.is = TRUE)

scafs.x <- readLines('singlegenomes/seqdata/ref/mnor/Microcebus_MananaraNord.xList.txt')
scafs.mt <- readLines('singlegenomes/seqdata/ref/mnor/Microcebus_MananaraNord.mitoList.txt')
scafs.exclude <- c(scafs.x, scafs.mt)

scafs.bed <- scafs.df %>%
  filter(! V1 %in% scafs.exclude)
scafs.bed$V2 <- 0
scafs.bed$V3 <- scafs.bed$V3 - 1

scafs.bed.file <- 'singlegenomes/seqdata/ref/mnor/Mnor.scaffolds.autosomal.txt'
write.table(scafs.bed, scafs.bed.file,
            col.names = FALSE, row.names = FALSE, sep = '\t', quote = FALSE)

scafs.exlude.file <- 'singlegenomes/seqdata/ref/mnor/Mnor.scaffolds.exclude.txt'
writeLines(scafs.exclude, scafs.exlude.file)
