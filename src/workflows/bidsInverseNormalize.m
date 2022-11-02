function matlabbatch = bidsInverseNormalize(opt)
  %
  % Brief workflow description
  %
  % USAGE::
  %
  %  matlabbatch = bidsInverseNormalize(opt)
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %

  % (C) Copyright 2022 bidspm developers

  opt.dir.input = opt.dir.preproc;

  [BIDS, opt] = setUpWorkflow(opt, 'inverse normalize');

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    filter = opt.bidsFilterFile.roi;
    filter.sub = subLabel;
    imgToResample = bids.query(BIDS, 'data', filter);

    matlabbatch = {};

    matlabbatch = setBatchInverseNormalize(matlabbatch, BIDS, opt, subLabel, imgToResample);

    saveAndRunWorkflow(matlabbatch, 'inverse normalize', opt, subLabel);

  end

  if ~opt.dryRun && opt.rename

    map =  Mapping();
    nameSpec = struct('entities', struct('space', opt.bidsFilterFile.roi.to));
    map = map.add_mapping('prefix', map.norm, 'name_spec', nameSpec);
    map = map.flatten_mapping();
    opt.spm_2_bids = map;
    bidsRename(opt);
  end

end
