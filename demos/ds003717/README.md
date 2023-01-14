# BIDSPM workshop January 2023

To run this code, you would need to clone bidspm
into the code/lib directory.

```bash
mkdir -p code/lib
git clone --recurse-submodules https://github.com/cpp-lln-lab/bidspm.git code/lib/bidspm
```

You would also need to install the dataset with datalad:

```bash
mkdir -p inputs
datalad install https://github.com/OpenNeuroDatasets/ds003717 inputs/ds003717
```
