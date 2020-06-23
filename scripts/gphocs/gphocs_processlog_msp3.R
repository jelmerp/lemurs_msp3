#### SET-UP --------------------------------------------------------------------
library(here)
source(here('scripts/genomics/gphocs/gphocs_processlogs_fun.R'))

## Input and output files:
infile_lookup <- here('metadata/msp3_gphocs_pop-abbrev.txt')
logdir_base <- here('analyses/gphocs/output/')

## Variables:
set.seed(7643)
primate_mutrates <- c(0.94, 0.81, 1.1, 1.2, 1.3, 1.6, 1.7) # (multiplied by 1e-8)
gentime <- 3.5 # generation time
gentime_sd <- 1.16 # SD for generation time
mutrate_gen <- mean(primate_mutrates) # mutation rate (will be multiplied by 1e-8)
mutrate_var <- var(primate_mutrates) # variance for mutation rate (will be multiplied by 1e-8)
rename_pops_before <- TRUE # Rename populations
rename_pops_after <- TRUE # Rename populations
m_scale <- 1000 # Gphocs scaling of m (migration rate)
t_scale <- 0.0001 # Gphocs scaling of theta and tau
burnin <- 70000 # Size of burn-in, to remove.
subsample <- 50 # Subsample 1 in x samples (output lines). Default: 50
last_sample <- NULL # Stop processing log at sample x.

## Pops:
lookup <- read.delim(infile_lookup, header = TRUE, as.is = TRUE)

poplist_3sp <- list(sp3E = 'sp3',  sp3W = 'sp3',
                    mac = 'anc.A3', sp3 = 'anc.A3',
                    leh = 'anc.root', anc.A3 = 'anc.root')

poplist_6sp <- list(mac = 'anc.A3', sp3 = 'anc.A3',
                    leh = 'anc.LI', mit = 'anc.LI',
                    anc.A3 = 'anc.LISA3', anc.LIS = 'anc.LISA3',
                    anc.LI = 'anc.LIS', sim = 'anc.LIS',
                    anc.LISA3 = 'anc.root', mur = 'anc.root')


#### PROCESS LOGS --------------------------------------------------------------
## 6-species model:
setID_6sp <- 'msp3_6sp'
indir_6sp <- paste0(logdir_base, '/msp3_6sp/raw/')
outdir_6sp <- paste0(logdir_base, '/msp3_6sp/processed/')
outfile_6sp <- paste0(outdir_6sp, '/msp3_6sp_mergedlogs.txt')

Log_6sp <- getlogs(
  setID = setID_6sp, logdir = indir_6sp, burnin = burnin,
  last_sample = last_sample, subsample = subsample,
  mutrate_var = mutrate_var, gentime_sd = gentime_sd,
  rename_pops_before = rename_pops_before, rename_pops_after = rename_pops_after,
  poplist = poplist_6sp, lookup = lookup
  )
Log_6sp <- Log_6sp %>% filter(!(var == 'tau' & pop == 'leh'))
write.table(Log_6sp, outfile_6sp, sep = '\t', quote = FALSE, row.names = FALSE)

## 3-species model:
setID_3sp <- 'msp3_3sp'
indir_3sp <- paste0(logdir_base, '/msp3_3sp/raw/')
outdir_3sp <- paste0(logdir_base, '/msp3_3sp/processed/')
outfile_3sp <- paste0(outdir_3sp, '/msp3_3sp_mergedlogs.txt')

Log_3sp <- getlogs(
  setID = setID_3sp, logdir = indir_3sp, burnin = burnin,
  last_sample = last_sample, subsample = subsample,
  mutrate_var = mutrate_var, gentime_sd = gentime_sd,
  rename_pops_before = rename_pops_before, rename_pops_after = rename_pops_after,
  poplist = poplist_3sp, lookup = lookup
  )
Log_3sp <- Log_3sp %>% filter(!(var == 'tau' & pop == 'leh'))
write.table(Log_3sp, outfile_3sp, sep = '\t', quote = FALSE, row.names = FALSE)

