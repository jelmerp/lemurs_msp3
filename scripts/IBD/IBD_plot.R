library(here)

#### SETTINGS ------------------------------------------------------------------
setID <- 'msp3proj.all.mac3.FS6' # TO DO: CHANGE TO FS7
subsetID <- 'mitleh'
input_dir <- here('analyses/IBD/RDS/')
output_dir <- here('analyses/IBD/plots/')
if(!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)


#### SET-UP --------------------------------------------------------------------
suppressPackageStartupMessages(library(tidyverse))

## Input files:
mantel_RDS <- paste0(input_dir, setID, '_', subsetID, '.RDS')
stopifnot(file.exists(mantel_RDS))

## Load and inspect Mantel test results:
mantel <- readRDS(mantel_RDS)
head(mantel$lookup)
print(mantel$Dgen)
print(mantel$Dgeo)

#### FUNCTIONS -----------------------------------------------------------------
# dist2df(): transform an object of class 'dist' to a dataframe:
dist2df <- function(dist, varname = 'distance') {
  as.data.frame(as.matrix(dist)) %>%
    rownames_to_column() %>%
    rename(pop1 = rowname) %>%
    pivot_longer(cols = -pop1, names_to = 'pop2') %>%
    filter(pop1 != pop2) %>%
    rename(!!varname := value)
}


#### EXPLORE AND PLOT ----------------------------------------------------------
Dgeo_df <- dist2df(mantel$Dgeo, varname = 'geo_dist')
Dgen_df <- dist2df(mantel$Dgen, varname = 'gen_dist')
dist_df <- merge(Dgeo_df, Dgen_df,
                 by = c('pop1', 'pop2'), all.x = TRUE, all.y = TRUE)

ggplot(data = dist_df) +
  geom_point(aes(x = geo_dist, y = gen_dist)) +
  theme_bw() +
  labs(x = "Geographic distance", y = 'Genetic distance')
