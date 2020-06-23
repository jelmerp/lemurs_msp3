#### SET-UP --------------------------------------------------------------------
library(here)
source(here('scripts/genomics/admixture/admixture_plot_fun.R'))

## IDs:
setID_all <- 'msp3proj.all.mac3.FS6.all'
species_all <- c('macarthurii', 'msp3', 'lehilahytsara', 'mittermeieri', 'simmonsi')

setID_mac <- 'msp3proj.all.mac3.FS6.macsp3'
species_mac <- c('macarthurii', 'msp3')

setID_leh <- 'msp3proj.all.mac3.FS6.lehmit'
species_leh <- c('lehilahytsara', 'mittermeieri')

## Input files:
infile_lookup <- here('metadata/msp3_lookup.txt')
infile_sites <- here('metadata/msp3_sites.txt')
infile_cols <- here('metadata/msp3_cols.txt')
indir <- here('analyses/admixture/output/')

## Output files:
figfile <- here('figs/ms/SuppFig_admixture.png')

## Read and process metadata:
cols <- read.delim(infile_cols, as.is = TRUE) %>% select(pop, col)
sites <- read.delim(infile_sites, as.is = TRUE) %>%
  select(sp, site, site_lump, site_lab, pop)

lookup <- read.delim(infile_lookup, as.is = TRUE) %>%
  filter(! sp %in% 'mmur') %>%
  merge(., sites, by = c('site', 'sp')) %>%
  mutate(pop = ifelse(is.na(pop), sp, pop)) %>%
  merge(., cols, by = 'pop', all.x = TRUE) %>%
  merge(., cols, by.x = 'sp', by.y = 'pop', all.x = TRUE) %>%
  rename(col_sp = col.y, col_pop = col.x) %>%
  mutate(species = factor(species, levels = species_all)) %>%
  arrange(species, pop) %>%
  mutate(sp = fct_inorder(factor(sp)),
         col_sp = fct_inorder(factor(col_sp)),
         col_pop = fct_inorder(factor(col_pop)))

## Colors:
col_sim <- filter(lookup, sp == 'msim') %>% pull(col_sp) %>% head(1) %>% as.character()
col_leh <- filter(lookup, sp == 'mleh') %>% pull(col_sp) %>% head(1) %>% as.character()
col_mit <- filter(lookup, sp == 'mmit') %>% pull(col_sp) %>% head(1) %>% as.character()
col_mac <- filter(lookup, sp == 'mmac') %>% pull(col_sp) %>% head(1) %>% as.character()
col_sp3 <- filter(lookup, sp == 'msp3') %>% pull(col_sp) %>% head(1) %>% as.character()
col_lehmit <- get_midcol(col_leh, col_mit)
col_macsp3 <- get_midcol(col_mac, col_sp3)


#### PLOT: All SPECIES ---------------------------------------------------------
## Color and label settings:
barcol_all_3 <- rev(c(col_macsp3, col_lehmit, col_sim))
barcol_all_5 <- levels(lookup$col_sp)[c(4, 5, 2, 3, 1)]
bgcol_all <- levels(lookup$col_sp)

## All species:
cv_all <- CVplot(setID_all, title = 'All species') +
  theme(plot.margin  = margin(0.2, 0.5, 0.8, 0.2, 'cm'))

k3_all <- Qdf(setID_all, lookup, K = 3, toShortID = TRUE, sort_by = 'species') %>%
  ggax_v(ID_column = 'ID', group_column = 'sp',
         barcols = barcol_all_3, indlabs = FALSE, ylab = 'K=3',
         grouplab_angle = 0, grouplab_bgcol = bgcol_all,
         mar = c(0.2, 0.5, 0.8, 0.2))

k5_all <- Qdf(setID_all, lookup, K = 5, toShortID = TRUE, sort_by = 'species') %>%
  ggax_v(ID_column = 'ID', group_column = 'sp',
         barcols = barcol_all_5, indlabs = FALSE, ylab = 'K=5',
         grouplab_angle = 0, grouplab_bgcol = bgcol_all,
         mar = c(0.2, 0.5, 0.8, 0.2))


