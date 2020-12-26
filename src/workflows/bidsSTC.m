% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function bidsSTC(opt)
  %
  % Performs the slie timing correction of the functional data.
  %
  % USAGE::
  %
  %  bidsSTC([opt])
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % STC will be performed using the information provided in the BIDS data set. It
  % will use the mid-volume acquisition time point as as reference.
  %
  % The fields of the ``opt`` structure related to STC can still be used to do some slice
  % timing correction even if no information can be found in the BIDS data set.
  %
  % In general slice order and reference slice is entered in time unit (ms) (this is
  % the BIDS way of doing things) instead of the slice index of the reference slice
  % (the "SPM" way of doing things).
  %
  % If no slice timing information is available from the file metadata or from
  % the ``opt`` strcuture this step will be skipped.
  %
  % See also ``getSliceOrder()``.
  %
  % See the documentation for more information about slice timing correction.
  %

  if nargin < 1
    opt = [];
  end

  [BIDS, opt, group] = setUpWorkflow(opt, 'slice timing correction');

  %% Loop through the groups, subjects, and sessions
  for iGroup = 1:length(group)

    groupName = group(iGroup).name;

    for iSub = 1:group(iGroup).numSub

      subID = group(iGroup).subNumber{iSub};

      printProcessingSubject(groupName, iSub, subID);

      matlabbatch = [];
      matlabbatch = setBatchSTC(matlabbatch, BIDS, opt, subID);

      saveAndRunWorkflow(matlabbatch, 'STC', opt, subID);

    end
  end

end
