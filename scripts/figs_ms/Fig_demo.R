#### SET-UP --------------------------------------------------------------------
library(here)
source(here('scripts/genomics/gphocs/gphocs_plot_fun.R')) # General gphocs plotting functions
source(here('scripts/gphocs/gphocs_plot_fun_msp3.R')) # Msp3-proj specific plotting functions

## Settings:
figdir <- here('figs/ms/')
figtype <- 'eps'

## Input files:
# BPP and G-PhoCS:
infile_gphocs <- here('analyses/gphocs/output/msp3_6sp/processed/msp3_6sp_mergedlogs.txt')
infile_bpp <- here('analyses/bpp/output/processed/bpp_log.txt')

# Metadata:
infile_popcols <- here('metadata/msp3_cols.txt')

## Output files:
figfile <- paste0(figdir, 'fig_demo.', figtype)

## Pops:
poplist <- list(mac = 'anc.A3', sp3 = 'anc.A3', anc.A3 = 'anc.LISA3',
                leh = 'anc.LI', mit = 'anc.LI', anc.LI = 'anc.LIS',
                sim = 'anc.LIS', anc.LIS = 'anc.LISA3',
                anc.LISA3 = 'anc.root', mur = 'anc.root',
                'anc.root' = 'anc.root')


#### SET-UP: PROCESS INPUT AND VARS --------------------------------------------
## Pops:
childpops <- names(poplist)
parentpops <- as.character(poplist)
allpops <- unique(c(childpops, parentpops))
currentpops <- setdiff(allpops, parentpops)

## Load pop colors:
popcols <- read.delim(infile_popcols, as.is = TRUE) %>%
  select(pop_gphocs, col) %>%
  rename(pop = pop_gphocs) %>%
  add_ancestralcols(poplist, .)

## Load log files:
log_gphocs <- as.data.frame(fread(infile_gphocs, stringsAsFactors = FALSE))
log_bpp <- as.data.frame(fread(infile_bpp, stringsAsFactors = FALSE))
Log <- bind_rows(log_gphocs, log_bpp)
log_gphocs <- NULL; log_bpp <- NULL

Log <- Log %>%
  filter(runID %in% c('multmig1', 'noMig', 'bpp')) %>%
  mutate(pop = factor(pop, levels = allpops),
         runID = factor(runID, levels = c('bpp', 'noMig', 'multmig1')))


#### DEMO PLOTS ----------------------------------------------------------------
(p_bpp <- dplotwrap_6sp(
  runID.focal = 'bpp', popcols = popcols, poplist = poplist,
  y.max = 1500, rm.y.ann = FALSE, plot.title = 'BPP',
  ) +
  scale_y_continuous(breaks = seq(0, 2000, by = 200), expand = c(0, 0)) +
  theme(axis.title.x = element_text(colour = 'white'),
        axis.title.y = element_text(margin = margin(0, 0.1, 0, 0, 'cm')),
        panel.border = element_rect(colour = "grey20", fill = NA, size = 1),
        plot.title = element_text(size = 22, face = 'plain'),
        plot.margin = margin(0.5, 0.4, 0.2, 0.4, 'cm')))

(p_iso <- dplotwrap_6sp(
  runID.focal = 'noMig', popcols = popcols, poplist = poplist,
  y.max = 1500, rm.y.ann = TRUE, plot.title = 'GPhoCS: isolation'
  ) +
  scale_y_continuous(breaks = seq(0, 2000, by = 200), expand = c(0, 0)) +
  theme(panel.border = element_rect(colour = "grey20", fill = NA, size = 1),
        plot.title = element_text(size = 22, face = 'plain'),
        plot.margin = margin(0.5, 0.4, 0.2, 0.4, 'cm')))

(p_mig <- dplotwrap_6sp(
  runID.focal = 'multmig1', popcols = popcols, poplist = poplist,
  y.max = 1500, rm.y.ann = TRUE, plot.title = 'GPhoCS: migration'
  ) +
  scale_y_continuous(breaks = seq(0, 2000, by = 200), expand = c(0, 0)) +
  theme(axis.title.x = element_text(colour = 'white'),
        panel.border = element_rect(colour = "grey20", fill = NA, size = 1),
        plot.title = element_text(size = 22, face = 'plain'),
        plot.margin = margin(0.5, 0.4, 0.2, 0.4, 'cm')))

(m <- mprep(Log) %>% filter(runID == 'multmig1', var == '2Nm'))
(tt <- ttprep_6sp(Log = filter(Log, runID == 'multmig1'),
                  poplist = poplist, popcols = popcols,
                  pop.spacing = 25))

p_mig <- addmig(p_mig, m, tt, poplist, from = 'mit', to = 'leh',
                labpos = 'above', labmar = 90, labsize = 6, lab_bg = 'grey80',
                arrowhead_size = 0.3)
p_mig <- addmig(p_mig, m, tt, poplist, from = 'sp3', to = 'mac',
                labpos = 'above', labmar = 75, labsize = 6, lab_bg = 'grey80',
                arrowhead_size = 0.3, nudge_y = -50)
p_mig


#### TAU PLOT ------------------------------------------------------------------
poplabs_tau <- c('mac-sp3', 'leh-mit', 'A', 'B', 'root')

