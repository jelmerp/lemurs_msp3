################################################################################
##### SET-UP #####
################################################################################
## File ID:
setwd('/home/jelmer/Dropbox/sc_lemurs/proj/sisp/analyses/gphocs/')
# fileID <- 'berrufmyo.gphocs1'
# fileID <- 'berrufmyotan.gphocs1'
# fileID <- 'borsim.gphocs1'
# fileID <- 'mur3gri2c.gphocs'
# fileID <- 'jolmarger.gphocs1'
# fileID <- 'bonravdan.gphocs1'
fileID <- 'maemamsam.gphocs1'

## Scripts and dirs:
source('/home/jelmer/Dropbox/sc_lemurs/scripts/gphocs/gphocs_controlfiles_fun.R')
dir.source <- paste0('controlfiles/master/', fileID, '/')
dir.target <- paste0('controlfiles/reps/', fileID, '/')
pattern.focal <- 'ctrl'
pattern.focal <- 'nomig1.*ctrl'

################################################################################
##### CREATE REP FILES #####
################################################################################
## Remove ~ file:
file.remove(list.files(dir.source, pattern = '~', full.names = TRUE))

## List master files:
(masterfiles <- list.files(dir.source, pattern = pattern.focal,
                          full.names = FALSE, include.dirs = FALSE))

## Create rep files:
aap <- sapply(masterfiles, prep.reps,
              nreps = 6, rm.master = FALSE,
              dir.source = dir.source, dir.target = dir.target)
