%-----------------------------------------------------------------------
% Job saved on 08-Mar-2021 11:11:19 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.tools.ali.unified_segmentation.step1data = '<UNDEFINED>';
spmDir = spm('dir');
lesionPriorMap = fullfile(spmDir, 'toolbox', 'ALI', 'Priors_extraClass', 'wc4prior0.nii');
matlabbatch{1}.spm.tools.ali.unified_segmentation.step1prior = {lesionPriorMap};
matlabbatch{1}.spm.tools.ali.unified_segmentation.step1niti = 2;
matlabbatch{1}.spm.tools.ali.unified_segmentation.step1thr_prob = 0.333333333333333;
matlabbatch{1}.spm.tools.ali.unified_segmentation.step1thr_size = 0.8;
matlabbatch{1}.spm.tools.ali.unified_segmentation.step1coregister = 1;
matlabbatch{1}.spm.tools.ali.unified_segmentation.step1mask = {''};
matlabbatch{1}.spm.tools.ali.unified_segmentation.step1vox = 2;
matlabbatch{1}.spm.tools.ali.unified_segmentation.step1fwhm = [8 8 8];
