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


