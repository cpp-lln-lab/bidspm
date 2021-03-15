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

  [BIDS, opt, group] = setUpWorkflow(opt, 'lesion segmentation');

  %% Loop through the groups, subjects, and sessions
  for iGroup = 1:length(group)

    groupName = group(iGroup).name;

    parfor iSub = 1:group(iGroup).numSub

      subID = group(iGroup).subNumber{iSub};

      printProcessingSubject(groupName, iSub, subID);

      matlabbatch = [];
      matlabbatch = setBatchLesionSegmentation(matlabbatch, BIDS, opt, subID);

      saveAndRunWorkflow(matlabbatch, 'LesionSegmentation', opt, subID);

    end
  end

end