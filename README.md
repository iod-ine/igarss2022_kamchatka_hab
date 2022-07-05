Rendered paper |
[Rendered presentation](https://iod-ine.github.io/igarss2022_kamchatka_hab/presentation.html)

---

# Auxiliaries for *Dubrovin and Ivanov (2022)*

The whole workflow is contained within a [`targets`](https://github.com/ropensci/targets) pipeline.

## Dependencies

### R
- [`targets`](https://docs.ropensci.org/targets/) – used to structure a project into a pipeline.
- [`knitr`](https://yihui.org/knitr/) – used to compile the pdf of the article.
- [`tidyverse`](https://www.tidyverse.org/) – used to manipulate tabular data.
- [`sf`](https://r-spatial.github.io/sf/) – used for working with vector data.
- [`terra`](https://rspatial.github.io/terra/reference/terra-package.html) – used for working with raster data.
- [`tmap`](https://r-tmap.github.io/tmap/) – used for generating maps.
- [`reticulate`](https://rstudio.github.io/reticulate/) – used for calling Python code from R.
- [`geodata`](https://github.com/rspatial/geodata/) – used to fetch boundaries of Kamchatka.
- [`here`](https://here.r-lib.org/) – used to not think about file paths.
- [`git2r`](https://docs.ropensci.org/git2r/) – used to setup `snapista` from a GitHub repository.

### Python
- [`lxml`](https://pypi.org/project/lxml/) – used by `snapista` for generating XML graphs for SNAP GPT.

## Not automated: data retrival

I don't know how to include data retrieval into the pipeline.
I include the lists of used products in the folders that are supposed to contain them.
Offline Sentinel-2 MSI products can be downloaded from the Copernicus Hub without problems.
There is even a great API to automate that.
Offline Sentinel-3 ocean data (older than one year), however, as far as I know, can only be accessed via [EUMETSAT archive](https://archive.eumetsat.int).
It has no API and is, in general, quite a chore to use.
The EUMETSAT team is working on better alternatives, but at the moment, it's the only option.

I would put the data on public file sharing, but it's too big for any free service.
I will be keeping a copy of all products for some time, so if you need the data, you can suggest a way to share it here in the discussions or by reaching me at Ivan.Dubrovin@skoltech.ru.
