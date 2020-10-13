# General description

This set of function will read and unzip the data from a
[BIDS data set](https://bids.neuroimaging.io/). It will then perform:

-   slice timing correction,
-   spatial preprocessing (realignment, normalization to MNI space),
-   smoothing,
-   GLM at the subject level and
-   GLM at the group level a la SPM (i.e summary statistics approach).

This has to be run for each task independently. All parameters should preferably
be changed in the `getOptions.m` file.

It can also prepare the data to run an MVPA analysis by running a GLM for each
subject on non-normalized images and get one beta image for each condition to be
used in the MVPA.

The core functions are in the sub-function folder `subfun`

## Assumption

At the moment this pipeline makes some assumptions:

-   it assumes that the dummy scans have been removed from the BIDS data set and
    it can jump straight into pre-processing,
-   it assumes the metadata for a given task are the same as those the first run
    of the first subject this pipeline is being run on,
-   it assumes that group are defined in the subject field (eg `sub-ctrl01`,
    `sub-blind01`, ...) and not in the `participants.tsv` file.


