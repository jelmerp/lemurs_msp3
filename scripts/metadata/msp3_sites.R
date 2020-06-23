library(here)
library(tidyverse)

## Input files:
infile_lookup <- here('metadata/msp3_lookup.txt')
infile_sites <- here('metadata/lemurs_metadata_link/lookup/sites_gps.txt')

## Output file:
outfile_sites <- here('metadata/msp3_sites.txt')

##
sites_org <- read.delim(infile_sites, as.is = TRUE) %>%
  select(sp, site, lat, lon)

sites <- read.delim(infile_lookup, as.is = TRUE) %>%
  select(site, sp, species) %>%
  distinct(sp, site, .keep_all = TRUE) %>%
  merge(., sites_org, by = c('site', 'sp')) %>%
  mutate(
    site_lab = site,
    site_lab = gsub('Anjanaharibe_Sud', 'Anjanaharibe-Sud', site_lab),
    site_lab = gsub('Mananara_Nord', 'Mananara-Nord', site_lab),
    site_lump = site_lab,
    site_lump = gsub('Ambavala', 'Ambavala+', site_lump),
    site_lump = gsub('Madera', 'Ambavala+', site_lump),
    site_lump = gsub('Antsiradrano', 'Ambavala+', site_lump),
    site_lump = gsub('Anjiahely', 'Anjiahely+', site_lump),
    site_lump = gsub('Antsahabe', 'Anjiahely+', site_lump),
    pop = ifelse(site %in% c('Mananara_Nord', 'Antanambe'), 'sp3S',
                 ifelse(species == 'msp3', 'sp3N', NA))
    )

## Write file:
write.table(sites, outfile_sites,
            sep = '\t', quote = FALSE, row.names = FALSE)
