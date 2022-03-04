make_roi_map <- function(shp) {
  kamchatka <- read_sf(shp)
  elizovskiy_rayon <- filter(kamchatka, NAME_2 == "Elizovskiy rayon")
  russia <- geodata::gadm("Russia", path = here::here("Data"), level = 1) |>
    st_as_sf()

  source(here::here("R", "constants.R"))

  bbox <- st_bbox(avacha_bay) |> st_as_sfc()

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

  list(main = main_map, inset = inset_map)
}

make_time_series_map <- function(shp, ...) {
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

  files <- c(
    here::here("Data", "anomaly", "ranomaly_S3_2020-08-31T00-00-25_chl.tif"),
    here::here("Data", "anomaly", "ranomaly_S3_2020-09-15T00-11-39_chl.tif"),
    here::here("Data", "anomaly", "ranomaly_S3_2020-09-23T23-38-01_chl.tif"),
    here::here("Data", "anomaly", "ranomaly_S3_2020-10-03T00-05-51_chl.tif"),
    here::here("Data", "anomaly", "ranomaly_S3_2020-10-10T23-58-22_chl.tif"),
    here::here("Data", "anomaly", "ranomaly_S3_2020-10-20T23-38-02_chl.tif"),
    here::here("Data", "anomaly", "ranomaly_S3_2020-11-06T23-58-27_chl.tif")
  )

  kamchatka <- read_sf(shp)

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

  ranomaly_maps <- map(files, make_ranomaly_map)

  anomaly <- rast(files[[1]])
  ranomaly_maps[[8]] <- tm_shape(anomaly, bbox = anomaly_roi) +
    tm_raster(
      style = "cont",
      midpoint = 0,
      palette = "-RdBu",
      legend.show = TRUE,
      legend.is.portrait = FALSE,
      title = "Chlorophyll relative anomaly",
      breaks = seq(-1, 20, 1),
    ) +
    tm_layout(
      legend.only = TRUE,
      legend.text.size = 0.4,
      legend.height = 0.3,
    ) +
    tm_scale_bar(
      position = c("left", "bottom"),
      breaks = c(0, 50, 100),
      text.size = 0.4,
    ) +
    tm_compass(size = 1.5, position = c("right", "bottom"))

  ranomaly_maps <- tmap_arrange(ranomaly_maps)

  tmap_save(
    ranomaly_maps, here::here("Maps", "_ranomaly_maps.png"),
    width = 110, height = 60, units = "mm", dpi=500,
  )

  here::here("Maps", "_ranomaly_maps.png")
}
