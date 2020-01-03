#!/usr/bin/env Rscript

################################################################################
##### SET-UP #####
################################################################################
## Dirs and files:
basedir.fastq <- '/datacommons/yoderlab/data/radseq/fastq/consortium/'
setwd(basedir.fastq)
indir <- 'original'
outdir <- 'renamed2'
if(!dir.exists(outdir)) dir.create(outdir, recursive = TRUE)
infile_rename <- '/datacommons/yoderlab/users/jelmer/proj/msp3/metadata/msp3_r99_fastqRenamingTable.txt'

## Read metadata file:
sp3.df <- read.delim(infile_rename, header = TRUE, as.is = TRUE)

################################################################################
##### COPY FILES WITH NEW NAMES #####
################################################################################
## Check whether all files can be found:
cat('##### Checking whether all filenames are matching:\n')
sp3.df$fastq.file %in% list.files(indir, pattern = 'fastq.gz')

## Create old and new names:
oldnames <- paste0(indir, '/', sp3.df$fastq.file)
newnames <- paste0(outdir, '/', sp3.df$ID, '.', sp3.df$read, '.fastq.gz')

cat('##### Showing old and new names:\n')
print(cbind(oldnames, newnames))

## Copy:
file.copy(from = oldnames, to = newnames)

cat('##### Done with script.\n')