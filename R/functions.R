fetch_kamchatka_shp <- function() {
  path <- here::here("Data", "vectors", "kamchatka.shp")

  geodata::gadm("Russia", path = here::here("Data"), level = 2) |>
    st_as_sf() |>
    st_set_crs(4326) |>
    filter(NAME_1 == "Kamchatka") |>
    select(NAME_2) |>
    st_transform(32657) |>
    write_sf(path)

  path
}

setup_snapista_for_python <- function() {
  temp_repo <- file.path(tempdir(), "snapista")
  git2r::clone("https://github.com/iod-ine/snapista", local_path = temp_repo)
  snapista_path <- here::here("snapista")
  file.rename(from = file.path(temp_repo, "snapista"), to = snapista_path)
  list.files(snapista_path, recursive = TRUE, full.names = TRUE, pattern = "\\.py$")
}

atmospherically_correct_msil1c <- function(...) {
  output_dir <- here::here("Data", "proc", "c2rcc")
  dir.create(output_dir, recursive = TRUE)
  source_python(here::here("Python", "atmospherically_correct_msil1c.py"))
  list.files(output_dir, full.names = TRUE, pattern = "\\.dim")
}

extract_msi_chlorophyll <- function(...) {
  output_dir <- here::here("Data", "export")
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  source_python(here::here("Python", "extract_msi_chlorophyll.py"))
  list.files(output_dir, full.names = TRUE, pattern = "S2_.*\\.tif$")
}

extract_olci_chlorophyll <- function(...) {
  output_dir <- here::here("Data", "export")
  source_python(here::here("Python", "extract_olci_chlorophyll.py"))
  list.files(output_dir, full.names = TRUE, pattern = "S3_.*\\.tif$")
}

extract_slstr_sst <- function(...) {
  output_dir <- here::here("Data", "export")
  source_python(here::here("Python", "extract_slstr_sea_surface_temperature.py"))
  list.files(output_dir, full.names = TRUE, pattern = "S3_.*_sst\\.tif$")
}
