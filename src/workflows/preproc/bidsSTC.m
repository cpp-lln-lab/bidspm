function matlabbatch = bidsSTC(opt)
  %
  % Performs the slice timing correction of the functional data.
  %
  % USAGE::
  %
  %  bidsSTC(opt)
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See  also: checkOptions
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % STC will be performed using the information provided in the BIDS data set.
  % It will use the mid-volume acquisition time point as as reference.
  %
  % In general slice order and reference slice is entered in time unit (ms) (this is
  % the BIDS way of doing things) instead of the slice index of the reference slice
  % (the "SPM" way of doing things).
  %
  % If no slice timing information is available from the file metadata this step will be skipped.
  %
  % See also: setBatchSTC, getAndCheckSliceOrder
  %
  % See the documentation for more information about slice timing correction.
  %
  % (C) Copyright 2019 CPP_SPM developers

  opt.pipeline.type = 'preproc';

  opt.dir.input = opt.dir.preproc;

  [BIDS, opt] = setUpWorkflow(opt, 'slice timing correction');

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    matlabbatch = {};

    for iTask = 1:numel(opt.taskName)

      opt.query.task = opt.taskName{iTask};

      matlabbatch = setBatchSTC(matlabbatch, BIDS, opt, regexify(subLabel));

    end

    saveAndRunWorkflow(matlabbatch, 'STC', opt, subLabel);

  end

  prefix = get_spm_prefix_list;
  opt.query.prefix = prefix.stc;
  bidsRename(opt);

end
