################################################################################
##### SET-UP #####
################################################################################
rm(list = ls()); gc()
setwd('/home/jelmer/Dropbox/sc_lemurs/radseq/')
library(plyr); library(reshape2); library(tidyverse)
source('scripts/dfoil/dfoil_plot_fun.R')

###########################################################################
##### PROCESS RESULTS #####
###########################################################################

## Normal mode:
file.id <- 'msp3proj.mac3.FS6.noMleh'
(dfoil <- read.dfoil.out(file.id = file.id, id.short = 'noMleh', alt = FALSE))

file.id <- 'msp3proj.mac3.FS6.noMmit'
(dfoil <- read.dfoil.out(file.id = file.id, id.short = 'noMmit', alt = FALSE))

file.id <- 'msp3proj.mac3.FS6.pop'
(dfoil <- read.dfoil.out(file.id = file.id, id.short = 'pop', alt = FALSE))

## dfoilalt mode:
file.id <- 'msp3proj.mac3.FS6.noMleh.altMode'
(dfoil <- read.dfoil.out(file.id = file.id, id.short = 'noMleh', alt = FALSE))

file.id <- 'msp3proj.mac3.FS6.noMmit.altMode'
(dfoil <- read.dfoil.out(file.id = file.id, id.short = 'noMmit', alt = FALSE))

file.id <- 'msp3proj.mac3.FS6.pop.altMode'
(dfoil <- read.dfoil.out(file.id = file.id, id.short = 'pop', alt = FALSE))

## Allele pattern counts:
#dfoil.in <- read.dfoil.in(file.id = file.id, id.short = 't10.maf0.15')
#dfoil.in %>% select(BBABA, BBBAA)
#dfoil.in %>% select(ABABA, ABBAA)
#dfoil.in %>% select(BAABA, BABAA)


###########################################################################
##### PLOT #####
###########################################################################
dfoil.plot <- dfoil %>%
  select(DFO, DIL, DFI, DOL) %>%
  melt(measure.vars = c('DFO', 'DIL', 'DFI', 'DOL'))

p <- ggplot(dfoil.plot, aes(variable, value))
p <- p + geom_col()
p <- p + scale_fill_discrete(name = 'statistic')
#p <- p + scale_y_continuous(limits = c(-0.09, 0.15))
p <- p + labs(x = "DFOIL statistic", y = 'value')
p <- p + theme_bw()
p <- p + theme(axis.text.x = element_text(size = 16), axis.text.y = element_text(size = 16))
p <- p + theme(axis.title.x = element_text(size = 18), axis.title.y = element_text(size = 18))
p <- p + theme(legend.position = 'top')
p <- p + theme(legend.title = element_text(size = 15, face = 'bold'), legend.text = element_text(size = 15))
p <- p + theme(legend.key.height = unit(0.5, "cm"), legend.key.width = unit(0.5, "cm"))
p

plotfile <- paste0('analyses/dfoil/figures/', file.id, '.png')
ggsave(plotfile, plot = p, width = 5, height = 6)



# p <- p + geom_bar(stat = "identity", position = 'dodge', colour = 'black')
# position=position_dodge(0.9)
# p <- p + scale_x_discrete(labels = c('Eja-Fus', 'Dec-Fus', 'Dec-Eja'))

# dd <- ggplot_build(p)$data[[1]]
# p <- p + annotate(geom = "text", x = dd$x[1], y = 0.09, label = "0", color = dd$fill[1], size = 6)
# p <- p + annotate(geom = "text", x = dd$x[2], y = 0.09, label = "0", color = dd$fill[2], size = 6)
# p <- p + annotate(geom = "text", x = dd$x[3], y = 0.09, label = "-", color = dd$fill[3], size = 8)
# p <- p + annotate(geom = "text", x = dd$x[4], y = 0.09, label = "-", color = dd$fill[4], size = 8)
# p <- p + annotate(geom = "text", x = dd$x[5], y = 0.09, label = "0", color = dd$fill[5], size = 6)
# p <- p + annotate(geom = "text", x = dd$x[6], y = 0.09, label = "0", color = dd$fill[6], size = 6)
# p <- p + annotate(geom = "text", x = dd$x[7], y = 0.09, label = "-", color = dd$fill[7], size = 8)
# p <- p + annotate(geom = "text", x = dd$x[8], y = 0.09, label = "-", color = dd$fill[8], size = 8)
# p <- p + annotate(geom = "text", x = dd$x[9], y = 0.09, label = "+", color = dd$fill[9], size = 8)
# p <- p + annotate(geom = "text", x = dd$x[10], y = 0.09, label = "+", color = dd$fill[10], size = 8)
# p <- p + annotate(geom = "text", x = dd$x[11], y = 0.09, label = "-", color = dd$fill[11], size = 8)
# p <- p + annotate(geom = "text", x = dd$x[12], y = 0.09, label = "-", color = dd$fill[12], size = 8)
# p <- p + annotate(geom = "text", x = 1, y = 0.11, label = "p12 <-> p4", color = 'grey20', size = 6)
# p <- p + annotate(geom = "text", x = 2, y = 0.11, label = "p12 <-> p4", color = 'grey20', size = 6)
# #p <- p + annotate(geom = "text", x = 3, y = 0.14, label = "p4 - p1p2", color = 'grey20', size = 5)