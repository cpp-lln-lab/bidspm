The fMRI data were analysed with CPP SPM (v1.1.5dev;
https://github.com/cpp-lln-lab/CPP_SPM; DOI:
https://doi.org/10.5281/zenodo.3554331) using statistical parametric mapping
(SPM12 - 7771; Wellcome Center for Neuroimaging, London, UK;
www.fil.ion.ucl.ac.uk/spm; RRID:SCR_007037) using MATLAB 9.2.0.538062 (R2017a)
on a unix computer (Ubuntu 18.04.6 LTS).

The input data were the preprocessed BOLD images in individual IXI549Space space
for the task "facerepetition".

At the subject level, we performed a mass univariate analysis with a linear
regression at each voxel of the brain, using generalized least squares with a
global AR(1) model to account for temporal auto-correlation and a drift fit with
discrete cosine transform basis (128.2051 seconds cut-off).

Image intensity scaling was done run-wide before statistical modeling such that
the mean image would have a mean intracerebral intensity of 100.

We modeled the fMRI experiment in a block design with regressors entered into
the run-specific design matrix. The the onsets  
were convolved with a canonical hemodynamic response function (HRF) and its
temporal and dispersion derivatives for the conditions: famous_1, famous_2,
unfamiliar_1, unfamiliar_2.

Nuisance covariates included the 6 realignment parameters to account for
residual motion artefacts.

This method section was automatically generated using CPP SPM (v1.1.5dev;
https://github.com/cpp-lln-lab/CPP_SPM; DOI:
https://doi.org/10.5281/zenodo.3554331) and octache
(https://github.com/Remi-Gau/Octache).
