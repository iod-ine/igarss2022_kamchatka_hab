source("utils_constants.R")

library(tmap)
library(terra)
library(tidyverse)
library(lubridate)

path <- file.path("..", "Data", "export")
files <- list.files(path, pattern = "sst", full.names = TRUE)

sst <- tibble(file = files, date = ymd_hms(file))

sst2017 <- sst |>
  filter(date > ymd("2017-08-31") & date < ymd("2017-10-01")) |>
  pull(file) |>
  rast()

sst2018 <- sst |>
  filter(date > ymd("2018-08-31") & date < ymd("2019-10-01")) |>
  pull(file) |>
  rast()

sst2019 <- sst |>
  filter(date > ymd("2019-08-31") & date < ymd("2020-10-01")) |>
  pull(file) |>
  rast()

sst2020 <- sst |>
  filter(date > ymd("2020-08-31") & date < ymd("2021-10-01")) |>
  pull(file) |>
  rast()

sst2017[sst2017 < 270] <- NA
sst2018[sst2018 < 270] <- NA
sst2019[sst2019 < 270] <- NA
sst2020[sst2020 < 270] <- NA

sst_historical <- c(sst2017, sst2018, sst2019)

mean_sst_2020 <- app(sst2020, "mean", na.rm = TRUE)
median_sst_2020 <- app(sst2020, median, na.rm = TRUE)

historical_mean_sst <- app(sst_historical, "mean", na.rm = TRUE)
historical_median_sst <- app(sst_historical, median, na.rm = TRUE)

mean_ <- tm_shape(mean_sst_2020 - historical_mean_sst) +
  tm_raster(
    style = "cont",
    palette = "-RdBu",
    midpoint = 0,
    breaks = seq(-10, 10, 2),
    legend.show = FALSE,
    title = "Temperature anomaly [K]"
  ) +
  tm_shape(st_union(kamchatka)) +
  tm_polygons(
    col = "#e5d89a",
    lwd = 0.5,
  ) +
  tm_graticules(
    alpha = 0.3,
    n.y = 7,
  ) +
  tm_layout(
    legend.outside = TRUE,
    frame = FALSE,
    main.title = "Mean temperature anomaly",
    main.title.size = 0.6,
    main.title.position = "center",
  )

median_ <- tm_shape(median_sst_2020 - historical_median_sst) +
  tm_raster(
    style = "cont",
    palette = "-RdBu",
    midpoint = 0,
    breaks = seq(-10, 10, 2),
    legend.show = FALSE,
    title = "Temperature, K"
  ) +
  tm_shape(st_union(kamchatka)) +
  tm_polygons(
    col = "#e5d89a",
    lwd = 0.5,
  ) +
  tm_graticules(
    alpha = 0.3,
    n.y = 7,
  ) +
  tm_layout(
    legend.outside = TRUE,
    frame = FALSE,
    main.title = "Median temperature anomaly",
    main.title.size = 0.6,
    main.title.position = "center",
  )

sst_anomalies <- tmap_arrange(mean_, median_)

tmap_save(
  sst_anomalies, file.path("..", "Maps", "sst_anomaly.png"),
  width = 105, height = 75, units = "mm", dpi = 400,
)
