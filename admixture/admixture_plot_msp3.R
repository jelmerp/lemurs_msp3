###############################################################################################
##### SET-UP #####
###############################################################################################
rm(list = ls()); gc()
setwd('/home/jelmer/Dropbox/sc_lemurs/radseq/')
library(tidyverse); library(plyr); library(reshape2); library(gridExtra)
library(RColorBrewer); library(gdata); library(ggpubr); library(cowplot)
library(png); library(grid)
source('scripts/admixture/admixture_plot_fun.R')

## Inds.df:
inds.df.file <- 'metadata/ID.lookupTable.txt'
inds.df <- read.delim(inds.df.file, header = TRUE, as.is = TRUE)

inds.df %>% filter(species.short == 'mmac')

## Get colors:
cols.sp.df <- read.delim('metadata/colors/colors.species.txt', header = TRUE, as.is = TRUE)
#cols.sp.df$color <- rep(brewer.pal(n = 8, name = 'Dark2'), 10)[1:nrow(cols.sp.df)]
cols.loc.df <- read.delim('metadata/colors/colors.loc.txt', header = TRUE, as.is = TRUE)
#cols.loc.df$color <- rep(brewer.pal(n = 8, name = 'Dark2'), 10)[1:nrow(cols.loc.df)]

## File ID:
file.ID <- 'msp3proj.mac3.FS6'
ind.set <- 'msp3proj.mac3.FS6'
#ind.set <- 'msp3proj.mac3.FS6.msp3mmac'


###############################################################################################
##### PLOT #####
###############################################################################################
k.plot(ind.set)

admix.plot.all(ind.set, col.by = 'species', indlab.text = 'ID',
               col.bars = FALSE, col.labs = TRUE,
               orientation = 'upright', plotwidth = 8, plotheight = 10)


###############################################################################################
##### PLOT SPECIFIC K #####
###############################################################################################
## For mmac and msp3 only:
admix.plot(ind.set = ind.set, K = 2, col.by = 'species', indlab.text = 'ID',
           col.bars = c('black', 'red'), col.labs = TRUE,
           orientation = 'upright', plotwidth = 6, plotheight = 8)

## For all pops:
admix.plot(ind.set = ind.set, K = 6, col.by = 'species', indlab.text = 'ID',
           col.bars = c('#0BFEFE', '#00CD00', '#0000FF', 'black', '#FF00FF', 'red'),
           col.labs = TRUE,
           orientation = 'upright', plotwidth = 6, plotheight = 8)

admix.ggplot(ind.set = ind.set, K = 6, col.by = 'species', indlab.text = 'ID',
             col.bars = c('#0BFEFE', '#00CD00', '#0000FF', 'black', '#FF00FF', 'red'),
             col.labs = TRUE, plotwidth = 6, plotheight = 8)


###############################################################################################
##### COMBINE PLOTS #####
###############################################################################################
## All species:
kplot.all <- k.plot('msp3proj.mac3.FS6', plot.title = 'All species')

## Intermediate bw/ mleh and mmit: #006780 http://www.colortools.net/color_combination.html
colvec5 <- c('grey50', '#FF00FF', 'red',  'black', '#0BFEFE')
cplot.all.k5 <- admix.ggplot(ind.set = 'msp3proj.mac3.FS6', K = 5,
                             col.bars = colvec5, col.labs = TRUE,
                             col.df = cols.sp.df, col.by.column = 'species.short',
                             indlab.text = 'sp', indlab.first.only = TRUE, indlab.size = 16,
                             plotwidth = 6, plotheight = 8, plot.title = 'K=5',
                             return.plot = TRUE, file.open = FALSE)

colvec6 <- c('#0BFEFE', '#00CD00', '#0000FF', 'black', '#FF00FF', 'red')
cplot.all.k6 <- admix.ggplot(ind.set = 'msp3proj.mac3.FS6', K = 6,
                             col.bars = colvec6, col.labs = TRUE,
                             col.df = cols.sp.df, col.by.column = 'species.short',
                             indlab.text = 'sp', indlab.first.only = TRUE, indlab.size = 16,
                             plotwidth = 6, plotheight = 8, plot.title = 'K=6',
                             return.plot = TRUE, file.open = FALSE)

## Mac and sp3 only:
kplot.mac <- k.plot('msp3proj.mac3.FS6.msp3mmac', plot.title = 'M. macarthurii and M. sp3')

cplot.mac.k2 <- admix.ggplot(ind.set = 'msp3proj.mac3.FS6.msp3mmac', K = 2,
                             col.bars = c('black', 'red'), col.labs = TRUE,
                             col.df = cols.sp.df, col.by.column = 'species.short',
                             indlab.text = 'sp', indlab.first.only = TRUE, indlab.size = 16,
                             plotwidth = 6, plotheight = 8, plot.title = 'K=2',
                             return.plot = TRUE, file.open = FALSE)

cplot.mac.k3 <- admix.ggplot(ind.set = 'msp3proj.mac3.FS6.msp3mmac', K = 3,
                             col.bars = c('grey20', 'red', 'grey60'), col.labs = TRUE,
                             col.df = cols.loc.df, col.by.column = 'sp.loc',
                             indlab.text = 'sp', indlab.first.only = TRUE, indlab.size = 12,
                             plotwidth = 6, plotheight = 8,
                             plot.title = 'K=3',
                             return.plot = TRUE, file.open = FALSE)

## Combine plots:
plots.all <- ggarrange(kplot.all, cplot.all.k5, cplot.all.k6,
                       ncol = 3, nrow = 1, widths = c(1, 1.1, 1.1))
plots.mac <- ggarrange(kplot.mac, cplot.mac.k2, cplot.mac.k3,
                       ncol = 3, nrow = 1, widths = c(1, 1.1, 1.1))

plots <- ggarrange(plots.all, plots.mac, ncol = 1, nrow = 2, heights = c(1, 1))
#plots <- plots + draw_plot_label(label = c('A', 'B', 'C'), size = 24,
#                                 x = c(0, 0, 0.4), y = c(1, 0.55, 0.9))

## Save plot:
figfile <- paste0('analyses/admixture/figures/msp3proj/', file.ID, 'combined.png')
ggexport(plots, filename = figfile, width = 900, height = 650)
system(paste0('xdg-open ', figfile))
