## Set-up:
library(tidyverse)
setwd('/home/jelmer/Dropbox/sc_lemurs/')
infile_IDs_r01_msp3 <- 'radseq/metadata/r01/sampleIDs_msp3_yoderlab.txt'
infile_lookup <- 'radseq/metadata/lookup_IDlong.txt'

outfile_IDs <- 'msp3/metadata/msp3_r01_longIDs.txt'
outfile_lookup <- 'msp3/metadata/msp3_r01_fastqs.txt'

## Cluster dirs:
r01_dir <- '/datacommons/yoderlab/data/radseq/20180502_r01_ConsortiumRun/demult_dedup_trim'
r02_dir <- '/datacommons/yoderlab/data/radseq/20181125_r02_ConsortiumRun_redo/processed/'

## Read files:
IDs <- readLines(infile_IDs_r01_msp3)
lookup <- read.delim(infile_lookup, as.is = TRUE)

## Fix ID for r02 (name error in fastqs):
lookup$ID[lookup$seqRun == 'r02'] <- paste0(substr(lookup$ID[lookup$seqRun == 'r02'], 1, 15),
                                            substr(lookup$ID[lookup$seqRun == 'r02'], 17, 17))

## Select:
lookup_sel <- lookup %>%
  filter(Sample_ID %in% lookup$Sample_ID[lookup$ID %in% IDs]) %>%
  mutate(fastq_dir = ifelse(seqRun == 'r01', r01_dir, r02_dir)) %>%
  mutate(fastq_file_R1 = paste0(fastq_dir, '/', ID, '.R1.fastq.gz'),
         fastq_file_R2 = paste0(fastq_dir, '/', ID, '.R2.fastq.gz')) %>%
  select(ID, Sample_ID, seqRun, fastq_file_R1, fastq_file_R2)

## Write files:
writeLines(lookup_sel$ID, outfile_IDs)
write.table(lookup_sel, outfile_lookup,
            sep = '\t', quote = FALSE, row.names = FALSE)


