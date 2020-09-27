# Usage

<!-- TOC -->

- [Usage](#usage)
  - [Setting up](#setting-up)
    - [getOptions](#getoptions)
      - [spm_my_defaults](#spm_my_defaults)
    - [model JSON files](#model-json-files)
  - [Order of the analysis](#order-of-the-analysis)

<!-- /TOC -->

## Setting up

### getOptions

All the details specific to your analysis should be set in the `getOptions.m`.
There is a getOption_template file that shows you would set up the getOption
file if one wanted to analyse the
[ds001 data set from OpenNeuro](https://openneuro.org/datasets/ds000001/versions/57fecb0ccce88d000ac17538).

Set the group of subjects to analyze.

```
opt.groups = {'control', 'blind'};
```

If there are no groups (i.e subjects names are of the form `sub-01` for example)
or if you want to run all subjects of all groups then use:

```matlab
opt.groups = {''};
opt.subjects = {[]};
```

If you have 2 groups (`cont` and `cat` for example) the following will run
cont01, cont02, cat03, cat04..

```matlab
opt.groups = {'cont', 'cat'};
opt.subjects = {[1 2], [3 4]};
```

If you have more than 2 groups but want to only run the subjects of 2 groups
then you can use.

```matlab
opt.groups = {'cont', 'cat'};
opt.subjects = {[], []};
```

You can also directly specify the subject label for the participants you want to
run

```matlab
opt.groups = {''};
opt.subjects = {'01', 'cont01', 'cat02', 'ctrl02', 'blind01'};
```

Set the task to analyze in the BIDS data set `opt.taskName = 'auditory'`

The directory where your files are located on your computer: make sure you have
a copy of the data set as this pipeline will change it.
`opt.derivativesDir = '/Data/auditoryBIDS/derivatives'`

#### spm_my_defaults

Some more SPM options can be set in the `spm_my_defaults.m`.

-   Use of FAST and not AR1 for auto-correlation modelisation

Using FAST does not seem to affect results on time series with "normal" TRs but
improves results when using sequences: it is therefore used by default in this
pipeline.

> Olszowy, W., Aston, J., Rua, C. et al. Accurate autocorrelation modeling
> substantially improves fMRI reliability. Nat Commun 10, 1220 (2019).
> https://doi.org/10.1038/s41467-019-09230-w

### model JSON files

This files allow you to specify which contrasts to run and follow the BIDS
statistical model extension and as implement by
[fitlins](https://fitlins.readthedocs.io/en/latest/model.html)

The model json file that describes:

-   out to prepare the regressors for the GLM: `Transformation`
-   the design matrix: `X`
-   the contrasts to compute: `contrasts`

It also allows to specify those for different levels of the analysis:

-   run
-   session
-   subject
-   dataset

An example of json file could look something like that.

```json
{
    "Name": "Basic",
    "Description": "",
    "Input": {
        "task": "motionloc"
    },
    "Steps": [
        {
            "Level": "subject",
            "AutoContrasts": ["stim_type.motion", "stim_type.static"],
            "Contrasts": [
                {
                    "Name": "motion_vs_static",
                    "ConditionList": ["stim_type.motion", "stim_type.static"],
                    "weights": [1, -1],
                    "type": "t"
                }
            ]
        },
        {
            "Level": "dataset",
            "AutoContrasts": [
                "stim_type.motion",
                "stim_type.static",
                "motion_vs_static"
            ]
        }
    ]
}
```

In brief this means:

-   at the subject level automatically compute the t contrast against baseline
    for the condition `motion`and `static` and compute the t-contrats for motion
    VS static with these given weights.
-   at the level of the data set (so RFX) do the t contrast of the `motion`,
    `static`, `motion VS static`.

We are currently using this to run different subject level GLM models for our
univariate and multivariate analysis where in the first one we compute a con
image that averages the beta image of all the runs where as in the latter case
we get one con image for each run.

## Order of the analysis

1.  **Remove Dummy Scans**: Unzip bold files and removes dummy scans by running
    the script (to be run even if `opt.numDummies` set to `0`):
    `BIDS_rmDummies.m`

2.  **Slice Time Correction**: Performs Slice Time Correction (STC) of the
    functional volumes by running the script: `BIDS_STC.m`

STC will be performed using the information provided in the BIDS data set. It
will use the mid-volume acquisition time point as as reference.

The `getOption.m` fields related to STC can still be used to do some slice
timing correction even no information is can be found in the BIDS data set.

In general slice order and reference slice is entered in time unit (ms) (this is
the BIDS way of doing things) instead of the slice index of the reference slice
(the "SPM" way of doing things).

More info available on this page of the
[SPM wikibook](https://en.wikibooks.org/wiki/SPM/Slice_Timing).

3.  **Spatial Preprocessing**: Performs spatial preprocessing by running the
    script: `BIDS_SpatialPrepro.m`

4.  **SMOOTHING**: Performs smoothing of the functional data by running the
    script: `BIDS_Smoothing.m`

5.  **FIXED EFFECTS ANALYSIS (FIRST-LEVEL ANALYSIS)**: Performs the fixed
    effects analysis by running the ffx script: `BIDS_FFX.m`

This will run twice, once for model specification and another time for model
estimation. See the function for more details.

This will take each condition present in the `events.tsv` file of each run and
convolve it with a canonical HRF. It will also add the 6 realignment parameters
of every run as confound regressors.

6.  **RANDOM EFFECTS ANALYSIS (SECOND-LEVEL ANALYSIS)**: Performs the random
    effects analysis by running the RFX script: `BIDS_RFX.m`

7.  **GET THE RESULTS FROM A SPECIFIC CONTRAST**: `BIDS_Results.m`

-   See **"batch.m"** for examples and for the order of the scripts.
-   See **"batch_dowload_run.m"** for an example of how to download a data set
    and analyze it all in one go.
