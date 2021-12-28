# Fetch the data used in the rest of the scripts.

vectors <- file.path("..", "Data", "vectors")

russia <- geodata::gadm('Russia', path = vectors, level = 2)
russia <- sf::st_as_sf(russia)

kamchatka <- dplyr::filter(russia, NAME_1 == "Kamchatka")
kamchatka <- sf::st_transform(kamchatka, 32657)
kamchatka <- sf::st_geometry(kamchatka)

sf::write_sf(kamchatka, file.path(vectors, "kamchatka.shp"))

