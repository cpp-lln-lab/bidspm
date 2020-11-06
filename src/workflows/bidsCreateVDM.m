% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function bidsCreateVDM(opt)
  % bidsCreateVDM(opt)
  %
  % inspired from spmup spmup_BIDS_preprocess (@ commit
  % 198c980d6d7520b1a996f0e56269e2ceab72cc83)

  if nargin < 1
    opt = [];
  end
  
  [BIDS, opt, group] = setUpWorkflow(opt, 'create voxel displacement map');

  %% Loop through the groups, subjects, and sessions
  for iGroup = 1:length(group)

    groupName = group(iGroup).name;

    for iSub = 1:group(iGroup).numSub

      subID = group(iGroup).subNumber{iSub};

      % TODO Move to getInfo
      types = spm_BIDS(BIDS, 'types', 'sub', subID);

      if any(ismember(types, {'phase12', 'phasediff', 'fieldmap', 'epi'}))

        printProcessingSubject(groupName, iSub, subID);

        matlabbatch = setBatchCoregistrationFmap(BIDS, opt, subID);        
        saveAndRunWorkflow(matlabbatch, 'coregister_fmap', opt, subID);

        matlabbatch = setBatchCreateVDMs(BIDS, opt, subID);        
        saveAndRunWorkflow(matlabbatch, 'create_vdm', opt, subID);

        % TODO
        % delete temporary mean images ??

      end

    end

  end
end
