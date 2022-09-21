function [matlabbatch, opt] = setBatchSegmentation(matlabbatch, opt, imageToSegment)
  %
  % Creates a batch to segment the anatomical image
  %
  % USAGE::
  %
  %   matlabbatch = setBatchSegmentation(matlabbatch, opt)
  %
  % :param matlabbatch: list of SPM batches
  % :type  matlabbatch: structure
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See also: checkOptions
  %
  % :returns: :matlabbatch: (structure)
  %

  % (C) Copyright 2020 bidspm developers

  if ~opt.segment.do
    opt.orderBatches.segment = 0;
    return
  else
    opt.orderBatches.segment = numel(matlabbatch) + 1;
  end

  printBatchName('Segmentation anatomical image', opt);

  % define SPM folder
  spmLocation = spm('dir');

  % save bias correction field = false
  % save bias corrected image = true
  preproc.channel.write = [false true];

  % firts part assumes we are in the bidsSpatialPreproc workflow
  if isfield(opt, 'orderBatches') && isfield(opt.orderBatches, 'selectAnat')

    % SAVE BIAS CORRECTED IMAGE
    preproc.channel.vols(1) = cfg_dep('Named File Selector: Anatomical(1) - Files', ...
                                      returnDependency(opt, 'selectAnat'), ...
                                      substruct('.', 'files', '{}', {1}));
  else

    % TODO
    % implement the opt.segment.do and opt.segment.force
    % with segmentationAlreadyDone ?

    % in case a cell was given as input
    if iscell(imageToSegment)
      imageToSegment = char(imageToSegment);
    end

    % add all the images to segment
    for iImg = 1:size(imageToSegment, 1)
      file = validationInputFile([], deblank(imageToSegment(iImg, :)));
      preproc.channel.vols{iImg, 1} = file;
    end

  end

  preproc.channel.biasreg = 0.001;
  preproc.channel.biasfwhm = opt.segment.biasfwhm;

  % CREATE SEGMENTS IN NATIVE SPACE OF GM, WM AND CSF
  nativeSpace = 1;
  dartelSpace = 0;
  native = [nativeSpace dartelSpace];
  preproc.tissue(1).tpm = {[fullfile(spmLocation, 'tpm', 'TPM.nii') ',1']};
  preproc.tissue(1).ngaus = 1;
  preproc.tissue(1).native = native;
  preproc.tissue(1).warped = [0 0];

  preproc.tissue(2).tpm = {[fullfile(spmLocation, 'tpm', 'TPM.nii') ',2']};
  preproc.tissue(2).ngaus = 1;
  preproc.tissue(2).native = native;
  preproc.tissue(2).warped = [0 0];

  preproc.tissue(3).tpm = {[fullfile(spmLocation, 'tpm', 'TPM.nii') ',3']};
  preproc.tissue(3).ngaus = 2;
  preproc.tissue(3).native = native;
  preproc.tissue(3).warped = [0 0];

  preproc.tissue(4).tpm = {[fullfile(spmLocation, 'tpm', 'TPM.nii') ',4']};
  preproc.tissue(4).ngaus = 3;
  preproc.tissue(4).native = [0 0];
  preproc.tissue(4).warped = [0 0];

  preproc.tissue(5).tpm = {[fullfile(spmLocation, 'tpm', 'TPM.nii') ',5']};
  preproc.tissue(5).ngaus = 4;
  preproc.tissue(5).native = [0 0];
  preproc.tissue(5).warped = [0 0];

  preproc.tissue(6).tpm = {[fullfile(spmLocation, 'tpm', 'TPM.nii') ',6']};
  preproc.tissue(6).ngaus = 2;
  preproc.tissue(6).native = [0 0];
  preproc.tissue(6).warped = [0 0];

  % SAVE FORWARD DEFORMATION FIELD FOR NORMALISATION
  preproc.warp.mrf = 1;
  preproc.warp.cleanup = 1;
  preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
  preproc.warp.affreg = 'mni';
  preproc.warp.fwhm = 0;
  preproc.warp.samp = opt.segment.samplingDistance;
  preproc.warp.write = [1 1];

  matlabbatch{end + 1}.spm.spatial.preproc = preproc;
end
