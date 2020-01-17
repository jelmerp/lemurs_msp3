#https://rdrr.io/cran/dartR/f/inst/doc/IntroTutorial_dartR.pdf

#### SET-UP---------------------------------------------------------------------
## Settings:
setID <- 'msp3proj.all.mac3.FS6' # TO DO: CHANGE TO FS7

## Packages:
library(here)
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(vcfR))
suppressPackageStartupMessages(library(adegenet))
suppressPackageStartupMessages(library(dartR))

## Input files:
# VCF:
infile_vcf <- here('seqdata/vcf/', paste0(setID, '.vcf.gz'))

# Metadata:
infile_lookup <- here('metadata/radseq_metadata_link/lookup_IDshort.txt')
infile_sites <- here('metadata/lemurs_metadata_link/lookup/sites_gps.txt')
infile_pops <- here('metadata/lemurs_metadata_link/lookup/sites_pops.txt')

# Check:
stopifnot(file.exists(infile_lookup), file.exists(infile_sites),
          file.exists(infile_pops), file.exists(infile_vcf))

## Output files:
outdir_plots <- here('analyses/IBD/plots/')
if(!dir.exists(outdir_plots)) dir.create(outdir_plots, recursive = TRUE)
outdir_RDS <- here('analyses/IBD/RDS/')
if(!dir.exists(outdir_RDS)) dir.create(outdir_RDS, recursive = TRUE)
out_RDS_base <- paste0(outdir_RDS, setID, '_')


#### READ AND PREP DATA --------------------------------------------------------
## Read VCF:
snps_raw <- vcfR2genlight(read.vcfR(infile_vcf))
snps_raw@ind.names <- substr(snps_raw@ind.names, 1, 7) # Long->short IDs
saveRDS(snps_raw, paste0(out_RDS_base, 'snps_raw.RDS'))

## Read and process metadata:
lookup_raw <- read.delim(infile_lookup, as.is = TRUE) %>%
  select(ID, Sample_ID, species, sp, site)

pops <- read.csv(infile_pops, as.is = TRUE) %>%
  select(site, site_short, site_lump, sp, pop2)
sites <- read.delim(infile_sites, as.is = TRUE) %>%
  select(site, sp, lat, lon) %>%
  merge(., pops, by = c('site', 'sp'), all.x = TRUE)

# Subset to inds in VCF:
stopifnot(all(snps_raw@ind.names %in% lookup_raw$ID)) # Check if all VCF inds are in lookup
lookup_raw_sel <- lookup_raw %>% filter(ID %in% snps_raw@ind.names)

# Include site GPS coords:
stopifnot(all(lookup_raw_sel$site %in% sites$site)) # Check if all sites are in site-lookup
lookup <- lookup_raw_sel %>%
  merge(., sites, by = c('site', 'sp')) %>%
  mutate(site_short = ifelse(is.na(site_short), site, site_short),
         site_lump = ifelse(is.na(site_lump), site, site_lump),
         pop2 = ifelse(is.na(pop2), sp, pop2)) %>%
  arrange(match(ID, snps_raw@ind.names)) # Same order as in "snps" object!

## Modify genlight object:
(snps_raw@other$latlong <- lookup %>% select(lat, lon)) # Include lat-long in genlight object
(snps_raw@pop <- lookup %>% pull(site_short) %>% factor()) # Include pop-info


#### RUN IBD TEST --------------------------------------------------------------
## Subset to specific species:
subsetID <- 'mitleh'
focal_sps <- c('mittermeieri', 'lehilahytsara')
lookup_sel <- filter(lookup, species %in% focal_sps)
inds_sel <- lookup_sel %>% pull(ID)
snps_sel <- gl.keep.ind(snps, ind.list = inds_sel)

## Do Mantel test at population level (uses FST):
mantel <- gl.ibd(snps_sel) #[, 1:100]
mantel$lookup <- lookup_sel
saveRDS(mantel, paste0(out_RDS_base, subsetID, '.RDS'))





#### FILTER A VCF --------------------------------------------------------------
#snps <- new('genlight', as.matrix(snps)[keep.rows, ])

#### TESTING -------------------------------------------------------------------
# ordering <- levels(snps@pop)
# latlon <- RgoogleMaps::geosphere_mercator(snps@other$latlong)
# latlon <- apply(latlon, 2, function(a) tapply(a, pop(snps), mean, na.rm = T))
# Dgeo <- as.dist(as.matrix(log(dist(latlon)))[ordering, ordering])
# Dgen <- gl.dist.pop(snps[, 1:1000], method = "euclidean")
# Dgen <- as.dist(as.matrix(Dgen)[ordering, ordering])
#
# ## Mantel test at individual level:
# snps_sel_ind <- snps_sel
# snps_sel_ind@pop <- factor(snps_sel_ind@ind.names)
# aap <- gl.ibd(snps_sel_ind[, 1:100])
#
# ## "Manual" Mantel:
# #gl.ibd
# snps_sel_ind <- snps_sel
# snps_sel_ind@pop <- factor(snps_sel_ind@ind.names)
# ordering <- levels(snps_sel_ind@pop)
# latlon <- RgoogleMaps::geosphere_mercator(snps_sel@other$latlong) +
#   round(rnorm(length(inds_sel), mean = 5, sd = 10)) # Add random noise to avoid same GPS
# #latlon <- snps_sel@other$latlong
# Dgeo <- log(dist(latlon))
# str(Dgeo)
# Dgeo <- as.dist(as.matrix(Dgeo)[ordering, ordering])
# Dgen <- gl.dist.pop(snps_sel_ind, method = "euclidean")
# Dgen <- as.dist(as.matrix(Dgen)[ordering, ordering])
#
# dim(latlon)
# length(snps_sel_ind@ind.names)