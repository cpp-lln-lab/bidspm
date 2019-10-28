[![Build Status](https://travis-ci.com/cpp-lln-lab/CPP_BIDS_SPM_pipeline.svg?branch=master)](https://travis-ci.com/cpp-lln-lab/CPP_BIDS_SPM_pipeline)
[![All Contributors](https://img.shields.io/badge/all_contributors-5-orange.svg?style=flat-square)](#contributors)

# Instructions for SPM12 Preprocessing Pipeline

<!-- TOC -->

-   [Instructions for SPM12 Preprocessing Pipeline](#instructions-for-spm12-preprocessing-pipeline)
  - [Dependencies](#dependencies)
  - [General description](#general-description)
  - [Assumption](#assumption)
  - [Setting up](#setting-up)
  - [Order of the analysis](#order-of-the-analysis)
  - [Docker](#docker)
    - [build docker image](#build-docker-image)
    - [run docker image](#run-docker-image)
  - [Details about some steps](#details-about-some-steps)
    - [Slice timing correction](#slice-timing-correction)
  - [Boiler plate methods section](#boiler-plate-methods-section)
    - [Preprocessing](#preprocessing)
    - [fMRI data analysis](#fmri-data-analysis)
    - [References](#references)
  - [Testing](#testing)

<!-- /TOC -->

## Dependencies

Make sure that the following toolboxes are installed and added to the matlab path.

For instructions see the following links:

| Dependencies                                                                              | Used version |
|-------------------------------------------------------------------------------------------|--------------|
| [Matlab](https://www.mathworks.com/products/matlab.html)                                  | 20???        |
| [SPM12](https://www.fil.ion.ucl.ac.uk/spm/software/spm12/)                                | v7487        |
| [Tools for NIfTI and ANALYZE image toolbox](https://github.com/sergivalverde/nifti_tools) | NA           |

For simplicity the NIfTI tools toolbox has been added to this repo in the `subfun` folder.

## General description

This set of function will read and unzip the data from a [BIDS data set](https://bids.neuroimaging.io/). It will then perform:
-   slice timing correction,
-   spatial preprocessing (realignment, normalization to MNI space),
-   smoothing,
-   GLM at the subject level and
-   GLM at the group level a la SPM (i.e summary statistics approach).

This has to be run for each task independently. All parameters should preferably be changed in the `getOptions.m` file.

The core functions are in the sub-function folder `subfun`

## Assumption

At the moment this pipeline makes some assumptions:
-   it assumes that the dummy scans have been removed from the BIDS data set and it can jump straight into pre-processing,
-   it assumes the metadata for a given task are the same as those the first run of the first subject this pipeline is being run on,
-   it assumes that group are defined in the subject field (eg `sub-ctrl01`, `sub-blind01`, ...) and not in the `participants.tsv` file.

## Setting up

All the details specific to your analysis should be set in the `getOptions.m`.

Set the group of subjects to analyze.
```
opt.groups = {'control', 'blind'};
```

If there are no groups (i.e subjects names are of the form `sub-01` for example) or if you want to run all subjects of all groups then use:
```matlab
opt.groups = {''};
opt.subjects = {[]};
```

If you have 2 groups (`cont` and `cat` for example) the following will run cont01, cont02, cat03, cat04..
```matlab
opt.groups = {'cont', 'cat'};
opt.subjects = {[1 2], [3 4]};
```
If you have more than 2 groups but want to only run the subjects of 2 groups then you can use.
```matlab
opt.groups = {'cont', 'cat'};
opt.subjects = {[], []};
```
You can also directly specify the subject label for the participants you want to run
```matlab
opt.groups = {''};
opt.subjects = {'01', 'cont01', 'cat02', 'ctrl02', 'blind01'};
```

Set the task to analyze in the BIDS data set
`opt.taskName = 'auditory'`

The directory where your files are located on your computer: make sure you have a copy of the data set as this pipeline will change it.
`opt.derivativesDir = '/Data/auditoryBIDS/derivatives'`

Some more SPM options can be set in the `spm_my_defaults.m`.

## Order of the analysis

1.  __Remove Dummy Scans__:
Unzip bold files and removes dummy scans by running the script (to be run even if `opt.numDummies` set to `0`):
`BIDS_rmDummies.m`

2.  __Slice Time Correction__: Performs Slice Time Correction (STC) of the functional volumes by running the script:
`BIDS_STC.m`
STC will be performed using the information provided in the BIDS data set. It will use the mid-volume acquisition time point as as reference.
The `getOption.m` fields related to STC can still be used to do some slice timing correction even no information is can be found in the BIDS data set.
In general slice order and reference slice is entered in time unit (ms) (this is the BIDS way of doing things) instead of the slice index of the reference slice (the "SPM" way of doing things).
More info available on this page of the [SPM wikibook](https://en.wikibooks.org/wiki/SPM/Slice_Timing).

3.  __Spatial Preprocessing__:
Performs spatial preprocessing by running the script:
`BIDS_SpatialPrepro.m`

4.  __SMOOTHING__:
Performs smoothing of the functional data by running the script:
`BIDS_Smoothing.m`

5.  __FIXED EFFECTS ANALYSIS (FIRST-LEVEL ANALYSIS)__:
Performs the fixed effects analysis by running the ffx script:
`BIDS_FFX.m`

This will run twice, once for model specification and another time for model estimation. See the function for more details.

This will take each condition present in the `events.tsv` file of each run and convolve it with a canonical HRF. It will also add the 6 realignment parameters of every run as confound regressors.

6.  __RANDOM EFFECTS ANALYSIS (SECOND-LEVEL ANALYSIS)__:
Performs the random effects analysis by running the RFX script:
`BIDS_RFX.m`

-   See __"batch.m"__ for examples and for the order of the scripts.
-   See __"batch_dowload_run.m"__ for an example of how to download a data set and analyze it all in one go.

## Docker

The recipe to build the docker image is in the `Dockerfile`

### build docker image

To build the image with with octave and SPM the `Dockerfile` just type :

`docker build  -t cpp_spm:0.0.1 .`

This will create an image with the tag name `cpp_spm_octave:0.0.1`

### run docker image

The following code would start the docker image and would map 2 folders one for `output` and one for `code` you want to run.

``` bash
docker run -it --rm \
-v [output_folder]:/output \
-v [code_folder]:/code cpp_spm:0.0.1
```

To test it you can copy the `batch_download_run.m` file in the `code` folder on your computer and then start running the docker and type:

```bash
cd /code # to change to the code folder inside the container (running the command 'ls' should show only batch_download_run.m )
octave --no-gui --eval batch_download_run # to run the batch_download_run script
```

### MRIQC

If you want to run some quality control on your data you can do it using MRIQC.

```bash
data_dir=pat_to_data # define where the data is

docker run -it --rm -v $data_dir/raw:/data:ro -v $data_dir:/out poldracklab/mriqc:0.15.0 /data /out/derivatives/mriqc participant --verbose-reports --mem_gb 50 --n_procs 16 -m bold
```

## Details about some steps

### Slice timing correction

BELOW: some comments from [here](http://mindhive.mit.edu/node/109) on STC, when it should be applied

_At what point in the processing stream should you use it?_

_This is the great open question about slice timing, and it's not super-answerable. Both SPM and AFNI recommend you do it before doing realignment/motion correction, but it's not entirely clear why. The issue is this:_

_If you do slice timing correction before realignment, you might look down your non-realigned time course for a given voxel on the border of gray matter and CSF, say, and see one TR where the head moved and the voxel sampled from CSF instead of gray. This would results in an interpolation error for that voxel, as it would attempt to interpolate part of that big giant signal into the previous voxel. On the other hand, if you do realignment before slice timing correction, you might shift a voxel or a set of voxels onto a different slice, and then you'd apply the wrong amount of slice timing correction to them when you corrected - you'd be shifting the signal as if it had come from slice 20, say, when it actually came from slice 19, and shouldn't be shifted as much._

_There's no way to avoid all the error (short of doing a four-dimensional realignment process combining spatial and temporal correction - Remi's note: fMRIprep does it), but I believe the current thinking is that doing slice timing first minimizes your possible error. The set of voxels subject to such an interpolation error is small, and the interpolation into another TR will also be small and will only affect a few TRs in the time course. By contrast, if one realigns first, many voxels in a slice could be affected at once, and their whole time courses will be affected. I think that's why it makes sense to do slice timing first. That said, here's some articles from the SPM e-mail list that comment helpfully on this subject both ways, and there are even more if you do a search for "slice timing AND before" in the archives of the list._

## Boiler plate methods section

### Preprocessing

The fMRI data were pre-processed and analyzed using statistical parametric mapping (SPM12 – v7487; Wellcome Center for Neuroimaging, London, UK; www.fil.ion.ucl.ac.uk/spm) running on {octave 4.{??} / matlab 20{XX} (Mathworks)}.

The preprocessing of the functional images was performed in the following order: removing of dummy scans, {slice timing correction}, realignment, normalization to MNI, smoothing.

{XX} dummy scans were removed to allow signal stabilization.

{Slice timing correction was then performed taking the {XX} th slice as a reference (interpolation: sinc interpolation).}

Functional scans from each participant were realigned using the mean image as a reference (SPM 2 passes ; number of degrees of freedom: 6 ; cost function: least square) (Friston et al, 1995).

The mean image obtained from realignement was then co-registered to the anatomical T1 image (number of degrees of freedom: 6 ; cost function: normalized mutual information) (Friston et al, 1995). The transformation matrix from this coregistration was then applied to all the functional images.

The anatomical T1 image was bias field corrected, segmented and normalized to MNI space (target space resolution: 1 mm ; interpolation: 4th degree b-spline) using a unified segmentation. The deformation field obtained from this step was then applied to all the functional images (target space resolution equal that used at acquisition ; interpolation: 4th degree b-spline)

Functional MNI normalized images were then spatially smoothed using a 3D gaussian kernel (FWHM = {XX} mm).

### fMRI data analysis

At the subject level, we performed a mass univariate analysis with a linear regression at each voxel of the brain, using generalized least squares with a global FAST model to account for temporal auto-correlation (Corbin et al, 2018) and a drift fit with discrete cosine transform basis (128 seconds cut-off). Image intensity scaling was done run-wide before statistical modeling such that the mean image will have mean intracerebral intensity of 100.

We modeled the fMRI experiment in an event related design with regressors entered into the run-specific design matrix after convolving the onsets of each event with a canonical hemodynamic response function (HRF).

Table of conditions with duration of each event: WIP

Nuisance covariates included the 6 realignment parameters to account for residual motion artefacts.

Contrast images were computed for the following condition and spatially smoothed using a 3D gaussian kernel (FWHM = {XX} mm).

Table of constrast with weight: WIP

Group level: WIP

### References

Friston KJ, Ashburner J, Frith CD, Poline J-B, Heather JD & Frackowiak RSJ (1995) Spatial registration and normalization of images Hum. Brain Map. 2:165-189

Corbin, N., Todd, N., Friston, K. J. & Callaghan, M. F. Accurate modeling of temporal correlations in rapidly sampled fMRI time series. Hum. Brain Mapp. 39, 3884–3897 (2018).


## Testing

All tests are in the test folder. There is also an empty dummy BIDS dataset that is partly created using the bash script `createDummyDataSet.sh`.

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore -->
<table>
  <tr>
    <td align="center"><a href="https://cpplab.be"><img src="https://avatars0.githubusercontent.com/u/55407947?v=4" width="100px;" alt="OliColli"/><br /><sub><b>OliColli</b></sub></a><br /><a href="https://github.com/cpp-lln-lab/CPP_BIDS_SPM_pipeline/commits?author=OliColli" title="Code">💻</a> <a href="#design-OliColli" title="Design">🎨</a> <a href="https://github.com/cpp-lln-lab/CPP_BIDS_SPM_pipeline/commits?author=OliColli" title="Documentation">📖</a></td>
    <td align="center"><a href="https://github.com/anege"><img src="https://avatars0.githubusercontent.com/u/50317099?v=4" width="100px;" alt="anege"/><br /><sub><b>anege</b></sub></a><br /><a href="https://github.com/cpp-lln-lab/CPP_BIDS_SPM_pipeline/commits?author=anege" title="Code">💻</a> <a href="#design-anege" title="Design">🎨</a></td>
    <td align="center"><a href="https://github.com/mohmdrezk"><img src="https://avatars2.githubusercontent.com/u/9597815?v=4" width="100px;" alt="Mohamed Rezk"/><br /><sub><b>Mohamed Rezk</b></sub></a><br /><a href="https://github.com/cpp-lln-lab/CPP_BIDS_SPM_pipeline/commits?author=mohmdrezk" title="Code">💻</a> <a href="#review-mohmdrezk" title="Reviewed Pull Requests">👀</a> <a href="#design-mohmdrezk" title="Design">🎨</a></td>
    <td align="center"><a href="https://github.com/marcobarilari"><img src="https://avatars3.githubusercontent.com/u/38101692?v=4" width="100px;" alt="marcobarilari"/><br /><sub><b>marcobarilari</b></sub></a><br /><a href="https://github.com/cpp-lln-lab/CPP_BIDS_SPM_pipeline/commits?author=marcobarilari" title="Code">💻</a> <a href="#design-marcobarilari" title="Design">🎨</a> <a href="#review-marcobarilari" title="Reviewed Pull Requests">👀</a> <a href="https://github.com/cpp-lln-lab/CPP_BIDS_SPM_pipeline/commits?author=marcobarilari" title="Documentation">📖</a></td>
    <td align="center"><a href="https://remi-gau.github.io/"><img src="https://avatars3.githubusercontent.com/u/6961185?v=4" width="100px;" alt="Remi Gau"/><br /><sub><b>Remi Gau</b></sub></a><br /><a href="https://github.com/cpp-lln-lab/CPP_BIDS_SPM_pipeline/commits?author=Remi-Gau" title="Code">💻</a> <a href="https://github.com/cpp-lln-lab/CPP_BIDS_SPM_pipeline/commits?author=Remi-Gau" title="Documentation">📖</a> <a href="#infra-Remi-Gau" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="#design-Remi-Gau" title="Design">🎨</a> <a href="#review-mohmdrezk" title="Reviewed Pull Requests">👀</a></td>
  </tr>
</table>

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
