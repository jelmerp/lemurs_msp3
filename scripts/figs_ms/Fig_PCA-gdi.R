#### SET-UP - SETTINGS, FILES AND METADATA -------------------------------------
library(here)
source(here('scripts/genomics/PCA/PCA_R_fun.R'))
source(here('scripts/genomics/gphocs/gphocs_plot_fun.R'))

## Settings:
fileID_pca <- 'msp3proj.all.mac1.FS6'

## Pops:
sp_pca_all <- c("mmac", "msp3", "mleh", "mmit")

poplist <- list(mac = 'anc.A3', sp3 = 'anc.A3', anc.A3 = 'anc.LISA3',
                leh = 'anc.LI', mit = 'anc.LI', anc.LI = 'anc.LIS',
                sim = 'anc.LIS', anc.LIS = 'anc.LISA3',
                anc.LISA3 = 'anc.root', mur = 'anc.root')
childpops <- names(poplist)
parentpops <- as.character(poplist)
allpops <- unique(c(childpops, parentpops))
currentpops <- setdiff(allpops, parentpops)

## Input files - metadata:
infile_lookup <- here('metadata/msp3_lookup.txt')
infile_sites <- here('metadata/msp3_sites.txt')
infile_cols <- here('metadata/msp3_cols.txt')
stopifnot(file.exists(infile_lookup, infile_cols))

## Input files - PCA:
infile_vcf <- paste0(here('seqdata/vcf/'), fileID_pca, '.vcf.gz')
stopifnot(file.exists(infile_vcf))

## Input files - gdi:
infile_gphocs_log <- here('analyses/gphocs/output/msp3_6sp/processed/msp3_6sp_mergedlogs.txt')
infile_bpp_log <- here('analyses/bpp/output/processed/bpp_log.txt')
stopifnot(file.exists(infile_gphocs_log, infile_bpp_log))

## Output files and dirs:
outdir_snpgds <- here('analyses/PCA/gds_files/') # SNPGDS files will be created from VCF files
outfile_snpgds <- paste0(outdir_snpgds, '/', fileID_pca, '.gds') # SNPGDS files will be created from VCF files
outdir_pca <- here('analyses/PCA/dfs/') # PCA results
figfile <- paste0('figs/ms/fig_PCA-gdi.eps')

## Read metadata:
popcols_raw <- read.delim(infile_cols, as.is = TRUE)
popcols_pca <- popcols_raw %>% select(pop, col)

sites <- read.delim(infile_sites, as.is = TRUE) %>% select(site, sp, site_lump)

lookup <- read.delim(infile_lookup, as.is = TRUE) %>%
  filter(sp %in% sp_pca_all) %>%
  select(ID, sp, species, site) %>%
  merge(., sites, by = c('site', 'sp'), all.x = TRUE) %>%
  merge(., popcols_pca, by.x = 'sp', by.y = 'pop',  all.x = TRUE) %>%
  mutate(site_lump = sub('Mananara-Nord', 'Mananara', site_lump),
         site_lump = sub('Anjanaharibe-Sud', 'Anjanaharibe', site_lump),
         site_lump = sub('\\+$', '', site_lump)) %>%
  mutate(sp = factor(sp, levels = sp_pca_all)) %>%
  arrange(sp) %>%
  mutate(species = fct_inorder(factor(species)))

## Read VCF (for PCA):
snps <- snps_get(infile_vcf, outfile_snpgds)
inds_vcf <- read.gdsn(index.gdsn(snps, "sample.id"))


#### PANEL A: PCA FOR ALL INDS, PC1-2 ------------------------------------------
## Inds and labels:
inds_pca_all_short <- lookup %>% filter(sp %in% sp_pca_all) %>% pull(ID)
inds_pca_all <- inds_vcf[substr(inds_vcf, 1, 7) %in% inds_pca_all_short]

labs_pca_all <- c(expression(italic("macarthurii")),
                  expression("sp. #3"),
                  expression(italic("lehilahytsara")),
                  expression(italic("mittermeieri")))

