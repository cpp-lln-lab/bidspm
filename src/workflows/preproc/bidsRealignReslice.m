function bidsRealignReslice(opt)
  %
  % Realigns and reslices the functional data of a given task.
  %
  % USAGE::
  %
  %   bidsRealignReslice(opt)
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See also: checkOptions
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % Assumes that ``bidsSTC()`` has already been run if ``opt.stc.skip`` is not set
  % to ``true``.
  %
  %

  % (C) Copyright 2020 bidspm developers

  opt.pipeline.type = 'preproc';

  opt.dir.input = opt.dir.preproc;
  opt.query.modality = 'func';

  [BIDS, opt] = setUpWorkflow(opt, 'realign and reslice');

  for iSub = 1:numel(opt.subjects)

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

    if ~opt.dryRun && opt.rename.do

      copyFigures(BIDS, opt, subLabel);

      for iTask = 1:numel(opt.taskName)
        rpFiles = spm_select('FPListRec', ...
                             fullfile(BIDS.pth, ['sub-' subLabel]), ...
                             ['^rp_.*sub-', subLabel, ...
                              '.*_task-', opt.taskName{iTask}, ...
                              '.*_' opt.bidsFilterFile.bold.suffix '.txt$']);
        for iFile = 1:size(rpFiles, 1)
          rmInput = true;
          convertRealignParamToTsv(rpFiles(iFile, :), opt, rmInput);
        end
      end

      prefix = get_spm_prefix_list();
      opt.query.prefix = prefix.realign;

      opt = setRenamingConfig(opt, 'RealignReslice');
      bidsRename(opt);

    end

  end

  cleanUpWorkflow(opt);

end
