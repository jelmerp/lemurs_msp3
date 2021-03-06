################################################################################
##### SET-UP #####
################################################################################
setwd('/home/jelmer/Dropbox/sc_lemurs/radseq/analyses/trees/treemix/')
source('/home/jelmer/Dropbox/sc_lemurs/radseq/scripts/trees/treemix_plotting_funcs.R') # Script that comes with Treemix
source('/home/jelmer/Dropbox/sc_lemurs/radseq/scripts/trees/treemix_plotFun.R') # My script

library(tidyverse)
library(ggpubr)
library(cowplot)

## Variables:
file.ID <- 'msp3proj.mac3.FS6'
root <-'mmur'
nmig.vector <- 0:10
dir.output <- 'output'
dir.fig <- 'figures'
poporder <- c('mleh', 'mmac', 'mmit', 'mmur', 'msim', 'msp3')
file.open <- TRUE

## Process:
poporder.file <- paste0('popfiles/', file.ID, '_poporder.txt')
writeLines(poporder, poporder.file)


################################################################################
##### PROPORTION OF VARIANCE EXPLAINED #####
################################################################################
cat('Df with proportion of variance explained: \n')
(propVar.df <- get.propVar.df(file.ID, dir.output, root))
propVar.plot <- plot.propVar(propVar.df, file.ID, dir.fig, file.open = TRUE)


################################################################################
##### LIKELIHOOD PLOT AND LRT #####
################################################################################
cat('Df with likelihoods: \n')
llh.df <- get.llh.df(file.ID, root, nmig.vector, dir.output)
llh.plot <- plot.llh(llh.df, file.ID, dir.fig, file.open = TRUE)


################################################################################
##### TREE PLOT FOR EACH VALUE OF M #####
################################################################################
cat('Plotting trees: \n')
sapply(nmig.vector, plot.tree,
       file.ID, root, dir.output, dir.fig,
       png.background = 'white', file.open = file.open, filetype = 'png')


################################################################################
##### PLOT RESIDUALS #####
################################################################################
## Positive residuals: candidates for admixture
sapply(nmig.vector, plot.residuals,
       file.ID, poporder.file, dir.output, dir.figs, file.open = file.open)
#plot.residuals(0, file.ID, poporder.file, dir.output, dir.figs)


################################################################################
##### COMBINE PLOTS #####
################################################################################
library(png); library(grid)
treemix.plot.file <- 'figures/msp3proj.mac3.FS6.nmig3.rootmmur.png'
treemix.plot <- rasterGrob(readPNG(treemix.plot.file), interpolate = TRUE)
treemix.plot <- ggplot(data.frame()) +
  geom_blank() +
  annotation_custom(treemix.plot, xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf)

plots1 <- ggarrange(propVar.plot, llh.plot, ncol = 1, nrow = 2, heights = c(1, 1.2))
plots <- ggarrange(plots1, treemix.plot, ncol = 2, nrow = 1, widths = c(1, 1.5))
plots <- plots + draw_plot_label(label = c('A', 'B', 'C'), size = 24,
                                 x = c(0, 0, 0.4), y = c(1, 0.55, 0.9))

figfile <- paste0('figures/msp3proj/', file.ID, 'combined.png')
ggexport(plots, filename = figfile, width = 900, height = 650)
system(paste0('xdg-open ', figfile))
