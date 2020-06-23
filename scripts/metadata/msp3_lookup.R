library(here)
library(tidyverse)

## Input files:
infile_lookup <- here('metadata/radseq_metadata_link/lookup_IDshort.txt')
infile_msp3_IDs <- here('metadata/msp3_IDs.txt')

## Output file:
outfile_lookup <- here('metadata/msp3_lookup.txt')

## Prep lookup df:
msp3_IDs <- readLines(infile_msp3_IDs)

lookup <- read.delim(infile_lookup, as.is = TRUE) %>%
  select(ID, Sample_ID, species, sp, site, exclude) %>%
  filter(ID %in% msp3_IDs) %>%
  filter(exclude == 'incl') %>%
  select(Sample_ID, ID, ID_long, species, sp, site)

## Write file:
write.table(lookup, outfile_lookup,
            sep = '\t', quote = FALSE, row.names = FALSE)
