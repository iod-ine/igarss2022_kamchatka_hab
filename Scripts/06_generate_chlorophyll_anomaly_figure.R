source("utils_constants.R")

library(tmap)
library(terra)
library(tidyverse)
library(lubridate)


anomaly_roi <- rbind(
    c(439517.2, 5747000),
    c(740896.1, 5747000),
    c(740381, 6063000),
    c(439517.2, 6063000),
    c(439517.2, 5747000)
  ) |>
  matrix(ncol = 2) |>
  list() |>
  st_polygon() |>
  st_sfc(crs = 32657)

path <- file.path("Data", "anomaly")

rfiles <- c(
  file.path("..", "Data", "anomaly", "ranomaly_2020-08-31T00-00-25_chl.tif"),
  file.path("..", "Data", "anomaly", "ranomaly_2020-09-15T00-11-39_chl.tif"),
  file.path("..", "Data", "anomaly", "ranomaly_2020-09-23T23-38-01_chl.tif"),
  file.path("..", "Data", "anomaly", "ranomaly_2020-10-03T00-05-51_chl.tif"),
  file.path("..", "Data", "anomaly", "ranomaly_2020-10-10T23-58-22_chl.tif"),
  file.path("..", "Data", "anomaly", "ranomaly_2020-10-20T23-38-02_chl.tif"),
  file.path("..", "Data", "anomaly", "ranomaly_2020-11-06T23-58-27_chl.tif")
)

make_ranomaly_map <- function(file) {
  date <- str_extract(file, "\\d{4}-\\d{2}-\\d{2}")
  anomaly <- rast(file)
  
  tm_shape(anomaly, bbox = anomaly_roi) +
    tm_raster(
      style = "cont",
      midpoint = 0,
      palette = "-RdBu",
      legend.show = FALSE,
      breaks = seq(-1, 20, 1),
    ) +
    tm_shape(st_union(st_geometry(kamchatka))) +
    tm_polygons(
      col = "#e5d89a",
      lwd = 0.5,
    ) +
    tm_credits(
      text = date,
      size = 0.31,
      position = c("left", "top"),
    )
}

ranomaly_maps <- rfiles |>
  map(make_ranomaly_map) |>
  tmap_arrange()

tmap_save(
  ranomaly_maps, file.path("..", "Maps", "ranomaly_maps.png"),
  width = 110, height = 60, units = "mm", dpi=500,
)

