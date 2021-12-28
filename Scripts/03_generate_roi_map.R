source("utils_constants.R")

library(tmap)
library(grid)
library(terra)

bbox <- st_bbox(avacha_bay) |> st_as_sfc()

# The main map -------------

main_map <- tm_shape(kamchatka, bbox = avacha_bay) +
  tm_polygons(
    col = "#e5d89a",
    border.col = "#3681c2",
  ) +
  tm_graticules(
    alpha = 0.2,
  ) +
  tm_shape(khalaktyrsky_beach) +
  tm_symbols(
    size = 0.1,
    col = "red",
    border.lwd = 0.1,
    border.col = "black",
  ) +
  tm_text(
    text = "name",
    size = 0.65,
    xmod = 2.7,
  ) +
  tm_shape(avacha_bay_point) +
  tm_text(
    text = "name",
    size = 1,
    col = "#455da3",
  ) +
  tm_shape(cities) +
  tm_symbols(
    size = 0.1,
    border.lwd = 0.1,
    col = "black",
  ) +
  tm_text(
    text = "name",
    size = 0.45,
    xmod = 1.1,
    ymod = 0.55,
  ) +
  tm_scale_bar(
    position = c("left", "top"),
    lwd = 0.5,
    text.size = 0.5,
    breaks = c(0, 10, 20, 30),
  ) +
  tm_compass(
    size = 1.25,
    position = c("right", "top")
  ) +
  tm_layout(
    bg.color = "#cce8f8",
  )

# The inset map -----------

inset_map <- tm_shape(russia, bbox = kamchatka) +
  tm_polygons(
    col = "#e5d89a",
    border.col = "#3681c2",
    lwd = 0.2,
  ) +
  tm_shape(bbox) +
  tm_borders(
    col = "red",
    lwd = 0.5,
    alpha = 0.85,
  ) +
  tm_shape(seas) +
  tm_text(
    text = "name",
    col = "#455da3",
    size = 0.4,
  ) +
  tm_layout(
    bg.color = "#cce8f8",
  )

# Saving the result ----------

ivp <- grid::viewport(
  x = 0.69, y = 0.12,
  width = 0.3, height = 0.3,
  just = c("left", "bottom"),
)

tmap_save(
  main_map, file.path("..", "Maps", "roi.png"),
  insets_tm = inset_map, insets_vp = ivp,
  width = 105, height = 105, units = "mm", dpi = 400,
)

