## fMRI statistical analysis

The fMRI data were analysed with bidspm (v2.2.0; https://github.com/cpp-lln-lab/bidspm; DOI: https://doi.org/10.5281/zenodo.3554331)
using statistical parametric mapping
(SPM12 - 7771; Wellcome Center for Neuroimaging, London, UK;
https://www.fil.ion.ucl.ac.uk/spm; RRID:SCR_007037)
using MATLAB 9.4.0.813654 (R2018a)
on a unix computer (Linux version 5.15.0-53-generic (build@lcy02-amd64-047) (gcc (Ubuntu 11.2.0-19ubuntu1) 11.2.0, GNU ld (GNU Binutils for Ubuntu) 2.38) #59-Ubuntu SMP Mon Oct 17 18:53:30 UTC 2022
).

The input data were the preprocessed BOLD images in IXI549Space space for the task " facerepetition ".

### Run / subject level analysis

At the subject level, we performed a mass univariate analysis with a linear
regression at each voxel of the brain, using generalized least squares with a
global  AR(1)  model to account for temporal auto-correlation
 and a drift fit with discrete cosine transform basis ( 128 seconds cut-off).

Image intensity scaling was done run-wide before statistical modeling such that
the mean image would have a mean intracerebral intensity of 100.

We modeled the fMRI experiment in a  event  design with regressors
entered into the run-specific design matrix. The onsets
were convolved with SPM canonical hemodynamic response function (HRF)
 and its temporal and dispersion derivatives for the conditions:
  - `famous_1`,
 - `famous_2`,
 - `unfamiliar_1`,
 - `unfamiliar_2`,
 .

 Nuisance covariates included:

 - `trans_?`,
 - `rot_?`,

to account for residual motion artefacts,
 .



 ## References

This method section was automatically generated using bidspm
(v2.2.0; https://github.com/cpp-lln-lab/bidspm; DOI: https://doi.org/10.5281/zenodo.3554331)
and octache (https://github.com/Remi-Gau/Octache).
