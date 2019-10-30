##########################################################################################
##### SET-UP #####
##########################################################################################
rm(list = ls()); gc()
setwd('/home/jelmer/Dropbox/sc_lemurs/radseq/')
library(gdata); library(tidyverse)

## Read input files:
inds <- read.xls('metadata/consortium.files/20180709_Samples_RAD_consortium.xls',
                 sheet = 'Samples_rad_micro_may_2018', as.is = TRUE)
filenames <- readLines('metadata/r99_msp3/msp3_r99_fastq.filenames.txt')

## Output files:
outfile_fastqRename <- 'metadata/r99_msp3/msp3_r99_fastqRenamingTable.txt'
outfile_snames <- 'metadata/r99_msp3/samplenames_r99_msp3.txt'


##########################################################################################
##### MAKE RENAMING TABLE FOR FASTQS #####
##########################################################################################
## IDs:
ID <- filenames %>%
  gsub(pattern = '_R[1-2]_paired\\.fastq\\.gz', replacement = '')

## Species names:
species.or <- tolower(inds$Species[match(ID, inds$Sample_ID_edits)])
msp3.df <- data.frame(ID, species.or, filenames) %>% arrange(species.or)

## Reordered:
ID <- as.character(msp3.df$ID)
species.or <- species <- as.character(msp3.df$species.or)
filenames <- as.character(msp3.df$filenames)

species <- species %>%
  gsub(pattern = 'sp. nov.#3', replacement = 'spp') %>%
  gsub(pattern = 'sp. - mananara nord', replacement = 'spp')

## ID read type 0/1/2: (0 means single-end)
reads <- filenames %>%
  gsub(pattern = '.*_R([1-2])_paired\\.fastq\\.gz', replacement = '\\1') %>%
  as.integer()

## Filenames that only occur once are single-end and get 0:
nr.occ <- table(ID)
nr.occ <- nr.occ[match(ID, names(nr.occ))]
reads[which(nr.occ == 1)] <- 0

## Additions:
additions <- rep('00000', length(ID))

## Get ID nr within species:
macarthurii.count <- 1
mittermeieri.count <- 8
simmonsi.count <- 1
spp.count <- 16

nrs <- vector(); i <- 1
for(sp.f in species) {
  if(reads[i] != '2') cur.value <- get(paste0(sp.f, '.count'))
  if(reads[i] == '2') cur.value <- get(paste0(sp.f, '.count')) - 1

  assign(paste0(sp.f, '.count'), cur.value + 1)

  if(nchar(cur.value) == 1) nrs[i] <- paste0('00', cur.value)
  if(nchar(cur.value) == 2) nrs[i] <- paste0('0', cur.value)

  i <- i + 1
}

## Create final IDs:
fileIDs <- paste0('m', substr(species, 1, 3), nrs, '_r99_', additions)

## Create and write final df:
msp3.df <- data.frame(fastq.file = filenames, Sample_ID = ID,
                     species, species.or, sp.nr = nrs, read = reads, ID = fileIDs)

write.table(msp3.df, outfile_fastqRename,
            sep = '\t', quote = FALSE, row.names = FALSE)


##########################################################################################
##### CREATE SAMPLENAMES DF #####
##########################################################################################
# msp3.df <- read.delim(outfile_fastqRename, header = TRUE, as.is = TRUE)
snames.r99.msp3 <- msp3.df %>%
  mutate(ID.short = substr(ID, 1, 7),
         genus = 'Microcebus',
         seqType = ifelse(read == 0, 'se', 'pe')) %>%
  select(ID, ID.short, Sample_ID, genus, species, seqType)

## Write file:
write.table(snames.r99.msp3, outfile_snames,
            sep = '\t', quote = FALSE, row.names = FALSE)
