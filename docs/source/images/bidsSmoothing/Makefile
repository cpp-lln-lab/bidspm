# .PHONY: sub-01_task-audio_space-IXI549Space_desc-preproc_bold.nii bidsSmoothing.m

# Final output
bidspm-preproc/sub-01/func/: sub-01_task-audio_space-IXI549Space_desc-smth6_bold.nii

# Workflows and batches
setBatchSmoothingFunc.m: bidsSmoothing.m

setBatchSmoothing.m: setBatchSmoothingFunc.m

bidsRename.m: bidsSmoothing.m

spm_2_bids.m: bidsRename.m

# Files
sub-01_task-audio_space-IXI549Space_desc-smth6_bold.nii: s6sub-01_task-audio_space-IXI549Space_desc-preproc_bold.nii spm_2_bids.m

s6sub-01_task-audio_space-IXI549Space_desc-preproc_bold.nii: sub-01_task-audio_space-IXI549Space_desc-preproc_bold.nii setBatchSmoothing.m
