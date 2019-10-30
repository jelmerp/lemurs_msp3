library(plyr)
library(reshape2)
library(tidyverse)

################################################################################
#### FUNCTIONS #####
################################################################################

## prep Log:
prepLog <- function(bppLog, runID, setID) {
  colnames(bppLog)[which(colnames(bppLog) == 'lnL')] <- 'FullLd_NA'

  mlog <- bppLog %>%
    reshape2::melt(id = 'Gen') %>%
    tidyr::separate(variable, sep = '_', into = c('var', 'pop')) %>%
    dplyr::rename(val = value, Sample = Gen) %>%
    dplyr::mutate(setID = setID, runID = runID, rep = 1) %>%
    dplyr::select(setID, runID, rep, Sample, var, val, pop)

  ## Rename pops:
  mlog$pop <- poprename(mlog$pop)

  ## Add converted values:
  mlog <- add.cvalue(mlog)

  return(mlog)
}

## Add converted demographic values:
add.cvalue <- function(Log) {

  cat('Adding converted values...\n')
  Log$cval <- NA

  gentime_dist <- rlnorm(nrow(Log), meanlog = log(gentime_mean), sdlog = gentime_sd)
  mutrate.gen_dist <- rnorm(nrow(Log), mean = mutrate.gen_mean, sd = mutrate.gen_sd)

  my_theta  <- Log$val[Log$var == 'theta'] * t.scale
  my_mutrate.gen <- mutrate.gen_dist[Log$var == 'theta']
  Log$cval[Log$var == 'theta'] <- my_theta / (4 * my_mutrate.gen)

  my_tau <- Log$val[Log$var == 'tau'] * t.scale
  my_mutrate.yr <- mutrate.gen_dist[Log$var == 'tau'] / gentime_dist[Log$var == 'tau']
  Log$cval[Log$var == 'tau'] <- my_tau / my_mutrate.yr

  return(Log)
}

## Rename pop:
poprename <- function(pop) {
  pop.lookup$popname.short[match(pop, pop.lookup$popname.long)]
}

## Calculate gdi:
calc.gdi <- function(pop, pop.anc) {
  theta <- bppLog[, paste0('theta_', pop)]
  tau <- bppLog[, paste0('tau_', pop.anc)]
  gdi <- 1 - exp((-2 * tau) / theta)
}

