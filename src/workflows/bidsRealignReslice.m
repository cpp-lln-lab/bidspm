function bidsRealignReslice(opt)
  %
  % Realigns and reslices the functional data of a given task.
  %
  % USAGE::
  %
  %   bidsRealignReslice(opt)
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % Assumes that ``bidsSTC()`` has already been run.
  %
  % (C) Copyright 2020 CPP_SPM developers

  [BIDS, opt] = setUpWorkflow(opt, 'realign and reslice');

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel);

    matlabbatch = {};
    [matlabbatch, ~] = setBatchRealign( ...
                                       matlabbatch, ...
                                       BIDS, ...
                                       subLabel, ...
                                       opt, ...
                                       'realignReslice');

    saveAndRunWorkflow(matlabbatch, 'realign_reslice', opt, subLabel);

    copyFigures(BIDS, opt, subLabel);

  end

end
