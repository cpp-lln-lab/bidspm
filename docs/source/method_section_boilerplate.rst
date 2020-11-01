Boilerplate methods section
***************************

Preprocessing
=============

The fMRI data were pre-processed and analyzed using statistical parametric
mapping (SPM12 – v7487; Wellcome Center for Neuroimaging, London, UK;
www.fil.ion.ucl.ac.uk/spm) running on {octave 4.{??} / matlab 20{XX}
(Mathworks)}.

The preprocessing of the functional images was performed in the following order:
removing of dummy scans, {slice timing correction}, realignment, normalization
to MNI, smoothing.

{XX} dummy scans were removed to allow signal stabilization.

{Slice timing correction was then performed taking the {XX} th slice as a
reference (interpolation: sinc interpolation).}

Functional scans from each participant were realigned using the mean image as a
reference (SPM 2 passes ; number of degrees of freedom: 6 ; cost function: least
square) (Friston et al, 1995).

The mean image obtained from realignement was then co-registered to the
anatomical T1 image (number of degrees of freedom: 6 ; cost function: normalized
mutual information) (Friston et al, 1995). The transformation matrix from this
coregistration was then applied to all the functional images.

The anatomical T1 image was bias field corrected, segmented and normalized to
MNI space (target space resolution: 1 mm ; interpolation: 4th degree b-spline)
using a unified segmentation. The deformation field obtained from this step was
then applied to all the functional images (target space resolution equal that
used at acquisition ; interpolation: 4th degree b-spline)

Functional MNI normalized images were then spatially smoothed using a 3D
gaussian kernel (FWHM = {XX} mm).

fMRI data analysis
==================

At the subject level, we performed a mass univariate analysis with a linear
regression at each voxel of the brain, using generalized least squares with a
global FAST model to account for temporal auto-correlation (Corbin et al, 2018)
and a drift fit with discrete cosine transform basis (128 seconds cut-off).
Image intensity scaling was done run-wide before statistical modeling such that
the mean image will have mean intracerebral intensity of 100.

We modeled the fMRI experiment in an event related design with regressors
entered into the run-specific design matrix after convolving the onsets of each
event with a canonical hemodynamic response function (HRF).

.. todo:
    Table of conditions with duration of each event

Nuisance covariates included the 6 realignment parameters to account for
residual motion artefacts.

Contrast images were computed for the following condition and spatially smoothed
using a 3D gaussian kernel (FWHM = {XX} mm).

.. todo:
    Table of constrast with weight

Group level
===========

WIP

References
==========

Friston KJ, Ashburner J, Frith CD, Poline J-B, Heather JD & Frackowiak RSJ
(1995) Spatial registration and normalization of images Hum. Brain Map.
2:165-189

Corbin, N., Todd, N., Friston, K. J. & Callaghan, M. F. Accurate modeling of
temporal correlations in rapidly sampled fMRI time series. Hum. Brain Mapp. 39,
3884–3897 (2018).


---

Use the report function to get a print out of the content of a dataset.

.. automodule:: src.reports 

.. autofunction:: reportBIDS
.. autofunction:: copyGraphWindownOutput