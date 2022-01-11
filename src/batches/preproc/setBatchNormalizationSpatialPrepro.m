function matlabbatch = setBatchNormalizationSpatialPrepro(matlabbatch, BIDS, opt, voxDim)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   matlabbatch = setBatchNormalizationSpatialPrepro(matlabbatch, opt, voxDim)
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  % :param opt:
  % :type opt: structure
  % :param voxDim:
  % :type opt: array
  %
  % :returns: - :matlabbatch: (structure)
  %
  % (C) Copyright 2019 CPP_SPM developers

  jobsToAdd = numel(matlabbatch) + 1;

  if opt.anatOnly
    maxJobsToAdd = 4;
  else
    maxJobsToAdd = 5;
  end

  % set the deformation field for all the images we are about to normalize
  % we reuse a previously created deformation field if it is there
  % otherwise we link to a segmentation module by using a dependency
  deformationField = getDeformationField(matlabbatch, BIDS, opt);

  for iJob = jobsToAdd:(jobsToAdd + maxJobsToAdd)
    % we set images to be resampled at the voxel size we had at acquisition
    matlabbatch = setBatchNormalize(matlabbatch, deformationField, voxDim);
  end

  if ~opt.anatOnly
    printBatchName('normalise functional images', opt);
    matlabbatch{jobsToAdd}.spm.spatial.normalise.write.subj.resample(1) = ...
        cfg_dep('Coregister: Estimate: Coregistered Images', ...
                returnDependency(opt, 'coregister'), ...
                substruct('.', 'cfiles'));
    jobsToAdd = jobsToAdd + 1;
  end

  % NORMALIZE STRUCTURAL
  biasCorrectedImage = getBiasCorrectedImage(matlabbatch, BIDS, opt);
  printBatchName('normalise anatomical images', opt);
  matlabbatch{jobsToAdd}.spm.spatial.normalise.write.subj.resample(1) = biasCorrectedImage;
  % TODO why do we choose this resolution for this normalization?
  matlabbatch{jobsToAdd}.spm.spatial.normalise.write.woptions.vox = [1 1 1];
  jobsToAdd = jobsToAdd + 1;

  % NORMALIZE TISSUE PROBABILITY MAPS
  [gmTpm, wmTpm, csfTpm] = getTpms(matlabbatch, BIDS, opt);

  printBatchName('normalise grey matter tissue probability map', opt);
  matlabbatch{jobsToAdd}.spm.spatial.normalise.write.subj.resample(1) = gmTpm;
  jobsToAdd = jobsToAdd + 1;

  printBatchName('normalise white matter tissue probability map', opt);
  matlabbatch{jobsToAdd}.spm.spatial.normalise.write.subj.resample(1) = wmTpm;
  jobsToAdd = jobsToAdd + 1;

  printBatchName('normalise csf tissue probability map', opt);
  matlabbatch{jobsToAdd}.spm.spatial.normalise.write.subj.resample(1) = csfTpm;
  jobsToAdd = jobsToAdd + 1;

  % NORMALIZE SKULSTRIPPED STRUCTURAL
  skullstrippedImage = getSkullstrippedImage(matlabbatch, BIDS, opt);
  printBatchName('normalise skullstripped anatomical images', opt);
  matlabbatch{jobsToAdd}.spm.spatial.normalise.write.subj.resample(1) = skullstrippedImage;
  % TODO why do we choose this resolution for this normalization?
  matlabbatch{jobsToAdd}.spm.spatial.normalise.write.woptions.vox = [1 1 1];

end

function anatFile = getAnatFileFromBatch(matlabbatch)

  anatFile = '';
  if not(isempty(matlabbatch)) && isfield(matlabbatch{1}, 'cfg_basicio')
    anatFile = matlabbatch{1}.cfg_basicio.cfg_named_file.files{1}{1};
    anatFile = bids.internal.parse_filename(anatFile);
  end

end

