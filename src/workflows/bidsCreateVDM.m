% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function bidsCreateVDM(opt)
  %
  % Creates the voxel displacement maps from the fieldmaps of a BIDS
  % dataset.
  %
  % USAGE::
  %
  %   bidsCreateVDM([opt])
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % .. TODO:
  %
  %    - take care of all types of fieldmaps
  %
  % Inspired from spmup ``spmup_BIDS_preprocess`` (@ commit 198c980d6d7520b1a99)
  % (URL missing)
  %

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
      types = bids.query(BIDS, 'types', 'sub', subID);

      if any(ismember(types, {'phase12', 'phasediff', 'fieldmap', 'epi'}))

        printProcessingSubject(groupName, iSub, subID);
        
        % Create rough mean of the 1rst run to improve SNR for coregistration
        % TODO use the slice timed EPI if STC was used ?
        sessions = getInfo(BIDS, subID, opt, 'Sessions');
        runs = getInfo(BIDS, subID, opt, 'Runs', sessions{1});
        [fileName, subFuncDataDir] = getBoldFilename(BIDS, subID, sessions{1}, runs{1}, opt);
        spmup_basics(fullfile(subFuncDataDir, fileName), 'mean');

        matlabbatch = [];
        matlabbatch = setBatchCoregistrationFmap(matlabbatch, BIDS, opt, subID);
        saveAndRunWorkflow(matlabbatch, 'coregister_fmap', opt, subID);

        matlabbatch = [];
        matlabbatch = setBatchCreateVDMs(matlabbatch, BIDS, opt, subID);
        saveAndRunWorkflow(matlabbatch, 'create_vdm', opt, subID);

        % TODO
        % delete temporary mean images ??

      end

    end

  end
end
