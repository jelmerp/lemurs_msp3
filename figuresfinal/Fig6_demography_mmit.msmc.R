################################################################################
#### SET-UP #####
################################################################################
setwd('/home/jelmer/Dropbox/sc_lemurs/')

## Scripts:
source('scripts/gphocs/gphocs_6_analyze_fun.R')
source('proj/msp3/scripts/gphocs/gphocs_fun_msp3.R')
source('scripts/msmc/msmc_processOutput_fun.R')

## Files:
infile_gphocsLog <- 'proj/msp3/analyses/gphocs/output/msp3_snapp12/mergedLogs.txt'
infile_gphocsLog2 <- 'proj/msp3/analyses/gphocs/output/msp3_eastwest2/mergedLogs.txt' # Ne plot
msmc.filedir <- 'proj/singlegenomes/analyses/msmc/output/samtools/ind/'
infile_popcols <- 'proj/msp3/analyses/gphocs/popInfo/ghocs_cols.txt'
infile_pops <- 'proj/msp3/analyses/gphocs/popInfo/ghocs_pops.txt'
infile_popcols2 <- 'metadata/colors/popcols.txt'
figfile_eps <- paste0('proj/msp3/figures_final/MSMC_comp.eps')

## Set ID:
setID <- 'msp3_bppComp'
setID.pops <- 'msp3_snapp12'

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

## Mean mutrate and gentime for MSMC:
mutrate.yr_mean <- 1.64e-8 / 3.5
gentime_mean <- 3.5

## Load log file:
Log <- as.data.frame(fread(infile_gphocsLog, stringsAsFactors = TRUE))
poplevels_snapp12 <- c('mac', 'sp3', 'anc.A3', 'leh', 'mit', 'anc.LI',
                       'sim', 'anc.LIS', 'anc.LISA3', 'mur', 'anc.root')
Log$pop <- factor(Log$pop, levels = poplevels_snapp12)
Log <- filter(Log, runID %in% c('multmig1', 'noMig', 'bpp'))
Log$runID <- factor(Log$runID, levels = c('bpp', 'noMig', 'multmig1'))

## Pops and pop colors:
pops <- read.delim(infile_pops, header = TRUE, as.is = TRUE)
kidpops <- pops$kidpop[pops[, grep(setID.pops, colnames(pops))] == 1]
parentpops <- pops$parentpop[pops[, grep(setID.pops, colnames(pops))] == 1]
allpops <- levels(Log$pop)
currentpops <- allpops[grep('anc', allpops, invert = TRUE)]
ancpops <- allpops[grep('anc', allpops)]

## Species and pop colors:
popcols.df <- read.delim(infile_popcols, header = TRUE, as.is = TRUE)
cols.df <- read.delim(infile_popcols2, header = TRUE, as.is = TRUE)
col.mit <- cols.df$color[cols.df$species.short == 'mmit']
col.sp3 <- cols.df$color[cols.df$species.short == 'msp3']


################################################################################
#### MSMC COMP PLOT -- MMIT #####
################################################################################
## Get MSMC result:
msmc <- select_files(msmc_mode = 'ind',
                     to.select = 'mmit01',
                     method = 'samtools',
                     filedir = msmc.filedir,
                     additional.grep = 'scaffoldsGt1mb') %>%
  read_msmc(mutrate = mutrate.yr_mean,
            gen.time = gentime_mean) %>%
  mutate(ID = 'MSMC')

## G-PhoCS results - mig:
setID = 'RAD: mig'
Log.subset <- subset(Log, runID == 'multmig1')
gphocsNe <- tt.prep.snapp12(Log.subset) %>%
    dplyr::select(pop, tau, theta) %>%
    dplyr::rename(t.min = tau, Ne = theta) %>%
    dplyr::filter(pop %in% c('anc.root', 'anc.LISA3', 'anc.LIS', 'anc.LI', 'mit')) %>%
    dplyr::mutate(t.max = NA, Ne = Ne * 1000, t.min = t.min * 1000)
gphocsNe$ID <- setID
gphocsNe$t.min[which(is.na(gphocsNe$t.min))] <- 0
gphocsNe$t.max[gphocsNe$pop == 'anc.root'] <- 10e7
gphocsNe$t.max[gphocsNe$pop == 'mit'] <- gphocsNe$t.min[gphocsNe$pop == 'anc.LI']
gphocsNe$t.max[gphocsNe$pop == 'anc.LI'] <- gphocsNe$t.min[gphocsNe$pop == 'anc.LIS']
gphocsNe$t.max[gphocsNe$pop == 'anc.LIS'] <- gphocsNe$t.min[gphocsNe$pop == 'anc.LISA3']
gphocsNe$t.max[gphocsNe$pop == 'anc.LISA3'] <- gphocsNe$t.min[gphocsNe$pop == 'anc.root']
(gphocs.mig <- gather(gphocsNe, 'aap', 'time', c('t.min', 't.max')) %>%
    select(-aap) %>%
    arrange(time, pop) %>%
    select(time, Ne, pop, ID))

## G-PhoCS results - iso:
setID = 'RAD: iso'
Log.subset <- subset(Log, runID == 'noMig')
gphocsNe <- tt.prep.snapp12(Log.subset) %>%
  dplyr::select(pop, tau, theta) %>%
  dplyr::rename(t.min = tau, Ne = theta) %>%
  dplyr::filter(pop %in% c('anc.root', 'anc.LISA3', 'anc.LIS', 'anc.LI', 'mit')) %>%
  dplyr::mutate(t.max = NA, Ne = Ne * 1000, t.min = t.min * 1000)
