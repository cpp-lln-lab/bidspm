# Installation

## Requirements

This SPM toolbox runs with Matlab and Octave.

| Dependencies | Minimum required | Used for testing in CI                     |
| ------------ | ---------------- | ------------------------------------------ |
| MATLAB       | 2014             |  2023b on Ubuntu 22.04, Windowns and MacOS |
| Octave       | 6.4.0            |  6.4.0 on Ubuntu 22.04                     |
| SPM12        | 7219             |  7771                                      |


Some functionalities require some extra SPM toolbox to work:
for example the ALI toolbox for brain lesion segmentation.

## Installation

If you are only going to use this toolbox for a new analysis
and you are not planning to edit the code base of bidspm itself, we STRONGLY
suggest you use this [template repository](https://github.com/cpp-lln-lab/template_datalad_fMRI)
to create a new project with a basic structure of folders and with the bidspm code already set up.

Otherwise you can clone the repo with all its dependencies
with the following git command:

```bash
git clone --recurse-submodules https://github.com/cpp-lln-lab/bidspm.git
```

If you need the latest development, then you must clone from the ``dev`` branch:

## Initialization

```{warning}
In general DO NOT ADD bidspm PERMANENTLY to your MATLAB / Octave path.
```

You just need to initialize for a given session with:

```matlab
bidspm()
```

This will add all the required folders to the path.

You can also remove bidspm from the path with:

```matlab
bidspm uninit
```

## BIDS app Command line Interface (CLI)

bidspm comes with a BIDS app CLI.

### Requirements

-   [python3](https://www.python.org/downloads/)
-   pip

If you are using MATLAB, you need to edit the file `src/matlab.py`,
so that it returns the fullpath to the MATLAB executable on your computer.

For this you first need to know where is the MATLAB application.
Here are the typical location depending on your operating system
(where `XXx` corresponds to the version you use).

-   Windows: `C:\Program Files\MATLAB\R20XXx\bin\matlab.exe`
-   Mac: `/Applications/Matlab_R20XXx.app/bin/matlab`
-   Linux: `/usr/local/MATLAB/R20XXx/bin/matlab`

You can then install the bidspm CLI from within the `bidspm` folder with:

```bash
pip install .
```

You can then type the following in your terminal to see which command you have access to:

```bash
bidspm --help
```

### BIDS validation

After installing bidspm python package, you can get access to extra validation options.

#### BIDS stats model validation

Please see [the documentation](https://bidspm.readthedocs.io/en/latest/bids_stats_model.html#using-the-bids-stats-model-python-package)

#### BIDS dataset validation

To run the bids-validator when running bidspm, you
will need:

-   [node.js and npm](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm)
-   the bidspm python CLI (see above)

You can then install:

-   the bids validator

by running from the command line in the root folder of the repository:

```bash
make install
```

or

```bash
npm install -g bids-validator
```

## Octave compatibility

The following features do not yet work with Octave:

- {func}`anatQA`
- slice_display toolbox

Not (yet) tested with Octave:

- MACS toolbox workflow for model selection
- ALI toolbox workflow for model selection

```{toctree}
:maxdepth: 2

containers
hpc
```
