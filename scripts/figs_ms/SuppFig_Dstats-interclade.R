## Set-up:
library(here)
source(here('scripts/genomics/admixtools/admixtools_plot_fun.R'))

## Input file>
infile_atools <- here('analyses/admixtools/output/msp3proj.mac3.FS6.dstat_msp3.dmode.out')

## Output file:
figfile <- here('figs/ms/SuppFig_Dstats2.eps')

## Get df:
d <- prep_d(infile_atools) %>%
  mutate(popcomb = gsub('\\(m', '(', popcomb),
         popcomb = gsub(',m', ',', popcomb),
         plotorder = c(7, 8, 4, 5, 6, 1, 2, 3, 9, 10),
         popcomb = factor(popcomb, levels = popcomb[order(plotorder)]))

## Create D-stats plot:
p <- plot_d(d, marg_sig = TRUE, figsave = TRUE, figfile = figfile)