gphocsNe$ID <- setID
gphocsNe$t.min[which(is.na(gphocsNe$t.min))] <- 0
gphocsNe$t.max[gphocsNe$pop == 'anc.root'] <- 10e7
gphocsNe$t.max[gphocsNe$pop == 'mit'] <- gphocsNe$t.min[gphocsNe$pop == 'anc.LI']
gphocsNe$t.max[gphocsNe$pop == 'anc.LI'] <- gphocsNe$t.min[gphocsNe$pop == 'anc.LIS']
gphocsNe$t.max[gphocsNe$pop == 'anc.LIS'] <- gphocsNe$t.min[gphocsNe$pop == 'anc.LISA3']
gphocsNe$t.max[gphocsNe$pop == 'anc.LISA3'] <- gphocsNe$t.min[gphocsNe$pop == 'anc.root']
(gphocs.iso <- gather(gphocsNe, 'aap', 'time', c('t.min', 't.max')) %>%
    select(-aap) %>%
    arrange(time, pop) %>%
    select(time, Ne, pop, ID))

## Merge:
ne.comp.mmit <- rbind.fill(msmc, gphocs.mig, gphocs.iso)

## Make plot:
(p_mmit <- plot_msmc(ne.comp.mmit, lwd = 2, save.plot = FALSE) +
    coord_cartesian(xlim = c(10000, 1.5e6),
                    ylim = c(0, 140)) +
    theme(axis.text.y = element_blank(),
          axis.title.y = element_blank(),
          axis.text.x = element_text(size = 24),
          axis.title.x = element_text(size = 24,
                                      margin = margin(0, 0, 0, 0, 'cm')),
          legend.position = 'right',
          legend.title = element_blank(),
          legend.text = element_text(size = 15),
          legend.margin = margin(0.15, 0.15, 0.15, 0.15, "cm"),
          legend.key.height = unit(0.6, "cm"),
          legend.key.width = unit(0.4, "cm"),
          legend.background = element_rect(fill = "grey90", colour = "grey30"),
          legend.key = element_rect(fill = "grey90"),
          panel.border = element_rect(colour = "grey20", fill = NA, size = 1),
          plot.margin = margin(1, 0.6, 0.4, 0.2, 'cm')))


################################################################################
#### MSMC COMP PLOT -- MSP3 #####
################################################################################
## Set-up for 3-sp GPhoCS run:
setID <- 'msp3_eastwest2'
Log_eastwest2 <- as.data.frame(fread(infile_gphocsLog2, stringsAsFactors = TRUE))
poplevels <- c('mac', 'anc.A3', 'sp3-W', 'sp3-E', 'anc.sp3', 'leh', 'anc.root')
Log_eastwest2$pop <- factor(Log_eastwest2$pop, levels = poplevels)

## Pops and popcols:
allpops <- levels(Log_eastwest2$pop)
currentpops <- allpops[grep('anc', allpops, invert = TRUE)]
ancpops <- allpops[grep('anc', allpops)]

## Get MSMC result:
msmc <- select_files(msmc_mode = 'ind',
                     to.select = 'mmac01',
                     method = 'samtools',
                     filedir = msmc.filedir,
                     additional.grep = 'scaffoldsGt1mb') %>%
  read_msmc(mutrate = mutrate.yr_mean,
            gen.time = gentime_mean) %>%
  mutate(ID = 'MSMC')

## Get G-PhoCS results and merge:
gphocs.mig <- prep.gphocsNe(subset(Log_eastwest2, runID == 'multmig3'),
                            setID = 'GPhoCS: mig')
gphocs.iso <- prep.gphocsNe(subset(Log_eastwest2, runID == 'noMig'),
                            setID = 'GPhoCS: iso')
ne.comp <- rbind.fill(msmc, gphocs.mig, gphocs.iso)

## Make plot:
(p_msp3 <- plot_msmc(ne.comp,
                     lwd = 2,
                     save.plot = FALSE) +
    coord_cartesian(xlim = c(10000, 1.5e6),
                  ylim = c(0, 140)) +
    labs(y = expression(N[e] ~ "(in 1000s)")) +
    guides(color = FALSE) +
    theme(axis.text.x = element_text(size = 24),
        axis.title.x = element_text(size = 24,
                                    margin = margin(0, 0, 0, 0, 'cm')),
        legend.title = element_blank(),
        legend.text = element_text(size = 15),
        legend.margin = margin(0.15, 0.15, 0.15, 0.15, "cm"),
        legend.key.height = unit(0.6, "cm"),
        legend.key.width = unit(0.4, "cm"),
        legend.background = element_rect(fill = "grey90", colour = "grey30"),
        legend.key = element_rect(fill = "grey90"),
        panel.border = element_rect(colour = "grey20", fill = NA, size = 1),
        plot.margin = margin(1, 0.6, 0.4, 0.2, 'cm')))


################################################################################
#### COMBINE PLOTS #####
################################################################################
p <- ggarrange(p_msp3, p_mmit,
               ncol = 2, nrow = 1, widths = c(1, 1.12)) +
  draw_plot_label(label = c("A", "B"),
                  size = 26,
                  x = c(0.05, 0.44),
                  y = c(1, 1))

ggsave(filename = figfile_eps, width = 10, height = 6,
       device = cairo_ps, fallback_resolution = 150)
system(paste('xdg-open', figfile_eps))

