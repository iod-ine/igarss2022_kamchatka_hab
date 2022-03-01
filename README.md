# Auxiliaries for *Dubrovin and Ivanov (2021)*

The whole workflow is contained within a [`targets`](https://github.com/ropensci/targets) pipeline.

### Not automated: data retrival

I don't know how to include data retrieval into the pipeline.
I include the lists of used products in the folders that are supposed to contain them.
Offline Sentinel-2 MSI products can be downloaded from the Copernicus Hub without problems.
There is even a great API to automate that.
Offline Sentinel-3 ocean data (older than one year), however, as far as I know, can only be accessed via [EUMETSAT archive](https://archive.eumetsat.int).
It has no API and is, in general, quite a chore to use.
The EUMETSAT team is working on better alternatives, but at the moment, it's the only option.

I would put the data on public file sharing, but it's too big for any free service.
I will be keeping a copy of all products for some time, so if you need the data, you can suggest a way to share it here in the discussions or by reaching me at Ivan.Dubrovin@skoltech.ru.

