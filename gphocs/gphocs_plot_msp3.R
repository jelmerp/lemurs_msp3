################################################################################
#### SET-UP #####
################################################################################
setwd('/home/jelmer/Dropbox/sc_lemurs/msp3/')

## Set ID:
#setID <- 'msp3_snapp12'
setID <- 'msp3_eastwest2'

## Scripts:
source('/home/jelmer/Dropbox/sc_lemurs/scripts/gphocs/gphocs_6_analyze_fun.R')
source('scripts/gphocs/gphocs_fun_msp3.R')

## Files and dirs:
infile_logs <- paste0('analyses/gphocs/output/', setID, '/mergedLogs.txt')
infile_popcols <- 'analyses/gphocs/popInfo/ghocs_cols.txt'
infile_pops <- 'analyses/gphocs/popInfo/ghocs_pops.txt'
plotdir <- 'analyses/gphocs/plots/'

## Parameter settings:
gentime <- 3.75 # 3.0–4.5 y. from Yoder et al. 2016 PNAS
mutrate.gen <- 1.64e-8 # 0.5-1.2 × 10-8 from Yoder et al. 2016 PNAS
mutrate.year <- mutrate.gen / gentime
m.scale <- 1000
t.scale <- 0.0001

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
Log <- as.data.frame(fread(infile_logs, stringsAsFactors = TRUE))
if(setID == 'msp3_eastwest2') {
  poplevels <- c('mac', 'anc.A3', 'sp3-W', 'sp3-E',
                 'anc.sp3', 'leh', 'anc.root')
  Log$pop <- factor(Log$pop, levels = poplevels)
  Log <- Log %>% dplyr::filter(runID != 'multmig4', runID != 'multmig5')
}

if(setID == 'msp3_snapp12') {
  poplevels <- c('mac', 'sp3', 'anc.A3', 'leh', 'mit', 'anc.LI',
                 'sim', 'anc.LIS', 'anc.LISA3', 'mur', 'anc.root')
  Log$pop <- factor(Log$pop, levels = poplevels)
}

## Pops and pop colors:
popcols.df <- read.delim(infile_popcols, header = TRUE, as.is = TRUE)
pops <- read.delim(infile_pops, header = TRUE, as.is = TRUE)

kidpops <- pops$kidpop[pops[, grep(setID, colnames(pops))] == 1]
parentpops <- pops$parentpop[pops[, grep(setID, colnames(pops))] == 1]
allpops <- levels(Log$pop)
currentpops <- allpops[grep('anc', allpops, invert = TRUE)]
ancpops <- allpops[grep('anc', allpops)]


################################################################################
#### NR OF CHAIN SAMPLES #####
################################################################################
Log %>%
  group_by(runID, rep) %>%
  slice(which.max(Sample)) %>%
  mutate(Sample = Sample / 1000000) %>%
  select(runID, rep, Sample) %>%
  print(n = 50)


################################################################################
##### SUMMARIZE #####
################################################################################
(theta.sum <- filter(Log, var == 'theta') %>%
   group_by(migtype.run, pop, var) %>%
   summarise(value = round(mean(cval) / 1000),
             min = round(hpd.min(cval) / 1000),
             max = round(hpd.max(cval) / 1000)) %>%
   arrange(pop)) %>%
  print(n = 100)

(theta.sum <- filter(Log, var == 'theta') %>%
    group_by(pop, var) %>%
    summarise(value = round(mean(cval) / 1000),
              min = round(hpd.min(cval) / 1000),
              max = round(hpd.max(cval) / 1000)) %>%
    arrange(pop)) %>%
  print(n = 100)

(tau.sum <- filter(Log, var == 'tau') %>%
    group_by(migtype.run, pop, var) %>%
    summarise(min = round(hpd.min(cval) / 1000),
              mean = round(mean(cval) / 1000),
              max = round(hpd.max(cval) / 1000)) %>%
    arrange(pop))

