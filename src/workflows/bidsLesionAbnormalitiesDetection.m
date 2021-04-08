% (C) Copyright 2021 CPP BIDS SPM-pipeline developers

function bidsLesionAbnormalitiesDetection(opt)
  %
  % Step 2. Detects lesion abnormalities in anatomical image after segmentation of the image.
  %
  % USAGE::
  %
  %  bidsLesionAbnormalitiesDetection(opt)
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % Lesion abnormalities detection will be performed using the information provided from the LesionSegmentation output in Bids format.
  %

  [BIDS, opt] = setUpWorkflow(opt, 'abnormalities detection');

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel);

    matlabbatch = [];
    matlabbatch = setBatchLesionAbnormalitiesDetection(matlabbatch, BIDS, opt, subLabel);

    saveAndRunWorkflow(matlabbatch, 'LesionAbnormalitiesDetection', opt, subLabel);

    copyFigures(BIDS, opt, subLabel);

  end

end
