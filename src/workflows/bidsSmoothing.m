% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function bidsSmoothing(funcFWHM, opt)
  % This scripts performs smoothing to the functional data using a full width
  % half maximum smoothing kernel of size "mm_smoothing".

  % if input has no opt, load the opt.mat file
  if nargin < 2
    opt = [];
  end
  
  [BIDS, opt, group] = setUpWorkflow(opt, 'smoothing functional data');

  %% Loop through the groups, subjects, and sessions
  for iGroup = 1:length(group)

    groupName = group(iGroup).name;

    for iSub = 1:group(iGroup).numSub

      subID = group(iGroup).subNumber{iSub};

      printProcessingSubject(groupName, iSub, subID);

      matlabbatch = setBatchSmoothing(BIDS, opt, subID, funcFWHM);
      
      saveAndRunWorkflow(matlabbatch, ['smoothing_FWHM-' num2str(funcFWHM)], opt, subID);

    end
  end

end
