# .PHONY: sub-01_task-audio_bold.nii bidsSTC.m

# Final output
cpp_spm-preproc/sub-01/func/: sub-01_task-audio_desc-stc_bold.nii

# Workflows and batches
setBatchSTC.m: bidsSTC.m

bidsRename.m: bidsSTC.m

spm_2_bids.m: bidsRename.m

# Files
asub-01_task-audio_bold.nii: sub-01_task-audio_bold.nii setBatchSTC.m

sub-01_task-audio_desc-stc_bold.nii: asub-01_task-audio_bold.nii spm_2_bids.m