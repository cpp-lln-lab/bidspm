---
title: "Preprocessing: What images are resampled during preprocessing and to what resolution?"
---

In the spatial preprocessing workflow (`bidsSpatialPrepro`)
called by `bidspm(..., 'action', 'preprocess', ...)`:

1. When no normalization is requested

This is the case when `'space', 'individual'`, functional images resolution
is not changed. This cannot be overridden.

2. During normalization to MNI

By default, functional images resolution is not changed. Override possible by
setting `opt.funcVoxelDims` to the desired resolution.

The anatomical images are resampled at 1 mm.

Tissue probability maps downsampled at resolution of functional images mostly to
help with potential with creation of tissue-based mask and also quality control
pipelines.

For several files, you can guess their resolution if they have `res` entity in
their filename:

-   `res-bold` means that the image is resampled at the resolution of the BOLD
    timeseries
-   `res-r1pt0` means that the image is resampled at a resolution of 1.00 mm
    isometric

```bash
  sub-01
  ├── anat
  │   ├── sub-01_space-individual_desc-biascor_T1w.nii                   # native res
  │   ├── sub-01_space-individual_desc-skullstripped_T1w.nii             # native res
  │   ├── sub-01_space-individual_label-brain_mask.nii                   # native res
  │   ├── sub-01_space-individual_label-CSF_probseg.nii
  │   ├── sub-01_space-individual_label-GM_probseg.nii
  │   ├── sub-01_space-individual_label-WM_probseg.nii
  │   ├── sub-01_space-individual_res-r1pt0_desc-preproc_T1w.nii         # 1.0 mm
  │   ├── sub-01_space-IXI549Space_res-bold_label-CSF_probseg.nii        # bold res
  │   ├── sub-01_space-IXI549Space_res-bold_label-GM_probseg.nii         # bold res
  │   ├── sub-01_space-IXI549Space_res-bold_label-WM_probseg.nii         # bold res
  │   └── sub-01_space-IXI549Space_res-r1pt0_T1w.nii                     # 1.0 mm
  └── func
      ├── sub-01_task-auditory_space-individual_desc-mean_bold.nii       # native res
      ├── sub-01_task-auditory_space-individual_desc-preproc_bold.nii    # native res
      ├── sub-01_task-auditory_space-individual_desc-std_bold.nii        # native res
      ├── sub-01_task-auditory_space-IXI549Space_desc-mean_bold.nii      # native res
      └── sub-01_task-auditory_space-IXI549Space_desc-preproc_bold.nii   # native res
```

See those
[slides](https://docs.google.com/presentation/d/1bAAzvXpQ_4vcSO1yqOD3Uq_d70b-uu0h9xoIx0sx3es/edit?usp=sharing)
for some pointers on how to make choices for the resolution to choose for your
analysis.
