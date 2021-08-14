function bidsSmoothing(opt)
  %
  % This performs smoothing to the functional data using a full width
  % half maximum smoothing kernel of size "mm_smoothing".
  %
  % USAGE::
  %
  %   bidsSmoothing(opt)
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
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
    matlabbatch = setBatchSmoothingFunc(matlabbatch, BIDS, opt, subLabel);

    saveAndRunWorkflow(matlabbatch, ['smoothing_FWHM-' num2str(opt.fwhm.func)], opt, subLabel);

  end

  prefix = get_spm_prefix_list;
  opt.query.prefix = [prefix.smooth, num2str(opt.fwhm.func)];
  bidsRename(opt);

end
