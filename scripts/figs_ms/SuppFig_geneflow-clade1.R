#### SET-UP --------------------------------------------------------------------
library(here)
source(here('scripts/genomics/admixtools/admixtools_plot_fun.R'))
source(here('scripts/genomics/gphocs/gphocs_plot_fun.R'))
source(here('scripts/gphocs/gphocs_plot_fun_msp3.R'))

## Output file:
figfile <- here('figs/ms/SuppFig_geneflow-clade1.eps')


#### D-STATS PLOT --------------------------------------------------------------
## Input files:
infile_gphocs <- here('analyses/gphocs/output/msp3_3sp/processed/msp3_3sp_mergedlogs.txt')

## Pops:
migpatterns <- c("mac_2_sp3E", "sp3E_2_mac",
                 "mac_2_sp3W", "sp3W_2_mac",
                 "mac_2_sp3", "sp3_2_mac")
miglabs <- c('mac > sp3S', 'sp3S > mac',
             'mac > sp3N', 'sp3N > mac',
             'mac > anc_sp3', 'anc_sp3 > mac')

## Load logs:
Log <- as.data.frame(fread(infile_gphocs, stringsAsFactors = FALSE))
mlog <- Log %>%
  filter(var %in% c('2Nm', 'm.prop'),
         !grepl('leh', migpattern),
         !migpattern %in% c('sp3E_2_sp3W', 'sp3W_2_sp3E'),
         migtype.run == c('mult')) %>%
  mutate(migpattern = factor(migpattern, levels = migpatterns))


## Plot:
p_m1 <- vplot(
  data = filter(mlog, var == '2Nm'),
  xvar = 'migpattern', fillvar = 'cn', colvar = 'cn', yvar = 'val',
  xlab = "", ylab = '2Nm',
  legpos = 'top', legcolname = "migration in model", rm.leg.col = FALSE,
  yticks.by = 0.1, rotate.x.ann = TRUE, linecols = NULL) +
  scale_x_discrete(labels = miglabs) +
  theme(plot.margin  = margin(0.2, 0.2, 0, 0.2, 'cm'))
p_m1

p_m2 <- vplot(
  data = filter(mlog, var == 'm.prop'),
  xvar = 'migpattern', fillvar = 'cn', colvar = 'cn', yvar = 'val',
  xlab = "", ylab = 'migrant percentage',
  legpos = 'top', legcolname = "migration in model", rm.leg.col = FALSE,
  yticks.by = 0.03, rotate.x.ann = TRUE, linecols = NULL) +
  scale_x_discrete(labels = miglabs) +
  theme(plot.margin  = margin(0.2, 0.2, 0, 0.5, 'cm'))
p_m2


#### D-STATS PLOT --------------------------------------------------------------
## Input files:
infile_atools <- here('analyses/admixtools/output/msp3proj.mac3.FS6.dstat_msp3.msp3pops.dmode.out')

## D-stats df:
d <- prep_d(infile_atools) %>%
  mutate(popcomb = gsub('\\(m', '(', popcomb)) %>%
  mutate(popcomb = gsub(',m', ',', popcomb)) %>%
  mutate(popcomb = gsub('Mt3', '*', popcomb)) %>%
  mutate(popcomb = gsub('east', '-S', popcomb)) %>%
  mutate(popcomb = gsub('west', '-N', popcomb)) %>%
  mutate(popcomb = gsub('mac$', 'mac ', popcomb))

## Create D-stats plot:
mylabs <- c(expression(paste('(sp3-S,', bold("sp3-N"), ')', bold(',mac*'))),
            '(sp3-S,sp3-N),mac ')

p_d <- plot_d(d, marg_sig = TRUE, ylab = 'D', zero_line = FALSE) +
    scale_x_discrete(labels = mylabs) +
    scale_y_continuous(
      limits = c(0, 0.11), breaks = c(0, 0.05, 0.1), expand = c(0, 0)
      ) +
    theme(
      panel.grid.minor = element_blank(),
      legend.text = element_text(size = 16),
      legend.margin = margin(1, 5, 2, 1),
      legend.box.margin = margin(0, 0, -5, 0),
      plot.margin = margin(0.2, 0.2, 0, 0.2, 'cm')
      )
p_d


#### COMBINE AND SAVE ----------------------------------------------------------
p <- plot_grid(p_m1, p_m2, p_d,
               labels = c('A', 'B', 'C'), label_size = 20,
               rel_heights = c(1, 0.5))
ggsave(figfile, width = 12, height = 10,
       device = cairo_ps, fallback_resolution = 150)
system(paste0('xdg-open ', figfile))
