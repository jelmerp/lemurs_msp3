##### SET-UP #####
setwd('/home/jelmer/Dropbox/sc_lemurs/radseq/')
library(gdata); library(tidyverse)

## Read files:
inds <- read.xls('metadata/consortium.files/20180709_Samples_RAD_consortium.xls',
                 sheet = 'Samples_rad_micro_may_2018', as.is = TRUE)
filenames <- readLines('metadata/jordi.runs/20181008_sp3_filenames.txt')

## IDs:
sp3 <- filenames %>%
  gsub(pattern = '_rmdups_Msp3_sorted.bam', replacement = '')

## Species names:
#sp3[which(is.na(match(sp3, inds$Sample_ID_edits)))]
species.or <- tolower(inds$Species[match(sp3, inds$Sample_ID_edits)])
species.or.df <- data.frame(sp3, species.or, filenames) %>%
  arrange(species.or, filenames)

## Reordered:
sp3 <- as.character(species.or.df$sp3)
species.or <- species <- as.character(species.or.df$species.or)
filenames <- as.character(species.or.df$filenames)

species <- gsub('sp. nov.#3', 'spp', species)
species <- gsub('sp. - mananara nord', 'spp', species)

## Additions:
additions <- rep('00000', length(sp3))

## Get ID nr within species:
macarthurii.count <- 1
mittermeieri.count <- 8
simmonsi.count <- 1
spp.count <- 16

nrs <- vector(); i <- 1
for(sp.f in species) {
  #sp.f <- species[1]

  cur.value <- get(paste0(sp.f, '.count'))

  assign(paste0(sp.f, '.count'), cur.value + 1)

  if(nchar(cur.value) == 1) nrs[i] <- paste0('00', cur.value)
  if(nchar(cur.value) == 2) nrs[i] <- paste0('0', cur.value)

  i <- i + 1

  cat(species[i-1], cur.value, nrs[i-1], i, '\n')
}

## Create final IDs:
IDs <- paste0('m', substr(species, 1, 3), nrs, '_r99_', additions)

## Create and write final df:
sp3.df <- data.frame(bam.file = filenames, Sample_ID = sp3,
                     species, species.or, sp.nr = nrs, ID = IDs)

write.table(sp3.df, 'metadata/sp3/sp3_r99_bamRenamingTable.txt',
            sep = '\t', quote = FALSE, row.names = FALSE)

IDs.alphabetic <- sort(unique(as.character(sp3.df$ID)))
writeLines(IDs.alphabetic, 'metadata/sp3/sp3_r99_IDs.txt')
