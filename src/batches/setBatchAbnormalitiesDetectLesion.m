%-----------------------------------------------------------------------
% Job saved on 08-Mar-2021 12:47:16 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.tools.ali.outliers_detection.step3tissue.step3patients = '<UNDEFINED>';
matlabbatch{1}.spm.tools.ali.outliers_detection.step3tissue.step3controls = '<UNDEFINED>';
matlabbatch{1}.spm.tools.ali.outliers_detection.step3tissue.step3Alpha = 0.5;
matlabbatch{1}.spm.tools.ali.outliers_detection.step3tissue.step3Lambda = -4;
spmDir = spm('dir');
lesionMask = fullfile(spmDir, 'toolbox', 'ALI', 'Mask_image', 'mask_controls_vox2mm.nii');
matlabbatch{1}.spm.tools.ali.outliers_detection.step3mask_thr = 0;
matlabbatch{1}.spm.tools.ali.outliers_detection.step3binary_thr = 0.3;
matlabbatch{1}.spm.tools.ali.outliers_detection.step3binary_size = 0.8;
