library(here)
library(ggtext)
source(here('scripts/lemurs/maps/map_fun.R'))


#### SET-UP: SETTINGS ----------------------------------------------------------
## Focal species:
focal_species <- c('msp3', 'macarthurii',
                   'lehilahytsara', 'mittermeieri',
                   'simmonsi')
focal_sp <- c('msp3', 'mmac', 'mleh', 'mmit', 'msim')

## Coordinate system:
my_CRS <- 4297 # appropriate for Madagascar
# WGS_1984_UTM_Zone_39N # Dominik

## Lat and lon:
lon_min <- 48.45; lon_max <- 51.4
lat_min <- -18.1; lat_max <- -14.3
area_df <- data.frame(xmin = lon_min, ymin = lat_min,
                      xmax = lon_max, ymax = lat_max)
my_box <- make_sf_box(lon_min, lat_min, lon_max, lat_max)


#### SET-UP: FILES -------------------------------------------------------------
## Input files - site-coords:
infile_lookup <- here('metadata/msp3_lookup.txt')
infile_popcols <- here('metadata/msp3_cols.txt')
infile_sites <- here('metadata/msp3_sites.txt')

## Input files - shapefiles:
shp_veg_all <- here('metadata/lemurs/gps/vegetation/kew/madagascar_veg_geol.shp')
shp_elev_cut <- here('metadata/lemurs/gps/relief/SR_HR/SR_HR_Mada.RData')
shp_rivers_dominik <- here('metadata/lemurs/gps/rivers/Dominik/Rivers_Mada/River_Mada_1.shp')

## Output files:
outdir <- here('figs/ms/')
if(!dir.exists(outdir)) dir.create(outdir, recursive = TRUE)
figfile_base  <- file.path(outdir, 'fig_map')
figfile <- paste0(figfile_base, '.png')

#### SET-UP: LOAD AND PREPARE SAMPLE METADATA ----------------------------------
## Read and process metadata:
popcols <- read.delim(infile_popcols, as.is = TRUE) %>% select(pop, col)

sites <- read.delim(infile_sites, as.is = TRUE) %>%
  select(site, site_lab, lat, lon)

# mutate(site = gsub('Anjanaharibe_Sud', 'Anjanaharibe-Sud', site),
#        site = gsub('Madera', 'Ambavala', site),
#        site = gsub('Antsiradrano', 'Ambavala', site),
#        site = gsub('Mananara_Nord', 'Mananara-Nord', site),
#        site = gsub('Antsahabe', 'Anjiahely', site))

lookup <- read.delim(infile_lookup, as.is = TRUE) %>%
  merge(., sites, by = 'site') %>%
  filter(sp != 'mmur') %>%
  group_by(species, site) %>%
  summarise(count = n()) %>%
  merge(., lookup_raw, by = c('species', 'site'), all.x = TRUE) %>%
  merge(., popcols, by.x = 'sp', by.y = 'pop') %>%
  distinct(sp, site, .keep_all = TRUE) %>%
  select(site, site_lab, sp, species, count, lat, lon, col) %>%
  mutate(species = factor(species, levels = focal_species),
         sp = factor(sp, levels = focal_sp)) %>%
  arrange(species) %>%
  mutate(col = fct_inorder(as.factor(col)))

## Avoid plotting site names twice, for sites with 2 species:
lookup$site_name <- lookup$site
lookup$site_name[duplicated(lookup$site_name)] <- ""

## Move sites with 2 species for 1 of the two species:
Amba_sp3_row <- which(lookup$sp == 'msp3' & lookup$site == 'Ambavala')
lookup$lon[Amba_sp3_row] <- lookup$lon[Amba_sp3_row] - 0.05

Anja_mac_row <- which(lookup$sp == 'mmac' & lookup$site == 'Anjiahely')
lookup$lon[Anja_mac_row] <- lookup$lon[Anja_mac_row] - 0.05


#### SET-UP: LOAD MAP DATA -----------------------------------------------------
## Basemap data from rnaturalearth for overview and CHP maps:
mada_map_rne <- ne_countries(scale = 10, returnclass = "sf") %>%
  filter(name_long == "Madagascar") %>%
  st_transform(my_CRS)

## Kew vegetation:
veg_all <- st_read(shp_veg_all) %>% veg_edit()

## Create dummy dataframe for forest-type legend:
# forest_type <- c('humid_low', 'humid_mont')
# lat <- rep(-16, 4)
# lon <- rep(55, 4)
# dummy <- data.frame(forest_type, lat, lon)
# veg_labs <- c('humid lowland', 'humid montane')
# veg_cols <- c('darkgreen', 'olivedrab2')

