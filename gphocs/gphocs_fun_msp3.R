################################################################################################
##### PREP DATAFRAME FOR DEMOGRAPHY PLOT - EASTWEST RUNS #####
################################################################################################
tt.prep.eastwest <- function(tt, x.even = FALSE,
                             pops.fixed = NULL, pops.fixed.size = 1,
                             summary.provided = FALSE,
                             pop.spacing = 1, popnames = NULL) {

  if(summary.provided == FALSE) {
    tt <- tt %>%
      subset(var %in% c('theta', 'tau')) %>%
      group_by(pop, var) %>%
      dplyr::summarise(cval.mean = mean(cval / 1000)) %>%
      dcast(pop ~ var)
  }

  tt$NeToScale <- 1
  if(!is.null(pops.fixed)) tt$theta[match(pops.fixed, tt$pop)] <- pops.fixed.size

  ## Functions:
  getpos <- function(pop) match(pop, tt$pop)
  get.xmin <- function(pop) tt$x.min[match(pop, tt$pop)]
  get.th <- function(pop) tt$theta[match(pop, tt$pop)]
  get.ta <- function(pop) tt$tau[match(pop, tt$pop)]
  get.xmax <- function(pop) round(get.xmin(pop) + get.th(pop), 2)

  ## x start positions:
  tt$x.min <- NA
  tt$x.min[getpos('mac')] <- pop.spacing
  tt$x.min[getpos('anc.A3')] <- get.xmax('mac')
  tt$x.min[getpos('anc.sp3')] <- get.xmax('anc.A3')
  tt$x.min[getpos('sp3-W')] <- get.xmin('anc.sp3') - get.th('sp3-W')
  tt$x.min[getpos('sp3-E')] <- get.xmax('anc.sp3')
  tt$x.min[getpos('anc.root')] <- get.xmax('anc.A3')
  tt$x.min[getpos('leh')] <- get.xmax('anc.root')

  ## x end positions:
  tt$x.max <- round(tt$x.min + tt$theta, 2)

  ## y positions:
  tt$y.min <- round(ifelse(tt$pop %in% currentpops, 0, tt$tau), 2)
  tt$y.max <- round(ifelse(tt$pop == 'anc.root',
                           tt$y.min + 50, get.ta(getparent(tt$pop))), 2)

  tt$popcol <- popcols.df$popcol[match(tt$pop, popcols.df$popname.short)]
  if(!is.null(popnames)) tt$pop <- popnames

  return(tt)
}


################################################################################################
##### PREP DATAFRAME FOR DEMOGRAPHY PLOT - SNAPP12 RUNS #####
################################################################################################
tt.prep.snapp12 <- function(tt, x.even = FALSE,
                            pops.fixed = NULL, pops.fixed.size = 1,
                            summary.provided = FALSE,
                            pop.spacing = 1, popnames = NULL) {

  if(summary.provided == FALSE) {
    tt <- tt %>%
      subset(var %in% c('theta', 'tau')) %>%
      group_by(pop, var) %>%
      dplyr::summarise(cval.mean = mean(cval / 1000)) %>%
      dcast(pop ~ var)
  }

  tt$NeToScale <- 1
  if(!is.null(pops.fixed)) tt$theta[match(pops.fixed, tt$pop)] <- pops.fixed.size

  ## Functions:
  getpos <- function(pop) match(pop, tt$pop)
  get.xmin <- function(pop) tt$x.min[match(pop, tt$pop)]
  get.th <- function(pop) tt$theta[match(pop, tt$pop)]
  get.ta <- function(pop) tt$tau[match(pop, tt$pop)]
  get.xmax <- function(pop) round(get.xmin(pop) + get.th(pop), 2)

  ## x start positions:
  tt$x.min <- NA
  tt$x.min[getpos('mac')] <- pop.spacing
  tt$x.min[getpos('anc.A3')] <- get.xmax('mac')
  tt$x.min[getpos('sp3')] <- get.xmax('anc.A3')
  tt$x.min[getpos('leh')] <- get.xmax('sp3') + pop.spacing
  tt$x.min[getpos('anc.LI')] <- get.xmax('leh')
  tt$x.min[getpos('mit')] <- ifelse(get.xmax('anc.LI') > get.xmax('leh') + pop.spacing,
                                    get.xmax('anc.LI'), get.xmax('leh') + pop.spacing)
  tt$x.min[getpos('anc.LIS')] <- get.xmin('mit')

  th.largest <- sort(c(get.th('mit'), get.th('anc.LIS')))[2]
  tt$x.min[getpos('sim')] <- round(get.xmin('mit') + th.largest + pop.spacing, 2)

  tt$x.min[getpos('mur')] <- get.xmax('sim') + pop.spacing

  Diff1 <- ((get.xmin('anc.LIS') - get.xmax('anc.A3')) / 2) - (get.th('anc.LISA3') / 2)
  tt$x.min[getpos('anc.LISA3')] <- get.xmax('anc.A3') + Diff1

  Diff2 <- ((get.xmin('mur') - get.xmax('anc.LISA3')) / 2) - (get.th('anc.root') / 2)
  tt$x.min[getpos('anc.root')] <- get.xmax('anc.LISA3') + Diff2

  ## x end positions:
  tt$x.max <- round(tt$x.min + tt$theta, 2)
  #tt$x.max[getpos('anc.root')] <- getx('anc.A3')

  ## y positions:
  tt$y.min <- round(ifelse(tt$pop %in% currentpops, 0, tt$tau), 2)
  tt$y.max <- round(ifelse(tt$pop == 'anc.root',
                           tt$y.min + 600, get.ta(getparent(tt$pop))), 2)

  tt$popcol <- popcols.df$popcol[match(tt$pop, popcols.df$popname.short)]
  if(!is.null(popnames)) tt$pop <- popnames

  return(tt)
}

