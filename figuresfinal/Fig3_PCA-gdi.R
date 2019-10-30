################################################################################
##### SET-UP - FILES AND DIRS #####
################################################################################
setwd('/home/jelmer/Dropbox/sc_lemurs/')

## Scripts:
script_pca_fun <- 'scripts/PCA/PCA_R_fun.R'
script_gphocs_fun <- 'scripts/gphocs/gphocs_6_analyze_fun.R'

## Files - PCA:
fileID_pca <- 'msp3proj.all.mac3.FS6'

infile_inds <- 'radseq/metadata/lookup_IDshort.txt'
infile_IDs <- 'metadata/msp3_IDs.txt'
infile_cols <- 'metadata/colors/popcols.txt'
infile_pca.all <- paste0('analyses/PCA/dfs/', fileID_pca, '_noMur.txt')
infile_eigen.all <- paste0('analyses/PCA/dfs/', fileID_pca, '_noMur_eigenvalues.txt')
infile_pca.sp3 <- paste0('analyses/PCA/dfs/', fileID_pca, '_mmacmsp3.txt')
infile_eigen.sp3 <- paste0('analyses/PCA/dfs/', fileID_pca, '_mmacmsp3_eigenvalues.txt')

## Files - gdi:
infile_popcols <- 'proj/msp3/analyses/gphocs/popInfo/ghocs_cols.txt'
infile_gphocs_log <- 'proj/msp3/analyses/gphocs/output/msp3_snapp12/mergedLogs.txt'
infile_bpp_log <- 'proj/msp3/analyses/bpp/bppLog.txt'

## Output file:
#figfile_png <- paste0('figures_final/Fig3_PCA-gdi.png')
figfile_eps <- paste0('figures_final/Fig3_PCA-gdi.eps')

## Colours:
cols.df <- read.delim(infile_cols, header = TRUE, as.is = TRUE)
col.leh <- cols.df$color[cols.df$species.short == 'mleh']
col.mac <- cols.df$color[cols.df$species.short == 'mmac']
col.mit <- cols.df$color[cols.df$species.short == 'mmit']
col.sim <- cols.df$color[cols.df$species.short == 'msim']
col.sp3 <- cols.df$color[cols.df$species.short == 'msp3']

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


################################################################################
##### SET-UP - PCA #####
################################################################################
source(script_pca_fun)

## Read metadata:
inds.IDs <- substr(readLines(infile_IDs), 1, 7)
inds.df <- read.delim(infile_inds) %>%
  filter(ID.short %in% inds.IDs)


################################################################################
##### A: PCA FOR ALL INDS, PC1-2 #####
################################################################################
pca.all <- read.table(infile_pca.all, header = TRUE)
pca.all$species.shorter <- substr(pca.all$species.short, 2, 4)
eigen.all <- as.numeric(readLines(infile_eigen.all))

labs_pca_all <- c(expression(italic("lehilahytsara")),
                  expression(italic("macarthurii")),
                  expression(italic("mittermeieri")),
                  expression(italic("simmonsi")),
                  expression(italic("sp. #3")))
cols_pca_all <- c(col.leh, col.mac, col.mit, col.sim, col.sp3)

(A <- pcplot(pca.all,
             eigenvalues = eigen.all,
             col.by = 'species.shorter',
             col.by.name = 'species:',
             col.by.labs = labs_pca_all,
             cols = cols_pca_all,
             dotsize = 6,
             strokesize = 0,
             legpos = 'left') +
    theme(legend.background = element_rect(fill = "grey90", colour = "grey30"),
          #legend.box.margin = margin(0, 1.3, 0, 0, "cm"),
          plot.margin = margin(0.7, 1, 0.3, 0.3, "cm")))


################################################################################
##### B: PCA FOR ALL INDS, PC3-4 #####
################################################################################
(B <- pcplot(pca.all,
             eigenvalues = eigen.all,
             pcX = 3,
             pcY = 4,
             col.by = 'species.shorter',
             col.by.name = 'species:',
             col.by.labs = labs_pca_all,
             cols = cols_pca_all,
             dotsize = 6,
             strokesize = 0,
             legpos = 'notany') +
   theme(plot.margin = margin(0.7, 0.3, 0.3, 0.3, "cm")))


