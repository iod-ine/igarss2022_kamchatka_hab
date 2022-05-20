""" Batch pre-process level 2 SLSTR data using SNAP GPT.

The processing graph is:
    - extract the sea surface temperature bands
    - collocate the images to enable stack processing;
    - export collocated images to GeoTIFF format.

The snapista I use here is my own version, you can find it at https://github.com/iod-ine/snapista.

"""

import os
import pathlib

# snapista package is assumed to be inside the Scripts folder, see README
import snapista

gpt_path = pathlib.Path("~/.esa-snap/bin/gpt").expanduser()

data = (pathlib.Path() / "Data").absolute()
slstr = data / "raw" / "SLSTR"
products = [slstr / f for f in os.listdir(slstr) if "S3" in f]
products.sort()

# we chose the master product by examining the footprints
master = next(filter(lambda p: "20200926T103547" in p.name, products))
products.remove(slstr / master.name)

wkt = (
    "POLYGON ((154.7357 62.87635, 166.0608 62.76349, "
    "164.1089 50.79012, 155.9193 50.86143, 154.7357 62.87635))"
)

gpt = snapista.GPT(gpt_path)

# the original product is not in WGS 84, it's in some CRS based on WGS
reproject_wgs = snapista.operators.Reproject()
reproject_wgs.crs = "EPSG:4326"
reproject_wgs.include_tie_point_grids = False
reproject_wgs.resampling = "Bilinear"

subset = snapista.operators.Subset()
subset.copy_metadata = False
subset.source_bands = ["sea_surface_temperature"]
subset.geo_region = wkt

reproject_utm = snapista.operators.Reproject()
reproject_utm.crs = "EPSG:32657"
reproject_utm.include_tie_point_grids = False
reproject_utm.resampling = "Bilinear"

graph = snapista.Graph()
graph.add_node(reproject_wgs)
graph.add_node(subset)
graph.add_node(reproject_utm)

gpt.run(
    graph,
    master,
    output_folder="Data/export",
    format_="GeoTIFF",
    suffix="_sst",
    prefix="S3_",
    date_time_only=True,
    suppress_stderr=False,
)

# redefine the master: set it to the processed version
master = data / "export" / "S3_2020-09-26T10-35-47_sst.tif"

# redefine the reproject operator: collocate everything with the master
reproject_utm = snapista.operators.Reproject()
reproject_utm.collocate_with = master
reproject_utm.include_tie_point_grids = False
reproject_utm.resampling = "Bilinear"

# recreate the graph
graph = snapista.Graph()
graph.add_node(reproject_wgs)
graph.add_node(subset)
graph.add_node(reproject_utm)

# run the graph on the rest of the products
gpt.run(
    graph,
    products,
    output_folder="Data/export",
    format_="GeoTIFF",
    suffix="_sst",
    prefix="S3_",
    date_time_only=True,
    suppress_stderr=False,
)