(m.sum <- filter(Log, var == '2Nm', runID == 'multmig3') %>%
    group_by(migfrom, migto, var) %>%
    summarise(Nm = round(mean(val), 3)))

(m.sum <- filter(Log, var == 'm.prop', runID == 'multmig3') %>%
    group_by(migfrom, migto, var) %>%
    summarise(m.prop = round(mean(val) * 100, 3)))

#write.table(theta.sum, 'analyses/gphocs/output/summaries/theta.noMig.txt',
#            sep = '\t', quote = FALSE, row.names = FALSE)
#write.table(tau.sum, 'analyses/gphocs/output/summaries/tau.noMig.txt',
#            sep = '\t', quote = FALSE, row.names = FALSE)



################################################################################
#### TAU & THETA #####
################################################################################
## Plot each rep separately, one plot per variable and pop combination:
# for(var.focal in c('theta', 'tau')) for(pop.focal in unique(subset(Log, var == var.focal)$pop))
#   vplot(subset(Log, var == var.focal & pop == pop.focal & migtype.run != 'single'),
#         xvar = 'migtype.run', fillvar = 'migtype.run', colvar = 'rep', yvar = 'cval', y.max = 'max.hpd',
#         xlab = paste('migration bands'), ylab = cvar(var.focal),
#         plot.title = paste(var.focal, "across runs for", pop.focal),
#         filename = paste0(setID, '.', var.focal, '.', pop.focal))

## For a specific run:
if(setID == 'msp3_eastwest2') runID.focal <- 'multmig3'
if(setID == 'msp3_snapp12') runID.focal <- 'multmig1'

var.focal  <- 'theta'
th <- vplot(subset(Log, var == var.focal & runID == runID.focal),
      xvar = 'pop', fillvar = 'cn', colvar = 'pop', yvar = 'cval', rotate.x.ann = TRUE,
      y.max = 'max.hpd', rm.violins = TRUE, hpdline.width = 1, linecols = 'pop.cols',
      legpos = 'top', rm.leg.col = TRUE, yticks.by = 25,
      xlab = "", ylab = cvar(var.focal),
      plotdir = paste0(plotdir, '/tt/'), filename = paste0(setID, '.', runID.focal, '.', var.focal))

var.focal  <- 'tau'
vplot(subset(Log, var == var.focal & runID == runID.focal),
      xvar = 'pop', fillvar = 'cn', colvar = 'pop', yvar = 'cval', rotate.x.ann = TRUE,
      y.max = 'max.hpd', rm.violins = TRUE, hpdline.width = 1, linecols = 'pop.cols',
      legpos = 'top', rm.leg.col = TRUE, yticks.by = 25,
      xlab = "", ylab = cvar(var.focal),
      plotdir = paste0(plotdir, '/tt/'),
      filename = paste0(setID, '.', runID.focal, '.', var.focal))

## Compare mult-migration and no-migration runs:
var.focal  <- 'theta'
vplot(subset(Log, var == var.focal & migtype.run != 'single'),
      xvar = 'pop', fillvar = 'cn', colvar = 'migtype.run', yvar = 'cval',
      y.max = 'max.hpd', rm.violins = TRUE, hpdline.width = 1, linecols = NULL,
      yticks.by = 25, rotate.x.ann = TRUE,
      legpos = 'top', legcolname = "Migration bands:", rm.leg.col = FALSE,
      xlab = "", ylab = cvar(var.focal),
      plotdir = paste0(plotdir, '/tt/'),
      filename = paste0(setID, '.migVSnomig.', var.focal))

var.focal  <- 'tau'
vplot(subset(Log, var == var.focal & migtype.run != 'single'),
      xvar = 'pop', fillvar = 'cn', colvar = 'migtype.run', yvar = 'cval', yticks.by = 25,
      y.max = 'max.hpd', rm.violins = TRUE, hpdline.width = 1, linecols = NULL,
      legpos = 'top', legcolname = "Migration bands:", rm.leg.col = FALSE,
      xlab = "", ylab = cvar(var.focal),
      plotdir = paste0(plotdir, '/tt/'),
      filename = paste0(setID, '.migVSnomig.', var.focal))

