################################################################################
##### SET-UP #####
################################################################################
## G-phocs run / setID:
#logdir <- 'msp3/analyses/gphocs/output/msp3_snapp12/'; setID <- 'msp3_snapp12'
#logdir <- 'msp3/analyses/gphocs/output/msp3_eastwest2/'; setID <- 'msp3_eastwest2'
logdir <- 'msp3/analyses/gphocs/output/msp3_eastwest2p/'; setID <- 'msp3_eastwest2'

wd <- '/home/jelmer/Dropbox/sc_lemurs/'

## Scipts:
script_processlog <- 'scripts/gphocs/gphocs_5_processlog_fun.R'

## Input and output files:
infile_pop.lookup <- 'msp3/analyses/gphocs/popInfo/ghocs_popAbbrev.txt'
infile_pops <- 'msp3/analyses/gphocs/popInfo/ghocs_pops.txt'
outfile_log <- paste0(logdir, '/mergedLogs.txt')

## Variables:
gentime_mean <- 3.5
gentime_sd <- 0.15
mutrate.gen_mean <- 1.64e-8
mutrate.gen_sd <- 0.08e-8
m.scale <- 1000
t.scale <- 0.0001
burnIn <- 70000
subSample <- 50
lastSample <- NULL

## Process:
setwd(wd)
source(script_processlog)

pop.lookup <- read.delim(infile_pop.lookup, header = TRUE, as.is = TRUE)
pops <- read.delim(infile_pops, header = TRUE, as.is = TRUE)

## Pops:
if(grepl('eastwest', setID))
  pop.lookup$popname.short[which(pop.lookup$popname.short == 'sp3')] <- 'anc.sp3'
if(setID == 'msp3_eastwest2p') pops$msp3_eastwest2p <- pops$msp3_eastwest2

kidpops <- pops$kidpop[pops[, grep(setID, colnames(pops))] == 1]
parentpops <- pops$parentpop[pops[, grep(setID, colnames(pops))] == 1]
allpops <- unique(c(kidpops, parentpops))
currentpops  <- kidpops[grep('anc', kidpops, invert = TRUE)]


################################################################################
##### PROCESS LOGS #####
################################################################################
Log <- getLogs(logdir = logdir, setID = setID,
               burnIn = burnIn, lastSample = lastSample, subSample = subSample)

Log <- Log %>%
  dplyr::filter(!(var == 'tau' & pop == 'leh'))


################################################################################
##### WRITE FILE #####
################################################################################
write.table(Log, outfile_log,
            sep = '\t', quote = FALSE, row.names = FALSE)
