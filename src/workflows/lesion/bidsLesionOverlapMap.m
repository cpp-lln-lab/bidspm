function bidsLesionOverlapMap(opt)
  %
  % Creates lesion overlap map on the anatomical image after initial segmentation
  % and lesion abnormality detection of the image.
  %
  % Requires the ALI toolbox: https://doi.org/10.3389/fnins.2013.00241
  %
  % USAGE::
  %
  %  bidsLesionOverlapMap(opt)
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See :func:`checkOptions`.
  % :type opt: structure
  %
  % Lesion overlap map will be created using the information provided from the
  % Lesion abnormalities detection output in BIDS format.
  %
  %

  % (C) Copyright 2021 bidspm developers

  if checkToolbox('ALI', 'verbose', opt.verbosity > 0)
    opt = setFields(opt, ALI_my_defaults());
  end

  [BIDS, opt] = setUpWorkflow(opt, 'lesion overlap map');

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    matlabbatch = {};
    matlabbatch = setBatchLesionOverlapMap(matlabbatch, BIDS, opt, subLabel);

    saveAndRunWorkflow(matlabbatch, 'LesionOverlapMap', opt, subLabel);

    copyFigures(BIDS, opt, subLabel);

  end

end
