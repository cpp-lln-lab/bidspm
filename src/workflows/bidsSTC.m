function bidsSTC(opt)
  %
  % Performs the slie timing correction of the functional data.
  %
  % USAGE::
  %
  %  bidsSTC([opt])
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % STC will be performed using the information provided in the BIDS data set. It
  % will use the mid-volume acquisition time point as as reference.
  %
  % The fields of the ``opt`` structure related to STC can still be used to do some slice
  % timing correction even if no information can be found in the BIDS data set.
  %
  % In general slice order and reference slice is entered in time unit (ms) (this is
  % the BIDS way of doing things) instead of the slice index of the reference slice
  % (the "SPM" way of doing things).
  %
  % If no slice timing information is available from the file metadata or from
  % the ``opt`` strcuture this step will be skipped.
  %
  % See also ``getSliceOrder()``.
  %
  % See the documentation for more information about slice timing correction.
  %
  % (C) Copyright 2019 CPP_SPM developers

  [BIDS, opt] = setUpWorkflow(opt, 'slice timing correction');

  parfor iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    matlabbatch = [];
    matlabbatch = setBatchSTC(matlabbatch, BIDS, opt, subLabel);

    saveAndRunWorkflow(matlabbatch, 'STC', opt, subLabel);

  end

end
