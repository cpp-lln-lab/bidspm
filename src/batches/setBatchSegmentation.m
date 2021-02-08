% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchSegmentation(matlabbatch, opt, imageToSegment)
  %
  % Creates a batch to segment the anatomical image
  %
  % USAGE::
  %
  %   matlabbatch = setBatchSegmentation(matlabbatch, opt)
  %
  % :param matlabbatch: list of SPM batches
  % :type matlabbatch: structure
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % :returns: :matlabbatch: (structure)
  %

  printBatchName('Segmentation anatomical image');

  % define SPM folder
  spmLocation = spm('dir');

  % save bias correction field = false
  % save bias corrected image = true
  matlabbatch{end + 1}.spm.spatial.preproc.channel.write = [false true];

  if isfield(opt, 'orderBatches') && isfield(opt.orderBatches, 'selectAnat')

    % SAVE BIAS CORRECTED IMAGE
    matlabbatch{end}.spm.spatial.preproc.channel.vols(1) = ...
        cfg_dep('Named File Selector: Anatomical(1) - Files', ...
                substruct( ...
                          '.', 'val', '{}', {opt.orderBatches.selectAnat}, ...
                          '.', 'val', '{}', {1}, ...
                          '.', 'val', '{}', {1}, ...
                          '.', 'val', '{}', {1}), ...
                substruct('.', 'files', '{}', {1}));
  else

    % in case a cell was given as input
    if iscell(imageToSegment)
      imageToSegment = char(imageToSegment);
    end

    % add all the images to segment
    for iImg = 1:size(imageToSegment, 1)
      file = validationInputFile([], deblank(imageToSegment(iImg, :)));
      matlabbatch{end}.spm.spatial.preproc.channel.vols{iImg, 1} = file;
    end

  end

  matlabbatch{end}.spm.spatial.preproc.channel.biasreg = 0.001;
  matlabbatch{end}.spm.spatial.preproc.channel.biasfwhm = 60;

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
