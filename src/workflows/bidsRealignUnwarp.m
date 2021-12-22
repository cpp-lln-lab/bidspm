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
  %
  % (C) Copyright 2020 CPP_SPM developers

  opt.dir.input = opt.dir.preproc;
  opt.query.modality = 'func';

  [BIDS, opt] = setUpWorkflow(opt, 'realign and unwarp');

  runTime = [];

  for iSub = 1:numel(opt.subjects)

    subjectStart = elapsedTime(opt, 'start');

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    matlabbatch = {};
    [matlabbatch, ~] = setBatchRealign( ...
                                       matlabbatch, ...
                                       BIDS, ...
                                       opt, ...
                                       regexify(subLabel), ...
                                       'realignUnwarp');

    saveAndRunWorkflow(matlabbatch, 'realign_unwarp', opt, subLabel);

    if ~opt.dryRun
      copyFigures(BIDS, opt, subLabel);
    end

    [~, runTime] = elapsedTime(opt, 'stop', subjectStart, runTime, numel(opt.subjects));

  end

  cleanUpWorkflow(opt);

  prefix = get_spm_prefix_list();
  opt.query.prefix = prefix.unwarp;
  bidsRename(opt);

end
