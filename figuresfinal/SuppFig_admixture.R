###############################################################################################
##### SET-UP #####
###############################################################################################
setwd('/home/jelmer/Dropbox/sc_lemurs/msp3/')
source('../scripts/admixture/admixture_plot_fun.R')

## Libraries:
library(tidyverse)
library(gridExtra)
library(RColorBrewer)
library(ggpubr)
library(cowplot)
library(png)
library(grid)
library(rlang)

## IDs:
setID.all <- 'msp3proj.mac3.FS6'
setID.mac <- 'msp3proj.mac3.FS6.msp3mmac'

## Files and dirs:
indir <- 'analyses/admixture/output/'
infile_metadata <- '../radseq/metadata/lookup_IDshort.txt'
infile_cols.sp <- '../metadata/colors/colors.species.txt'
infile_cols.loc <- '../metadata/colors/colors.loc.txt'

figfile <- paste0('final_figures/SuppFig_admixture.png')

## Read metadata:
cols.sp.df <- read.delim(infile_cols.sp, as.is = TRUE) %>%
  select(-species)
inds.df <- read.delim(infile_metadata, as.is = TRUE) %>%
  merge(., cols.sp.df, by = 'species.short') %>%
  rename(labcol = color) %>%
  mutate(species.cor = substr(species.cor, 2, 4))
missingSupersite <- which(is.na(inds.df$supersite))
inds.df$supersite[missingSupersite] <- inds.df$species.cor[missingSupersite]

#cols.loc.df <- read.delim(infile_cols.loc, as.is = TRUE)
#inds.df$sp.loc2 <- cols.loc.df$sp.loc2[match(inds.df$spSite, cols.loc.df$sp.loc)]


###############################################################################################
##### PLOTS -- All SPECIES #####
###############################################################################################
colvec5 <- c('grey50', '#FF00FF', 'red',  'black', '#0BFEFE')
colvec6 <- c('#0BFEFE', '#00CD00', '#0000FF', 'black', '#FF00FF', 'red')

## All species:
k.all <- k.plot(setID.all, plot.title = 'All species', file.save = F) +
  theme(plot.margin  = margin(0.2, 0.5, 0.8, 0.2, 'cm'))

c.all.k5 <- Qdf(setID.all, K = 5,
                convertToShortIDs = TRUE, sort.by = 'species.cor') %>%
  ggax(., barcols = colvec5, labcols = 'labcol',
       indlab.column = 'species.cor', indlab.firstOnly = TRUE,
       indlab.size = 16, plot.title = 'K=5') +
  theme(plot.margin  = margin(0.2, 0.5, 0.8, 0.2, 'cm'))

c.all.k6 <- Qdf(setID.all, K = 6,
                convertToShortIDs = TRUE, sort.by = 'species.cor') %>%
  ggax(., barcols = colvec6, labcols = 'labcol',
       indlab.column = 'species.cor', indlab.firstOnly = TRUE,
       indlab.size = 16, plot.title = 'K=6') +
  theme(plot.margin  = margin(0.2, 0.5, 0.8, 0.2, 'cm'))


###############################################################################################
##### PLOTS -- ONLY MAC AND SP3 #####
###############################################################################################
k.title <- expression(paste(bolditalic("M. macarthurii"), bold("and "),
                            bolditalic('M.'), bold("sp. #3")))

## K plot:
k.mac <- k.plot(setID.mac, plot.title = k.title) +
  theme(plot.margin  = margin(0.8, 0.5, 0, 0.2, 'cm'))

## Barplots:
c.mac.k2 <- Qdf(setID.mac, K = 2,
                convertToShortIDs = TRUE, sort.by = 'species.cor') %>%
  ggax(., barcols = c('black', 'red'), labcols = 'labcol',
       indlab.column = 'species.cor', indlab.firstOnly = TRUE,
       indlab.size = 16, plot.title = 'K=2') +
  theme(plot.margin  = margin(0.8, 0.5, 0, 0.2, 'cm'))

c.mac.k3 <- Qdf(setID.mac, K = 3,
                convertToShortIDs = TRUE, sort.by = 'supersite') %>%
  ggax(., barcols =  c('grey20', 'red', 'grey60'), labcols = 'labcol',
       indlab.column = 'supersite', indlab.firstOnly = TRUE,
       indlab.size = 16, plot.title = 'K=3') +
  theme(plot.margin  = margin(0.8, 0.5, 0, 0.2, 'cm'))


###############################################################################################
##### COMBINE PLOTS #####
###############################################################################################
plots.all <- ggarrange(k.all, c.all.k5, c.all.k6,
                       ncol = 3, nrow = 1, widths = c(1, 1.1, 1.1))
plots.mac <- ggarrange(k.mac, c.mac.k2, c.mac.k3,
                       ncol = 3, nrow = 1, widths = c(1, 1.1, 1.1))
plots <- ggarrange(plots.all, plots.mac, ncol = 1, nrow = 2, heights = c(1, 1))

#plots <- plots + draw_plot_label(label = c('A', 'B', 'C'), size = 24,
#                                 x = c(0, 0, 0.4), y = c(1, 0.55, 0.9))

ggexport(plots, filename = figfile, width = 900, height = 650)
system(paste0('xdg-open ', figfile))
