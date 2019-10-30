################################################################################################
#### SET-UP #####
################################################################################################
setwd('/home/jelmer/Dropbox/sc_lemurs/msp3/')
source('../scripts/admixtools/admixtools_plot_fun.R')
library(tidyverse)

## Output file:
figfile_eps <- 'figures_final/panels-and-prep/Fig5_geneflow_Dstats.eps'

## D-stats df:
d.pop1 <- return.dfmode(file.id = 'msp3proj.mac3.FS6.dstat_msp3.msp3pops2')
d.pop2 <- return.dfmode(file.id = 'msp3proj.mac3.FS6.dstat_msp3.msp3pops')
d.df <- rbind(d.pop1, d.pop2) %>%
  mutate(popcomb = gsub('\\(m', '(', popcomb)) %>%
  mutate(popcomb = gsub(',m', ',', popcomb)) %>%
  mutate(popcomb = gsub('Mt3', '*', popcomb)) %>%
  mutate(popcomb = gsub('east', '-S', popcomb)) %>%
  mutate(popcomb = gsub('west', '-N', popcomb)) %>%
  mutate(popcomb = gsub('mac$', 'mac ', popcomb))
(d.df <- d.df[c(6, 10), ])

mylabs <- c('(sp3-S,sp3-N),mac ',
            expression(paste('(sp3-S,', bold("sp3-N"), ')', bold(',mac*'))))

## Create D-stats plot:
(p_d <- plot.dstats(d.df, marg.sig = TRUE, ylab = 'D') +
    scale_x_discrete(labels = mylabs) +
    scale_y_continuous(limits = c(0, 0.11),
                       breaks = c(0, 0.05, 0.1),
                       expand = c(0, 0)) +
    theme(panel.grid.minor = element_blank(),
          legend.text = element_text(size = 16),
          legend.margin = margin(1, 5, 2, 1),
          legend.box.margin = margin(0, 0, -5, 0),
          legend.background = element_rect(fill = "white", colour = "grey10",
                                           size = 0.1),
          plot.margin = margin(0.2, 1, 0, 0.2, 'cm')))

## Save plot:
ggsave(figfile_eps, width = 4.5, height = 2.5)
system(paste0('xdg-open ', figfile_eps))
