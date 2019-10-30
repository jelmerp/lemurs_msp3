################################################################################
#### SET-UP #####
################################################################################
setwd('/home/jelmer/Dropbox/sc_lemurs/')

## Scripts:
source('scripts/gphocs/gphocs_6_analyze_fun.R')
source('msp3/scripts/gphocs/gphocs_fun_msp3.R')
source('scripts/msmc/msmc_processOutput_fun.R')

## Files:
infile_gphocsLog <- 'msp3/analyses/gphocs/output/msp3_snapp12/mergedLogs.txt'
infile_bppLog <- 'msp3/analyses/bpp/bppLog.txt'
infile_gphocsLog2 <- 'msp3/analyses/gphocs/output/msp3_eastwest2/mergedLogs.txt' # Ne plot
msmc.filedir <- 'singlegenomes/analyses/msmc/output/samtools/ind/'
infile_popcols <- 'msp3/analyses/gphocs/popInfo/ghocs_cols.txt'
infile_pops <- 'msp3/analyses/gphocs/popInfo/ghocs_pops.txt'
infile_popcols2 <- 'metadata/colors/popcols.txt'
figfile_eps <- paste0('msp3/figures_final/Fig6_demography2.eps')

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
bppLog <- read.table(infile_bppLog, header = TRUE, as.is = TRUE)
Log <- rbind.fill(Log, bppLog)
bppLog <- NULL
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
col.leh <- cols.df$color[cols.df$species.short == 'mleh']
col.mac <- cols.df$color[cols.df$species.short == 'mmac']
col.mit <- cols.df$color[cols.df$species.short == 'mmit']
col.sim <- cols.df$color[cols.df$species.short == 'msim']
col.sp3 <- cols.df$color[cols.df$species.short == 'msp3']
col.mur <- cols.df$color[cols.df$species.short == 'mmur']


################################################################################
#### SUMMARIZE #####
################################################################################
## Migration rates in snapp12 model:
Log$migtype.run[Log$runID == 'bpp'] <- 'none'

(m.sum <- filter(Log, var == 'm.prop', runID == 'multmig1') %>%
    group_by(migfrom, migto, var) %>%
    summarise(m.prop = round(mean(val), 4)))

## Migration rates to include in plot:
m_mit2leh <- m.sum %>% filter(migfrom == 'mit' & migto == 'leh') %>% pull(m.prop)
m_mit2leh_label <- paste0(m_mit2leh * 100, '%')
m_sp3mac <- m.sum %>% filter(migfrom == 'sp3' & migto == 'mac') %>% pull(m.prop)
m_sp3mac_label <- paste0(m_sp3mac * 100, '%')

## Migration rates in eastwest2 model:
# (m.sum2 <- filter(Log_eastwest2, var == 'm.prop', runID == 'multmig3') %>%
#     group_by(migfrom, migto, var) %>%
#     summarise(m.prop = round(mean(val), 4)))

## Divergence times:
(tau.sum <- filter(Log, var == 'tau') %>%
    group_by(runID, pop) %>%
    summarise(tau = round(mean(cval) / 1000),
              min = round(hpd.min(cval) / 1000),
              max = round(hpd.max(cval) / 1000)) %>%
  arrange(pop))

## Population sizes:
(th.sum <- filter(Log, var == 'theta') %>%
    group_by(runID, pop) %>%
    summarise(Ne = round(mean(cval) / 1000),
              min = round(hpd.min(cval) / 1000),
              max = round(hpd.max(cval) / 1000)) %>%
    arrange(pop))

(th.sum <- filter(Log, var == 'theta') %>%
    group_by(pop) %>%
    summarise(Ne = round(mean(cval) / 1000),
              min = round(hpd.min(cval) / 1000),
              max = round(hpd.max(cval) / 1000)) %>%
    arrange(pop))

(th.sum <- filter(Log_eastwest2, var == 'theta') %>%
    group_by(pop) %>%
    summarise(Ne = round(mean(cval) / 1000),
              min = round(hpd.min(cval) / 1000),
              max = round(hpd.max(cval) / 1000)) %>%
    arrange(pop))

#th.sum %>% filter(pop == 'anc.LISA3')


