#### SET-UP --------------------------------------------------------------------
## Script with IBD functions:
library(here)
source(here('scripts/genomics/IBD/IBD_fun.R'))

## Settings:
setID <- 'msp3proj.all.mac3.FS6' # VCF file ID
asprat <- 9/4 # Figure aspect ratio
figheight <- 4 # Figure height
figtype <- 'eps' # Figure filetype
my_cols <- RColorBrewer::brewer.pal(name = 'Set1', n = 3)[1:2] # Colors
my_grouplabs <- c('between', 'within')

## Dirs/files:
input_dir <- here('analyses/IBD/output/RDS/')
output_dir <- here('figs/ms/')
figfile <- paste0(output_dir, 'fig_IBD.', figtype)


#### CREATE INITIAL PLOTS ------------------------------------------------------
p_mitleh <- ibd_plot_wrap(setID, subsetID = 'mitleh',
                          my_cols = my_cols, grouplabs = my_grouplabs,
                          input_dir = input_dir, output_dir = output_dir)

p_inset <- ibd_plot_wrap(setID, subsetID = 'mitleh',
                         my_cols = my_cols, grouplabs = my_grouplabs,
                         input_dir = input_dir, output_dir = output_dir,
                         pointsize = 2)

p_macsp3 <- ibd_plot_wrap(setID, subsetID = 'macsp3',
                          my_cols = my_cols, grouplabs = my_grouplabs,
                          input_dir = input_dir, output_dir = output_dir)


#### PLOT FORMATTING -----------------------------------------------------------
(pm <- p_macsp3 + xlim(c(7, 13)) + ylim(c(0, 1.3)) +
    ggtitle(expression(paste(italic("macarthurii - M."), " sp. #3"))) +
    guides(color = FALSE) +
    theme(axis.title.x = element_blank(),
          plot.margin = margin(10, 0.2, 20, 10)))

(pl <- p_mitleh +
    xlim(c(7, 13)) + ylim(c(0, 1.3)) +
    ggtitle(expression(italic("mittermeieri - lehilahytsara"))) +
    theme(axis.title = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks.y = element_blank(),
          legend.background = element_rect(color = 'grey30'),
          legend.box.margin = margin(0, 5, 0, 0),
          plot.margin = margin(10, 0.5, 20, 0.2)))

(pl_inset <- p_inset +
    guides(color = FALSE) +
    theme(axis.text.x = element_blank(), axis.ticks.x = element_blank(),
          axis.title = element_blank(), panel.grid = element_blank(),
          axis.text.y = element_text(size = 12),
          panel.background = element_rect(fill = 'grey90', colour = 'grey10'),
          plot.margin = margin(0, 0, 0, 0)))


#### COMBINE PLOTS AND SAVE ----------------------------------------------------
plot_grid(pm, pl, rel_widths = c(1, 1.25)) +
  draw_plot(pl_inset, x = 0.62, y = 0.5, width = 0.42 / asprat, height = 0.35) +
  draw_plot_label(c("A", "B"), x = c(0.08, 0.44), y = c(1, 1), size = 15) +
  draw_plot_label("Geographic distance (log meters)", x = 0.45, y = 0.085,
                  hjust = 0.5, size = 16, fontface = "plain")

ggsave(figfile, width = figheight * asprat, height = figheight)
system(paste('xdg-open', figfile))


#### RESULTS -------------------------------------------------------------------
## mitleh:
# Statistic: Pearson's product-moment correlation
# Value: 0.6929998
# Significance: 0.002

## macsp3:
# Statistic: Pearson's product-moment correlation
# Value: 0.6929998
# Significance: 0.002