## Compare two specific runs:
if(setID == 'msp3_eastwest2') {
  var.focal  <- 'theta'
  vplot(subset(Log, var == var.focal & runID %in% c('multmig3', 'multmig4')),
        xvar = 'pop', fillvar = 'cn', colvar = 'runID', yvar = 'cval',
        y.max = 'max.hpd', rm.violins = TRUE, hpdline.width = 1, linecols = NULL,
        legpos = 'top', legcolname = "Migration bands:",  rm.leg.col = FALSE,
        xlab = "focal population", ylab = cvar(var.focal),
        plotdir = paste0(plotdir, '/tt/'),
        filename = paste0(setID, '.compRuns.', var.focal))

  var.focal  <- 'tau'
  vplot(subset(Log, var == var.focal & runID %in% c('multmig3', 'multmig4')),
        xvar = 'pop', fillvar = 'cn', colvar = 'runID', yvar = 'cval',
        y.max = 'max.hpd', rm.violins = TRUE, hpdline.width = 1, linecols = NULL,
        legpos = 'top', legcolname = "Migration bands:",rm.leg.col = FALSE,
        xlab = "focal population", ylab = cvar(var.focal),
        plotdir = paste0(plotdir, '/tt/'),
        filename = paste0(setID, '.compRuns.', var.focal))
}


################################################################################
##### MIG FOR MULTI-MIG RUNS #####
################################################################################
if(setID == 'msp3_eastwest2') runID.focal <- 'multmig3'
if(setID == 'msp3_snapp12') runID.focal <- 'multmig1'

M <- vplot(subset(Log, var == 'm' & runID == runID.focal),
           xvar = 'migpattern', fillvar = 'cn', colvar = 'cn', yvar = 'cval', y.max = 'max.hpd',
           ylab = 'M (total migration rate)', rotate.x.ann = TRUE, yticks.by = 0.2,
           rm.violins = TRUE, hpdline.width = 1, linecols = 'red', saveplot = FALSE)
Nm <- vplot(subset(Log, var == '2Nm' & runID == runID.focal),
            xvar = 'migpattern', fillvar = 'cn', colvar = 'cn', yvar = 'val', y.max = 'max.hpd',
            ylab = '2Nm (population migration rate)', rotate.x.ann = TRUE, yticks.by = 0.2,
            rm.violins = TRUE, hpdline.width = 1, linecols = 'red', saveplot = FALSE)
mprop <- vplot(subset(Log, var == 'm.prop' & runID == runID.focal),
               xvar = 'migpattern', fillvar = 'cn', colvar = 'cn', yvar = 'val', y.max = 'max.hpd',
               ylab = 'migrant percentage', rotate.x.ann = TRUE, yticks.by = 0.01,
               rm.violins = TRUE, hpdline.width = 1, linecols = 'red', saveplot = FALSE)

plots <- ggarrange(M, Nm, mprop, ncol = 3, nrow = 1)
figfile <- paste0(plotdir, '/m/', setID, '.', runID.focal, '_allMig.png')
ggexport(plots, filename = figfile, width = 1300, height = 600)
figfile.pdf <- paste0(plotdir, '/m/', setID, '.', runID.focal, '_allMig.pdf')
ggexport(plots, filename = figfile.pdf, width = 2000, height = 600)
system(paste('xdg-open', figfile))


################################################################################
##### MIG FOR SINGLE-TO-MIG RUNS #####
################################################################################
M <- vplot(subset(Log, var == 'm' & migtype.run == 'single'),
           xvar = 'migpattern', fillvar = 'cn', colvar = 'cn', yvar = 'cval', y.max = 'max.hpd',
           ylab = 'M (total migration rate)', rotate.x.ann = TRUE, yticks.by = 0.3,
           rm.violins = TRUE, hpdline.width = 1, linecols = 'red', saveplot = FALSE)

