#!/usr/bin/env Rscript

################################################################################
##### SET-UP #####
################################################################################
setwd('/datacommons/yoderlab/data/radseq/fastq/20181022_r99_msp3proj/')

## Metdata file:
infile_rename <- '/datacommons/yoderlab/users/jelmer/proj/msp3/metadata/msp3_r99_fastqRenamingTable.txt'
sp3.df <- read.delim(infile_rename, header = TRUE, as.is = TRUE)

## Dirs:
indir <- 'raw'
outdir <- 'raw_renamed'
if(!dir.exists(outdir)) dir.create(outdir, recursive = TRUE)

################################################################################
##### COPY FILES WITH NEW NAMES #####
################################################################################
## Check whether all files can be found:
cat('##### Checking whether all filenames are matching:\n')
sp3.df$fastq.file %in% list.files('raw/', pattern = 'fastq.gz')

## Create old and new names:
oldnames <- paste0(indir, '/', sp3.df$fastq.file)
newnames <- paste0(outdir, '/', sp3.df$ID, '.', sp3.df$read, '.fastq.gz')

cat('##### Showing old and new names:\n')
print(cbind(oldnames, newnames))

## Copy:
file.copy(from = oldnames, to = newnames)

cat('##### Done with script.\n')