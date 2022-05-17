The fMRI data were pre-processed with CPP SPM (v1.1.5dev;
https://github.com/cpp-lln-lab/CPP_SPM; DOI:
https://doi.org/10.5281/zenodo.3554331) using statistical parametric mapping
(SPM12 - 7771; Wellcome Center for Neuroimaging, London, UK;
www.fil.ion.ucl.ac.uk/spm; RRID:SCR_007037) using MATLAB 9.2.0.538062 (R2017a)
on a unix computer (Ubuntu 18.04.6 LTS).

The preprocessing of the functional images was performed in the following order:

-   removing of dummy scans
-   slice timing correction
-   realignment and unwarping
-   segmentation and skullstripping
-   normalization MNI space
-   smoothing

4 dummy scans were removed to allow signal stabilization.

Slice timing correction was performed taking the 16^th slice as a reference
(interpolation: sinc interpolation).

Functional scans from each participant were realigned and unwarped using the
mean image as a reference (SPM single pass; number of degrees of freedom: 6 ;
cost function: least square) (Friston et al, 1995).

The anatomical image was bias field corrected. The bias field corrected image
was segmented and normalized to MNI space (target space: IXI549Space; target
resolution: 1 mm; interpolation: 4th degree b-spline) using a unified
segmentation.

The tissue propability maps generated by the segmentation were used to
skullstripp the bias corrected image removing any voxel with p(gray matter) +
p(white matter) + p(CSF) > 0.75.

The mean functional image obtained from realignement was co-registered to the
bias corrected anatomical image (number of degrees of freedom: 6 ; cost
function: normalized mutual information) (Friston et al, 1995). The
transformation matrix from this coregistration was applied to all the functional
images.

The deformation field obtained from the segmentation was applied to all the
functional images (target space: IXI549Space; target resolution: equal to that
used at acquisition; interpolation: 4th degree b-spline).

Preprocessed functional images were spatially smoothed using a 3D gaussian
kernel (FWHM = 6 mm).

This method section was automatically generated using CPP SPM (v1.1.5dev;
https://github.com/cpp-lln-lab/CPP_SPM; DOI:
https://doi.org/10.5281/zenodo.3554331) and octache
(https://github.com/Remi-Gau/Octache).