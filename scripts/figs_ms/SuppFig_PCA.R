#### SET-UP - SETTINGS, FILES AND METADATA -------------------------------------
library(here)
source(here('scripts/genomics/PCA/PCA_R_fun.R'))
source(here('scripts/genomics/gphocs/gphocs_plot_fun.R'))

## Settings:
fileID_pca <- 'msp3proj.all.mac1.FS6'

## Input files - metadata:
infile_lookup <- here('metadata/msp3_lookup.txt')
infile_cols <- here('metadata/msp3_cols.txt')
stopifnot(file.exists(infile_lookup, infile_cols))

## Input files - PCA:
infile_vcf <- paste0(here('seqdata/vcf/'), fileID_pca, '.vcf.gz')
stopifnot(file.exists(infile_vcf))

## Output files and dirs:
outdir_snpgds <- here('analyses/PCA/gds_files/') # SNPGDS files will be created from VCF files
outfile_snpgds <- paste0(outdir_snpgds, '/', fileID_pca, '.gds') # SNPGDS files will be created from VCF files
outdir_pca <- here('analyses/PCA/dfs/') # PCA results
figfile <- paste0('figs/ms/SuppFig_PCA.eps')

## Read metadata:
popcols_raw <- read.delim(infile_cols, header = TRUE, as.is = TRUE)
popcols_pca <- popcols_raw %>% select(pop, col)

lookup <- read.delim(infile_lookup, as.is = TRUE) %>%
  select(ID, sp, site) %>%
  merge(., popcols_pca, by.x = 'sp', by.y = 'pop', all.x = TRUE)

## Read VCF (for PCA):
snps <- snps_get(infile_vcf, outfile_snpgds)
inds_vcf <- read.gdsn(index.gdsn(snps, "sample.id"))


#### RUN PCA  ------------------------------------------------------------------
## Inds and labels:
sp_pca_all <- c("mmac", "msp3", "mleh", "mmit", 'msim')
inds_pca_all_short <- lookup %>% filter(sp %in% sp_pca_all) %>% pull(ID)
inds_pca_all <- inds_vcf[substr(inds_vcf, 1, 7) %in% inds_pca_all_short]

labs_pca_all <- c(expression(italic("macarthurii")),
                  expression("sp. #3"),
                  expression(italic("lehilahytsara")),
                  expression(italic("mittermeieri")),
                  expression(italic("simmonsi")))

## Run PCA:
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


#### PANEL A: PC1-2 ------------------------------------------------------------
p_pc12 <- pcplot(
  pca_df = pca_all, eigenvals = eig_all,
  col_by = 'sp', col_by_labs = labs_pca_all,
  col_by_name = 'species:', cols = unique(pca_all$col),
  my_shape = 1, dotsize = 4, strokesize = 3, legpos = 'left'
) +
  theme(
    legend.key = element_rect(fill = NA),
    legend.background = element_rect(fill = NA, colour = "grey50"),
    legend.margin = margin(0.2, 0.2, 0.2, 0.2, "cm"),
    legend.box.margin = margin(0.2, 0.2, 0.2, 0.2, "cm"),
    plot.margin = margin(0.1, 0.4, 0.1, 0.4, "cm")
  )
p_pc12

#### PANEL B: PC3-4 ------------------------------------------------------------
p_pc34 <- pcplot(
  pca_df = pca_all, eigenvals = eig_all, pcX = 3, pcY = 4,
  col_by = 'sp', col_by_labs = labs_pca_all,
  col_by_name = 'species:', cols = unique(pca_all$col),
  my_shape = 1, dotsize = 4, strokesize = 3, legpos = 'left'
) +
  guides(colour = FALSE) +
  theme(plot.margin = margin(0.1, 0.4, 0.1, 0.4, "cm"))
p_pc34


#### COMBINE PLOTS -------------------------------------------------------------
p <- p_pc12 + p_pc34 +
  plot_annotation(tag_levels = 'A') &
  theme(plot.tag = element_text(size = 24, face = 'bold'))
ggsave(p, filename = figfile, width = 8.5*1.2, height = 4*1.2)
system(paste0('xdg-open ', figfile))


# p <- ggarrange(p_gdi, p_pca_all, p_pca_clade1, p_pca_clade2,
#                ncol = 2, nrow = 2, widths = c(1.2, 1)) +
#   draw_plot_label(label = c('A', 'B', 'C', 'D'),
#                   size = 28, x = c(0, 0.54, 0, 0.54),
#                   y = c(1, 1, 0.52, 0.52))
# ggsave(p, filename = figfile, width = 18, height = 12)
# system(paste0('xdg-open ', figfile))