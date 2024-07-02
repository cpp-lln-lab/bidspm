function matlabbatch = bidsSTC(opt)
  %
  % Performs the slice timing correction of the functional data.
  %
  % USAGE::
  %
  %  bidsSTC(opt)
  %
  % :param opt: Options chosen for the analysis.
  %             See :func:`checkOptions`.
  % :type opt:  structure
  %
  % STC will be performed using the information provided in the BIDS data set.
  % It will use the mid-volume acquisition time point as as reference.
  %
  % In general slice order and reference slice is entered in time unit (ms)
  % (this is the BIDS way of doing things)
  % instead of the slice index of the reference slice
  % (the "SPM" way of doing things).
  %
  % If no slice timing information is available
  % from the file metadata this step will be skipped.
  %
  % See also: setBatchSTC, getAndCheckSliceOrder
  %

  % (C) Copyright 2019 bidspm developers

  opt.pipeline.type = 'preproc';

  opt.dir.input = opt.dir.preproc;

  indexData = true;
  indexDependencies = false;
  [BIDS, opt] = setUpWorkflow(opt, ...
                              'slice timing correction', ...
                              '', ...
                              indexData, ...
                              indexDependencies);

  newMetadata = struct('SliceTimingCorrected', [], ...
                       'StartTime', []);

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    matlabbatch = {};

    for iTask = 1:numel(opt.taskName)

      opt.query.task = opt.taskName{iTask};

      [matlabbatch, metadata] = setBatchSTC(matlabbatch, ...
                                            BIDS, ...
                                            opt, ...
                                            regexify(subLabel));

      newMetadata(iTask) = metadata;

    end

    saveAndRunWorkflow(matlabbatch, 'STC', opt, subLabel);

  end

  cleanUpWorkflow(opt);

  prefix = get_spm_prefix_list;
  opt.query.prefix = prefix.stc;
  createdFiles = bidsRename(opt);

  for iTask = 1:numel(opt.taskName)
    idx = ~cellfun('isempty', strfind(createdFiles, opt.taskName{iTask}));
    files = createdFiles(idx);
    transferMetadataFromJson(files, newMetadata(iTask));
  end

end
