# Outputs of bidspm

## jobs and logs

Each batch is saved in `jobs` folder in time a stamped m-file: those are more
human readable and interoperable than their equivalent `.mat` file, and they can
still be loaded in the SPM batch interface.

It is accompanied by a `.json` file that contains information about the
environment in which the batch was run (operating system, bidspm version...).

```text
bidspm-stats
├── jobs
│   └── taskName
│       ├── sub-01
│       │   ├── batch_batchName_task-taskName_space-space_FWHM-0_YYYY-MM-HHTMM-SS.json
│       │   └── batch_batchName_task_taskName_space_space_FWHM_0_YYYY-MM-HHTMM-SS.m
│       ├── sub-02
```

## preprocessing

<!-- markdown-link-check-disable -->

For a complete list of how SPM outputs are renamed into BIDS derivatives see the
[Mapping](mapping) page.

<!-- markdown-link-check-enable -->

### func

| SPM                                 | BIDS                                                        |
| ----------------------------------- | ----------------------------------------------------------- |
| s6usub-01_task-auditory_bold.nii    | sub-01_task-auditory_space-individual_desc-smth6_bold.nii   |
| s6rsub-01_task-auditory_bold.nii    | sub-01_task-auditory_space-individual_desc-smth6_bold.nii   |
| s6uasub-01_task-auditory_bold.nii   | sub-01_task-auditory_space-individual_desc-smth6_bold.nii   |
| s6rasub-01_task-auditory_bold.nii   | sub-01_task-auditory_space-individual_desc-smth6_bold.nii   |
| s6wusub-01_task-auditory_bold.nii   | sub-01_task-auditory_space-IXI549Space_desc-smth6_bold.nii  |
| s6wrsub-01_task-auditory_bold.nii   | sub-01_task-auditory_space-IXI549Space_desc-smth6_bold.nii  |
| s6wuasub-01_task-auditory_bold.nii  | sub-01_task-auditory_space-IXI549Space_desc-smth6_bold.nii  |
| s6wrasub-01_task-auditory_bold.nii  | sub-01_task-auditory_space-IXI549Space_desc-smth6_bold.nii  |
| s6sub-01_task-auditory_bold.nii     | sub-01_task-auditory_desc-smth6_bold.nii                    |
| rp_sub-01_task-auditory_bold.txt    | sub-01_task-auditory_desc-confounds_regressors.tsv          |
| rp_asub-01_task-auditory_bold.txt   | sub-01_task-auditory_desc-confounds_regressors.tsv          |
| usub-01_task-auditory_bold.nii      | sub-01_task-auditory_space-individual_desc-preproc_bold.nii |
| uasub-01_task-auditory_bold.nii     | sub-01_task-auditory_space-individual_desc-preproc_bold.nii |
| rsub-01_task-auditory_bold.nii      | sub-01_task-auditory_space-individual_desc-preproc_bold.nii |
| rasub-01_task-auditory_bold.nii     | sub-01_task-auditory_space-individual_desc-preproc_bold.nii |
| std_usub-01_task-auditory_bold.nii  | sub-01_task-auditory_space-individual_desc-std_bold.nii     |
| std_uasub-01_task-auditory_bold.nii | sub-01_task-auditory_space-individual_desc-std_bold.nii     |

### anat

```{note}
Not listed:

- some of the outputs of the segmentation done by the ALI toolbox for
lesion detection
```

| SPM                                                          | BIDS                                                    |
| ------------------------------------------------------------ | ------------------------------------------------------- |
| wc1sub-01_T1w.nii                                            | sub-01_space-IXI549Space_res-bold_label-GM_probseg.nii  |
| wc2sub-01_T1w.nii                                            | sub-01_space-IXI549Space_res-bold_label-WM_probseg.nii  |
| wc3sub-01_T1w.nii                                            | sub-01_space-IXI549Space_res-bold_label-CSF_probseg.nii |
| rc1sub-01_T1w.nii                                            | sub-01_space-individual_res-bold_label-GM_probseg.nii   |
| rc2sub-01_T1w.nii                                            | sub-01_space-individual_res-bold_label-WM_probseg.nii   |
| rc3sub-01_T1w.nii                                            | sub-01_space-individual_res-bold_label-CSF_probseg.nii  |
| wmsub-01_T1w.nii                                             | sub-01_space-IXI549Space_res-r1pt0_T1w.nii              |
| wmsub-01_desc-skullstripped_T1w.nii                          | sub-01_space-IXI549Space_res-r1pt0_desc-preproc_T1w.nii |
| msub-01_desc-skullstripped_T1w.nii                           | sub-01_space-individual_desc-preproc_T1w.nii            |
| wsub-01_desc-skullstripped_T1w.nii                           | sub-01_space-individual_res-r1pt0_desc-preproc_T1w.nii  |
| msub-01_space-individual_desc-something_label-brain_mask.nii | sub-01_space-individual_label-brain_mask.nii            |
| c1sub-01_T1w.surf.gii                                        | sub-01_desc-pialsurf_T1w.gii                            |

## Statistics

At the subject level each folder contains for each run modeled:

-   a pair of `*_onsets.mat` / `*_onsets.tsv`

The `*_onsets.mat` file contains the `names`, `onsets`, `durations`, `pmod`
required by SPM to build the "multi condition" section of the model
specification. The `*_onsets.tsv` is a human readable equivalent organised like
BIDS `events.tsv` files.

-   a pair of `*_desc-confounds_regressors.mat` /
    `*_desc-confounds_regressors.tsv`

The `*_desc-confounds_regressors.mat` file contains the `names`, `R` required by
SPM to build the "multi regressor" section of the model specification. The
`*_desc-confounds_regressors.tsv` is a human readable equivalent organised like
BIDS derivatives `timeseries.tsv` files.

```text
bidspm-stats
├── sub-01
│   └── task-taskName_space-space_FWHM-0_node-nodeName
│       |
│       ├── beta_0001.nii  ----------
│       ├── beta_*.nii              |
│       ├── con_0001.nii            |
│       ├── con_*.nii               |
│       ├── mask.nii                | Regular SPM output
│       ├── ResMS.nii               |
│       ├── RPV.nii                 |
│       ├── SPM.mat                 |
│       ├── spmT_0001.nii           |
│       ├── spmT_*.nii     ----------
│       |
│       ├── sub-blnd01_task-taskName_space-space_desc-contrastName_label-0039_p-0pt050_k-10_MC-FWE_montage.png
│       |
│       ├── sub-blnd01_task-taskName_space-space_desc-afterEstimation_designmatrix.png
│       ├── sub-blnd01_task-taskName_space-space_desc-beforeEstimation_designmatrix.png
│       |
│       ├── sub-blnd01_task-taskName_run-01_desc-confounds_regressors.mat ------
│       ├── sub-blnd01_task-taskName_run-01_desc-confounds_regressors.tsv      |
│       ├── sub-blnd01_task-taskName_run-01_onsets.mat                         |
│       ├── sub-blnd01_task-taskName_run-01_onsets.tsv                         | Files used for model specification
│       ├── sub-blnd01_task-taskName_run-*_desc-confounds_regressors.mat       |
│       ├── sub-blnd01_task-taskName_run-*_desc-confounds_regressors.tsv       |
│       ├── sub-blnd01_task-taskName_run-*_onsets.mat                          |
│       └── sub-blnd01_task-taskName_run-*_onsets.tsv --------------------------
...
```
