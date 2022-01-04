.PHONY: all sub-01_T1w.nii setBatchSegmentation.m setBatSkullstripping.m bidsRename.m

all: sub-01_space-individual_label-GM_probseg.nii

# Rename
sub-01_space-individual_label-GM_probseg.nii: bidsRename.m c1sub-01_T1w.nii

sub-01_space-individual_label-WM_probseg.nii: bidsRename.m c2sub-01_T1w.nii

sub-01_space-individual_label-CSF_probseg.nii: bidsRename.m c3sub-01_T1w.nii

sub-01_from-IXI549Space_to-T1w_mode-image_xfm.nii: bidsRename.m iysub-01_T1w.nii

sub-01_from-T1w_to-IXI549Space_mode-image_xfm.nii: bidsRename.m ysub-01_T1w.nii


# Skullstripping
sub-01_space-individual_desc-skullstripped_T1w.nii: setBatSkullstripping.m msub-01_T1w.nii c1sub-01_T1w.nii c2sub-01_T1w.nii c3sub-01_T1w.nii

sub-01_space-individual_label-brain_mask.nii: setBatSkullstripping.m msub-01_T1w.nii c1sub-01_T1w.nii c2sub-01_T1w.nii c3sub-01_T1w.nii


# Segmentation
msub-01_T1w.nii: setBatchSegmentation.m sub-01_T1w.nii

c1sub-01_T1w.nii: setBatchSegmentation.m sub-01_T1w.nii

c2sub-01_T1w.nii: setBatchSegmentation.m sub-01_T1w.nii

c3sub-01_T1w.nii: setBatchSegmentation.m sub-01_T1w.nii

sub-01_label-T1w_segparam: setBatchSegmentation.m sub-01_T1w.nii

ysub-01_T1w.nii: setBatchSegmentation.m sub-01_T1w.nii

iysub-01_T1w.nii: setBatchSegmentation.m sub-01_T1w.nii
