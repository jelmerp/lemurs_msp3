### SET-UP ---------------------------------------------------------------------
library(here)
source(here('scripts/bpp/bpp_processlog_fun.R'))

## Settings:
set.seed(7643)
primate_mutrates <- c(0.94, 0.81, 1.1, 1.2, 1.3, 1.6, 1.7) # (multiplied by 1e-8)
setID <- 'msp3_6sp'
runID <- 'bpp'
gentime <- 3.5 # generation time
gentime_sd <- 1.16 # SD for generation time
mutrate_gen <- mean(primate_mutrates) # mutation rate (will be multiplied by 1e-8)
mutrate_var <- var(primate_mutrates) # variance for mutation rate  (will be multiplied by 1e-8)
t_scale <- 1

## Input and output files:
infile_poplookup <-  here('analyses/bpp/lookup/bpp_popAbbrev.txt')
infile_bpp <- here('analyses/bpp/output/raw/combined.mcmc')
outfile_log <- here('analyses/bpp/output/processed/bpp_log.txt')

## Read metadata:
poplookup <- read.table(infile_poplookup, header = TRUE)


#### PROCESS BPP LOG -----------------------------------------------------------
Log <- read.table(infile_bpp, header = TRUE, as.is = TRUE)

## Include gdi:
Log$gdi_4Mmac <- calc_gdi(Log, pop = '4Mmac', anc = '11MmacMsp3')
Log$gdi_5Msp3 <- calc_gdi(Log, pop = '5Msp3', anc = '11MmacMsp3')
Log$gdi_1Mleh <- calc_gdi(Log, pop = '1Mleh', anc = '10MlehMmit')
Log$gdi_2Mmit <- calc_gdi(Log, pop = '2Mmit', anc = '10MlehMmit')

## Melt:
Log <- Log %>%
  prep_log(., setID = setID, runID = runID, lookup = poplookup) %>%
  mutate(migfrom = NA, migto = NA, migpattern = NA, migtype.run = NA, cn = 'aa') %>%
  select(setID, runID, rep, Sample, var, val, cval, pop,
         migfrom, migto, migpattern, migtype.run, cn)

## Write to file:
write.table(Log, outfile_log,
            row.names = FALSE, quote = FALSE, sep = '\t')


#### NOT RUN -------------------------------------------------------------------
## M. simmonsi gdi:
# bppLog$gdi_3Msim <- calc.gdi('3Msim', '9MlehMmitMsim')
# mean(bppLog$gdi_3Msim)
# library(TeachingDemos) # has emp.hpd function
# hpd.min <- function(x) emp.hpd(x)[1]
# hpd.max <- function(x) emp.hpd(x)[2]
# hpd.min(bppLog$gdi_3Msim)
# hpd.max(bppLog$gdi_3Msim)

## Check output:
# bppLog %>%
#  dplyr::group_by(var, pop) %>%
#  dplyr::summarise(mean_var = round(mean(cval) / 1000))
