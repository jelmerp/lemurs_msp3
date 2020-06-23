#### SET-UP ---------------------------------------------------------------------
library(here)

## Scripts:
source(here('scripts/genomics/gphocs/gphocs_plot_fun.R'))
source(here('scripts/gphocs/gphocs_plot_fun_msp3.R'))
source(here('scripts/genomics/msmc/msmc_process-output_fun.R'))

## Input files:
infile_gphocs_6sp <- here('analyses/gphocs/output/msp3_6sp/processed/msp3_6sp_mergedlogs.txt')
infile_gphocs_3sp <- here('analyses/gphocs/output/msp3_3sp/processed/msp3_3sp_mergedlogs.txt') # Ne plot
indir_msmc <- here('analyses/msmc/output/')
infile_popcols <- here('metadata/msp3_cols.txt')

## Output files:
figfile <- here('figs/ms/fig_Ne.eps')

## Mean mutrate and gentime for MSMC:
gentime <- 3.5
mutrate_gen <- mean(c(0.94, 0.81, 1.1, 1.2, 1.3, 1.6, 1.7)) * 1e-8
mutrate_yr <- mutrate_gen / gentime

## Load log files:
Log_6sp <- as.data.frame(fread(infile_gphocs_6sp, stringsAsFactors = TRUE)) %>%
  filter(runID %in% c('multmig1', 'noMig')) %>%
  mutate(runID = factor(runID, levels = c('noMig', 'multmig1')))
Log_3sp <- as.data.frame(fread(infile_gphocs_3sp, stringsAsFactors = TRUE))

## Pops:
poplist_6sp <- list(
  mac = 'anc.A3', sp3 = 'anc.A3', anc.A3 = 'anc.LISA3',
  leh = 'anc.LI', mit = 'anc.LI', anc.LI = 'anc.LIS',
  sim = 'anc.LIS', anc.LIS = 'anc.LISA3',
  anc.LISA3 = 'anc.root', mur = 'anc.root'
  )
fpops_6sp <- c('mit', 'anc.LI', 'anc.LIS',  'anc.LISA3', 'anc.root')

poplist_3sp <- list(
  sp3W = 'sp3', sp3E = 'sp3', mac = 'anc.A3', leh = 'anc.root'
)

## Colors:
popcols <- read.delim(infile_popcols, header = TRUE, as.is = TRUE)


#### MSMC COMP PLOT - MMIT -----------------------------------------------------
## Get MSMC result:
msmc <- select_files(
  msmc_mode = 'ind', to.select = 'mmit01', method = 'samtools',
  filedir = indir_msmc, additional.grep = 'scaffoldsGt1mb'
  ) %>%
  read_msmc(mu = mutrate_yr, gt = gentime) %>%
  mutate(ID = 'MSMC')

## Get G-PhoCS-mig results:
setID = 'RAD: mig'

gNe_iso <- ttprep_6sp(Log = filter(Log_6sp, runID == 'multmig1'),
                      poplist = poplist_6sp) %>%
    select(pop, tau, theta) %>%
    rename(t.min = tau, Ne = theta) %>%
    filter(pop %in% fpops_6sp) %>%
    mutate(t.max = NA,
           Ne = Ne * 1000,
           t.min = t.min * 1000,
           ID = setID)

gNe_iso$t.min[which(is.na(gNe_iso$t.min))] <- 0
gNe_iso$t.max[gNe_iso$pop == 'anc.root'] <- 10e7
gNe_iso$t.max[gNe_iso$pop == 'mit'] <- gNe_iso$t.min[gNe_iso$pop == 'anc.LI']
gNe_iso$t.max[gNe_iso$pop == 'anc.LI'] <- gNe_iso$t.min[gNe_iso$pop == 'anc.LIS']
gNe_iso$t.max[gNe_iso$pop == 'anc.LIS'] <- gNe_iso$t.min[gNe_iso$pop == 'anc.LISA3']
gNe_iso$t.max[gNe_iso$pop == 'anc.LISA3'] <- gNe_iso$t.min[gNe_iso$pop == 'anc.root']

gNe_iso <- gather(gNe_iso, 'aap', 'time', c('t.min', 't.max')) %>%
  select(-aap) %>%
  ungroup() %>%
  mutate(pop = factor(pop, levels = fpops_6sp)) %>%
  arrange(time, pop) %>%
  select(time, Ne, pop, ID)

## G-PhoCS results - iso:
setID = 'RAD: iso'

gNe_mig <- ttprep_6sp(Log = filter(Log_6sp, runID == 'noMig'),
                    poplist = poplist_6sp) %>%
  select(pop, tau, theta) %>%
  rename(t.min = tau, Ne = theta) %>%
  filter(pop %in% fpops_6sp) %>%
  mutate(t.max = NA,
         Ne = Ne * 1000,
         t.min = t.min * 1000,
         ID = setID)

