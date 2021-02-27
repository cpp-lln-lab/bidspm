% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function bidsSmoothing(funcFWHM, opt)
  %
  % This performs smoothing to the functional data using a full width
  % half maximum smoothing kernel of size "mm_smoothing".
  %
  % USAGE::
  %
  %  bidsSmoothing(funcFWHM, [opt])
  %
  % :param funcFWHM: How much smoothing was applied to the functional
  %                  data in the preprocessing (Gaussian kernel size).
  % :type funcFWHM: scalar
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure

  %

  if nargin < 2
    opt = [];
  end

  [BIDS, opt, group] = setUpWorkflow(opt, 'smoothing functional data');

  %% Loop through the groups, subjects, and sessions
  for iGroup = 1:length(group)

    groupName = group(iGroup).name;

    parfor iSub = 1:group(iGroup).numSub

      subID = group(iGroup).subNumber{iSub};

      printProcessingSubject(groupName, iSub, subID);

      matlabbatch = [];
      matlabbatch = setBatchSmoothingFunc(matlabbatch, BIDS, opt, subID, funcFWHM);

      saveAndRunWorkflow(matlabbatch, ['smoothing_FWHM-' num2str(funcFWHM)], opt, subID);

    end
  end

end
