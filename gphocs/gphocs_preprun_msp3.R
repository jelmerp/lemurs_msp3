## Set-up:
rm(list = ls()); gc()
setwd('/home/jelmer/Dropbox/sc_lemurs/radseq/analyses/gphocs/')
source('/home/jelmer/Dropbox/sc_lemurs/radseq/scripts/gphocs/gphocs_3_prepRun_fun.R')

## Focal file ID:
fileID <- 'msp3proj.eastwest2'
#fileID <- 'msp3proj.snapp12'
dir.source <- paste0('controlfiles/master/', fileID, '/')
dir.target <- paste0('controlfiles/reps/', fileID, '/')
pattern.focal <- '.ctrl'

## Prepare replicates:
file.remove(list.files(dir.source, pattern = '~', full.names = TRUE))
(masterfiles <- list.files(dir.source, pattern = pattern.focal,
                          full.names = FALSE, include.dirs = FALSE))
aap <- sapply(masterfiles, prepReps,
              nreps = 5, rm.master = FALSE,
              dir.source = dir.source, dir.target = dir.target)


# ## Variables:
# migpatterns.Cgal <- c(migpatterns.CgalCgui[grep('Cgal2', migpatterns.CgalCgui)], "noMig")
# ## Prepare master for each migration band pattern:
# prep.migbands(radiation.id = 'EjaC.AU', template.id = 'Cgal2Cdec', migpatterns = migpatterns.AU,
#               sourcefolder = 'controlfiles/master/EjaC.AU/')
