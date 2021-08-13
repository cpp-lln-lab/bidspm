function bidsSmoothing(opt, funcFWHM)
  %
  % This performs smoothing to the functional data using a full width
  % half maximum smoothing kernel of size "mm_smoothing".
  %
  % USAGE::
  %
  %   bidsSmoothing(funcFWHM, [opt])
  %
  % :param funcFWHM: How much smoothing was applied to the functional
  %                  data in the preprocessing (Gaussian kernel size).
  % :type funcFWHM: scalar
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % (C) Copyright 2020 CPP_SPM developers

  opt.dir.input = opt.dir.preproc;

  [BIDS, opt] = setUpWorkflow(opt, 'smoothing functional data');

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    matlabbatch = [];
    matlabbatch = setBatchSmoothingFunc(matlabbatch, BIDS, opt, subLabel, funcFWHM);

    saveAndRunWorkflow(matlabbatch, ['smoothing_FWHM-' num2str(funcFWHM)], opt, subLabel);

  end

  renameToBids(opt);

end
