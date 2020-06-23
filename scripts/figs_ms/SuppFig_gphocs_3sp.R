#### SET-UP --------------------------------------------------------------------
library(here)
source(here('scripts/genomics/gphocs/gphocs_plot_fun.R')) # General gphocs plotting functions
source(here('scripts/gphocs/gphocs_plot_fun_msp3.R')) # Msp3-proj specific plotting functions

## Settings:
figdir <- here('figs/ms/')
figtype <- 'eps'

## Output files:
figfile <- paste0(figdir, 'SuppFig_demo.', figtype)

## Input files:
infile_logs <- here('analyses/gphocs/output/msp3_3sp/processed/msp3_3sp_mergedlogs.txt')

## Pops:
poplist <- list(mac = 'anc.A3', sp3W = 'sp3', sp3E = 'sp3', leh = 'anc.root')
childpops <- names(poplist)
parentpops <- as.character(poplist)
allpops <- unique(c(childpops, parentpops))
currentpops <- setdiff(allpops, parentpops)
poporder <- c('mac', 'sp3W', 'sp3E', 'sp3', 'anc.A3', 'leh', 'anc.root')

## Load log file:
Log <- as.data.frame(fread(infile_logs, stringsAsFactors = FALSE)) %>%
  mutate(pop = factor(pop, levels = poporder))


#### THETA PLOT ---------------------------------------------------------------
## Prep:
poplabs_theta <- c('mac', 'sp3N',  'sp3S', 'sp3A', 'anc_ms', 'leh', 'root')

## Plot:
th <- vplot(
  data = filter(Log, var == 'theta', migtype.run %in% c('none', 'mult')),
  xvar = 'pop', fillvar = 'cn', colvar = 'migtype.run', yvar = 'cval',
  xlab = "", ylab = cvar('theta'), pop.labs = poplabs_theta,
  legpos = 'top', legcolname = "", rm.leg.col = FALSE,
  col.labs = c('isolation model', 'migration model'),
  rotate.x.ann = TRUE, yticks.by = 50, linecols = NULL
  ) +
  theme(plot.margin  = margin(0.2, 0.2, 0, 0.2, 'cm'))
th


#### M PLOT --------------------------------------------------------------------
## Prep:
mlog <- Log %>%
  filter(var %in% c('2Nm', 'm.prop'),
         grepl('leh', migpattern),
         migtype.run %in% c('single', 'mult'))
mlog$migpattern <- recode(
  factor(mlog$migpattern),
  'mac_2_leh' = 'a', 'leh_2_mac' = 'b',
  'sp3E_2_leh' = 'c', 'leh_2_sp3E' = 'd',
  'sp3W_2_leh' = 'e', 'leh_2_sp3W' = 'f',
  'sp3_2_leh' = 'i', 'leh_2_sp3' = 'j',
  'anc.A3_2_leh' = 'g', 'leh_2_anc.A3' = 'h'
  ) %>%
  factor(., levels = c('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j')) %>%
  droplevels()

poplabs <- c('mac > leh', 'leh > mac', 'sp3S > leh', 'leh > sp3S',
             'sp3N > leh', 'leh > sp3N', 'sp3A > leh', 'leh > sp3A',
             'anc_ms > leh', 'leh > anc_ms')

## Plot:
m1 <- vplot(
  data = filter(mlog, var == '2Nm'),
  xvar = 'migpattern', fillvar = 'cn', colvar = 'migtype.run', yvar = 'val',
  xlab = "", ylab = '2Nm', col.labs = c('multiple', 'single'),
  legpos = 'top', legcolname = "migration in model", rm.leg.col = FALSE,
  yticks.by = 0.1, rotate.x.ann = TRUE, linecols = NULL) +
  scale_x_discrete(labels = poplabs) +
  theme(plot.margin  = margin(0.2, 0.2, 0, 0.5, 'cm'))
m1

m2 <- vplot(
  data = filter(mlog, var == 'm.prop'),
  xvar = 'migpattern', fillvar = 'cn', colvar = 'migtype.run', yvar = 'val',
  xlab = "", ylab = 'migrant percentage', col.labs = c('multiple', 'single'),
  legpos = 'top', legcolname = "migration in model", rm.leg.col = FALSE,
  yticks.by = 0.01, rotate.x.ann = TRUE, linecols = NULL) +
  scale_x_discrete(labels = poplabs) +
  theme(plot.margin  = margin(0.2, 0.2, 0, 0.5, 'cm'))
m2


#### COMBINE PLOTS -------------------------------------------------------------
p <- th + m1 + m2 +
  plot_annotation(tag_levels = 'A') &
  theme(plot.tag = element_text(size = 24, face = 'bold'))
ggsave(filename = figfile, plot = p, width = 18, height = 8,
       device = cairo_ps, fallback_resolution = 150)
system(paste('xdg-open', figfile))

#p <- ggarrange(th, m, ncol = 2, nrow = 1, widths = c(1, 1)) +
#  draw_plot_label(label = c("A", "B", "C"), size = 24, x = c(0, 0.33, 0.67), y = c(1, 1))
# ggexport(p, filename = figfile, width = 900, height = 500)