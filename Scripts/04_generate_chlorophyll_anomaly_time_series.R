source("utils_constants.R")

library(tmap)
library(terra)
library(tidyverse)
library(lubridate)

path <- file.path("..", "Data", "export")
files <- list.files(path, pattern = "\\d_chl", full.names = TRUE)

chlorophyll <- tibble(file = files, date = ymd_hms(file))

make_anomaly_map <- function(anomaly, date, bbox, output_name) {
  map <- tm_shape(anomaly, bbox = bbox) +
    tm_raster(
      style = "cont",
      palette = "-RdBu",
      title = "CHl-a Anomaly",
      midpoint = 0,
      breaks = seq(-15, 15, 5),
    ) +
    tm_shape(st_union(kamchatka)) +
    tm_polygons(
      col = "grey",
      border.alpha = 0,
    ) +
    tm_grid(alpha = 0.2) +
    tm_layout(
      legend.outside = TRUE,
      title = paste(date(date)),
    )
  
  tmap_save(
    map, output_name,
    width = 297, height = 210, units = "mm", dpi = 400,
  )
}

make_relative_anomaly_map <- function(anomaly, date, bbox, output_name) {
  map <- tm_shape(anomaly, bbox = bbox) +
    tm_raster(
      style = "cont",
      palette = "-RdBu",
      title = "Chl-a Relative Anomaly",
      midpoint = 0,
      breaks = c(-1, 5, 10, 15),
    ) +
    tm_shape(st_union(kamchatka)) +
    tm_polygons(
      col = "grey",
      border.alpha = 0,
    ) +
    tm_grid(alpha = 0.2) +
    tm_layout(
      legend.outside = TRUE,
      title = paste(date(date)),
    )
  
  tmap_save(
    map, output_name,
    width = 297, height = 210, units = "mm", dpi = 400,
  )
}

create_anomaly_maps <- function(file, date) {
  start <- date - days(75)
  end <- date - days(15)
  
  files <- chlorophyll |>
    filter(between(date, start, end)) |>
    pull(file)
  
  previous_chl <- rast(files)
  current_chl <- rast(file)
  
  previous_chl[previous_chl > 100] <- NA
  current_chl[current_chl > 100] <- NA
  
  reference_concentration <- app(previous_chl, median, na.rm = TRUE)
  anomaly <- current_chl - reference_concentration
  relative_anomaly <- anomaly / reference_concentration
  
  writeRaster(
    relative_anomaly,
    file.path("..", "Data", "anomaly", paste0("ranomaly_", basename(file))
  ))
  
  output_basename <- file.path("..", "Maps", basename(file))
  
  out0 <- str_replace(output_basename, "\\.tif", "_anomaly_0.png")
  out1 <- str_replace(output_basename, "\\.tif", "_anomaly_1.png")
  out2 <- str_replace(output_basename, "\\.tif", "_anomaly_2.png")
  out3 <- str_replace(output_basename, "\\.tif", "_rel_anomaly_0.png")
  out4 <- str_replace(output_basename, "\\.tif", "_rel_anomaly_1.png")
  out5 <- str_replace(output_basename, "\\.tif", "_rel_anomaly_2.png")
  
  make_anomaly_map(anomaly, date, st_bbox(anomaly), out0)
  make_anomaly_map(anomaly, date, elizovskiy_rayon, out1)
  make_anomaly_map(anomaly, date, avacha_bay, out2)
  make_relative_anomaly_map(relative_anomaly, date, st_bbox(anomaly), out3)
  make_relative_anomaly_map(relative_anomaly, date, elizovskiy_rayon, out4)
  make_relative_anomaly_map(relative_anomaly, date, avacha_bay, out5)
}


chlorophyll |>
  filter(date > first(date) + days(75)) |>
  pwalk(create_anomaly_maps)
