## Set-up:
setwd('/home/jelmer/Dropbox/sc_lemurs/msp3/')
library(tidyverse)
source('../scripts/admixtools/admixtools_plot_fun.R')
file.id.short <- 'msp3proj.mac3.FS6'
figfile_eps <- 'final_figures/SuppFig_Dstats.eps'

## Get df:
fileID.sp <- 'msp3proj.mac3.FS6.dstat_msp3'
(d.sp <- return.dfmode(file.id = fileID.sp) %>%
    mutate(popcomb = gsub('\\(m', '(', popcomb)) %>%
    mutate(popcomb = gsub(',m', ',', popcomb)) %>%
    arrange(desc(popcomb)))

#d.sp$plotorder <- c(9, 10, 7, 6, 8, 3, 5, 4, 2, 1)
d.sp$plotorder <- c(7, 8, 4, 5, 6, 1, 2, 3, 9, 10)
d.sp$popcomb <- factor(d.sp$popcomb,
                       levels = d.sp$popcomb[order(d.sp$plotorder)])

## Create D-stats plot:
p <- plot.dstats(d.sp, marg.sig = TRUE,
                 fig.save = TRUE, figfile = figfile_eps)

