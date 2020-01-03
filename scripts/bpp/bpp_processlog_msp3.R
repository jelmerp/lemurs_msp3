################################################################################
#### SET-UP #####
################################################################################
setID <- 'msp3_snapp12'
runID <- 'bpp'

## Files:
wd <- '/home/jelmer/Dropbox/sc_lemurs/'
script_processlog <- 'proj/msp3/scripts/bpp/bpp_processlog_fun.R'
infile_pop.lookup <-  'proj/msp3/analyses/bpp/bpp_popAbbrev.txt'
infile_bppLog <- 'proj/msp3/analyses/bpp/combined.mcmc'
outfile_log <- 'proj/msp3/analyses/bpp/bppLog.txt'

## Settings:
gentime_mean <- 3.5
gentime_sd <- 0.15
mutrate.gen_mean <- 1.64e-8
mutrate.gen_sd <- 0.08e-8
t.scale <- 1

## Process args:
setwd(wd)
source(script_processlog)
pop.lookup <- read.table(infile_pop.lookup, header = TRUE)


################################################################################
#### RUN #####
################################################################################
bppLog <- read.table(infile_bppLog, header = TRUE, as.is = TRUE)

## Include gdi:
bppLog$gdi_4Mmac <- calc.gdi('4Mmac', '11MmacMsp3')
bppLog$gdi_5Msp3 <- calc.gdi('5Msp3', '11MmacMsp3')
bppLog$gdi_1Mleh <- calc.gdi('1Mleh', '10MlehMmit')
bppLog$gdi_2Mmit <- calc.gdi('2Mmit', '10MlehMmit')
#bppLog$gdi_3Msim <- calc.gdi('3Msim', '9MlehMmitMsim')

#mean(calc.gdi('2Mmit', '9MlehMmitMsim'))
#mean(calc.gdi('1Mleh', '9MlehMmitMsim'))

## Msim gdi
#mean(bppLog$gdi_3Msim)
#library(TeachingDemos) # has emp.hpd function
#hpd.min <- function(x) emp.hpd(x)[1]
#hpd.max <- function(x) emp.hpd(x)[2]
#hpd.min(bppLog$gdi_3Msim)
#hpd.max(bppLog$gdi_3Msim)


## Melt:
bppLog <- bppLog %>%
  prepLog(., setID = setID, runID = runID) %>%
  mutate(migfrom = NA, migto = NA, migpattern = NA, migtype.run = NA, cn = 'aa') %>%
  select(setID, runID, rep, Sample, var, val, cval, pop,
         migfrom, migto, migpattern, migtype.run, cn)

## Write to file:
write.table(bppLog, outfile_log, row.names = FALSE, quote = FALSE, sep = '\t')


## Check:
# bppLog %>%
#  dplyr::group_by(var, pop) %>%
#  dplyr::summarise(mean_var = round(mean(cval) / 1000))
