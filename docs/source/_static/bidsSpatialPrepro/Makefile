# Final output
cpp_spm-preproc/sub-01/func/: 	sub-01_task-auditory_desc-confounds_regressors.tsv \
								sub-01_task-audio_desc-stc_bold.mat \
								sub-01_task-auditory_label-bold_unwarpparam.mat \
								sub-01_task-audio_space-IXI549Space_desc-mean_bold.nii \
								sub-01_task-audio_space-IXI549Space_desc-preproc_bold.nii \
								sub-01_task-audio_space-T1w_desc-mean_bold.nii \
								sub-01_task-audio_space-T1w_desc-preproc_bold.nii \
								sub-01_task-auditory_space-individual_desc-std_bold.nii \
								sub-01_task-auditory_space-individual_desc-preproc_bold.avi

cpp_spm-preproc/sub-01/anat/: 	sub-01_space-individual_label-GM_probseg.nii \
								sub-01_space-individual_label-WM_probseg.nii \
								sub-01_space-individual_label-CSF_probseg.nii \
								sub-01_from-IXI549Space_to-T1w_mode-image_xfm.nii \
								sub-01_space-individual_label-brain_mask.nii \
								sub-01_space-individual_desc-skullstripped_T1w.nii \
								sub-01_space-individual_desc-biascor_T1w.nii \
								sub-01_space-IXI549Space_res-r1pt0_desc-preproc_T1w.nii \
								sub-01_space-IXI549Space_res-bold_label-GM_probseg.nii \
								sub-01_space-IXI549Space_res-bold_label-WM_probseg.nii \
								sub-01_space-IXI549Space_res-bold_label-CSF_probseg.nii \
								sub-01_desc-pialsurf_T1w.gii

cpp_spm-preproc/sub-01/reports/: sub-01_label-T1w_qa.pdf \
									sub-01_label-T1w_qametrics.json \
									sub-01_task-auditory_label-bold_qametrics.json \
									sub-01_task-auditory_label-bold_qa.pdf

################################################################################
# Workflows and batches
setBatchRealign.m: bidsSpatialPrepro.m

setBatchCoregistrationFuncToAnat.m: bidsSpatialPrepro.m

setBatchSegmentation.m: bidsSpatialPrepro.m

setBatchSkullstripping.m: bidsSpatialPrepro.m

setBatchNormalizationSpatialPrepro.m: bidsSpatialPrepro.m

setBatchNormalize.m: setBatchNormalizationSpatialPrepro.m

convertRealignParamToTsv.m: bidsSpatialPrepro.m

spmup_comp_dist2surf.m: bidsSpatialPrepro.m

functionalQA.m: bidsSpatialPrepro.m

bidsRename.m: bidsSpatialPrepro.m

spm_2_bids.m: bidsRename.m

anatomicalQA.m: bidsSpatialPrepro.m

################################################################################
# Realign and unwarp
usub-01_task-audio_desc-stc_bold.nii: sub-01_task-audio_desc-stc_bold.nii setBatchRealign.m

meansub-01_task-audio_desc-stc_bold.nii: sub-01_task-audio_desc-stc_bold.nii setBatchRealign.m

rp_sub-01_task-audio_desc-stc_bold.nii: sub-01_task-audio_desc-stc_bold.nii setBatchRealign.m

sub-01_task-auditory_label-bold_unwarpparam.mat: sub-01_task-audio_desc-stc_bold.nii setBatchRealign.m

################################################################################
# Segmentation
msub-01_T1w.nii: setBatchSegmentation.m sub-01_T1w.nii

c1sub-01_T1w.nii: setBatchSegmentation.m sub-01_T1w.nii

c2sub-01_T1w.nii: setBatchSegmentation.m sub-01_T1w.nii

c3sub-01_T1w.nii: setBatchSegmentation.m sub-01_T1w.nii

sub-01_label-T1w_segparam: setBatchSegmentation.m sub-01_T1w.nii

ysub-01_T1w.nii: setBatchSegmentation.m sub-01_T1w.nii

iysub-01_T1w.nii: setBatchSegmentation.m sub-01_T1w.nii

################################################################################
# Skullstripping
sub-01_space-individual_desc-skullstripped_T1w.nii: setBatchSkullstripping.m msub-01_T1w.nii \
													c1sub-01_T1w.nii \
													c2sub-01_T1w.nii \
													c3sub-01_T1w.nii

sub-01_space-individual_label-brain_mask.nii: setBatchSkullstripping.m c1sub-01_T1w.nii c2sub-01_T1w.nii c3sub-01_T1w.nii

#  Coregister
usub-01_task-audio_space-T1w_desc-stc_bold.nii: meansub-01_task-audio_desc-stc_bold.nii msub-01_T1w.nii \
												setBatchCoregistrationFuncToAnat.m

meansub-01_task-audio_space-T1w_desc-stc_bold.nii: 	meansub-01_task-audio_desc-stc_bold.nii msub-01_T1w.nii \
													setBatchCoregistrationFuncToAnat.m

sub-01_task-audio_desc-stc_bold.mat: 	meansub-01_task-audio_desc-stc_bold.nii msub-01_T1w.nii \
										setBatchCoregistrationFuncToAnat.m

