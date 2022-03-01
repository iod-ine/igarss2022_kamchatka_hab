""" Batch pre-process level 1 MSI data using SNAP GPT.

This is the first step in processing Sentinel-2 data.
The second one is: extract_msi_chlorophyll.py

The processing graph is:
    - resample to 10 meter spatial resolution;
    - mask out the land using the .shp file of Kamchatka;
    - apply the C2RCC atmospheric correction.

The snapista I use here is my own version, you can find it at https://github.com/iod-ine/snapista.

"""

import os
import pathlib

import snapista

gpt_path = pathlib.Path('~/.esa-snap/bin/gpt').expanduser()

data = (pathlib.Path() / 'Data').absolute()
msi = data / 'raw' / 'MSI'
products = [msi / f for f in os.listdir(msi) if 'MSIL1C' in f]
products = [p for p in products if 'T57UVU' in p.stem]
products.sort()

gpt = snapista.GPT(gpt_path)

resample = snapista.operators.Resample()
resample.reference_band = 'B2'

import_vector = snapista.operators.ImportVector()
import_vector.separate_shapes = False
import_vector.vector_file = 'Data/vectors/kamchatka.shp'

land_sea_mask = snapista.operators.LandSeaMask()
land_sea_mask.use_srtm = False
land_sea_mask.geometry = 'kamchatka'
land_sea_mask.invert_geometry = True
land_sea_mask.shoreline_extension = 3

c2rcc = snapista.operators.C2RCC_MSI()
c2rcc.output_r_toa = False
c2rcc.output_kd = False

graph = snapista.Graph()
graph.add_node(resample)
graph.add_node(import_vector)
graph.add_node(land_sea_mask)
graph.add_node(c2rcc)

gpt.run(
    graph,
    products,
    output_folder='Data/proc/c2rcc',
    format_='BEAM-DIMAP',
    suffix='_c2rcc',
    prefix='S2_',
    date_time_only=True,
    suppress_stderr=False,
)
