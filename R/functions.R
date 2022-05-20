# This is a collection of functions defining pipeline steps that process the data.
# Most of these are wrappers around Python scripts, which are themselves wrappers
# around Sentinel Application Platform (SNAP) Graph Processing Tool (GPT).

fetch_kamchatka_shp <- function() {
  # Fetch the shapefile for Kamchatka from GADM database of Administrative Areas.
  # This file is used to mask out land during processing and for maps.

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
  # Fetch a copy of the `snapista` library for Python.
  # `snapista` is a wrapper for SNAP GPT. This specific version is my own take on it.
  # The function just clones the repository and copies the package files so that thay
  # are importable by Python.

  temp_repo <- file.path(tempdir(), "snapista")
  git2r::clone("https://github.com/iod-ine/snapista", local_path = temp_repo)
  snapista_path <- here::here("snapista")
  file.rename(from = file.path(temp_repo, "snapista"), to = snapista_path)
  list.files(snapista_path, recursive = TRUE, full.names = TRUE, pattern = "\\.py$")
}

atmospherically_correct_msil1c <- function(...) {
  # Run the Python script that applies C2RCC atmospheric correction to L1 Sentinel-2 data.
  # For more details, see the corresponding Python script.

  output_dir <- here::here("Data", "proc", "c2rcc")
  dir.create(output_dir, recursive = TRUE)
  source_python(here::here("Python", "atmospherically_correct_msil1c.py"))
  list.files(output_dir, full.names = TRUE, pattern = "\\.dim")
}

extract_msi_chlorophyll <- function(...) {
  # Run the Python script that extracts chlorophyll concentrations from Sentinel-2 data.
  # For more details, see the corresponding Python script.

  output_dir <- here::here("Data", "export")
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  source_python(here::here("Python", "extract_msi_chlorophyll.py"))
  list.files(output_dir, full.names = TRUE, pattern = "S2_.*\\.tif$")
}

extract_olci_chlorophyll <- function(...) {
  # Run the Python script that extracts chlorophyll concentrations from Sentinel-3 data.
  # For more details, see the corresponding Python script.

  output_dir <- here::here("Data", "export")
  source_python(here::here("Python", "extract_olci_chlorophyll.py"))
  list.files(output_dir, full.names = TRUE, pattern = "S3_.*\\.tif$")
}

extract_slstr_sst <- function(...) {
  # Run the Python script that sea surface temperatures from Sentinel-3 data.
  # For more details, see the corresponding Python script.

  output_dir <- here::here("Data", "export")
  source_python(here::here("Python", "extract_slstr_sea_surface_temperature.py"))
  list.files(output_dir, full.names = TRUE, pattern = "S3_.*_sst\\.tif$")
}