p_tau <- vplot(
  data = filter(Log, var == 'tau'),
  xvar = 'pop', fillvar = 'cn', colvar = 'runID', yvar = 'cval',
  col.labs = c('BPP', 'GPhoCS: iso', 'GPhoCS: mig'),
  pop.labs = poplabs_tau,
  rotate.x.ann = TRUE, linecols = NULL,
  yticks.by = 400, y.max = 'max.hpd',
  legpos = 'top', legcolname = "", rm.leg.col = FALSE,
  xlab = "", ylab = cvar('tau')
  ) +
  theme(
    axis.text.x = element_text(size = 18, angle = 40, hjust = 1,
                               colour = 'black', face = 'plain'),
    axis.title.x = element_blank(),
    axis.title.y = element_text(margin = margin(0, 0.1, 0, 0, 'cm')),
    legend.text = element_text(size = 18),
    panel.border = element_rect(colour = "grey20", fill = NA, size = 1),
    plot.margin = margin(0.5, 0.6, 0, 0.2, 'cm')
    )
p_tau


#### THETA PLOT ----------------------------------------------------------------
poplabs_theta <- c('mac', 'sp3', 'mac-sp3', 'leh', 'mit','leh-mit',
                   'sim', 'A', 'B', 'mur', 'root')

p_th <- vplot(
  filter(Log, var == 'theta'),
  xvar = 'pop', fillvar = 'cn', colvar = 'runID', yvar = 'cval',
  col.labs = c('BPP', 'GPhoCS: iso', 'GPhoCS: mig'),
  pop.labs = poplabs_theta,
  rotate.x.ann = TRUE, yticks.by = 50, y.max = 'max.hpd',
  legpos = 'top', legcolname = "", rm.leg.col = FALSE,
  linecols = NULL, xlab = "", ylab = cvar('theta')
  ) +
  theme(
    axis.text.x = element_text(size = 18, angle = 40, hjust = 1,
                               colour = 'black', face = 'plain'),
    axis.title.x = element_blank(),
    axis.title.y = element_text(margin = margin(0, 0, 0, 0, 'cm')),
    legend.text = element_text(size = 18),
    panel.border = element_rect(colour = "grey20", fill = NA, size = 1),
    plot.margin = margin(0.5, 0.6, 0, 0.2, 'cm')
    )
p_th


#### COMBINE PLOTS -------------------------------------------------------------
popcols_cur <- popcols %>% filter(pop %in% currentpops)
popcols_lab <- popcols_cur$col[match(popcols_cur$pop, currentpops)]

p_top <- ggarrange(p_bpp, p_iso, p_mig, ncol = 3, widths = c(1.1, 1, 1))
p_bottom <- ggarrange(p_tau, p_th, ncol = 2, widths = c(1, 1))

p <- ggarrange(p_top, p_bottom,
               ncol = 1, nrow = 2, heights = c(1, 1)) +
  draw_plot_label(label = c("A", "B", "C", 'D', 'E'),
                  size = 30,
                  x = c(0.04, 0.345, 0.67, 0.04, 0.54),
                  y = c(1, 1, 1, 0.495, 0.495)) +
  draw_plot_label(label = c('mac', 'sp3', 'leh', 'mit', 'sim', 'mur'),
                  colour = popcols_lab, size = 20, fontface = 'plain',
                  y = c(rep(0.575, 6)),
                  x = c(0.045, 0.085, 0.13, 0.221, 0.26, 0.292)) +
  draw_plot_label(label = c('mac', 'sp3', 'leh', 'mit', 'sim', 'mur'),
                  colour = popcols_lab, size = 20, fontface = 'plain',
                  y = c(rep(0.575, 6)),
                  x = c(0.045, 0.085, 0.13, 0.235, 0.272, 0.31) + 0.30) +
  draw_plot_label(label = c('mac', 'sp3', 'leh', 'mit', 'sim', 'mur'),
                  colour = popcols_lab, size = 20, fontface = 'plain',
                  y = c(rep(0.575, 6)),
                  x = c(0.045, 0.085, 0.13, 0.2, 0.247, 0.292) + 0.63) +
  draw_plot_label(label = c('A', 'B'),
                  size = 19, fontface = 'plain',
                  x = c(0.245, 0.16),
                  y = c(0.76, 0.808)) +
  draw_plot_label(label = c('A', 'B'),
                  size = 19, fontface = 'plain',
                  x = c(0.56, 0.46),
                  y = c(0.742, 0.783)) +
  draw_plot_label(label = c('A', 'B'),
                  size = 19, fontface = 'plain',
                  x = c(0.84, 0.765),
                  y = c(0.735, 0.778))
ggsave(filename = figfile, plot = p, width = 16, height = 12,
       device = cairo_ps, fallback_resolution = 150)
system(paste('xdg-open', figfile))


#### SUMMARIZE RESULTS ---------------------------------------------------------
## Migration rates in snapp12 model:
# Log$migtype.run[Log$runID == 'bpp'] <- 'none'
# (m.sum <- filter(Log, var == 'm.prop', runID == 'multmig1') %>%
#     group_by(migfrom, migto, var) %>%
#     summarise(m.prop = round(mean(val), 4)))
#
# ## Divergence times:
# (tau.sum <- filter(Log, var == 'tau') %>%
#     group_by(runID, pop) %>%
#     summarise(tau = round(mean(cval) / 1000),
#               min = round(hpd.min(cval) / 1000),
#               max = round(hpd.max(cval) / 1000)) %>%
#     arrange(pop))
#
# ## Population sizes:
# (th.sum <- filter(Log, var == 'theta') %>%
#     group_by(runID, pop) %>%
#     summarise(Ne = round(mean(cval) / 1000),
#               min = round(hpd.min(cval) / 1000),
#               max = round(hpd.max(cval) / 1000)) %>%
#     arrange(pop))
