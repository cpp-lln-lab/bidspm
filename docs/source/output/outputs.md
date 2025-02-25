# Outputs

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
│       ├── sub-blnd01_task-taskName_space-space_label-0039_desc-contrastName_p-0pt050_k-10_MC-FWE_montage.png
│       |
│       ├── sub-blnd01_task-taskName_space-space_label-0001_desc-afterEstimation_designmatrix.png
│       ├── sub-blnd01_task-taskName_space-space_label-0002_desc-beforeEstimation_designmatrix.png
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


```
outputs/derivatives/bidspm-stats
├── CHANGES
├── dataset_description.json
├── derivatives
│   └── bidspm-groupStats
│       ├── CHANGES
│       ├── dataset_description.json
│       ├── jobs
│       │   └── <taskLabel>
│       │       └── group
│       │           ├── batch_contrasts_rfx_2023-05-06T12-49.json
│       │           ├── batch_contrasts_rfx_2023_05_06T12_49.m
│       │           ├── batch_group_level_model_specification_estimation_2023-05-06T12-49.json
│       │           └── batch_group_level_model_specification_estimation_2023_05_06T12_49.m
│       ├── LICENSE
│       ├── README.md
│       ├── sub-ALL_task-<taskLabel>_space-<spaceLabel>_FWHM-6_conFWHM-0_node-dataset_contrast-<taskLabel>
│       │   ├── beta_0001.nii
│       │   ├── con_0001.nii
│       │   ├── mask.nii
│       │   ├── ResMS.nii
│       │   ├── RPV.nii
│       │   ├── SPM.mat
│       │   ├── spmT_0001.nii
│       │   ├── task-<taskLabel>_space-<spaceLabel>_desc-afterEstimation_designmatrix.png
│       │   └── task-<taskLabel>_space-<spaceLabel>_desc-beforeEstimation_designmatrix.png
│       └── sub-ALL_task-<taskLabel>_space-<spaceLabel>_FWHM-6_conFWHM-6_node-dataset_contrast-<taskLabel>
│           ├── beta_0001.nii
│           ├── con_0001.nii
│           ├── mask.nii
│           ├── ResMS.nii
│           ├── RPV.nii
│           ├── SPM.mat
│           ├── spmT_0001.nii
│           ├── task-<taskLabel>_space-<spaceLabel>_desc-afterEstimation_designmatrix.png
│           └── task-<taskLabel>_space-<spaceLabel>_desc-beforeEstimation_designmatrix.png
├── jobs
│   └── <taskLabel>
│       ├── group
│       │   ├── batch_smooth_con_FWHM-6_task-<taskLabel>_2023-05-06T12-49.json
│       │   └── batch_smooth_con_FWHM_6_task_<taskLabel>_2023_05_06T12_49.m
│       ├── sub-292
│       │   ├── batch_contrasts_ffx_task-<taskLabel>_space-<spaceLabel>_FWHM-6_2023-05-06T12-43.json
│       │   ├── batch_contrasts_ffx_task_<taskLabel>_space_<spaceLabel>_FWHM_6_2023_05_06T12_43.m
│       │   ├── batch_specifyAndEstimate_ffx_task-<taskLabel>_space-<spaceLabel>_FWHM-6_2023-05-06T12-35.json
│       │   └── batch_specifyAndEstimate_ffx_task_<taskLabel>_space_<spaceLabel>_FWHM_6_2023_05_06T12_35.m
│       ├── sub-302
│       └── sub-307

├── LICENSE
├── README.md
├── reports
│   ├── bidspm.bib
│   └── stats_model-default_es_model_citation.md
├── sub-292
│   └── task-<taskLabel>_space-<spaceLabel>_FWHM-6
│       ├── beta_0001.nii
│       ├── beta_0002.nii
│       ├── ...
│       ├── beta_0060.nii
│       ├── con_0001.nii
│       ├── con_0002.nii
│       ├── con_0003.nii
│       ├── con_0004.nii
│       ├── con_0005.nii
│       ├── con_0006.nii
│       ├── mask.nii
│       ├── ResMS.nii
│       ├── RPV.nii
│       ├── s6con_0001.nii
│       ├── s6con_0002.nii
│       ├── s6con_0003.nii
│       ├── s6con_0004.nii
│       ├── s6con_0005.nii
│       ├── s6con_0006.nii
│       ├── SPM.mat
│       ├── spmT_0001.nii
│       ├── spmT_0002.nii
│       ├── spmT_0003.nii
│       ├── spmT_0004.nii
│       ├── spmT_0005.nii
│       ├── spmT_0006.nii
│       ├── sub-292_ses-<sesLabel>_task-<taskLabel>_run-01_desc-confounds_regressors.mat
│       ├── sub-292_ses-<sesLabel>_task-<taskLabel>_run-01_desc-confounds_regressors.tsv
│       ├── sub-292_ses-<sesLabel>_task-<taskLabel>_run-01_onsets.mat
│       ├── sub-292_ses-<sesLabel>_task-<taskLabel>_run-01_onsets.tsv
│       ├── sub-292_task-<taskLabel>_space-<spaceLabel>_desc-afterEstimation_designmatrix.png
│       └── sub-292_task-<taskLabel>_space-<spaceLabel>_desc-beforeEstimation_designmatrix.png
├── sub-302
│   └── task-<taskLabel>_space-<spaceLabel>_FWHM-6
│       ├── beta_0001.nii
│       ├── beta_0002.nii
│       ├── ...
│       ├── beta_0154.nii
│       ├── con_0001.nii
│       ├── con_0002.nii
│       ├── con_0003.nii
│       ├── mask.nii
│       ├── ResMS.nii
│       ├── RPV.nii
│       ├── s6con_0001.nii
│       ├── s6con_0002.nii
│       ├── s6con_0003.nii
│       ├── SPM.mat
│       ├── spmT_0001.nii
│       ├── spmT_0002.nii
│       ├── spmT_0003.nii
│       ├── sub-302_ses-<sesLabel>_task-<taskLabel>_run-01_desc-confounds_regressors.mat
│       ├── sub-302_ses-<sesLabel>_task-<taskLabel>_run-01_desc-confounds_regressors.tsv
│       ├── sub-302_ses-<sesLabel>_task-<taskLabel>_run-01_onsets.mat
│       ├── sub-302_ses-<sesLabel>_task-<taskLabel>_run-01_onsets.tsv
│       ├── sub-302_task-<taskLabel>_space-<spaceLabel>_desc-afterEstimation_designmatrix.png
│       └── sub-302_task-<taskLabel>_space-<spaceLabel>_desc-beforeEstimation_designmatrix.png
└── sub-307
    └── task-<taskLabel>_space-<spaceLabel>_FWHM-6
        ├── beta_0001.nii
        ├── beta_0002.nii
        ├── ...
        ├── beta_0237.nii
        ├── con_0001.nii
        ├── con_0002.nii
        ├── con_0003.nii
        ├── con_0004.nii
        ├── con_0005.nii
        ├── con_0006.nii
        ├── con_0007.nii
        ├── con_0008.nii
        ├── mask.nii
        ├── ResMS.nii
        ├── RPV.nii
        ├── s6con_0001.nii
        ├── s6con_0002.nii
        ├── s6con_0003.nii
        ├── s6con_0004.nii
        ├── s6con_0005.nii
        ├── s6con_0006.nii
        ├── s6con_0007.nii
        ├── s6con_0008.nii
        ├── SPM.mat
        ├── spmT_0001.nii
        ├── spmT_0002.nii
        ├── spmT_0003.nii
        ├── spmT_0004.nii
        ├── spmT_0005.nii
        ├── spmT_0006.nii
        ├── spmT_0007.nii
        ├── spmT_0008.nii
        ├── sub-307_ses-<sesLabel>_task-<taskLabel>_run-01_desc-confounds_regressors.mat
        ├── sub-307_ses-<sesLabel>_task-<taskLabel>_run-01_desc-confounds_regressors.tsv
        ├── sub-307_ses-<sesLabel>_task-<taskLabel>_run-01_onsets.mat
        ├── sub-307_ses-<sesLabel>_task-<taskLabel>_run-01_onsets.tsv
        ├── sub-307_task-<taskLabel>_space-<spaceLabel>_desc-afterEstimation_designmatrix.png
        └── sub-307_task-<taskLabel>_space-<spaceLabel>_desc-beforeEstimation_designmatrix.png
```
