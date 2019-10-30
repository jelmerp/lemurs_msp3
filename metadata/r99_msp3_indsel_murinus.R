rm(list = ls()); gc()
setwd('/home/jelmer/Dropbox/sc_lemurs/radseq')
library(tidyverse)

inds.df <-  read.delim('metadata/r01/samples/samplenames_r01.txt', header = TRUE)

stats.dir <- 'analyses/qc/vcf/gatk/mapped2mmur/paired/joint/vcftools'
file.id <- 'Microcebus.r01.FS6.mac3.MurGanMan'

imiss.file <- paste0(stats.dir, '/', file.id, '.imiss')
imiss <- read.table(imiss.file, header = TRUE)
imiss$species <- substring(imiss$INDV, 1, 4)
imiss <- imiss %>%
  filter(species == 'mmur') %>%
  arrange(F_MISS)
head(imiss)

idepth.file <- paste0(stats.dir, '/', file.id, '.idepth')
idepth <- read.table(idepth.file, header = TRUE)
idepth$species <- substring(idepth$INDV, 1, 4)
idepth <- idepth %>%
  filter(species == 'mmur') %>%
  arrange(desc(MEAN_DEPTH))
head(idepth)

miss.df <- merge(imiss[, c('INDV', 'F_MISS')],
             idepth[, c('INDV', 'MEAN_DEPTH')],
             by = 'INDV', all.x = TRUE, all.y = TRUE)
colnames(miss.df) <- c('ID', 'f.miss', 'mean.depth')

miss.df <- merge(miss.df, inds.df, by = 'ID')
miss.df <- miss.df %>% filter(species == 'murinus')


ggplot(data = miss.df) +
  geom_jitter(aes(x = locality, y = mean.depth), width = 0.1)

ggplot(data = miss.df) +
  geom_jitter(aes(x = locality, y = f.miss), width = 0.1)

miss.df %>%
  filter(locality == 'Andranomena') %>%
  select(ID, mean.depth, f.miss)
