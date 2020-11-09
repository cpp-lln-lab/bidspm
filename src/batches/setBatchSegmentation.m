% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchSegmentation(matlabbatch, opt)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   [argout1, argout2] = templateFunction(argin1, [argin2 == default,] [argin3])
  %
  % :param argin1: (dimension) obligatory argument. Lorem ipsum dolor sit amet,
  %                consectetur adipiscing elit. Ut congue nec est ac lacinia.
  % :type argin1: type
  % :param argin2: Options chosen for the analysis. See ``checkOptions()``.
  % :type argin2: string
  %
  % :returns: - :argout1: (type) (dimension)
  %           - :argout2: (type) (dimension)
  %

  printBatchName('segmentation anatomical image');

  % define SPM folder
  spmLocation = spm('dir');

  % SAVE BIAS CORRECTED IMAGE
  matlabbatch{end + 1}.spm.spatial.preproc.channel.vols(1) = ...
      cfg_dep('Named File Selector: Anatomical(1) - Files', ...
              substruct( ...
                        '.', 'val', '{}', {opt.orderBatches.selectAnat}, ...
                        '.', 'val', '{}', {1}, ...
                        '.', 'val', '{}', {1}, ...
                        '.', 'val', '{}', {1}), ...
              substruct('.', 'files', '{}', {1}));

  matlabbatch{end}.spm.spatial.preproc.channel.biasreg = 0.001;
  matlabbatch{end}.spm.spatial.preproc.channel.biasfwhm = 60;
  % save bias correction field = false
  % save bias corrected image = true
  matlabbatch{end}.spm.spatial.preproc.channel.write = [false true];

  % CREATE SEGMENTS IN NATIVE SPACE OF GM,WM AND CSF
  matlabbatch{end}.spm.spatial.preproc.tissue(1).tpm = ...
      {[fullfile(spmLocation, 'tpm', 'TPM.nii') ',1']};
  matlabbatch{end}.spm.spatial.preproc.tissue(1).ngaus = 1;
  matlabbatch{end}.spm.spatial.preproc.tissue(1).native = [1 1];
  matlabbatch{end}.spm.spatial.preproc.tissue(1).warped = [0 0];

  matlabbatch{end}.spm.spatial.preproc.tissue(2).tpm = ...
      {[fullfile(spmLocation, 'tpm', 'TPM.nii') ',2']};
  matlabbatch{end}.spm.spatial.preproc.tissue(2).ngaus = 1;
  matlabbatch{end}.spm.spatial.preproc.tissue(2).native = [1 1];
  matlabbatch{end}.spm.spatial.preproc.tissue(2).warped = [0 0];

  matlabbatch{end}.spm.spatial.preproc.tissue(3).tpm = ...
      {[fullfile(spmLocation, 'tpm', 'TPM.nii') ',3']};
  matlabbatch{end}.spm.spatial.preproc.tissue(3).ngaus = 2;
  matlabbatch{end}.spm.spatial.preproc.tissue(3).native = [1 1];
  matlabbatch{end}.spm.spatial.preproc.tissue(3).warped = [0 0];

  matlabbatch{end}.spm.spatial.preproc.tissue(4).tpm = ...
      {[fullfile(spmLocation, 'tpm', 'TPM.nii') ',4']};
  matlabbatch{end}.spm.spatial.preproc.tissue(4).ngaus = 3;
  matlabbatch{end}.spm.spatial.preproc.tissue(4).native = [0 0];
  matlabbatch{end}.spm.spatial.preproc.tissue(4).warped = [0 0];

  matlabbatch{end}.spm.spatial.preproc.tissue(5).tpm = ...
      {[fullfile(spmLocation, 'tpm', 'TPM.nii') ',5']};
  matlabbatch{end}.spm.spatial.preproc.tissue(5).ngaus = 4;
  matlabbatch{end}.spm.spatial.preproc.tissue(5).native = [0 0];
  matlabbatch{end}.spm.spatial.preproc.tissue(5).warped = [0 0];

  matlabbatch{end}.spm.spatial.preproc.tissue(6).tpm = ...
      {[fullfile(spmLocation, 'tpm', 'TPM.nii') ',6']};
  matlabbatch{end}.spm.spatial.preproc.tissue(6).ngaus = 2;
  matlabbatch{end}.spm.spatial.preproc.tissue(6).native = [0 0];
  matlabbatch{end}.spm.spatial.preproc.tissue(6).warped = [0 0];

  % SAVE FORWARD DEFORMATION FIELD FOR NORMALISATION
  matlabbatch{end}.spm.spatial.preproc.warp.mrf = 1;
  matlabbatch{end}.spm.spatial.preproc.warp.cleanup = 1;
  matlabbatch{end}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
  matlabbatch{end}.spm.spatial.preproc.warp.affreg = 'mni';
  matlabbatch{end}.spm.spatial.preproc.warp.fwhm = 0;
  matlabbatch{end}.spm.spatial.preproc.warp.samp = 3;
  matlabbatch{end}.spm.spatial.preproc.warp.write = [1 1];
end
