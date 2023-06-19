function bidsRealignUnwarp(opt)
  %
  % Realigns and unwarps the functional data of a given task.
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
  % Assumes that ``bidsSTC`` has already been run.
  %
  % If the ``bidsCreateVDM()`` workflow has been run before the voxel displacement
  % maps will be used unless ``opt.useFieldmaps`` is set to ``false``.
  %
  %

  % (C) Copyright 2020 bidspm developers

  opt.pipeline.type = 'preproc';

  opt.dir.input = opt.dir.preproc;
  opt.query.modality = 'func';

  [BIDS, opt] = setUpWorkflow(opt, 'realign and unwarp');

  for iSub = 1:numel(opt.subjects)

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

  end

  cleanUpWorkflow(opt);

  if ~opt.dryRun && opt.rename.do
    opt = set_spm_2_bids_defaults(opt);
    prefix = get_spm_prefix_list();
    opt.query.prefix = prefix.unwarp;
    bidsRename(opt);
  end

end
