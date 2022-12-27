---
title:
    "BIDS: What is a BIDS way to name and store Regions of Interest (ROIs)?"
---

There is no "official" way to name ROI in BIDS, but you can apply BIDS naming
principles to name those.

The closest things to ROI naming are the `masks` for the
[BIDS derivatives](https://bids-specification.readthedocs.io/en/latest/05-derivatives/03-imaging.html#masks).

Here is an example from the :ref:`face repetition demo`::

```text
  bidspm-roi
  ├── group
  │   ├── hemi-L_space-MNI_label-V1d_desc-wang_mask.json
  │   ├── hemi-L_space-MNI_label-V1d_desc-wang_mask.nii
  │   ├── hemi-L_space-MNI_label-V1v_desc-wang_mask.json
  │   ├── hemi-L_space-MNI_label-V1v_desc-wang_mask.nii
  │   ├── hemi-R_space-MNI_label-V1d_desc-wang_mask.json
  │   ├── hemi-R_space-MNI_label-V1d_desc-wang_mask.nii
  │   ├── hemi-R_space-MNI_label-V1v_desc-wang_mask.json
  │   └── hemi-R_space-MNI_label-V1v_desc-wang_mask.nii
  └── sub-01
      └── roi
          ├── sub-01_hemi-L_space-individual_label-V1d_desc-wang_mask.nii
          ├── sub-01_hemi-L_space-individual_label-V1v_desc-wang_mask.nii
          ├── sub-01_hemi-R_space-individual_label-V1d_desc-wang_mask.nii
          └── sub-01_hemi-R_space-individual_label-V1v_desc-wang_mask.nii
```

ROIs that are defined in some MNI space are going to be the same across
subjects, so you could store a "group" folder (this is not BIDSy but is less
redundant than having a copy of the same file for each subject).

The `desc` entity (description) here is used to denotate the atlas the ROI taken
from, so if you are building yours from a localizer you might not need to use
it.

Ideally you would want to add a JSON file to add metadata about those ROIs.

You can use bids-matlab to help you create BIDS valid filenames.

```matlab
  >> name_spec.ext = '.nii';
  >> name_spec.suffix = 'mask';
  >> name_spec.entities = struct( ...
                                'hemi', 'R', ...
                                'space', 'MNI', ...
                                'label', 'V1v', ...
                                'desc', 'wang');
  >> file = bids.File(name_spec);
  >> file.filename

     hemi-R_space-MNI_label-V1v_desc-wang_mask.nii
```
