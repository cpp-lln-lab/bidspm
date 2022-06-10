# .PHONY: models/
# .PHONY: raw/sub-01/func/
# .PHONY: preproc/sub-01/func/
# .PHONY: bidsFFX.m


# Final output
# beta_XXXX.nii: mask.nii
# mask.nii: cpp_spm-stats/sub-01/stats/task-audio_space-IXI549Space_FWHM-6

cpp_spm-stats/sub-01/stats/task-audio_space-IXI549Space_FWHM-6: SPM.mat \
																sub-01_task-audio_regressors.mat \
																sub-01_task-audio_onsets.mat \
																sub-01_task-audio_regressors.tsv \
																sub-01_task-audio_onsets.tsv \
																sub-01_task-audio_desc-beforeEstimation_designmatrix.png

# Workflows and batches
setBatchSubjectLevelGLMSpec.m: bidsFFX.m

createAndReturnCounfoundMatFile.m: setBatchSubjectLevelGLMSpec.m

returnOnsetsFile.m: setBatchSubjectLevelGLMSpec.m

createAndReturnOnsetFile.m: returnOnsetsFile.m

convertOnsetTsvToMat.m: createAndReturnOnsetFile.m

# Files

model-audio_smdl.json: models/

sub-01_task-audio_desc-confounds_regressors.tsv: preproc/sub-01/func/

sub-01_task-audio_space-IXI549Space_desc-smth6_bold.nii: preproc/sub-01/func/

sub-01_task-audio_events.tsv: raw/sub-01/func/

sub-01_task-audio_regressors.mat: sub-01_task-audio_desc-confounds_regressors.tsv \
									model-audio_smdl.json \
									createAndReturnCounfoundMatFile.m

sub-01_task-audio_regressors.tsv: sub-01_task-audio_regressors.mat

sub-01_task-audio_onsets.mat: sub-01_task-audio_events.tsv \
									model-audio_smdl.json \
									convertOnsetTsvToMat.m

sub-01_task-audio_onsets.tsv: sub-01_task-audio_onsets.mat

SPM.mat: sub-01_task-audio_space-IXI549Space_desc-smth6_bold.nii \
		sub-01_task-audio_onsets.mat \
		sub-01_task-audio_regressors.mat \
		model-audio_smdl.json setBatchSubjectLevelGLMSpec.m

sub-01_task-audio_desc-beforeEstimation_designmatrix.png: SPM.mat