gNe_mig$t.min[which(is.na(gNe_mig$t.min))] <- 0
gNe_mig$t.max[gNe_mig$pop == 'anc.root'] <- 10e7
gNe_mig$t.max[gNe_mig$pop == 'mit'] <- gNe_mig$t.min[gNe_mig$pop == 'anc.LI']
gNe_mig$t.max[gNe_mig$pop == 'anc.LI'] <- gNe_mig$t.min[gNe_mig$pop == 'anc.LIS']
gNe_mig$t.max[gNe_mig$pop == 'anc.LIS'] <- gNe_mig$t.min[gNe_mig$pop == 'anc.LISA3']
gNe_mig$t.max[gNe_mig$pop == 'anc.LISA3'] <- gNe_mig$t.min[gNe_mig$pop == 'anc.root']

gNe_mig <- gather(gNe_mig, 'aap', 'time', c('t.min', 't.max')) %>%
  select(-aap) %>%
  ungroup() %>%
  mutate(pop = factor(pop, levels = fpops_6sp)) %>%
  arrange(time, pop) %>%
  select(time, Ne, pop, ID)

## Merge MSMC and G-PhoCS results:
ne_comp_mit <- bind_rows(msmc, gNe_iso, gNe_mig) %>%
  mutate(ID = factor(ID, levels = c('MSMC', 'RAD: iso', 'RAD: mig')))

## Make plot:
p_mmit <- plot_msmc(msmc_output = ne_comp_mit, lwd = 2,
                    plot.title = expression(italic(mittermeieri))) +
  coord_cartesian(xlim = c(10000, 2e6), ylim = c(0, 190)) +
  scale_y_continuous(expand = c(0, 0)) +
  theme(
    axis.text.y = element_blank(),
    axis.title.y = element_blank(),
    axis.text.x = element_text(size = 22),
    #axis.title.x = element_text(size = 24, margin = margin(0, 0, 0, 0, 'cm')),
    axis.title.x = element_blank(),
    legend.position = 'right',
    legend.title = element_blank(),
    legend.text = element_text(size = 15),
    legend.margin = margin(0.15, 0.15, 0.15, 0.15, "cm"),
    legend.key.height = unit(0.6, "cm"),
    legend.key.width = unit(0.4, "cm"),
    legend.background = element_rect(fill = NA, colour = "grey30"),
    legend.key = element_rect(fill = NA),
    panel.border = element_rect(colour = "grey20", fill = NA, size = 1),
    plot.margin = margin(0.4, 0.4, 1, 0.4, 'cm')
    )
p_mmit


#### MSMC COMP PLOT - MSP3 -----------------------------------------------------
## Get MSMC result:
msmc <- select_files(
  msmc_mode = 'ind', to.select = 'mmac01', method = 'samtools',
  filedir = indir_msmc, additional.grep = 'scaffoldsGt1mb'
  ) %>%
  read_msmc(mu = mutrate_yr, gt = gentime) %>%
  mutate(ID = 'MSMC')

## Get G-PhoCS results and merge:
gNe_mig <- gphocs_Ne_prep(
  Log = filter(Log_3sp, migtype.run == 'mult'),
  setID = 'RAD: mig', poplist = poplist_3sp
  )
gNe_iso <- gphocs_Ne_prep(
  Log = subset(Log_3sp, runID == 'noMigp'),
  setID = 'RAD: iso', poplist = poplist_3sp
  )
ne_comp_sp3 <- bind_rows(msmc, gNe_mig, gNe_iso) %>%
  mutate(ID = factor(ID, levels = c('MSMC', 'RAD: iso', 'RAD: mig')))

## Make plot:
p_msp3 <- plot_msmc(msmc_output = ne_comp_sp3, lwd = 2,
                    plot.title = "sp. #3") +
  coord_cartesian(xlim = c(10000, 2e6), ylim = c(0, 190)) +
  scale_y_continuous(expand = c(0, 0)) +
  labs(y = expression(N[e] ~ "(in 1000s)")) +
  guides(color = FALSE) +
  theme(
    axis.text.x = element_text(size = 22),
    axis.title.x = element_blank(),
    legend.title = element_blank(),
    legend.text = element_text(size = 15),
    legend.margin = margin(0.15, 0.15, 0.15, 0.15, "cm"),
    legend.key.height = unit(0.6, "cm"),
    legend.key.width = unit(0.4, "cm"),
    legend.background = element_rect(fill = NA, colour = "grey30"),
    legend.key = element_rect(fill = NA),
    panel.border = element_rect(colour = "grey20", fill = NA, size = 1),
    plot.margin = margin(0.4, 0.4, 1, 0.4, 'cm')
    )
p_msp3


#### COMBINE PLOTS -------------------------------------------------------------
p <- ggarrange(p_msp3, p_mmit, ncol = 2, nrow = 1, widths = c(1, 1.17)) +
  draw_plot_label(label = c("A", "B"),
                  size = 24, x = c(0, 0.45), y = c(1, 1)) +
  draw_plot_label(label = c("Time (years ago)"),
                  size = 21, fontface = 'plain', x = 0.25, y = 0.07)
ggsave(filename = figfile, width = 10, height = 6,
       device = cairo_ps, fallback_resolution = 150)
system(paste('xdg-open', figfile))