################################################################################################
##### DEMOGRAPHY PLOT WRAPPER FOR EASTWEST RUNS #####
################################################################################################
dplotwrap.eastwest <- function(runID.focal, plot.save = TRUE) {
  #runID.focal <- 'noMig'

  ## Prepare df underlying plot:
  (tt <- subset(Log, runID == runID.focal) %>%
     subset(var %in% c('theta', 'tau')) %>%
     group_by(pop, var) %>%
     dplyr::summarise(cval.mean = mean(cval / 1000)) %>%
     dcast(pop ~ var))
  ttp <- tt.prep.eastwest(tt, x.even = FALSE, pop.spacing = 25, summary.provided = TRUE)
  #pops.fixed = 'leh', pops.fixed.size = 20
  #popnames.col <- c('black', 'black', 'black', 'white', 'black', 'black', 'black')

  ## Factor ordering for correct legend:
  ttp$pop <- factor(ttp$pop, levels = levels(Log$pop))
  ttp <- arrange(ttp, pop)
  ttp$popcol <- factor(ttp$popcol, levels = ttp$popcol)

  ## Main plot:
  (p <- dplot(tt = ttp, ann.pops = FALSE, x.min = 0, yticks.by = 50,
              popnames.adj.horz = rep(0, nrow(ttp)), popnames.adj.vert = 15,
              popnames.col = popnames.col, popnames.size = 5, x.extra = 25,
              saveplot = FALSE, plot.title = paste0(setID, ': ', runID.focal)))

  ## Print and save:
  print(p)

  if(plot.save == TRUE) {
    plotfile <- paste0(plotdir, '/demo/', setID, '.', runID.focal, '.demoplot.png')
    ggsave(filename = plotfile, plot = p, width = 8, height = 7)
    system(paste("xdg-open", plotfile))

    plotfile.pdf <- paste0(plotdir, '/demo/', setID, '.', runID.focal, '.demoplot.pdf')
    ggsave(filename = plotfile.pdf, plot = p, width = 8, height = 7)
  }
}