Nm <- vplot(subset(Log, var == '2Nm' & migtype.run == 'single'),
            xvar = 'migpattern', fillvar = 'cn', colvar = 'cn', yvar = 'val', y.max = 'max.hpd',
            ylab = '2Nm (population migration rate)', rotate.x.ann = TRUE, yticks.by = 0.2,
            rm.violins = TRUE, hpdline.width = 1, linecols = 'red', saveplot = FALSE)

mprop <- vplot(subset(Log, var == 'm.prop' & migtype.run == 'single'),
               xvar = 'migpattern', fillvar = 'cn', colvar = 'cn', yvar = 'val', y.max = 'max.hpd',
               ylab = 'migrant percentage', rotate.x.ann = TRUE, yticks.by = 0.1,
               rm.violins = TRUE, hpdline.width = 1, linecols = 'red', saveplot = FALSE)

plots <- ggarrange(M, Nm, mprop, ncol = 3, nrow = 1)
figfile <- paste0(plotdir, '/m/', setID, '.', runID.focal, '_migtoSingle.png')
ggexport(plots, filename = figfile, width = 1300, height = 600)
system(paste('xdg-open', figfile))

## Check effect on tau:
# vplot(subset(Log, pop == 'anc.root' & var == 'tau' & migtype.run == 'single'),
#       xvar = 'runID', fillvar = 'cn', colvar = 'cn', yvar = 'cval', y.max = 'max.hpd',
#       ylab = 'divergence time', rotate.x.ann = TRUE, yticks.by = 25,
#       rm.violins = TRUE, hpdline.width = 1, linecols = 'red',
#       plot.width = 5.5, plot.height = 4.5,
#       plot.title = NULL, filename = paste0(setID, '.tau_migtoSingle'))


################################################################################
#### DEMOGRAPHY PLOT #####
################################################################################
## eastwest:
if(setID == 'msp3_eastwest2') {
  dplotwrap.eastwest('noMig')
  dplotwrap.eastwest('multmig3')
}

## snapp12:
if(setID == 'msp3_snapp12') {
  dplotwrap.snapp12('noMig')
  dplotwrap.snapp12('multmig1')
}


################################################################################
#### SINGLE-RUN SUMMARIES ####
################################################################################
# (tt.all <- tt.prep(subset(Log, runID == 'multmig3')))
# (m.all <- m.prep(subset(Log, migRun == 'Mam2anc')))
#
# (tt <- subset(Log, var %in% c('theta', 'tau') & migRun == 'Mam2anc') %>%
#   group_by(pop, var) %>%
#     dplyr::summarise(cval.mean = round(mean(cval)), val.mean = round(mean(val), 3),
#                      hpd.min.cval = round(hpd.min(cval)), hpd.max.cval = round(hpd.max(cval)),
#                      hpd.min.val = round(hpd.min(cval)), hpd.max.val = round(hpd.max(cval))))
#
# (m <- subset(Log, var == 'm' & migRun == 'Mam2anc') %>%
#   group_by(migfrom, migto, var) %>%
#     dplyr::summarise(cval.mean = round(mean(cval), 3), val.mean = round(mean(val), 3),
#                      cval.hpd.min = round(hpd.min(cval), 3), cval.hpd.max = round(hpd.max(cval), 3),
#                      val.hpd.min = round(hpd.min(cval), 3), val.hpd.max = round(hpd.max(cval), 3)))
#
# (mt <- subset(Log, var == 'm' & migRun == 'Mam2anc') %>% group_by(migfrom, migto, var) %>% dplyr::summarise(m.mean = mean(val)))
# (tm <- subset(Log, var == 'theta' & migRun == 'Mam2anc') %>% group_by(pop, var) %>% dplyr::summarise(th.mean = mean(val)))
# (nrmig <- merge(mt, tm, by.x = 'migto', by.y = 'pop'))
# (nrmig$nrmig <- (nrmig$m.mean * m.scale) * (nrmig$th.mean * t.scale) / 4)
