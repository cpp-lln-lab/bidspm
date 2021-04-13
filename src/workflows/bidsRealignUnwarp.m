function bidsRealignUnwarp(opt)
  %
  % Realigns and unwarps the functional data of a given task.
  %
  % USAGE::
  %
  %   bidsRealignReslice(opt)
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % Assumes that ``bidsSTC`` has already been run.
  %
  % If the ``bidsCreateVDM()`` workflow has been run before the voxel displacement
  % maps will be used unless ``opt.useFieldmaps`` is set to ``false``.
  %
  % (C) Copyright 2020 CPP_SPM developers

  [BIDS, opt] = setUpWorkflow(opt, 'realign and unwarp');

  parfor iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel);

    matlabbatch = [];
    [matlabbatch, ~] = setBatchRealign( ...
                                       matlabbatch, ...
                                       BIDS, ...
                                       subLabel, ...
                                       opt, ...
                                       'realignUnwarp');

    saveAndRunWorkflow(matlabbatch, 'realign_unwarp', opt, subLabel);

    copyFigures(BIDS, opt, subLabel);

  end

end
