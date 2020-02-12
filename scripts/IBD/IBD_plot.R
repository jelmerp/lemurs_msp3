#### SET-UP --------------------------------------------------------------------
## Settings:
setID <- 'msp3proj.all.mac3.FS6' # TO DO: TRY FS7

## Script with functions:
library(here)
source(here('scripts/genomics_link/IBD/IBD_fun.R'))

## Dirs/files:
input_dir <- here('analyses/IBD/RDS/')
output_dir <- here('analyses/IBD/plots/')
plotbase <- paste0(output_dir, 'IBD_', setID, '_')

## Colors:
my_cols <- RColorBrewer::brewer.pal(name = 'Set1', n = 3)[1:2]
#my_cols <- colorblindr::palette_OkabeIto[1:2]


#### RUN -----------------------------------------------------------------------
outfile_plot <- paste0(plotbase, 'comp.png')

p_mitleh <- ibd_plot_wrap(setID, subsetID = 'mitleh', input_dir, output_dir,
                          plotplotly = FALSE, save_plot = FALSE)
p_inset <- ibd_plot_wrap(setID, subsetID = 'mitleh', input_dir, output_dir,
                         plotplotly = FALSE, save_plot = FALSE, pointsize = 2)
p_macsp3 <- ibd_plot_wrap(setID, subsetID = 'macsp3', input_dir, output_dir,
                          plotplotly = FALSE, save_plot = FALSE)

(pm <- p_macsp3 +
    xlim(c(7, 13)) +
    ylim(c(0, 1.3)) +
    ggtitle(expression(paste(italic("macarthuri - M."), " sp. #3"))) +
    theme(axis.title = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks.y = element_blank(),
          legend.background = element_rect(color = 'grey30'),
          plot.margin = margin(10, 0.2, 15, 0.5)))

(pl <- p_mitleh +
    xlim(c(7, 13)) + ylim(c(0, 1.3)) +
    ggtitle(expression(italic("mittermeieri - lehilahytsara"))) +
    guides(color = FALSE) +
    theme(axis.title.x = element_blank(),
          plot.margin = margin(10, 0.5, 15, 0.2)))

(pl_inset <- p_inset +
    guides(color = FALSE) +
    theme(axis.title = element_blank(), axis.text = element_blank(),
          axis.ticks = element_blank(), panel.grid = element_blank(),
          panel.background = element_rect(fill = 'grey90', colour = 'grey10'),
          plot.margin = margin(0, 0, 0, 0)))

p <- pl + pm
pl2 <- ggdraw() + draw_plot(p) +
  draw_plot(pl_inset, x = 0.02, y = 0.48, width = 0.35, height = 0.35) +
  draw_plot_label(c("A", "B"), x = c(0.06, 0.41), y = c(1, 1), size = 15) +
  draw_plot_label("Geographic distance", x = 0.45, y = 0.085,
                  hjust = 0.5, size = 16, fontface = "plain")
ggsave(outfile_plot, width = 7.2, height = 3.5); system(paste('xdg-open', outfile_plot))


#### RESULT --------------------------------------------------------------------
## mitleh:
# Statistic: Pearson's product-moment correlation
# Value: 0.6929998
# Significance: 0.002

## macsp3:
# Statistic: Pearson's product-moment correlation
# Value: 0.6929998
# Significance: 0.002
