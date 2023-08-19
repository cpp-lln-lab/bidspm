function matlabbatch = bidsSTC(opt)
  %
  % Performs the slice timing correction of the functional data.
  %
  % USAGE::
  %
  %  bidsSTC(opt)
  %
  % :param opt: Options chosen for the analysis.
  %             See checkOptions.
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

  srcMetadata = struct('RepetitionTime', [], ...
                       'SliceTimingCorrected', [], ...
                       'StartTime', []);
  fields = fieldnames(srcMetadata);

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

      for i = 1:numel(fields)
        srcMetadata(iSub).(fields{i}) = [srcMetadata(iSub).(fields{i}), ...
                                         metadata.(fields{i})];
      end

    end

    [~, batchOutput] = saveAndRunWorkflow(matlabbatch, 'STC', opt, subLabel);

    if ~opt.dryRun
      unRenamedFiles{iSub} = filesToTransferMetadataTo(batchOutput, ...
                                                       batchToTransferMetadataTo); %#ok<*AGROW>
    end

  end

  cleanUpWorkflow(opt);

  prefix = get_spm_prefix_list;
  opt.query.prefix = prefix.stc;
  createdFiles = bidsRename(opt);

  if ~opt.dryRun
    transferMetadata(opt, createdFiles, unRenamedFiles, srcMetadata);
  end

end