## Run PCA for all:
pca_all_raw <- snpgdsPCA(snps, sample.id = inds_pca_all, autosome.only = FALSE)
pca_all <- data.frame(ID = substr(pca_all_raw$sample.id, 1, 7),
                      PC1 = pca_all_raw$eigenvect[, 1],
                      PC2 = pca_all_raw$eigenvect[, 2],
                      PC3 = pca_all_raw$eigenvect[, 3],
                      PC4 = pca_all_raw$eigenvect[, 4],
                      stringsAsFactors = FALSE) %>%
  merge(., lookup, by = 'ID') %>%
  mutate(sp = droplevels(factor(sp, levels = sp_pca_all))) %>%
  arrange(sp)
eig_all <- pca_all_raw$eigenval # Eigenfactor df


## Plot PCA:
p_pca_all <- pcplot(
  pca_df = pca_all, eigenvals = eig_all, my_shape = 1, alpha = 0.6,
  col_by = 'sp', col_by_labs = labs_pca_all, col_by_name = 'species:',
  cols = unique(pca_all$col), dotsize = 4, strokesize = 3, legpos = 'left'
  ) +
  theme(
    legend.key = element_rect(fill = NA),
    legend.background = element_rect(fill = NA, colour = "grey50"),
    legend.margin = margin(0.2, 0.2, 0.2, 0.2, "cm"),
    legend.box.margin = margin(0.2, 0.2, 0.2, 0.2, "cm"),
    plot.margin = margin(0.1, 0.4, 0.1, 0.4, "cm")
  )
p_pca_all


#### PANEL B: PCA FOR MAC AND SP3 ----------------------------------------------
## Inds and labels:
sp_pca_clade1 <- c("mmac", "msp3")
inds_pca_clade1_short <- lookup %>% filter(sp %in% sp_pca_clade1) %>% pull(ID)
inds_pca_clade1 <- inds_vcf[substr(inds_vcf, 1, 7) %in% inds_pca_clade1_short]

labs_pca_clade1 <- c(expression(italic("macarthurii")), expression("sp. #3"))

## Run PCA:
pca_clade1_raw <- snpgdsPCA(snps, sample.id = inds_pca_clade1, autosome.only = FALSE)
pca_clade1 <- data.frame(ID = substr(pca_clade1_raw$sample.id, 1, 7),
                      PC1 = pca_clade1_raw$eigenvect[, 1],
                      PC2 = pca_clade1_raw$eigenvect[, 2],
                      PC3 = pca_clade1_raw$eigenvect[, 3],
                      PC4 = pca_clade1_raw$eigenvect[, 4],
                      stringsAsFactors = FALSE) %>%
  merge(., lookup, by = 'ID') %>%
  mutate(sp = droplevels(factor(sp, levels = sp_pca_clade1)),
         site_lump = fct_inorder(factor(site_lump))) %>%
  arrange(sp)
eig_clade1 <- pca_clade1_raw$eigenval # Eigenfactor df

## Plot:
p_pca_clade1 <- pcplot(
  pca_df = pca_clade1, eigenvals = eig_clade1,
  dotsize = 3.5, strokesize = 2.5, #alpha = 0.5,
  col_by = 'sp', col_by_labs = labs_pca_clade1,
  col_by_name = 'species:', cols = unique(pca_clade1$col),
  shape_by = 'site_lump', shape_by_name = 'site:',
  shape_by_labs = unique(pca_clade1$site_lump), shapes = c(1:4),
  legpos = 'left'
  ) +
  theme(
    legend.key = element_rect(fill = NA),
    legend.background = element_rect(fill = NA, colour = "grey50"),
    legend.margin = margin(0.2, 0.2, 0.2, 0.2, "cm"),
    legend.box.margin = margin(0.2, 0.2, 0.2, 0.2, "cm"),
    plot.margin = margin(0.1, 0.4, 0.1, 0.4, "cm")
    )
p_pca_clade1


#### PANEL C: PCA FOR MITT AND LEHI --------------------------------------------
## Inds and labels:
sp_pca_clade2 <- c("mleh", "mmit")
inds_pca_clade2_short <- lookup %>% filter(sp %in% sp_pca_clade2) %>% pull(ID)
inds_pca_clade2 <- inds_vcf[substr(inds_vcf, 1, 7) %in% inds_pca_clade2_short]

