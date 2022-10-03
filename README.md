[IEEE Xplore](https://ieeexplore.ieee.org/document/9884841)
|
[Rendered paper](https://iod-ine.github.io/igarss2022_kamchatka_hab/paper.html)
|
[Rendered presentation](https://iod-ine.github.io/igarss2022_kamchatka_hab/presentation.html)

---

# Auxiliaries for *Dubrovin and Ivanov (2022)*

```
@inproceedings{dubrovinRemoteSensingEvidence2022,
  title = {Remote {{Sensing Evidence}} for the {{Harmful Algal Bloom Explanation}} of the {{Ecological Situation}} in {{Kamchatka}} in {{Autumn}} of 2020},
  booktitle = {{{IGARSS}} 2022 - 2022 {{IEEE International Geoscience}} and {{Remote Sensing Symposium}}},
  author = {Dubrovin, Ivan and Ivanov, Anton},
  date = {2022-07-17},
  pages = {6764--6767},
  publisher = {{IEEE}},
  location = {{Kuala Lumpur, Malaysia}},
  doi = {10.1109/IGARSS46834.2022.9884841},
  eventtitle = {{{IGARSS}} 2022 - 2022 {{IEEE International Geoscience}} and {{Remote Sensing Symposium}}},
  isbn = {978-1-66542-792-0}
}
```

## Repository structure

- `Data/`: lists of used products for raw and simple READMEs that preserve the directory structure for generated data.
- `Python/`: Python scripts that wrap [SNAP](https://earth.esa.int/eogateway/tools/snap) GPT to process Sentinel images.
- `Qmd/`: Quarto source for the paper and the presentation + auxillary files.
- `R/`: R scripts that define functions used in the pipeline.
- `_targets.R`: the pipeline definition.

## Dependencies

The dependencies are contained within virtual environments: renv for R and Pipenv for Python.

## About

The whole workflow is contained within a [`targets`](https://github.com/ropensci/targets) pipeline.

## Not automated: data retrieval

I don't know how to include data retrieval into the pipeline.
I include the lists of used products in the folders that are supposed to contain them.
Offline Sentinel-2 MSI products can be downloaded from the Copernicus Hub without problems.
There is even a great API to automate that.
Offline Sentinel-3 ocean data (older than one year), however, as far as I know, can only be accessed via [EUMETSAT archive](https://archive.eumetsat.int).
It has no API and is, in general, quite a chore to use.
The EUMETSAT team is working on better alternatives, but at the moment, it's the only option.

I would put the data on public file sharing, but it's too big for any free service.
I will be keeping a copy of all products for some time, so if you need the data, you can suggest a way to share it here in the discussions or by reaching me at Ivan.Dubrovin@skoltech.ru.
