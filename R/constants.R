# Constants for the ROI map
avacha_bay <- st_polygon(
  list(
    rbind(
      c(445000, 5900000),
      c(545000, 5900000),
      c(545000, 5800000),
      c(445000, 5800000),
      c(445000, 5900000)
    )
  )
) |>
  st_sfc(crs = 32657)

khalaktyrsky_beach <- st_point(c(158.859018, 52.996211)) |>
  st_sfc(crs = 4326) |>
  st_as_sf() |>
  mutate(name = "Khalaktyrsky beach") |>
  st_transform(crs = 32640)

avacha_bay_point <- st_point(c(159.136409, 52.850091)) |>
  st_sfc(crs = 4326) |>
  st_as_sf() |>
  mutate(name = "Avacha Bay") |>
  st_transform(crs = 32640)

seas_coords <- rbind(
  c(170.333862, 57.250402),
  c(167.272312, 51.605518)
)

seas_names <- c(
  "Bering\nSea",
  "Pacific\nOcean"
)

seas <- st_multipoint(matrix(seas_coords, ncol = 2)) |>
  st_sfc(crs = 4326) |>
  st_cast(to = "POINT") |>
  st_as_sf() |>
  mutate(name = seas_names)

cities_coords <- rbind(
  c(158.643498, 53.024261)
)

cities_names <- c(
  "Petropavlovsk-\nKamchatsky"
)

cities <- st_multipoint(matrix(cities_coords, ncol = 2)) |>
  st_sfc(crs = 4326) |>
  st_cast(to = "POINT") |>
  st_as_sf() |>
  mutate(name = cities_names)

