library(tidyverse)

#### FUNCTIONS -----------------------------------------------------------------

## prep Log:
prep_log <- function(bppLog, runID, setID, lookup) {

  colnames(bppLog)[which(colnames(bppLog) == 'lnL')] <- 'FullLd_NA'

  mlog <- bppLog %>%
    #reshape2::melt(id = 'Gen') %>%
    #tidyr::separate(variable, sep = '_', into = c('var', 'pop')) %>%
    pivot_longer(-Gen, names_to = 'var_pop') %>%
    separate(var_pop, sep = '_', into = c('var', 'pop'), extra = 'merge') %>%
    rename(val = value, Sample = Gen) %>%
    mutate(setID = setID, runID = runID, rep = 1) %>%
    select(setID, runID, rep, Sample, var, val, pop)

  ## Rename pops:
  mlog$pop <- poprename(mlog$pop, lookup)

  ## Add converted values:
  mlog <- add_cvalue(mlog)

  return(mlog)
}


## Add converted demographic values:
add_cvalue <- function(Log) {

  cat('Adding converted values...\n')
  Log$cval <- NA

  #gentime_dist <- rlnorm(nrow(Log), meanlog = log(gentime_mean), sdlog = gentime_sd)
  #mutrate_gen_dist <- rnorm(nrow(Log), mean = mutrate.gen_mean, sd = mutrate.gen_sd)

  ## generation time and mut rate dist:
  gentime_dist <- rlnorm(nrow(Log), meanlog = log(gentime), sdlog = log(gentime_sd))

  my_shape <- mutrate_gen^2 / mutrate_var
  my_rate <- mutrate_gen / mutrate_var
  mutrate_gen_dist <- rgamma(nrow(Log), shape = my_shape, rate = my_rate) * 1e-8

  ## theta:
  my_theta  <- Log$val[Log$var == 'theta'] * t_scale
  my_mutrate_gen <- mutrate_gen_dist[Log$var == 'theta']
  Log$cval[Log$var == 'theta'] <- my_theta / (4 * my_mutrate_gen)

  ## tau:
  my_tau <- Log$val[Log$var == 'tau'] * t_scale
  my_mutrate_yr <- mutrate_gen_dist[Log$var == 'tau'] / gentime_dist[Log$var == 'tau']
  Log$cval[Log$var == 'tau'] <- my_tau / my_mutrate_yr

  return(Log)
}


## Rename pop:
poprename <- function(pop, lookup) {
  lookup$popname.short[match(pop, lookup$popname.long)]
}


## Calculate gdi:
calc_gdi <- function(Log, pop, anc) {
  theta <- Log[, paste0('theta_', pop)]
  tau <- Log[, paste0('tau_', anc)]
  gdi <- 1 - exp((-2 * tau) / theta)
}