################################################################################
#### DEMO PLOTS #####
################################################################################
p_bpp <- dplotwrap.snapp12('bpp',
                           y.max = 1150,
                           rm.y.ann = FALSE,
                           legend.plot = FALSE,
                           plot.title = 'BPP') +
  scale_y_continuous(breaks = seq(0, 2000, by = 200), expand = c(0, 0)) +
  theme(axis.title.x = element_text(colour = 'white'),
        axis.title.y = element_text(margin = margin(0, 0.1, 0, 0, 'cm')),
        panel.border = element_rect(colour = "grey20", fill = NA, size = 1),
        plot.title = element_text(size = 22, face = 'plain'),
        plot.margin = margin(0.5, 0.4, 0.2, 0.4, 'cm'))

p_iso <- dplotwrap.snapp12('noMig',
                           y.max = 1150,
                           rm.y.ann = TRUE,
                           legend.plot = FALSE,
                           plot.title = 'GPhoCS: isolation') +
  scale_y_continuous(breaks = seq(0, 2000, by = 200), expand = c(0, 0)) +
  theme(panel.border = element_rect(colour = "grey20", fill = NA, size = 1),
        plot.title = element_text(size = 22, face = 'plain'),
        plot.margin = margin(0.5, 0.4, 0.2, 0.4, 'cm'))

p_mig <- dplotwrap.snapp12('multmig1',
                           y.max = 1150,
                           rm.y.ann = TRUE,
                           legend.plot = FALSE,
                           plot.title = 'GPhoCS: migration') +
  scale_y_continuous(breaks = seq(0, 2000, by = 200), expand = c(0, 0)) +
  theme(axis.title.x = element_text(colour = 'white'),
        panel.border = element_rect(colour = "grey20", fill = NA, size = 1),
        plot.title = element_text(size = 22, face = 'plain'),
        plot.margin = margin(0.5, 0.4, 0.2, 0.4, 'cm')) +
  geom_segment(aes(x = 58, xend = 30, y = 90, yend = 90),
               colour = 'red', size = 1.5,
               arrow = arrow(length = unit(0.3, "cm"),
                             angle = 45, type = 'closed')) +
  geom_label(aes(x = 45, y = 190, label = m_sp3mac_label),
             fontface = 'bold', label.size = 0, size = 6,
             colour = 'gray10', fill = 'gray80', alpha = 0.7) +
  geom_segment(aes(x = 210, xend = 160, y = 90, yend = 90),
               colour = 'red', size = 1.5,
               arrow = arrow(length = unit(0.3, "cm"),
                             angle = 45, type = 'closed')) +
  geom_label(aes(x = 180, y = 160, label = m_mit2leh_label),
             fontface = 'bold', label.size = 0, size = 6,
             colour = 'gray10', fill = 'gray80', alpha = 0.7)


################################################################################
#### TAU PLOT #####
################################################################################
pop.labs.tau <- c('mac-sp3', 'leh-mit', 'A', 'B', 'root')
Log_tau <- subset(Log, var == 'tau' & runID %in% c('bpp', 'noMig', 'multmig1'))

p_tau <- vplot(Log_tau,
               xvar = 'pop',
               fillvar = 'cn',
               colvar = 'runID',
               yvar = 'cval',
               col.labs = c('BPP', 'GPhoCS: iso', 'GPhoCS: mig'),
               pop.labs = pop.labs.tau,
               rotate.x.ann = TRUE,
               yticks.by = 250,
               y.max = 'max.hpd',
               linecols = NULL,
               legpos = 'top',
               legcolname = "",
               rm.leg.col = FALSE,
               xlab = "",
               ylab = cvar('tau')) +
  theme(axis.text.x = element_text(size = 18, angle = 40, hjust = 1,
                                   colour = 'black', face = 'plain'),
        axis.title.x = element_blank(),
        axis.title.y = element_text(margin = margin(0, 0.1, 0, 0, 'cm')),
        legend.text = element_text(size = 15),
        panel.border = element_rect(colour = "grey20", fill = NA, size = 1),
        plot.margin = margin(0.5, 0.6, 0, 0.2, 'cm'))


################################################################################
#### THETA PLOT #####
################################################################################
pop.labs.theta <- c('mac', 'sp3', 'mac-sp3', 'leh', 'mit','leh-mit',
                    'sim', 'A', 'B', 'mur', 'root')
Log_theta <- subset(Log,
                    var == 'theta',
                    runID %in% c('bpp', 'noMig', 'multmig1'))