################################################################################
# Normalize
wmeansub-01_task-audio_desc-stc_bold.nii: meansub-01_task-audio_desc-stc_bold.nii ysub-01_T1w.nii setBatchNormalize.m

wusub-01_task-audio_desc-stc_bold.nii: usub-01_task-audio_desc-stc_bold.nii ysub-01_T1w.nii setBatchNormalize.m

wmsub-01_T1w.nii: msub-01_T1w.nii ysub-01_T1w.nii setBatchNormalize.m

wc1sub-01_T1w.nii: c1sub-01_T1w.nii ysub-01_T1w.nii setBatchNormalize.m

wc2sub-01_T1w.nii: c2sub-01_T1w.nii ysub-01_T1w.nii setBatchNormalize.m

wc3sub-01_T1w.nii: c3sub-01_T1w.nii ysub-01_T1w.nii setBatchNormalize.m

################################################################################
#  QA
c1sub-01_T1w.surf.gii: c1sub-01_T1w.nii c2sub-01_T1w.nii spmup_comp_dist2surf.m

sub-01_label-T1w_qa.pdf: sub-01_T1w.nii \
							sub-01_space-individual_label-GM_probseg.nii \
							sub-01_space-individual_label-WM_probseg.nii \
							anatomicalQA.m

sub-01_label-T1w_qametrics.json: sub-01_T1w.nii \
									sub-01_space-individual_label-GM_probseg.nii \
									sub-01_space-individual_label-WM_probseg.nii \
									sub-01_desc-pialsurf_T1w.gii \
									anatomicalQA.m

sub-01_task-auditory_label-bold_qa.pdf: rp_sub-01_task-audio_desc-stc_bold.nii \
										usub-01_task-audio_space-T1w_desc-stc_bold.nii \
										functionalQA.m

sub-01_task-auditory_label-bold_qametrics.json: rp_sub-01_task-audio_desc-stc_bold.nii \
												usub-01_task-audio_space-T1w_desc-stc_bold.nii \
												functionalQA.m

sub-01_task-auditory_desc-confounds_regressors.tsv: rp_sub-01_task-audio_desc-stc_bold.nii functionalQA.m

sub-01_task-auditory_desc-confounds_regressors.json: rp_sub-01_task-audio_desc-stc_bold.nii functionalQA.m

std_usub-01_task-audio_space-T1w_desc-stc_bold.nii: usub-01_task-audio_space-T1w_desc-stc_bold.nii functionalQA.m

usub-01_task-audio_space-T1w_desc-stc_bold.avi: usub-01_task-audio_space-T1w_desc-stc_bold.nii functionalQA.m

################################################################################
# Rename
sub-01_desc-pialsurf_T1w.gii: spm_2_bids.m c1sub-01_T1w.surf.gii

sub-01_space-individual_desc-biascor_T1w.nii: spm_2_bids.m msub-01_T1w.nii

sub-01_space-individual_label-GM_probseg.nii: spm_2_bids.m c1sub-01_T1w.nii

sub-01_space-individual_label-WM_probseg.nii: spm_2_bids.m c2sub-01_T1w.nii

sub-01_space-individual_label-CSF_probseg.nii: spm_2_bids.m c3sub-01_T1w.nii

sub-01_space-IXI549Space_res-r1pt0_desc-preproc_T1w.nii: spm_2_bids.m wmsub-01_T1w.nii

sub-01_space-IXI549Space_res-bold_label-GM_probseg.nii: spm_2_bids.m wc1sub-01_T1w.nii

sub-01_space-IXI549Space_res-bold_label-WM_probseg.nii: spm_2_bids.m wc2sub-01_T1w.nii

sub-01_space-IXI549Space_res-bold_label-CSF_probseg.nii: spm_2_bids.m wc3sub-01_T1w.nii

sub-01_from-IXI549Space_to-T1w_mode-image_xfm.nii: spm_2_bids.m iysub-01_T1w.nii

sub-01_from-T1w_to-IXI549Space_mode-image_xfm.nii: spm_2_bids.m ysub-01_T1w.nii

sub-01_task-audio_space-IXI549Space_desc-mean_bold.nii: wmeansub-01_task-audio_desc-stc_bold.nii spm_2_bids.m

sub-01_task-audio_space-IXI549Space_desc-preproc_bold.nii: wusub-01_task-audio_desc-stc_bold.nii spm_2_bids.m

sub-01_task-audio_space-T1w_desc-mean_bold.nii: meansub-01_task-audio_space-T1w_desc-stc_bold.nii spm_2_bids.m

sub-01_task-audio_space-T1w_desc-preproc_bold.nii: usub-01_task-audio_space-T1w_desc-stc_bold.nii spm_2_bids.m

sub-01_task-auditory_space-individual_desc-std_bold.nii: std_usub-01_task-audio_space-T1w_desc-stc_bold.nii spm_2_bids.m


sub-01_task-auditory_space-individual_desc-preproc_bold.avi: usub-01_task-audio_space-T1w_desc-stc_bold.avi spm_2_bids.m