% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function bidsRealignUnwarp(opt)
  %
  % Realigns and unwarps the functional data of a given task.
  %
  % USAGE::
  %
  %   bidsRealignReslice(opt)
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % Assumes that ``bidsSTC`` has already been run.
  %
  % If the ``bidsCreateVDM()`` workflow has been run before the voxel displacement
  % maps will be used unless ``opt.useFieldmaps`` is set to ``false``.
  %

  if nargin < 1
    opt = [];
  end

  [BIDS, opt, group] = setUpWorkflow(opt, 'realign and unwarp');

  %% Loop through the groups, subjects, and sessions
  for iGroup = 1:length(group)

    groupName = group(iGroup).name;

    parfor iSub = 1:group(iGroup).numSub

      % Get the ID of the subject
      % (i.e SubNumber doesnt have to match the iSub if one subject
      % is exluded for any reason)
      subID = group(iGroup).subNumber{iSub}; % Get the subject ID

      printProcessingSubject(groupName, iSub, subID);

      matlabbatch = [];
      [matlabbatch, ~] = setBatchRealign( ...
                                         matlabbatch, ...
                                         BIDS, ...
                                         subID, ...
                                         opt, ...
                                         'realignUnwarp');

      saveAndRunWorkflow(matlabbatch, 'realign_unwarp', opt, subID);

      copyFigures(BIDS, opt, subID);

    end
  end

end
