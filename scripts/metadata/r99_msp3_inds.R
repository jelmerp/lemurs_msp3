setwd('/home/jelmer/Dropbox/sc_lemurs/radseq')
library(gdata); library(tidyverse)

r01.df <-  read.delim('metadata/r01/samples/samplenames_r01.txt', header = TRUE)
#msp3.df <- read.xls('metadata/sp3/sp3_sample_selection_04_10_2018_JP.xls', sheet = 'Data')
all.df <- read.xls('metadata/consortium.files/20180709_Samples_RAD_consortium.xls',
                   sheet = 'Samples_rad_micro_may_2018') %>%
  select(Sample_ID, Sample_ID_edits, Species, Locality, Team, Type) %>%
  rename(species = Species, loc = Locality, team = Team, dnaType = Type)

##### GET LIST OF IDs ####

