# This is a collection of functions that recalculate concentrations into anomalies.

make_anomaly_map <- function(anomaly, date, bbox, kamchatka, output_name) {
  # Generate and save a chlorophyll anomaly map.

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
    width = 297, height = 210, units = "mm", dpi = 300,
  )
}

make_relative_anomaly_map <- function(anomaly, date, bbox, kamchatka, output_name) {
  # Generate and save a relative chlorophyll anomaly map.

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
    width = 297, height = 210, units = "mm", dpi = 300,
  )
}

generate_chl_anomaly_time_series <- function(files, kamchatka_shp) {
  # Generate a time-series of chlorophyll anomaly and relative anomaly maps.

  dates <- str_extract(files, "\\d{4}-\\d{2}-\\d{2}T\\d{2}-\\d{2}-\\d{2}")
  chlorophyll <- tibble(file = files, date = ymd_hms(dates))
  dir.create(here::here("Maps"), showWarnings = FALSE)

  source(here::here("R", "constants.R"))
  kamchatka <- read_sf(kamchatka_shp)
  elizovskiy_rayon <- filter(kamchatka, NAME_2 == "Elizovskiy rayon")

  create_anomaly_maps_for_date <- function(file, date) {
    # Calculate the relative anomaly map for a given date.

    # Reference value is calculated for 60 days ending 15 days before
    start <- date - days(75)
    end <- date - days(15)
    files <- filter(chlorophyll, between(date, start, end))[["file"]]

    previous_chl <- rast(files)
    current_chl <- rast(file)

    # There are some artifacts in the chlorophyll maps with insanely high values
    previous_chl[previous_chl > 100] <- NA
    current_chl[current_chl > 100] <- NA

    # Relative anomaly is the ratio of the anomaly to the reference value
    reference_concentration <- app(previous_chl, median, na.rm = TRUE)
    anomaly <- current_chl - reference_concentration
    relative_anomaly <- anomaly / reference_concentration

    # The rasters will be useful later for final map generation
    writeRaster(
      relative_anomaly,
      here::here("Data", "anomaly", paste0("ranomaly_", basename(file)))
    )

    # To select representative dates, save all maps (with different zoom levels)
    output_basename <- here::here("Maps", basename(file))

    out0 <- str_replace(output_basename, "\\.tif", "_anomaly_0.png")
    out1 <- str_replace(output_basename, "\\.tif", "_anomaly_1.png")
    out2 <- str_replace(output_basename, "\\.tif", "_anomaly_2.png")
    out3 <- str_replace(output_basename, "\\.tif", "_rel_anomaly_0.png")
    out4 <- str_replace(output_basename, "\\.tif", "_rel_anomaly_1.png")
    out5 <- str_replace(output_basename, "\\.tif", "_rel_anomaly_2.png")

    make_anomaly_map(anomaly, date, st_bbox(anomaly), kamchatka, out0)
    make_anomaly_map(anomaly, date, elizovskiy_rayon, kamchatka, out1)
    make_anomaly_map(anomaly, date, avacha_bay, kamchatka, out2)
    make_relative_anomaly_map(relative_anomaly, date, st_bbox(anomaly), kamchatka, out3)
    make_relative_anomaly_map(relative_anomaly, date, elizovskiy_rayon, kamchatka, out4)
    make_relative_anomaly_map(relative_anomaly, date, avacha_bay, kamchatka, out5)
  }

  chlorophyll |>
    filter(date > first(date) + days(75)) |>
    pwalk(create_anomaly_maps_for_date)

  files
}
