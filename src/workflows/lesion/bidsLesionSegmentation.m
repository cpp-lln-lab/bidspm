function bidsLesionSegmentation(opt)
  %
  % Use the ALI toolbox to perform segmentation to detect lesions of anatomical image.
  %
  % Requires the ALI toolbox: https://doi.org/10.3389/fnins.2013.00241
  %
  % USAGE::
  %
  %  bidsLesionSegmentation(opt)
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See also: checkOptions
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % Segmentation will be performed using the information provided in the BIDS data set.
  %
  %
  % (C) Copyright 2021 bidspm developers

  opt.pipeline.type = 'preproc';

  opt.dir.input = opt.dir.preproc;

  if checkToolbox('ALI', 'verbose', opt.verbosity > 0)
    opt = setFields(opt, ALI_my_defaults());
  end

  [BIDS, opt] = setUpWorkflow(opt, 'lesion segmentation');

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    matlabbatch = {};
    matlabbatch = setBatchLesionSegmentation(matlabbatch, BIDS, opt, subLabel);

    saveAndRunWorkflow(matlabbatch, 'LesionSegmentation', opt, subLabel);

  end

  opt = setRenamingConfig(opt, 'LesionSegmentation');
  bidsRename(opt);

end
