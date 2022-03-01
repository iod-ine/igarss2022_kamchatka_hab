""" Batch pre-process C2RCC corrected MSI data using SNAP GPT.

This is the second step in processing Sentinel-2 data.
The first one is: atmospherically_correct_msil1c.py

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
c2rcc = data / 'proc' / 'c2rcc'
products = [c2rcc / f for f in os.listdir(c2rcc) if '_c2rcc.dim' in f]
products.sort()

master_index = [p.stem for p in products].index('S2_2020-09-09T00-36-09_c2rcc')
master = products.pop(master_index)

gpt = snapista.GPT(gpt_path)

band_maths = snapista.operators.BandMaths()

band_maths.add_target_band(
    name='conc_chl',
    expression='conc_chl',
    unit='mg.m-3',
    description='Chlorophyll concentration',
    no_data_value='NaN',
)

subset = snapista.operators.Subset()
subset.copy_metadata = False
subset.source_bands = ['conc_chl']

graph = snapista.Graph()
graph.add_node(band_maths)
graph.add_node(subset)

gpt.run(
    graph,
    master,
    output_folder='Data/export',
    format_='GeoTIFF',
    suffix='_chl',
)

reproject = snapista.operators.Reproject()
reproject.include_tie_point_grids = False
reproject.resampling = 'Nearest'
reproject.collocate_with = master

graph = snapista.Graph()
graph.add_node(band_maths)
graph.add_node(subset)
graph.add_node(reproject)

gpt.run(
    graph,
    products,
    output_folder='Data/export',
    format_='GeoTIFF',
    suffix='_chl',
    suppress_stderr=False,
)
