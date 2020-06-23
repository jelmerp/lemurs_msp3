## This scripts contains G-PhoCS plotting wrappers specifically for
## the msp3 project.

#### PREP DF FOR DEMOGRAPHY PLOT: 3-SPECIES MODEL ------------------------------
ttprep_3sp <- function(
  Log = NULL, tt = NULL, poplist, popcols = NULL,
  summary.provided = FALSE,
  pops.fixed = NULL, pops.fixed.size = 1,
  pop.spacing = 1, popnames = NULL,
  x.even = FALSE
  ) {

  childpops <- names(poplist)
  parentpops <- as.character(poplist)
  allpops <- union(childpops, parentpops)
  currentpops <- setdiff(allpops, parentpops)

  if(summary.provided == FALSE) {
    tt <- Log %>%
      filter(var %in% c('theta', 'tau')) %>%
      group_by(pop, var) %>%
      summarise(cval.mean = mean(cval / 1000)) %>%
      pivot_wider(names_from = var, values_from = cval.mean,
                  values_fill = list(cval.mean = 0))
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
  tt$x.min[getpos('sp3W')] <- get.xmin('anc.sp3') - get.th('sp3W')
  tt$x.min[getpos('sp3E')] <- get.xmax('anc.sp3')
  tt$x.min[getpos('anc.root')] <- get.xmax('anc.A3')
  tt$x.min[getpos('leh')] <- get.xmax('anc.root')

  ## x end positions:
  tt$x.max <- round(tt$x.min + tt$theta, 2)

  ## y positions:
  tt$y.min <- round(ifelse(tt$pop %in% currentpops, 0, tt$tau), 2)
  tt$y.max <- round(ifelse(tt$pop == 'anc.root', tt$y.min + 50,
                           get.ta(as.character(poplist[tt$pop]))), 2)

  if(!is.null(popcols)) tt$popcol <- popcols$col[match(tt$pop, popcols$pop)]
  if(!is.null(popnames)) tt$pop <- popnames

  return(tt)
}


#### DEMOGRAPHY PLOT WRAPPER FOR 3-SPECIES RUNS --------------------------------
dplotwrap_3sp <- function(
  runID.focal, poplist, popcols,
  plot.save = TRUE) {

  ## Prepare df underlying plot:
  tt <- filter(Log, runID == runID.focal) %>%
    filter(var %in% c('theta', 'tau')) %>%
    group_by(pop, var) %>%
    summarise(cval.mean = mean(cval / 1000)) %>%
    pivot_wider(names_from = var, values_from = cval.mean, values_fill = list(cval.mean = 0))

  ttp <- ttprep_3sp(
    tt = tt, poplist = poplist, popcols = popcols,
    x.even = FALSE, pop.spacing = 25, summary.provided = TRUE
  ) %>%
    mutate(pop = factor(pop, levels = allpops)) %>%
    arrange(pop) %>%
    mutate(popcol = factor(popcol, levels = fct_inorder(popcol)))

  ## Main plot:
  p <- dplot(
    tt = ttp, plot.title = paste0(setID, ': ', runID.focal),
    x.min = 0, yticks.by = 50, x.extra = 25,
    popnames.adj.horz = rep(0, nrow(ttp)), popnames.adj.vert = 15,
    popnames.size = 5,
    saveplot = FALSE, ...
  )

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


#### PREP DF FOR DEMOGRAPHY PLOT: 6-SPECIES MODEL ------------------------------
ttprep_6sp <- function(
  Log = NULL, tt = NULL, poplist, popcols = NULL,
  summary.provided = FALSE,
  pops.fixed = NULL, pops.fixed.size = 1,
  pop.spacing = 1, popnames = NULL,
  x.even = FALSE
  ) {

  # Log = filter(Log, runID == 'multmig1')
  # summary.provided = FALSE; pops.fixed = NULL; x.even = FALSE;  popnames = NULL;  pop.spacing = 25

  childpops <- names(poplist)
  parentpops <- as.character(poplist)
  allpops <- union(childpops, parentpops)
  currentpops <- setdiff(allpops, parentpops)

  if(summary.provided == FALSE) {
    tt <- Log %>%
      subset(var %in% c('theta', 'tau')) %>%
      group_by(pop, var) %>%
      summarise(cval.mean = mean(cval / 1000)) %>%
      pivot_wider(names_from = var, values_from = cval.mean,
                  values_fill = list(cval.mean = 0))
    tt$pop <- as.character(tt$pop)
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

  ## y positions:
  getparent <- function(child) as.character(poplist[child])

  tt$y.min <- round(ifelse(tt$pop %in% currentpops, 0, tt$tau), 2)
  tt$y.max <- round(ifelse(tt$pop == 'anc.root', tt$y.min + 600,
                           get.ta(getparent(tt$pop))), 2)

  if(!is.null(popcols)) tt$popcol <- popcols$col[match(tt$pop, popcols$pop)]
  if(!is.null(popnames)) tt$pop <- popnames

  return(tt)
}


#### DEMOGRAPHY PLOT WRAPPER FOR 6-SPECIES RUNS --------------------------------
dplotwrap_6sp <- function(
  runID.focal, poplist, popcols,
  y.max = NULL, rm.y.ann = FALSE,
  ylab = 'time (ka ago)', xlab = expression(N[e] ~ "(1 tick mark = 25k)"),
  plot.title = NULL, plot.save = FALSE, ...
  ) {

  if(is.null(plot.title)) plot.title <- paste0(setID, ': ', runID.focal)

  ## Dataframe for plotting:
  tt <- filter(Log, runID == runID.focal) %>%
      filter(var %in% c('theta', 'tau')) %>%
      group_by(pop, var) %>%
      summarise(cval.mean = mean(cval / 1000)) %>%
      pivot_wider(names_from = var, values_from = cval.mean, values_fill = list(cval.mean = 0))
  ttp <- ttprep_6sp(
    tt = tt, poplist = poplist, popcols = popcols,
    x.even = FALSE, pop.spacing = 25, summary.provided = TRUE
    ) %>%
    ungroup() %>%
    mutate(pop = factor(pop, levels = allpops)) %>%
    arrange(pop) %>%
    mutate(popcol = factor(popcol, levels = fct_inorder(popcol)))

  ## Main plot:
  p <- dplot(
    tt = ttp, y.max = y.max, rm.y.ann = rm.y.ann, ylab = ylab, xlab = xlab,
    x.min = 0, yticks.by = 100,
    popnames.adj.horz = rep(0, nrow(ttp)), popnames.adj.vert = 15,
    popnames.size = 5, x.extra = 25,
    saveplot = FALSE, plot.title = plot.title, ...
    )

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


#### PREP GPHOCS RESULTS FOR MSMC COMPARISON PLOT ------------------------------
gphocs_Ne_prep <- function(Log, setID, poplist) {
  #Log = filter(Log_3sp, runID == 'multmig3'); poplist = poplist_3sp

  gphocsNe <- ttprep_3sp(Log = Log, poplist = poplist) %>%
     select(pop, tau, theta) %>%
     rename(t.min = tau, Ne = theta) %>%
     filter(pop %in% c('anc.root', 'sp3', 'anc.A3', 'sp3E')) %>%
     mutate(t.max = NA,
            Ne = Ne * 1000,
            t.min = t.min * 1000,
            ID = setID)

  gphocsNe$t.min[which(is.na(gphocsNe$t.min))] <- 0
  gphocsNe$t.max[gphocsNe$pop == 'anc.root'] <- 10e7
  gphocsNe$t.max[gphocsNe$pop == 'sp3E'] <- gphocsNe$t.min[gphocsNe$pop == 'sp3']
  gphocsNe$t.max[gphocsNe$pop == 'sp3'] <- gphocsNe$t.min[gphocsNe$pop == 'anc.A3']
  gphocsNe$t.max[gphocsNe$pop == 'anc.A3'] <- gphocsNe$t.min[gphocsNe$pop == 'anc.root']

  gphocsNe <- gather(gphocsNe, 'aap', 'time', c('t.min', 't.max')) %>%
      select(-aap) %>%
      arrange(time, Ne) %>%
      select(time, Ne, pop, ID)

  return(gphocsNe)
}