## Rivers:
rivers <- st_read(shp_rivers_dominik) %>% st_transform(my_CRS)

## Elevation:
elev_mada <- readRDS(shp_elev_cut) %>%
  dplyr::select(value, geometry) %>%
  st_intersection(., my_box)


#### PREP: LABELS --------------------------------------------------------------
## River labels:
riv_lab_vec <- c("Manambolo\nriver", "Mahavy\nriver")
lon = c(45.258, 46.06247)
lat = c(-18.897, -16.87926)
riv_lab <- data.frame(riv_lab_vec, lat, lon)

## Species labels:
sp_labs <- c(msp3 = "<i style='color:#D55E00'>sp. #3</i>",
             mmac = "<i style='color:#F0E442'>macarthurii</i>",
             mleh = "<i style='color:#0072B2'>lehilahytsara</i>",
             mmit = "<i style='color:#56B4E9'>mittermeieri</i>",
             msim = "<i style='color:#999999'>simmonsi</i>")


#### MAP: INSET OF ALL OF MADA -------------------------------------------------
p_mad <- ggplot() +
  geom_sf(data = mada_map_rne, fill = NA, color = 'grey40', lwd = 1) +
  coord_sf(xlim = c(43, 51.6), ylim = c(-25.8, -11.8),
           expand = FALSE, crs = st_crs(my_CRS)) +
  theme_void() +
  geom_rect(data = area_df,
            aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
            inherit.aes = FALSE, fill = NA, color = 'grey40', lwd = 1)


#### MAP: VEGETATION AND SAMPLING ----------------------------------------------
p_msp3 <- ggplot() +
  geom_sf(data = mada_map_rne, fill = NA, color = 'grey40', lwd = 0.7) +
  geom_sf(data = elev_mada, aes(colour = value), alpha = 0.3) +
  scale_colour_gradient(low = 'grey40', high = 'white', guide = FALSE) +
  #geom_sf(data = filter(veg_all, vegetation == 'humid_low'),
  #         fill = veg_cols[1], alpha = 0.2, lwd = 0) +
  #geom_sf(data = filter(veg_all, vegetation == 'humid_mont'),
  #         fill = veg_cols[2], alpha = 0.2, lwd = 0) +
  #geom_sf(data = rivers, fill = 'skyblue3', colour = 'skyblue3', alpha = 0.8, lwd = 0.7) +
  geom_point(data = lookup,
             aes(x = lon, y = lat, fill = sp, size = count),
             color = 'black', shape = 21, stroke = 2) +
  geom_text_repel(data = lookup,
                  aes(x = lon, y = lat, label = site_name),
                  point.padding = 0.5, size = 5, fontface = 'plain') +
  scale_fill_manual(name = NULL,
                    values = levels(lookup$col),
                    labels = sp_labs) +
  coord_sf(xlim = c(lon_min, lon_max), ylim = c(lat_min, lat_max),
           expand = FALSE, crs = st_crs(my_CRS)) +
  guides(size = FALSE,
         fill = guide_legend(override.aes = list(size = 4))) +
  theme_void() +
  theme(
    legend.position = c(0.85, 0.6),
    legend.title = element_blank(),
    legend.text.align = 0,
    legend.text = element_markdown(size = 17),
    legend.background = element_rect(fill = NA, colour = 'grey20'),
    legend.margin = margin(5, 5, 5, 5),
    legend.key.height = unit(0.75, 'cm'),
    panel.border = element_rect(color = 'grey20', fill = NA),
    plot.margin = margin(1, 1, 1, 1, 'cm')
    ) +
  annotation_scale(location = "tr", width_hint = 0.25,
                   text_cex = 1.2, height = unit(0.4, 'cm'),
                   pad_x = unit(0.25, "cm"), pad_y = unit(0.25, "cm")) +
  annotation_north_arrow(location = "tr", which_north = "true",
                         height = unit(2, "cm"), width = unit(2, "cm"),
                         pad_x = unit(0.7, "cm"), pad_y = unit(1, "cm"),
                         style = north_arrow_fancy_orienteering)
p_msp3


#### COMBINE AND SAVE MAP ------------------------------------------------------
p <- ggdraw() +
  draw_plot(p_msp3) +
  draw_plot(p_mad, x = 0.62, y = 0.055, width = 0.3, height = 0.3)

ggsave(figfile, plot = p, width = 9, height = 10)
system(paste('xdg-open ', figfile))
system(paste('xdg-open ', figfile))
