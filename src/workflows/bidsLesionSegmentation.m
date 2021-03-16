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

  if nargin < 1
    opt = [];
  end

  [BIDS, opt] = setUpWorkflow(opt, 'lesion segmentation');

  % %     % Loop through the groups, subjects, and sessions
  % %   for iGroup = 1:length(group)
  % %
  % %     groupName = group(iGroup).name;
  % %
  % %     for iSub = 1:group(iGroup).numSub
  % %
  % %       subID = group(iGroup).subNumber{iSub};
  % %
  % %       printProcessingSubject(groupName, iSub, subID);
  % %
  % %       [meanImage, meanFuncDir] = getMeanFuncFilename(BIDS, subID, opt);
  % %
  % %       get grey and white matter and CSF tissue probability maps
  % %       [anatImage, anatDataDir] = getAnatFilename(BIDS, subID, opt);
  % %       TPMs = validationInputFile(anatDataDir, anatImage, 'c[123]');

  parfor iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel);

    matlabbatch = [];
    matlabbatch = setBatchSTC(matlabbatch, BIDS, opt, subLabel);

    saveAndRunWorkflow(matlabbatch, 'LesionSegmentation', opt, subLabel);

  end

end
