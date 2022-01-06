# .PHONY: sub-01_T1w.nii bidsSegmentSkullstrip.m

# Final output
cpp_spm-preproc/sub-01/anat/: sub-01_space-individual_label-GM_probseg.nii sub-01_space-individual_label-WM_probseg.nii sub-01_space-individual_label-CSF_probseg.nii sub-01_from-IXI549Space_to-T1w_mode-image_xfm.nii sub-01_space-individual_label-brain_mask.nii sub-01_space-individual_desc-skullstripped_T1w.nii sub-01_space-individual_desc-biascor_T1w.nii

# Workflows and batches
setBatchSegmentation.m: bidsSegmentSkullstrip.m

setBatSkullstripping.m: bidsSegmentSkullstrip.m

bidsRename.m: bidsSegmentSkullstrip.m

spm_2_bids.m: bidsRename.m

# Rename
sub-01_space-individual_desc-biascor_T1w.nii: spm_2_bids.m msub-01_T1w.nii

sub-01_space-individual_label-GM_probseg.nii: spm_2_bids.m c1sub-01_T1w.nii

sub-01_space-individual_label-WM_probseg.nii: spm_2_bids.m c2sub-01_T1w.nii

sub-01_space-individual_label-CSF_probseg.nii: spm_2_bids.m c3sub-01_T1w.nii

sub-01_from-IXI549Space_to-T1w_mode-image_xfm.nii: spm_2_bids.m iysub-01_T1w.nii

sub-01_from-T1w_to-IXI549Space_mode-image_xfm.nii: spm_2_bids.m ysub-01_T1w.nii


# Skullstripping
sub-01_space-individual_desc-skullstripped_T1w.nii: setBatSkullstripping.m msub-01_T1w.nii c1sub-01_T1w.nii c2sub-01_T1w.nii c3sub-01_T1w.nii

sub-01_space-individual_label-brain_mask.nii: setBatSkullstripping.m c1sub-01_T1w.nii c2sub-01_T1w.nii c3sub-01_T1w.nii


# Segmentation
msub-01_T1w.nii: setBatchSegmentation.m sub-01_T1w.nii

c1sub-01_T1w.nii: setBatchSegmentation.m sub-01_T1w.nii

c2sub-01_T1w.nii: setBatchSegmentation.m sub-01_T1w.nii

c3sub-01_T1w.nii: setBatchSegmentation.m sub-01_T1w.nii

sub-01_label-T1w_segparam: setBatchSegmentation.m sub-01_T1w.nii

ysub-01_T1w.nii: setBatchSegmentation.m sub-01_T1w.nii

iysub-01_T1w.nii: setBatchSegmentation.m sub-01_T1w.nii
