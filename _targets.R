library(targets)
library(tarchetypes)

source(here::here("R", "functions.R"))
source(here::here("R", "maps.R"))
source(here::here("R", "anomalies.R"))

tar_option_set(packages = c(
  "tidyverse",
  "sf",
  "git2r",
  "reticulate",
  "tmap",
  "lubridate",
  "terra"
))

list(
  # Raw data is not a target because it would slow down pipeline inspection
  tar_target(kamchatka_shp, fetch_kamchatka_shp(), format = "file"),
  tar_target(snapista, setup_snapista_for_python(), format = "file"),
  tar_target(
    py_c2rcc_msi,
    here::here("Python", "atmospherically_correct_msil1c.py"),
    format = "file"
  ),
  tar_target(
    msil1c_ac,
    atmospherically_correct_msil1c(snapista, kamchatka_shp, py_c2rcc_msi),
    format = "file"
  ),
  tar_target(
    py_chl_msi,
    here::here("Python", "extract_msi_chlorophyll.py"),
    format = "file"
  ),
  tar_target(
    msil1c_chl,
    extract_msi_chlorophyll(py_chl_msi, msil1c_ac),
    format = "file"
  ),
  tar_target(
    py_chl_olci,
    here::here("Python", "extract_olci_chlorophyll.py"),
    format = "file"
  ),
  tar_target(
    olci_chl,
    extract_olci_chlorophyll(snapista, py_chl_olci),
    format = "file"
  ),
  tar_target(
    py_sst_slstr,
    here::here("Python", "extract_slstr_sea_surface_temperature.py"),
    format = "file"
  ),
  tar_target(
    slstr_sst,
    extract_slstr_sst(snapista, py_sst_slstr),
    format = "file"
  ),
  tar_target(roi_map, make_roi_map(kamchatka_shp)),
  tar_target(
    chl_anomaly_series,
    generate_chl_anomaly_time_series(olci_chl, kamchatka_shp),
    format = "file"
  )
)
