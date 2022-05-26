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
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % Lesion overlap map will be created using the information provided from the
  % Lesion abnormalities detection output in BIDS format.
  %
  %
  % (C) Copyright 2021 CPP_SPM developers

  % TODO add test

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
