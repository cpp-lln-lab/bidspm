
# Instructions for SPM12 Preprocessing Pipeline

## Dependencies:

Make sure that the following toolboxes are installed and added to the matlab path.

For instructions see the following links:

|                                                                                                                                          | Dependencies | Used version |
|------------------------------------------------------------------------------------------------------------------------------------------|--------------|--------------|
| [Matlab](https://www.mathworks.com/products/matlab.html)                                                                                 | 2018a(???)   |              |
| [SPM12](https://www.fil.ion.ucl.ac.uk/spm/software/spm12/)                                                                               | v7487        |              |
| [Tools for NIfTI and ANALYZE image toolbox](https://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image) | NA           |              |

## General description
This set of function will read and unzip the data from a BIDS data set. It will then perform slice timing correction, preprocessing, smoothing, GLM at the first level and then GLM at the group level a la SPM (i.e summary statistics approach).

This has to be run for each task independently. All parameters should preferably be changed in the `getOptions.m` file.

## Assumption
At the moment This pipeline makes some assumptions:
 - it assumes the metadata for a given task are the same as those the first run of the first subject this pipeline is being run on.


## Setting up
All the details specific to your analysis should be set in the `getOptions.m`.

Set the group of subjects to analyze.
```
opt.groups = {'control', 'blind'};
```

If there are no groups (i.e subjects names are of the form `sub-01` for example), then use:
```
opt.groups = {''};
```

Subjects to run in each group. If you have 2 groups the  following will run the first and second subjects of the first group and the third and fourth of the second group.
```
opt.subjects = {[1 2], [3 4]};
```

Set the task to analyze in the BIDS data set
`opt.taskName = 'auditory'`

The directory where your files are located on your computer: make sure you have a copy of the data set as this pipeline will change it.
`opt.derivativesDir = '/Data/auditoryBIDS/derivatives'`


## Order of the analysis:

1. __Remove Dummy Scans__:
Removes dummy scans by running the script:
`BIDS_rmDummies.m`

2. __Slice Time Correction__: Performs Slice Time Correction of the functional volumes by running the script:
`BIDS_STC.m`

3. __Spatial Preprocessing__:
Performs spatial preprocessing by running the script:
`BIDS_SpatialPrepro.m`

4. __SMOOTHING__:
Performs smoothing of the functional data by running the script:
`BIDS_Smoothing.m`

5. __FIXED EFFECTS ANALYSIS (FIRST-LEVEL ANALYSIS)__:
Performs the fixed effects analysis by running the ffx script:
`BIDS_FFX.m`

This will run twice, once for model specification and another time for model estimation. See the function for more details.

6. __RANDOM EFFECTS ANALYSIS (SECOND-LEVEL ANALYSIS)__:
Performs the random effects analysis by running the RFX script:
`BIDS_RFX.m`

- See __"batch.m"__ for examples and for the order of the scripts.

- See __"batch_dowload_run.m"__ for an example of how to download a data set and analyze all in one go.

## Details about some steps

### Slice timing correction

BELOW: some comments from http://mindhive.mit.edu/node/109 on STC, when it should be applied

_At what point in the processing stream should you use it?_

_This is the great open question about slice timing, and it's not super-answerable. Both SPM and AFNI recommend you do it before doing realignment/motion correction, but it's not entirely clear why. The issue is this:_

_If you do slice timing correction before realignment, you might look down your non-realigned time course for a given voxel on the border of gray matter and CSF, say, and see one TR where the head moved and the voxel sampled from CSF instead of gray. This would results in an interpolation error for that voxel, as it would attempt to interpolate part of that big giant signal into the previous voxel. On the other hand, if you do realignment before slice timing correction, you might shift a voxel or a set of voxels onto a different slice, and then you'd apply the wrong amount of slice timing correction to them when you corrected - you'd be shifting the signal as if it had come from slice 20, say, when it actually came from slice 19, and shouldn't be shifted as much._

_There's no way to avoid all the error (short of doing a four-dimensional realignment process combining spatial and temporal correction - [Remi's note: fMRIprep does it]]), but I believe the current thinking is that doing slice timing first minimizes your possible error. The set of voxels subject to such an interpolation error is small, and the interpolation into another TR will also be small and will only affect a few TRs in the time course. By contrast, if one realigns first, many voxels in a slice could be affected at once, and their whole time courses will be affected. I think that's why it makes sense to do slice timing first. That said, here's some articles from the SPM e-mail list that comment helpfully on this subject both ways, and there are even more if you do a search for "slice timing AND before" in the archives of the list._


## Boiler plate methods section

Work in progress...


The fMRI data were pre-processed and analyzed using statistical parametric mapping (SPM12 – [v7487]; Wellcome Center for Neuroimaging, London, UK; www.fil.ion.ucl.ac.uk/spm) running on matlab 20[XX] (Mathworks).

The preprocessing of the functional images was performed in the following order: removing of dummy scans, [slice timing correction], realignment, normalization to MNI, smoothing.

Slice timing correction was then performed taking the [XXXX] th slice as a reference (interpolation: sinc interpolation).

Functional scans from each participant were realigned using the first scan as a reference.

Normalization
(interpolation: 4th degree b-spline).

At the first level, we performed a mass univariate analysis with a linear regression at each voxel, using generalized least squares with a global approximate AR(1) autocorrelation model and a drift fit with discrete cosine transform basis ([XXXX] seconds cut-off).

We modeled the fMRI experiment in an event related design with regressors entered into the run-specific design matrix after convolving the onsets of each event with a canonical hemodynamic response function (HRF).
