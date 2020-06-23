# See https://rdrr.io/cran/dartR/f/inst/doc/IntroTutorial_dartR.pdf

#### SET-UP --------------------------------------------------------------------
library(here)
source(here('scripts/genomics/IBD/IBD_fun.R'))

## Settings:
setID <- 'msp3proj.all.mac3.FS6'
subsets <- list('mitleh' = c('mmit', 'mleh'),
                'macsp3' = c('mmac', 'msp3'))

## Input files:
# VCF:
infile_vcf <- here('seqdata/vcf/', paste0(setID, '.vcf.gz'))
# Metadata:
infile_lookup <- here('metadata/msp3_lookup.txt')
infile_sites <- here('metadata/msp3_sites.txt')

stopifnot(file.exists(infile_vcf),
          file.exists(infile_lookup), file.exists(infile_sites))

## Output files:
outdir_RDS <- here('analyses/IBD/output/RDS/')
RDS_vcf <- paste0(outdir_RDS, setID, '_snps.RDS')
if(!dir.exists(outdir_RDS)) dir.create(outdir_RDS, recursive = TRUE)


#### RUN MANTEL TEST -----------------------------------------------------------
## Prep lookup:
sites <- read.delim(infile_sites, as.is = TRUE) %>%
  select(site, sp, lat, lon)
lookup <- read.delim(infile_lookup, as.is = TRUE) %>%
  select(ID, Sample_ID, species, sp, site) %>%
  merge(., sites, by = c('site', 'sp'))

## Read vcf:
snps <- read_vcf(infile_vcf, lookup, RDS_vcf)

## Run for subsets:
macsp3 <- mantel_wrap(subsets['macsp3'], snps, lookup)
print(macsp3$mantel)

mitleh <- mantel_wrap(subsets['mitleh'], snps, lookup)
print(mitleh$mantel)

