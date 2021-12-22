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
  % Assumes that ``bidsSTC()`` has already been run if ``opt.stc.skip`` is not set
  % to ``true``.
  %
  %
  % (C) Copyright 2020 CPP_SPM developers

  opt.dir.input = opt.dir.preproc;
  opt.query.modality = 'func';

  [BIDS, opt] = setUpWorkflow(opt, 'realign and reslice');

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
                                       'realignReslice');

    saveAndRunWorkflow(matlabbatch, 'realign_reslice', opt, subLabel);

    if ~opt.dryRun
      copyFigures(BIDS, opt, subLabel);
    end

    [~, runTime] = elapsedTime(opt, 'stop', subjectStart, runTime, numel(opt.subjects));

  end

  cleanUpWorkflow(opt);

  prefix = get_spm_prefix_list();
  opt.query.prefix = prefix.realign;
  bidsRename(opt);

end
