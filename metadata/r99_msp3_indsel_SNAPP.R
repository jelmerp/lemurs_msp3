##### SET-UP #####
setwd('/home/jelmer/Dropbox/sc_lemurs/radseq/')
library(gdata); library(tidyverse)

inds <- read.delim('metadata/ID.lookupTable.txt', as.is = TRUE, header = TRUE)
indsel <- read.xls('metadata/sp3/sp3_sample_selection_04_10_2018_JP.xls',
                   sheet = 'SNAPP')

#indsel.file <- 'analyses/sp3/Msp3.data.info_withSNAPP.txt'
#indsel <- read.delim(indsel.file, as.is = TRUE, header = TRUE)

indsel %>%
  select(ID, sp, SNAPP_22, SNAPP_12) %>%
  filter(SNAPP_12 == 1)

inds.22 <- indsel$ID[indsel$SNAPP_22 == 1]
inds.12 <- indsel$ID[indsel$SNAPP_12 == 1]

inds.22 %in% inds$Sample_ID # should be all TRUE
#inds.22[! inds.22 %in% inds$Sample_ID]
inds.12 %in% inds$Sample_ID # should be all TRUE

IDs.22 <- sort(inds$ID[match(inds.22, inds$Sample_ID)])
IDs.12 <- sort(inds$ID[match(inds.12, inds$Sample_ID)])

inds[match(inds.12, inds$Sample_ID), ]

writeLines(IDs.22, 'analyses/SNAPP/snapp.22.inds.txt')
writeLines(IDs.12, 'analyses/SNAPP/snapp.12.inds.txt')

inds.sp3.file <- 'metadata/sp3/sp3_IDs.txt'
##inds.sp3 <- readLines(inds.sp3.file)
#IDs.12 %in% inds.sp3

