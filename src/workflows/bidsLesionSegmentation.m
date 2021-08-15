function bidsLesionSegmentation(opt)
  %
  % Performs segmentation to detect lesions of anatomical image.
  %
  % USAGE::
  %
  %  bidsLesionSegmentation(opt)
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % Segmentation will be performed using the information provided in the BIDS data set.
  %
  % (C) Copyright 2021 CPP_SPM developers

  % TODO add test

  [BIDS, opt] = setUpWorkflow(opt, 'lesion segmentation');

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    matlabbatch = [];
    matlabbatch = setBatchLesionSegmentation(matlabbatch, BIDS, opt, subLabel);

    saveAndRunWorkflow(matlabbatch, 'LesionSegmentation', opt, subLabel);

    %     copyFigures(BIDS, opt, subLabel);

  end

end