#### PLOT: ONLY MAC AND SP3 ----------------------------------------------------
## CV plot:
cv_title_mac <- expression(paste(italic("macarthurii"), " and sp. #3"))
cv_mac <- CVplot(setID_mac, title = cv_title_mac) +
  theme(plot.margin  = margin(0.8, 0.5, 0, 0.2, 'cm'))
cv_mac

## Barplots:
lookup_mac <- filter(lookup, sp %in% c('mmac', 'msp3'))
bgcol_mac <- levels(droplevels(lookup_mac$col_pop))
barcol_mac_2 <- rev(levels(droplevels(lookup_mac$col_sp)))
barcol_mac_3 <- levels(droplevels(lookup_mac$col_pop))[c(2, 1, 3)]

k2_mac <- Qdf(setID_mac, lookup, K = 2, toShortID = TRUE, sort_by = 'pop') %>%
  ggax_v(ID_column = 'ID', group_column = 'pop',
         barcols = barcol_mac_2, indlabs = FALSE,
         grouplab_bgcol = bgcol_mac, grouplab_angle = 0,
         ylab = 'K=2', mar = c(0.8, 0.5, 0, 0.2))

k3_mac <- Qdf(setID_mac, lookup, K = 3, toShortID = TRUE, sort_by = 'pop') %>%
  ggax_v(ID_column = 'ID', group_column = 'pop',
         barcols = barcol_mac_3, indlabs = FALSE,
         grouplab_bgcol = bgcol_mac, grouplab_angle = 0,
         ylab = 'K=3', mar = c(0.8, 0.5, 0, 0.2))


#### PLOT: ONLY LEH AND MIT ----------------------------------------------------
## CV plot:
cv_title_leh <- expression(paste(italic("lehilahytsara"), " and ",
                                 italic('mittermeieri')))
cv_leh <- CVplot(setID_leh, title = cv_title_leh) +
  theme(plot.margin  = margin(0.8, 0.5, 0, 0.2, 'cm'))
cv_leh

## Barplots:
lookup_leh <- filter(lookup, sp %in% c('mleh', 'mmit'))
bgcol_leh <- levels(droplevels(lookup_leh$col_pop))
barcol_leh_2 <- rev(levels(droplevels(lookup_leh$col_sp)))
barcol_leh_3 <- c("#FBB4AE", col_leh, col_mit)

k2_leh <- Qdf(setID_leh, lookup, K = 2, toShortID = TRUE, sort_by = 'pop') %>%
  ggax_v(ID_column = 'ID', group_column = 'pop',
         barcols = barcol_leh_2, indlabs = FALSE,
         grouplab_bgcol = bgcol_leh, grouplab_angle = 0,
         ylab = 'K=2', mar = c(0.8, 0.5, 0, 0.2))

k3_leh <- Qdf(setID_leh, lookup, K = 3, toShortID = TRUE, sort_by = 'pop') %>%
  ggax_v(ID_column = 'ID', group_column = 'pop',
         barcols = barcol_leh_3, indlabs = FALSE,
         grouplab_bgcol = bgcol_leh, grouplab_angle = 0,
         ylab = 'K=3', mar = c(0.8, 0.5, 0, 0.2))


#### COMBINE PLOTS -------------------------------------------------------------
p_all <- ggarrange(cv_all, k3_all, k5_all,
                   ncol = 3, nrow = 1, widths = c(1, 1.1, 1.1))
p_mac <- ggarrange(cv_mac, k2_mac, k3_mac,
                   ncol = 3, nrow = 1, widths = c(1, 1.1, 1.1))
p_leh <- ggarrange(cv_leh, k2_leh, k3_leh,
                   ncol = 3, nrow = 1, widths = c(1, 1.1, 1.1))
p <- ggarrange(p_all, p_mac, p_leh, ncol = 1, nrow = 3, heights = c(1, 1, 1))
p <- p + draw_plot_label(label = c('A', 'B', 'C'), size = 24,
                         x = c(0, 0, 0), y = c(1, 0.66, 0.33))
ggexport(p, filename = figfile, width = 1200, height = 1000)
system(paste0('xdg-open ', figfile))


#### MSC -----------------------------------------------------------------------
#barcol_pal <- viridis_pal(option = 'plasma')(5)
#barcol_pal <- brewer.pal(name = 'Set2', n = 8)
#barcol_pal <- brewer.pal(name = 'Pastel1', n = 8)