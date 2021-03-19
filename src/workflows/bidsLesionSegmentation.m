% (C) Copyright 2021 CPP BIDS SPM-pipeline developers

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

  [BIDS, opt] = setUpWorkflow(opt, 'lesion segmentation');

  parfor iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel);

    matlabbatch = [];
    matlabbatch = setBatchSTC(matlabbatch, BIDS, opt, subLabel);

    saveAndRunWorkflow(matlabbatch, 'LesionSegmentation', opt, subLabel);

  end

end  
  
