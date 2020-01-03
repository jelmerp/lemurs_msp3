#!/usr/bin/env Rscript

setwd('/work/jwp37/radseq/seqdata/bam/mapped2msp3/')

## Murinus:
rename.file <- '/datacommons/yoderlab/users/jelmer/radseq/metadata/jordi.runs/20181008_sp3_renaming.txt'
sp3.df <- read.delim(rename.file, header = TRUE, as.is = TRUE)
oldnames <- paste0('jordi/', sp3.df$filename)
newnames <- paste0('jordi_renamed/', sp3.df$ID, '.sort.MQ30.dedup.bam')

print(cbind(oldnames, newnames))

file.copy(from = oldnames, to = newnames)