p_th <- vplot(Log_theta,
              xvar = 'pop',
              fillvar = 'cn',
              colvar = 'runID',
              yvar = 'cval',
              col.labs = c('BPP', 'GPhoCS: iso', 'GPhoCS: mig'),
              pop.labs = pop.labs.theta,
              rotate.x.ann = TRUE,
              yticks.by = 50,
              y.max = 'max.hpd',
              linecols = NULL,
              legpos = 'top',
              legcolname = "",
              rm.leg.col = FALSE,
              xlab = "",
              ylab = cvar('theta')) +
  theme(axis.text.x = element_text(size = 18, angle = 40, hjust = 1,
                                   colour = 'black', face = 'plain'),
        axis.title.x = element_blank(),
        axis.title.y = element_text(margin = margin(0, 0, 0, 0, 'cm')),
        legend.text = element_text(size = 15),
        panel.border = element_rect(colour = "grey20", fill = NA, size = 1),
        plot.margin = margin(0.5, 0.6, 0, 0.2, 'cm'))


################################################################################
#### MSMC PLOT - SET-UP #####
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

## MSMC set-up:
msmc <- select_files(msmc_mode = 'ind',
                     to.select = 'mmac01',
                     method = 'samtools',
                     filedir = msmc.filedir,
                     additional.grep = 'scaffoldsGt1mb') %>%
  read_msmc(mutrate = mutrate.yr_mean,
            gen.time = gentime_mean) %>%
  mutate(ID = 'MSMC')

gphocs.mig <- prep.gphocsNe(subset(Log_eastwest2, runID == 'multmig3'),
                            setID = 'GPhoCS: mig')
gphocs.iso <- prep.gphocsNe(subset(Log_eastwest2, runID == 'noMig'),
                            setID = 'GPhoCS: iso')
ne.comp <- rbind.fill(msmc, gphocs.mig, gphocs.iso)


################################################################################
#### MSMC PLOT - CREATE PLOT #####
################################################################################
(p_msmc <- plot_msmc(ne.comp,
                     lwd = 2,
                     save.plot = FALSE) +
  coord_cartesian(xlim = c(10000, 1.5e6)) +
  labs(y = expression(N[e] ~ "(in 1000s)")) +
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
        plot.margin = margin(0.5, 0.6, 0.4, 0.2, 'cm')))


################################################################################
#### COMBINE PLOTS #####
################################################################################
p_top <- ggarrange(p_bpp, p_iso, p_mig, ncol = 3, widths = c(1.1, 1, 1))
p_bottom <- ggarrange(p_tau, p_th, p_msmc, ncol = 3, widths = c(1, 1, 1))

p <- ggarrange(p_top, p_bottom,
               ncol = 1, nrow = 2, heights = c(1, 1)) +
  draw_plot_label(label = c("A", "B", "C", 'D', 'E', 'F'),
                  size = 30,
                  x = c(0, 0.345, 0.67, 0, 0.345, 0.67),
                  y = c(1, 1, 1, 0.51, 0.51, 0.51)) +
  draw_plot_label(label = c('mac', 'sp3', 'leh', 'mit', 'sim', 'mur'),
                  colour = c(col.mac, col.sp3, col.leh, col.mit, col.sim, col.mur),
                  size = 20, fontface = 'plain',
                  y = c(rep(0.575, 6)),
                  x = c(0.045, 0.085, 0.13, 0.221, 0.26, 0.292)) +
  draw_plot_label(label = c('mac', 'sp3', 'leh', 'mit', 'sim', 'mur'),
                  colour = c(col.mac, col.sp3, col.leh, col.mit, col.sim, col.mur),
                  size = 20, fontface = 'plain',
                  y = c(rep(0.575, 6)),
                  x = c(0.045, 0.085, 0.13, 0.235, 0.272, 0.31) + 0.30) +
  draw_plot_label(label = c('mac', 'sp3', 'leh', 'mit', 'sim', 'mur'),
                  colour = c(col.mac, col.sp3, col.leh, col.mit, col.sim, col.mur),
                  size = 20, fontface = 'plain',
                  y = c(rep(0.575, 6)),
                  x = c(0.045, 0.085, 0.13, 0.2, 0.247, 0.292) + 0.63) +
  draw_plot_label(label = c('A', 'B'),
                  size = 19, fontface = 'plain',
                  x = c(0.238, 0.16),
                  y = c(0.76, 0.808)) +
  draw_plot_label(label = c('A', 'B'),
                  size = 19, fontface = 'plain',
                  x = c(0.55, 0.46),
                  y = c(0.742, 0.783)) +
  draw_plot_label(label = c('A', 'B'),
                  size = 19, fontface = 'plain',
                  x = c(0.84, 0.765),
                  y = c(0.735, 0.778))

ggsave(filename = figfile_eps, width = 16, height = 12,
       device = cairo_ps, fallback_resolution = 150)
system(paste('xdg-open', figfile_eps))

