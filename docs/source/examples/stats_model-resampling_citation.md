## fMRI statistical analysis

The fMRI data were analysed with bidspm (v4.0.; https://github.com/cpp-lln-lab/bidspm; DOI: https://doi.org/10.5281/zenodo.3554331 - [@bidspm])
using statistical parametric mapping
(SPM12 - 7771; Wellcome Center for Neuroimaging, London, UK;
https://www.fil.ion.ucl.ac.uk/spm; RRID:SCR_007037)
using MATLAB 9.4.0.813654 (R2018a)
on a unix computer (Linux version 6.8.0-40-generic (buildd@lcy02-amd64-078) (x86_64-linux-gnu-gcc-12 (Ubuntu 12.3.0-1ubuntu1~22.04) 12.3.0, GNU ld (GNU Binutils for Ubuntu) 2.38) #40~22.04.3-Ubuntu SMP PREEMPT_DYNAMIC Tue Jul 30 17:30:19 UTC 2
)

The input data were the preprocessed BOLD images in IXI549Space space for the task " facerepetition ".

### Run / subject level analysis

At the subject level, we performed a mass univariate analysis with a linear
regression at each voxel of the brain, using generalized least squares with a
global  AR(1)  model to account for temporal auto-correlation
 and a drift fit with discrete cosine transform basis ( 128 seconds cut-off).

 Image intensity scaling was done run-wide before statistical modeling such that the mean image would have a mean intracerebral intensity of 100.
We modeled the fMRI experiment in a  event  design with regressors
entered into the run-specific design matrix. The onsets
were convolved with SPM canonical hemodynamic response function (HRF)
 and its temporal and dispersion derivatives for the conditions:
  - `famous_first_show`,
 - `famous_delayed_repeat`,
 - `unfamiliar_first_show`,
 - `unfamiliar_delayed_repeat`,
 .

 Nuisance covariates included:

 - `trans_?`,
 - `rot_?`,

to account for residual motion artefacts,
 .



 ## References

This method section was automatically generated using bidspm
(v4.0.; https://github.com/cpp-lln-lab/bidspm; DOI: https://doi.org/10.5281/zenodo.3554331)
and octache (https://github.com/Remi-Gau/Octache).
