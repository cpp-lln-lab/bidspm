function matlabbatch = bidsRsHrf(opt)
  %
  % Use the rsHRF to estimate the HRF from resting state data.
  %
  % USAGE::
  %
  %   bidsRsHrf(opt)
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  %
  % (C) Copyright 2021 CPP_SPM developers

  % TODO add test

  opt.dir.input = opt.dir.preproc;

  opt.query.desc = 'preproc';
  opt.query.space = opt.space;

  [BIDS, opt] = setUpWorkflow(opt, 'estimate HRF from rest data');

  manageWorkersPool('close', opt);

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    matlabbatch = {};

    matlabbatch = setBatchRsHRF(matlabbatch, BIDS, opt, subLabel);

    batchName = 'estimate_hrf';

    saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

  end

end