function deformationField = getDeformationField(matlabbatch, BIDS, opt)

  deformationField = '';

  anatFile = getAnatFileFromBatch(matlabbatch);

  if not(isempty(anatFile))
    filter = anatFile.entities;
    filter.modality = 'anat';
    filter.suffix = 'xfm';
    filter.prefix = '';
    filter.from = anatFile.suffix;
    filter.to = 'IXI549Space';
    filter.extension = '.nii';
    deformationField = bids.query(BIDS, 'data', filter);
  end

  if isempty(deformationField)
    deformationField = ...
        cfg_dep('Segment: Forward Deformations', ...
                returnDependency(opt, 'segment'), ...
                substruct('.', 'fordef', '()', {':'}));
  end
end

function biasCorrectedImage = getBiasCorrectedImage(matlabbatch, BIDS, opt)

  biasCorrectedImage = '';

  anatFile = getAnatFileFromBatch(matlabbatch);

  if not(isempty(anatFile))
    filter = anatFile.entities;
    filter.modality = 'anat';
    filter.suffix = anatFile.suffix;
    filter.desc = 'biascor';
    filter.prefix = '';
    filter.extension = '.nii';
    biasCorrectedImage = bids.query(BIDS, 'data', filter);
  end

  if isempty(biasCorrectedImage)
    biasCorrectedImage = cfg_dep('Segment: bias corrected image', ...
                                 returnDependency(opt, 'segment'), ...
                                 substruct( ...
                                           '.', 'channel', '()', {1}, ...
                                           '.', 'biascorr', '()', {':'}));
  end
end

function [gmTpm, wmTpm, csfTpm] = getTpms(matlabbatch, BIDS, opt)

  gmTpm = '';
  wmTpm = '';
  csfTpm = '';

  anatFile = getAnatFileFromBatch(matlabbatch);

  if not(isempty(anatFile))

    filter = anatFile.entities;
    filter.modality = 'anat';
    filter.suffix = 'probseg';
    filter.space = 'individual';
    filter.res =  '';
    filter.prefix = '';
    filter.extension = '.nii';

    filter.label = 'GM';
    gmTpm = bids.query(BIDS, 'data', filter);

    filter.label = 'WM';
    wmTpm = bids.query(BIDS, 'data', filter);

    filter.label = 'CSF';
    csfTpm = bids.query(BIDS, 'data', filter);

  end

  if isempty(gmTpm)
    gmTpm = cfg_dep('Segment: grey matter image', ...
                    returnDependency(opt, 'segment'), ...
                    returnDependencyOutputTissueClass(1));
  end

  if isempty(wmTpm)
    wmTpm = cfg_dep('Segment: white matter image', ...
                    returnDependency(opt, 'segment'), ...
                    returnDependencyOutputTissueClass(2));
  end

  if isempty(csfTpm)
    csfTpm = cfg_dep('Segment: csf matter image', ...
                     returnDependency(opt, 'segment'), ...
                     returnDependencyOutputTissueClass(3));
  end
end

function skullstrippedImage = getSkullstrippedImage(matlabbatch, BIDS, opt)

  skullstrippedImage = '';

  anatFile = getAnatFileFromBatch(matlabbatch);

  if not(isempty(anatFile))
    filter = anatFile.entities;
    filter.modality = 'anat';
    filter.prefix = '';
    filter.suffix = anatFile.suffix;
    filter.desc = 'skullstripped';
    filter.extension = '.nii';
    skullstrippedImage = bids.query(BIDS, 'data', filter);
  end

  if isempty(skullstrippedImage)
    skullstrippedImage = cfg_dep('Image Calculator: skullstripped anatomical', ...
                                 returnDependency(opt, 'skullStripping'), ...
                                 substruct('.', 'files'));
  end
end

function tissueClass = returnDependencyOutputTissueClass(tissueClassNumber)
  tissueClass = substruct( ...
                          '.', 'tiss', '()', {tissueClassNumber}, ...
                          '.', 'c', '()', {':'});
end
