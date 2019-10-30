################################################################################
##### SET-UP #####
################################################################################
setwd('/home/jelmer/Dropbox/sc_lemurs/msp3/')
source('../scripts/admixtools/admixtools_plot_fun.R')
library(tidyverse)
library(ggpubr)
library(cowplot)

file.id.short <- 'msp3proj.mac3.FS6'


################################################################################
##### D-STATS ####
################################################################################
source('../scripts/admixtools/admixtools_plot_fun.R')
file.id.short <- 'msp3proj.mac3.FS6'

## By species:
fileID.sp <- 'msp3proj.mac3.FS6.dstat_msp3'
figfile <- paste0('analyses/admixtools/figures/', file.id, '2.png')
(d.sp <- return.dfmode(file.id = fileID.sp) %>%
    mutate(popcomb = gsub('\\(m', '(', popcomb)) %>%
    mutate(popcomb = gsub(',m', ',', popcomb)) %>%
    arrange(desc(popcomb)))
#dplot.sp <- plot.dstats(d.df, fig.save = FALSE, figfile = figfile)

## By pop:
fileID.pop <- 'msp3proj.mac3.FS6.dstat_msp3.msp3pops'
figfile <- paste0('analyses/admixtools/figures/msp3proj/', file.id, '.png')
(d.pop1 <- return.dfmode(file.id = 'msp3proj.mac3.FS6.dstat_msp3.msp3pops2'))
(d.pop2 <- return.dfmode(file.id = 'msp3proj.mac3.FS6.dstat_msp3.msp3pops'))
d.pop <- rbind(d.pop1, d.pop2) %>%
  mutate(popcomb = gsub('\\(m', '(', popcomb)) %>%
  mutate(popcomb = gsub(',m', ',', popcomb)) %>%
  mutate(popcomb = gsub('Mt3', '*', popcomb)) %>%
  mutate(popcomb = gsub('east', 'S', popcomb)) %>%
  mutate(popcomb = gsub('west', 'N', popcomb))
(d.pop <- d.pop[-c(1:5, 7, 8, 9, 11), ])
#dplot.pop <- plot.dstats(d.pop, fig.save = FALSE)

## Combine dfs:
d.all <- rbind(d.sp, d.pop)
d.all$plotorder <- c(9, 10, 7, 6, 8, 3, 5, 4, 11, 12, 2, 1)
d.all$popcomb <- factor(d.all$popcomb, levels = d.all$popcomb[order(d.all$plotorder)])

## Create D-stats plot:
dplot.all <- plot.dstats(d.all, fig.save = FALSE) +
  theme(plot.margin  = margin(0, 0, 0, 0, 'cm'))


################################################################################
##### COMBINE PLOTS PLOT ####
################################################################################
## Arrange A and B panels:
plots <- ggarrange(dplot.sp, dplot.pop,
                   ncol = 2, nrow = 1, widths = c(1, 1.2))
plots <- plots + draw_plot_label(label = c("A", "B"), size = 24,
                                 x = c(0, 0.45), y = c(1, 1))

## Save as png:
figfile <- paste0('analyses/admixtools/figures/Dstats_', file.id.short, '.png')
ggexport(plots, filename = figfile, width = 1000, height = 650)
system(paste0('xdg-open ', figfile))


