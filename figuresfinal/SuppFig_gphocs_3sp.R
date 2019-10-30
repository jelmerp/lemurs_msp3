################################################################################
#### SET-UP #####
################################################################################
setwd('/home/jelmer/Dropbox/sc_lemurs/')
source('scripts/gphocs/gphocs_6_analyze_fun.R')
source('msp3/scripts/gphocs/gphocs_fun_msp3.R')

## IDs and files:
setID <- 'msp3_eastwest2'

infile_logs1 <- 'msp3/analyses/gphocs/output/msp3_eastwest2/mergedLogs.txt'
infile_logs2 <- 'msp3/analyses/gphocs/output/msp3_eastwest2p/mergedLogs.txt'

infile_popcols <- 'msp3/analyses/gphocs/popInfo/ghocs_cols.txt'
infile_pops <- 'msp3/analyses/gphocs/popInfo/ghocs_pops.txt'

outfile_fig <- 'msp3/figures_final/SuppFig_gphocs_4sp.png'

## Packages:
library(data.table)
library(png)
library(grid)
library(RColorBrewer)
library(ggpubr)
library(cowplot)
library(TeachingDemos)
library(plyr)
library(reshape2)
library(tidyverse)

## Load log file:
Log1 <- as.data.frame(fread(infile_logs1, stringsAsFactors = TRUE))
Log1 <- Log1 %>% dplyr::filter(runID != 'multmig3',
                               runID != 'multmig4',
                               runID != 'multmig5')

Log2 <- as.data.frame(fread(infile_logs2, stringsAsFactors = TRUE))
Log2 <- Log2 %>% dplyr::filter(runID == 'multmig7')
Log <- rbind(Log1, Log2)
poplevels <- c('mac', 'sp3-W', 'sp3-E', 'anc.sp3', 'anc.A3', 'leh', 'anc.root')
Log$pop <- factor(Log$pop, levels = poplevels)

## Pops:
popcols.df <- read.delim(infile_popcols, header = TRUE, as.is = TRUE)
pops <- read.delim(infile_pops, header = TRUE, as.is = TRUE)
kidpops <- pops$kidpop[pops[, grep(setID, colnames(pops))] == 1]
parentpops <- pops$parentpop[pops[, grep(setID, colnames(pops))] == 1]
allpops <- levels(Log$pop)
currentpops <- allpops[grep('anc', allpops, invert = TRUE)]
ancpops <- allpops[grep('anc', allpops)]


################################################################################
#### THETA PLOT #####
################################################################################
## Prep:
thlog <- subset(Log, var == 'theta' & migtype.run != 'single')
pop.labs.theta <- c('mac', 'sp3N',  'sp3S', 'sp3A', 'anc_ms', 'leh', 'root')

## Plot:
th <- vplot(thlog,
            xvar = 'pop',
            fillvar = 'cn',
            colvar = 'migtype.run',
            yvar = 'cval',
            linecols = NULL,
            xlab = "",
            ylab = cvar('theta'),
            pop.labs = pop.labs.theta,
            legpos = 'top',
            legcolname = "",
            rm.leg.col = FALSE,
            rotate.x.ann = TRUE,
            col.labs = c('isolation model', 'migration model'),
            yticks.by = 25) +
  theme(plot.margin  = margin(0.2, 1, 0, 0.2, 'cm'))
th


################################################################################
#### M PLOT #####
################################################################################
## Prep:
mlog <- Log %>%
  dplyr::filter(var == 'm.prop' & grepl('leh', migpattern)) %>%
  dplyr::filter(migtype.run == 'single' | runID == 'multmig7')
mlog$migpattern <- droplevels(mlog$migpattern)

mlog$migpattern <- recode(
  mlog$migpattern,
  'mac_2_leh' = 'a', 'leh_2_mac' = 'b',
  'sp3-E_2_leh' = 'c', 'leh_2_sp3-E' = 'd',
  'sp3-W_2_leh' = 'e', 'leh_2_sp3-W' = 'f',
  'anc.sp3_2_leh' = 'i', 'leh_2_anc.sp3' = 'j',
  'anc.A3_2_leh' = 'g', 'leh_2_anc.A3' = 'h'
  ) %>%
  factor(., levels = c('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j')) %>%
  droplevels()

pop.labs.tau <- c('mac > leh', 'leh > mac', 'sp3S > leh', 'leh > sp3S',
                  'sp3N > leh', 'leh > sp3N', 'sp3A > leh', 'leh > sp3A',
                  'anc_ms > leh', 'leh > anc_ms')

## Plot:
m <- vplot(mlog,
           xvar = 'migpattern',
           fillvar = 'cn',
           colvar = 'migtype.run',
           yvar = 'val',
           linecols = NULL,
           xlab = "",
           ylab = 'migrant percentage',
           col.labs = c('multiple', 'single'),
           legpos = 'top',
           legcolname = "migration in model",
           rm.leg.col = FALSE,
           yticks.by = 0.01,
           rotate.x.ann = TRUE) +
  theme(plot.margin  = margin(0.2, 0.2, 0, 1, 'cm')) +
  scale_x_discrete(labels = pop.labs.tau)
m

################################################################################
#### COMBINE PLOTS #####
################################################################################
plots <- ggarrange(th, m, ncol = 2, nrow = 1, widths = c(1, 1)) +
  draw_plot_label(label = c("A", "B"), size = 24, x = c(0, 0.5), y = c(1, 1))

ggexport(plots, filename = outfile_fig, width = 900, height = 500)
system(paste('xdg-open', outfile_fig))
