source("utils_constants.R")

library(terra)
library(tmap)
library(sf)

s2 <- rast(file.path("..", "Data", "proc", "subset_S2_2020-09-09T00-36-09_c2rcc.tif"))
s2[s2 > 100] <- NA

s2_map <- tm_shape(s2) +
  tm_raster(
    style = "cont",
    palette = "Reds",
    title = "Chl, mg.m^-3",
    breaks = seq(0, 15, 2),
  ) +
  tm_shape(st_union(kamchatka)) +
  tm_polygons(
    col = "#e5d89a",
    lwd = 0.5,
  ) +
  tm_shape(khalaktyrsky_beach) +
  tm_symbols(
    size = 0.075,
    col = "black",
    border.lwd = 0.1,
    border.col = "black",
  ) +
  tm_text(
    text = "name",
    size = 0.42,
    ymod = 0.3,
    xmod = -1.3,
  ) +
  tm_grid(alpha = 0.2) +
  tm_layout(
    legend.outside = TRUE,
    legend.title.size = 0.75,
  )

tmap_save(
  s2_map, file.path("..", "Maps", "2020-09-09_s2_chl.png"),
  width = 105, height = 130, units = "mm", dpi = 400,
)
