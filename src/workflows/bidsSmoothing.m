function bidsSmoothing(opt, funcFWHM)
  %
  % This performs smoothing to the functional data using a full width
  % half maximum smoothing kernel of size "mm_smoothing".
  %
  % USAGE::
  %
  %   bidsSmoothing(opt, funcFWHM)
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  % :param funcFWHM: How much smoothing was applied to the functional
  %                  data in the preprocessing (Gaussian kernel size).
  % :type funcFWHM: scalar
  %
  %
  % (C) Copyright 2020 CPP_SPM developers

  opt.dir.input = opt.dir.preproc;
  opt.query.modality = 'func';

  [BIDS, opt] = setUpWorkflow(opt, 'smoothing functional data');

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    matlabbatch = [];
    matlabbatch = setBatchSmoothingFunc(matlabbatch, BIDS, opt, subLabel, funcFWHM);

    saveAndRunWorkflow(matlabbatch, ['smoothing_FWHM-' num2str(funcFWHM)], opt, subLabel);

  end

  prefix = get_spm_prefix_list;
  opt.query.prefix = [prefix.smooth, num2str(funcFWHM)];
  bidsRename(opt, funcFWHM);

end