################################################################################
##### C: PCA FOR MAC AND SP3 #####
################################################################################
eigen.sp3 <- as.numeric(readLines(infile_eigen.sp3))
pca.sp3 <- read.table(infile_pca.sp3, header = TRUE)
pca.sp3$species.shorter <- substr(pca.sp3$species.short, 2, 4)
pca.sp3$site <- gsub('Antsiradrano', 'Ambavala', pca.sp3$site)
pca.sp3$site <- gsub('Mananara_Nord', 'Mananara', pca.sp3$site)

labs_pca_sp3 <- c(expression(italic("macarthurii")),
                  expression(italic("sp. #3")))
cols_pca_sp3 <- c(col.mac, col.sp3)

(C <- pcplot(pca.sp3,
             eigenvalues = eigen.sp3,
             col.by = 'species.shorter',
             col.by.name = 'species:',
             col.by.labs = labs_pca_sp3,
             cols = cols_pca_sp3,
             shape.by = 'site',
             shape.by.name = 'site:',
             dotsize = 6,
             strokesize = 0,
             legpos = 'left') +
    theme(legend.background = element_rect(fill = "grey90", colour = "grey30"),
          legend.box.margin = margin(0, 0.2, 0, 0, "cm"),
          plot.margin = margin(0.3, 1, 0.5, 0.3, "cm")))


################################################################################
##### GDI - SET-UP #####
################################################################################
source(script_gphocs_fun)
popcols.df <- read.delim(infile_popcols, header = TRUE, as.is = TRUE)

## Set ID:
setID <- 'msp3_bppComp'
setID.pops <- 'msp3_snapp12'

## Parameter settings:
gentime <- 3.5
mutrate.gen <- 1.64e-8
mutrate.year <- mutrate.gen / gentime
m.scale <- 1000
t.scale <- 0.0001

## Load log files:
Log <- as.data.frame(fread(infile_gphocs_log, stringsAsFactors = TRUE))
bppLog <- read.table(infile_bpp_log, header = TRUE, as.is = TRUE)
Log <- rbind.fill(Log, bppLog)
poplevels <- c('mac', 'sp3', 'anc.A3', 'leh', 'mit', 'anc.LI',
               'sim', 'anc.LIS', 'anc.LISA3', 'mur', 'anc.root')
Log$pop <- factor(Log$pop, levels = poplevels)
Log <- filter(Log, runID %in% c('multmig1', 'noMig', 'bpp'))
Log$runID <- factor(Log$runID, levels = c('bpp', 'noMig', 'multmig1'))
Log_gdi <- subset(Log, var == 'gdi')


################################################################################
##### GDI PLOT #####
################################################################################
(D <- vplot(Log_gdi,
            xvar = 'pop',
            fillvar = 'cn',
            colvar = 'pop',
            yvar = 'val',
            yticks.by = 0.1,
            linecols = 'pop.cols',
            rm.leg.col = TRUE,
            shade = FALSE,
            xlab = "",
            ylab = 'gdi') +
    scale_x_discrete(labels = c('mac-sp3', 'sp3-mac', 'leh-mit', 'mit-leh')) +
    geom_hline(yintercept = 0.7, linetype = 'dashed',
               size = 1.3, colour = 'grey30') +
    geom_hline(yintercept = 0.2, linetype = 'dashed',
               size = 1.3, colour = 'grey30') +
    geom_vline(xintercept = 2.5, linetype = 'solid',
               size = 1, color = 'grey30') +
    theme(axis.text.x = element_text(size = 18, face = 'plain',
                                     angle = 0, hjust = 0.5),
          axis.title.y = element_text(size = 22,
                                      margin = margin(0, 0.1, 0, 0, 'cm')),
          plot.margin = margin(0.3, 0.3, 0, 0, "cm")))


################################################################################
##### COMBINE PLOTS #####
################################################################################
## Arrange  panels:
p <- ggarrange(A, B, C, D, ncol = 2, nrow = 2, widths = c(1.2, 1)) +
  draw_plot_label(label = c('A', 'B', 'C', 'D'),
                  size = 28, x = c(0, 0.54, 0, 0.54),
                  y = c(1, 1, 0.52, 0.52))

## Save as eps:
ggsave(p, filename = figfile_eps, width = 12, height = 10)
system(paste0('xdg-open ', figfile_eps))

## Save as png:
#ggexport(p, filename = figfile_png, width = 800, height = 600)
#system(paste0('xdg-open ', figfile_png))
