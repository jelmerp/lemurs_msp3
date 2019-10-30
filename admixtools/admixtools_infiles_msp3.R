##### SET-UP #####
rm(list = ls())
setwd('/home/jelmer/Dropbox/sc_lemurs/radseq/')
library(gdata); library(tidyverse)

inds <- read.xls('metadata/sp3/sp3_sample_selection_04_10_2018_JP.xls', sheet = 'Data') %>%
  select(ID, sp_short, loc, type, cluster, snapp)

ID.lookup.file <- 'metadata/ID.lookupTable.txt'
ID.lookup <- read.delim(ID.lookup.file, header = TRUE, as.is = TRUE)

msp3.IDs.file <- 'metadata/sp3/sp3_IDs.txt'
msp3.IDs <- readLines(msp3.IDs.file)

##### MSP3 INDFILE ####
msp3.oldIDs <- ID.lookup$Sample_ID[match(msp3.IDs, ID.lookup$ID)]

species <- substr(msp3.IDs, 1, 4) %>% gsub(pattern = 'mspp', replacement = 'msp3')
pop <- inds$loc[match(msp3.oldIDs, inds$ID)]
sp.pop <- ifelse(species == 'msp3', paste0(species, '.', pop), species)
sex <- 'U'

msp3.df <- data.frame(msp3.IDs, sex, sp.pop)
msp3.indfile <- 'analyses/admixtools/input/indfile_msp3.msp3pops.txt'
write.table(msp3.df, msp3.indfile,
            sep = '\t', quote = FALSE, row.names = FALSE, col.names = FALSE)


##### D4 POPFILE #####
#unique(msp3.df$sp.pop)
pop1 <- rep('mmac', 10)
pop2 <- c(rep('msp3.Anjiahely', 8), 'msp3.Ambavala', 'msim')
pop3 <- c(rep(c('msp3.Mananara_Nord', 'msp3.Ambavala', 'msp3.Antanambe', 'msp3.Antsiradrano'), 2), 'msim', 'mmit')
pop4 <- c(rep('mmur', 4), c(rep('msim', 4)), 'mmur', 'mmur')

popfile.d.df <- data.frame(pop1, pop2, pop3, pop4)
popfile <- 'analyses/admixtools/input/popfile_dstat_msp3.msp3pops.txt'
write.table(popfile.d.df, popfile,
            sep = '\t', quote = FALSE, row.names = FALSE, col.names = FALSE)

##### F3 POPFILE #####
pop1 <- rep('mmac', 6)
pop2 <- c(rep('msp3.Anjiahely', 4), 'msp3.Ambavala', 'msim')
pop3 <- c('msp3.Mananara_Nord', 'msp3.Ambavala', 'msp3.Antanambe', 'msp3.Antsiradrano', 'msim', 'mmit')

popfile.f3.df <- data.frame(pop1, pop2, pop3)
popfile <- 'analyses/admixtools/input/popfile_f3stat_msp3.msp3pops.txt'
write.table(popfile.f3.df, popfile,
            sep = '\t', quote = FALSE, row.names = FALSE, col.names = FALSE)

