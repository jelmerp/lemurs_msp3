##### SET-UP #####
setwd('/home/jelmer/Dropbox/sc_lemurs/radseq/')
library(tidyverse); library(reshape2)

inds.df <- read.delim('metadata/r01/samples/samplenames_r01.txt', header = TRUE, as.is = TRUE)
sp3.IDs <- readLines('metadata/r01/samples/sampleIDs_sp3_yoderlab.txt')

fqstats.file <- 'analyses/qc/fastq/readnumbers/readnrs_wide.txt'
fqstats <- read.delim(fqstats.file, header = TRUE) %>%
  select(ID, in.pairs, out.both) %>%
  rename(fastq.raw = in.pairs, fastq.filt = out.both) %>%
  filter(ID %in% sp3.IDs)

bamstats.dir <- '/home/jelmer/Dropbox/sc_lemurs/radseq/analyses/qc/bam/map2msp3/'

collect.stats <- function(ID) {
  #ID <- sp3.IDs[1]
  bamstats.file <- paste0(bamstats.dir, ID, '.bam.bamFilterStats.txt')
  stats <- readLines(bamstats.file)
  bam.raw <- gsub('.*: ([0-9]+$)', '\\1', stats[grep('input', stats)])
  bam.MQ30 <- gsub('.*: ([0-9]+$)', '\\1', stats[grep('MQ', stats)])
  bam.propPair <- gsub('.*: ([0-9]+$)', '\\1', stats[grep('proper', stats)])
  bam.dedup <- gsub('.*: ([0-9]+$)', '\\1', stats[grep('dedup', stats)])
  bam.autosomal <- gsub('.*: ([0-9]+$)', '\\1', stats[grep('out', stats)])
  ID.column <- c(ID, bam.raw, bam.MQ30, bam.propPair, bam.dedup, bam.autosomal)
  return(ID.column)
}

bamstats <- data.frame(do.call(rbind, lapply(sp3.IDs, collect.stats)))
colnames(bamstats) <- c('ID', 'bam.raw', 'bam.MQ30', 'bam.propPair', 'bam.dedup', 'bam.autosomal')

readstats <- merge(fqstats, bamstats, by = 'ID')
readstats.file <- 'analyses/qc/bam/map2msp3/readnumbers.txt'
write.table(readstats, readstats.file,
            col.names = TRUE, row.names = FALSE, sep = '\t', quote = FALSE)