################################################################################################
##### DEMOGRAPHY PLOT WRAPPER FOR SNAPP12 RUNS #####
################################################################################################
dplotwrap.snapp12 <- function(runID.focal,
                              y.max = NULL,
                              rm.y.ann = FALSE,
                              ylab = 'time (ka ago)',
                              xlab = expression(N[e] ~ "(1 tick mark = 25k)"),
                              legend.plot = TRUE,
                              legend.labs = NULL,
                              plot.title = NULL,
                              plot.save = FALSE) {
  #runID.focal <- 'noMig'

  if(is.null(plot.title)) plot.title <- paste0(setID, ': ', runID.focal)

  ## Dataframe for plotting:
  (tt <- subset(Log, runID == runID.focal) %>%
      subset(var %in% c('theta', 'tau')) %>%
      group_by(pop, var) %>%
      dplyr::summarise(cval.mean = mean(cval / 1000)) %>%
      dcast(pop ~ var))
  ttp <- tt.prep.snapp12(tt, x.even = FALSE, pop.spacing = 25, summary.provided = TRUE)

  ## Factors for correct legend ordering:
  ttp$pop <- factor(ttp$pop, levels = levels(Log$pop))
  ttp <- arrange(ttp, pop)
  ttp$popcol <- factor(ttp$popcol, levels = ttp$popcol)

  ## Main plot:
  (p <- dplot(tt = ttp, y.max = y.max, rm.y.ann = rm.y.ann, ylab = ylab, xlab = xlab,
              legend.plot = legend.plot, legend.labs = legend.labs,
              ann.pops = FALSE, x.min = 0, yticks.by = 100,
              popnames.adj.horz = rep(0, nrow(ttp)), popnames.adj.vert = 15,
              popnames.col = popnames.col, popnames.size = 5, x.extra = 25,
              saveplot = FALSE, plot.title = plot.title))

  p <- p + theme(panel.grid.minor.x = element_blank(),
                 panel.grid.major.x = element_blank(),
                 panel.grid.minor.y = element_blank(),
                 axis.title.x = element_text(margin = margin(t = 30, r = 0, b = 0, l = 0)))

  ## Connecting lines:
  p <- p + geom_segment(aes(y = ttp$y.max[ttp$pop == 'mur'],
                            yend = ttp$y.max[ttp$pop == 'mur'],
                            x = ttp$x.max[ttp$pop == 'anc.LISA3'],
                            xend = ttp$x.min[ttp$pop == 'mur']),
                        colour = 'grey50')
  p <- p + geom_segment(aes(y = ttp$y.max[ttp$pop == 'anc.LIS'],
                            yend = ttp$y.max[ttp$pop == 'anc.LIS'],
                            x = ttp$x.max[ttp$pop == 'anc.A3'],
                            xend = ttp$x.min[ttp$pop == 'anc.LIS']),
                        colour = 'grey50')
  p <- p + geom_segment(aes(y = ttp$y.max[ttp$pop == 'sim'],
                            yend = ttp$y.max[ttp$pop == 'sim'],
                            x = ttp$x.max[ttp$pop == 'anc.LI'],
                            xend = ttp$x.min[ttp$pop == 'sim']),
                        colour = 'grey50')

  ## Save plot:
  if(plot.save == TRUE) {
    plotfile <- paste0(plotdir, '/demo/', setID, '.', runID.focal, '.demoplot.png')
    ggsave(filename = plotfile, plot = p, width = 8, height = 7)
    system(paste("xdg-open", plotfile))

    plotfile.pdf <- paste0(plotdir, '/demo/', setID, '.', runID.focal, '.demoplot.pdf')
    ggsave(filename = plotfile.pdf, plot = p, width = 8, height = 7)
  }

  print(p)
  return(p)
}


################################################################################################
##### PREP GPHOCS RESULTS FOR MSMC COMPARISON PLOT #####
################################################################################################
prep.gphocsNe <- function(Log.subset, setID) {
  (gphocsNe <- tt.prep.eastwest(Log.subset) %>%
     dplyr::select(pop, tau, theta) %>%
     dplyr::rename(t.min = tau, Ne = theta) %>%
     dplyr::filter(pop %in% c('anc.root', 'anc.sp3', 'anc.A3', 'sp3-E')) %>%
     dplyr::mutate(t.max = NA, Ne = Ne * 1000, t.min = t.min * 1000))

  gphocsNe$ID <- setID

  gphocsNe$t.min[which(is.na(gphocsNe$t.min))] <- 0
  gphocsNe$t.max[gphocsNe$pop == 'anc.root'] <- 10e7
  gphocsNe$t.max[gphocsNe$pop == 'sp3-E'] <- gphocsNe$t.min[gphocsNe$pop == 'anc.sp3']
  gphocsNe$t.max[gphocsNe$pop == 'anc.sp3'] <- gphocsNe$t.min[gphocsNe$pop == 'anc.A3']
  gphocsNe$t.max[gphocsNe$pop == 'anc.A3'] <- gphocsNe$t.min[gphocsNe$pop == 'anc.root']

  (gphocsNe2 <- gather(gphocsNe, 'aap', 'time', c('t.min', 't.max')) %>%
      select(-aap) %>%
      arrange(time, Ne) %>%
      select(time, Ne, pop, ID))
}
