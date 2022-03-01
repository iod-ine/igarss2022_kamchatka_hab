""" Batch pre-process level 2 OLCI data using SNAP GPT.

The processing graph is:
    - extract the chlorophyll concentration bands;
    - collocate the images to enable stack processing;
    - export collocated images to GeoTIFF format.

The snapista I use here is my own version, you can find it at https://github.com/iod-ine/snapista.

"""

import os
import pathlib

import snapista

gpt_path = pathlib.Path('~/.esa-snap/bin/gpt').expanduser()

data = (pathlib.Path() / 'Data').absolute()
olci = data / 'raw' / 'OLCI'
products = [olci / f for f in os.listdir(olci) if 'S3' in f]
products.sort()

# we chose the master product by examining the footprints
master = next(filter(lambda p: '20200907T235256' in p.name, products))
products.remove(olci / master.name)

gpt = snapista.GPT(gpt_path)

band_maths = snapista.operators.BandMaths()
band_maths.add_target_band(
    name='CHL_NN',
    expression='CHL_NN',
    unit='mg.m-3',
    description='(Neural Net) Algal pigment concentration',
    no_data_value='NaN',
)

subset = snapista.operators.Subset()
subset.copy_metadata = False
subset.source_bands = ['CHL_NN']

reproject = snapista.operators.Reproject()
reproject.crs = 'EPSG:32657'
reproject.include_tie_point_grids = False
reproject.resampling = 'Nearest'

graph = snapista.Graph()
graph.add_node(band_maths)
graph.add_node(subset)
graph.add_node(reproject)

# run the graph on the master product only
gpt.run(
    graph,
    master,
    output_folder='Data/export',
    format_='GeoTIFF',
    suffix='_chl',
    date_time_only=True,
)

# redefine the master: set it to the processed version
master = data / 'export' / '2020-09-07T23-52-56_chl.tif'

# redefine the reproject operator: collocate everything with the master
reproject = snapista.operators.Reproject()
reproject.collocate_with = master
reproject.include_tie_point_grids = False
reproject.resampling = 'Nearest'

# recreate the graph
graph = snapista.Graph()
graph.add_node(band_maths)
graph.add_node(subset)
graph.add_node(reproject)

# run the graph on the rest of the products
gpt.run(
    graph,
    products,
    output_folder='Data/export',
    format_='GeoTIFF',
    suffix='_chl',
    prefix='S3_',
    date_time_only=True,
    suppress_stderr=False,
)
