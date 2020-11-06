% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function bidsSmoothing(funcFWHM, opt)
  %
  % This performs smoothing to the functional data using a full width
  % half maximum smoothing kernel of size "mm_smoothing".
  %
  % USAGE::
  %
  %  bidsResults([opt], funcFWHM, conFWHM)
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  % :param funcFWHM: How much smoothing was applied to the functional
  %                  data in the preprocessing.
  % :type funcFWHM: scalar
  %




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
