#### GLOBAL SET-UP -------------------------------------------------------------
## Packages:
library(here)
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(viridis))
suppressPackageStartupMessages(library(plotly))
if(!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

## Colors:
my_cols <- RColorBrewer::brewer.pal(name = 'Set1', n = 3)[1:2]
#my_cols <- colorblindr::palette_OkabeIto[1:2]

## Dirs:
input_dir <- here('analyses/IBD/RDS/')
output_dir <- here('analyses/IBD/plots/')


#### FUNCTIONS -----------------------------------------------------------------
# mytheme(): create ggplot theme
mytheme <- function () {
  theme_bw() %+replace%
    theme(axis.title = element_text(size = 16),
          axis.text = element_text(size = 16),
          legend.title = element_text(face = 'bold', size = 14),
          legend.text = element_text(size = 14))
}
theme_set(mytheme())

# dist2df(): transform an object of class 'dist' to a dataframe:
dist2df <- function(dist, varname = 'distance') {
  as.data.frame(as.matrix(dist)) %>%
    rownames_to_column() %>%
    rename(site1 = rowname) %>%
    pivot_longer(cols = -site1, names_to = 'site2') %>%
    filter(site1 != site2) %>%
    rename(!!varname := value)
}

## Create tidy df:
mantel2df <- function(mantel, lookup) {
  Dgeo_df <- dist2df(mantel$Dgeo, varname = 'geo_dist')
  Dgen_df <- dist2df(mantel$Dgen, varname = 'gen_dist')
  dist_df <- merge(Dgeo_df, Dgen_df, by = c('site1', 'site2')) %>%
    mutate(sp1 = lookup$sp[match(site1, lookup$site)],
           sp2 = lookup$sp[match(site2, lookup$site)],
           comparison = ifelse(sp1 == sp2, 'intraspecific', 'interspecific'))
}

## Create IBD plot:
ibd_plot <- function(dist_df,
                     show_plot = TRUE,
                     save_plot = TRUE,
                     outfile_plot = NULL) {
  ## Plot as regular ggplot:
  p <- ggplot(data = dist_df) +
     geom_point(aes(x = geo_dist, y = gen_dist, color = comparison), size = 4) +
     scale_color_manual(values = my_cols) +
     labs(x = "Geographic distance", y = 'Genetic distance')

  if(save_plot == TRUE) {
    ggsave(outfile_plot, width = 6, height = 4)
    system(paste('xdg-open', outfile_plot))
  }

  ## Create Plotly plot:
  p <- p + aes(text = paste0(site1, '-', site2))
  pl <- ggplotly(p)
  if(show_plot == TRUE) print(pl)
}

## Wrapper:
ibd_plot_wrap <- function(setID, subsetID) {

  ## Files:
  plotbase <- paste0(output_dir, setID, '_', subsetID)
  outfile_plot <- paste0(plotbase, '.png')
  mantel_RDS <- paste0(input_dir, setID, '_', subsetID, '_mantel.RDS')
  stopifnot(file.exists(mantel_RDS))

  ## Get mantel RDS:
  mantel <- readRDS(mantel_RDS)
  cat("## Statistic:", mantel$mantel$method, '\n')
  cat("## Value:", mantel$mantel$statistic, '\n')
  cat("## Significance:", mantel$mantel$signif, '\n')

  ## Plot:
  lookup <- mantel$lookup %>% select(species, site_short) %>% rename(site = site_short)
  dist_df <- mantel2df(mantel, lookup)
  ibd_plot(dist_df, outfile_plot = outfile_plot)

}



#### RUN -----------------------------------------------------------
setID <- 'msp3proj.all.mac3.FS6' # TO DO: CHANGE TO FS7
subsetID <- 'mitleh'
ibd_plot_wrap(setID, subsetID)
## Statistic: Pearson's product-moment correlation
## Value: 0.6929998
## Significance: 0.002


