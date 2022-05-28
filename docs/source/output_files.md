# Outputs of CPP SPM

⚠️ WIP ⚠️

For a complete list of how SPM outputs are renamed into BIDS derivatives see the
Mapping page.

## func

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

## anat

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

Not listed: some of the outputs of the segmentation done by the ALI toolbox for
lesion detection