labs_pca_clade2 <- c(expression(italic("lehilahytsara")),
                     expression(italic("mittermeieri")))

## Run PCA:
pca_clade2_raw <- snpgdsPCA(snps, sample.id = inds_pca_clade2, autosome.only = FALSE)
pca_clade2 <- data.frame(ID = substr(pca_clade2_raw$sample.id, 1, 7),
                         PC1 = pca_clade2_raw$eigenvect[, 1],
                         PC2 = pca_clade2_raw$eigenvect[, 2],
                         PC3 = pca_clade2_raw$eigenvect[, 3],
                         PC4 = pca_clade2_raw$eigenvect[, 4],
                         stringsAsFactors = FALSE) %>%
  merge(., lookup, by = 'ID') %>%
  mutate(sp = droplevels(factor(sp, levels = sp_pca_clade2)),
         site_lump = fct_inorder(factor(site_lump))) %>%
  arrange(sp)
eig_clade2 <- pca_clade2_raw$eigenval # Eigenfactor df

## Plot:
p_pca_clade2 <- pcplot(
  pca_df = pca_clade2, eigenvals = eig_clade2,
  dotsize = 3.5, strokesize = 2.5, #alpha = 0.5,
  col_by = 'sp', col_by_labs = labs_pca_clade2,
  col_by_name = 'species:', cols = unique(pca_clade2$col),
  shape_by = 'site_lump', shape_by_name = 'site:',
  shape_by_labs = levels(pca_clade2$site_lump), shapes = c(1:5),
  legpos = 'left'
) +
  theme(
    legend.key = element_rect(fill = NA),
    legend.background = element_rect(fill = NA, colour = "grey50"),
    legend.margin = margin(0.2, 0.2, 0.2, 0.2, "cm"),
    legend.box.margin = margin(0.2, 0.2, 0.2, 0.2, "cm"),
    plot.margin = margin(0.1, 0.4, 0.1, 0.4, "cm")
  )
p_pca_clade2


##### PANEL D: GDI -------------------------------------------------------------
## Inds and labels:
popcols <- popcols_raw %>% select(pop_gphocs, col) %>% rename(pop = pop_gphocs)
pops_gdi <- c('mac', 'sp3', 'leh', 'mit')
poplabs <- c('mac-sp3', 'sp3-mac', 'leh-mit', 'mit-leh')

## Load log files:
log_gphocs <- as.data.frame(fread(infile_gphocs_log, stringsAsFactors = TRUE))
log_bpp <- read.table(infile_bpp_log, header = TRUE, as.is = TRUE)
Log <- bind_rows(log_gphocs, log_bpp) %>%
  filter(runID == 'bpp',
         var == 'gdi',
         pop %in% pops_gdi) %>%
  mutate(pop = droplevels(factor(pop, levels = allpops)),
         runID = factor(runID, levels = c('bpp', 'noMig', 'multmig1')))

## Plot:
p_gdi <- vplot(
  data = Log,
  xvar = 'pop', fillvar = 'cn', colvar = 'pop', yvar = 'val',
  yticks.by = 0.1, linecols = 'pop.cols',
  rm.leg.col = TRUE, shade = FALSE,
  xlab = "", ylab = 'gdi',
  ) +
  scale_x_discrete(labels = poplabs) +
  geom_hline(yintercept = 0.7, linetype = 'dashed', size = 1, colour = 'grey30') +
  geom_hline(yintercept = 0.2, linetype = 'dashed', size = 1, colour = 'grey30') +
  geom_vline(xintercept = 2.5, linetype = 'solid', size = 0.5, color = 'grey30') +
  theme(
    axis.text.x = element_text(size = 13.5, face = 'plain'),
    plot.margin = margin(0.1, 0.4, 0.1, 0.4, "cm")
  )
p_gdi


#### COMBINE PLOTS -------------------------------------------------------------
p <- (p_gdi + p_pca_all) / (p_pca_clade1 + p_pca_clade2) +
  plot_annotation(tag_levels = 'A') &
  theme(plot.tag = element_text(size = 24, face = 'bold'))
ggsave(p, filename = figfile, width = 15/1.2, height = 10/1.2,
       device = cairo_ps, fallback_resolution = 150)
system(paste0('xdg-open ', figfile))
