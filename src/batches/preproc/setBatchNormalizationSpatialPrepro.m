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
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See :func:`checkOptions`.
  %
  % :param voxDim:
  % :type opt: array
  %
  % :return: :matlabbatch: (structure)
  %

  % (C) Copyright 2019 bidspm developers

  jobsToAdd = numel(matlabbatch) + 1;

  if opt.anatOnly
    maxJobsToAdd = 3;
  else
    maxJobsToAdd = 4;
  end
  if opt.skullstrip.do
    maxJobsToAdd = maxJobsToAdd + 2;
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

  if opt.skullstrip.do
    % NORMALIZE SKULLSTRIPPED STRUCTURAL AND MASK
    skullstrippedImage = getSkullstrippedImage(matlabbatch, BIDS, opt);
    printBatchName('normalise skullstripped anatomical images', opt);
    matlabbatch{jobsToAdd}.spm.spatial.normalise.write.subj.resample(1) = skullstrippedImage;
    % TODO why do we choose this resolution for this normalization?
    matlabbatch{jobsToAdd}.spm.spatial.normalise.write.woptions.vox = [1 1 1];
    jobsToAdd = jobsToAdd + 1;

    skullstripMask = getSkullstripMask(matlabbatch, BIDS, opt);
    printBatchName('normalise skullstrip mask', opt);
    matlabbatch{jobsToAdd}.spm.spatial.normalise.write.subj.resample(1) = skullstripMask;
    % TODO why do we choose this resolution for this normalization?
    matlabbatch{jobsToAdd}.spm.spatial.normalise.write.woptions.vox = [1 1 1];
    matlabbatch{jobsToAdd}.spm.spatial.normalise.write.woptions.interp = 0;
  end

end

function anatFile = getAnatFileFromBatch(matlabbatch)

  anatFile = '';
  if not(isempty(matlabbatch)) && isfield(matlabbatch{1}, 'cfg_basicio')
    anatFile = matlabbatch{1}.cfg_basicio.cfg_named_file.files{1}{1};
    anatFile = bids.File(anatFile);
  end

end

function filter = basicFilter(matlabbatch)

  filter = '';

  anatFile = getAnatFileFromBatch(matlabbatch);

  if not(isempty(anatFile))
    filter = anatFile.entities;
    filter.modality = 'anat';
    filter.prefix = '';
    filter.extension = '.nii';
  end

end

function deformationField = getDeformationField(matlabbatch, BIDS, opt)

  deformationField = '';

  filter = basicFilter(matlabbatch);
  anatFile = getAnatFileFromBatch(matlabbatch);

  if not(isempty(filter))
    filter.suffix = 'xfm';
    filter.from = anatFile.suffix;
    filter.to = 'IXI549Space';
    deformationField = bids.query(BIDS, 'data', filter);
  end

  if isempty(deformationField)
    deformationField = cfg_dep('Segment: Forward Deformations', ...
                               returnDependency(opt, 'segment'), ...
                               substruct('.', 'fordef', '()', {':'}));
  end
end

function biasCorrectedImage = getBiasCorrectedImage(matlabbatch, BIDS, opt)
  %
  % tries to grab a previously computed bias corrected image
  % if this fails we assume we are in a bidsSpatialPreproc workflow
  % and we rely on the batch dependency
  %

  biasCorrectedImage = '';

  filter = basicFilter(matlabbatch);
  anatFile = getAnatFileFromBatch(matlabbatch);

  if not(isempty(filter))
    filter.suffix = anatFile.suffix;
    filter.desc = 'biascor';
    filter.space = 'individual';
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
  %
  % tries to grab a previously tissue probability maps
  % if this fails we assume we are in a bidsSpatialPreproc workflow
  % and we rely on the batch dependency
  %

  gmTpm = '';
  wmTpm = '';
  csfTpm = '';

  filter = basicFilter(matlabbatch);

  if not(isempty(filter))

    filter.suffix = 'probseg';
    filter.space = 'individual';
    filter.res =  '';

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
  %
  % tries to grab a skullstripped image
  % if this fails we assume we are in a bidsSpatialPreproc workflow
  % and we rely on the batch dependency
  %

  skullstrippedImage = '';

  filter = basicFilter(matlabbatch);
  anatFile = getAnatFileFromBatch(matlabbatch);

  if not(isempty(filter))
    filter.suffix = anatFile.suffix;
    filter.desc = 'skullstripped';
    filter.space = 'individual';
    skullstrippedImage = bids.query(BIDS, 'data', filter);
  end

  if opt.skullstrip.do
    skullstrippedImage = cfg_dep('Image Calculator: skullstripped anatomical', ...
                                 returnDependency(opt, 'skullStripping'), ...
                                 substruct('.', 'files'));
  end
end

function skullstripMask = getSkullstripMask(matlabbatch, BIDS, opt)
  %
  % tries to grab a skullstripped mask
  % if this fails we assume we are in a bidsSpatialPreproc workflow
  % and we rely on the batch dependency
  %

  skullstripMask = '';

  filter = basicFilter(matlabbatch);

  if not(isempty(filter))
    filter.suffix = 'mask';
    filter.desc = 'brain';
    filter.space = 'individual';
    skullstripMask = bids.query(BIDS, 'data', filter);
  end

  if opt.skullstrip.do
    skullstripMask = cfg_dep('Image Calculator: skullstrip mask', ...
                             returnDependency(opt, 'skullStrippingMask'), ...
                             substruct('.', 'files'));
  end
end

function tissueClass = returnDependencyOutputTissueClass(tissueClassNumber)
  tissueClass = substruct('.', 'tiss', '()', {tissueClassNumber}, ...
                          '.', 'c', '()', {':'});
end
