% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function bidsRealignReslice(opt)
  %
  % Realigns and reslices the functional data of a given task.
  %
  % USAGE::
  %
  %   bidsRealignReslice(opt)
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % Assumes that ``bidsSTC()`` has already been run.
  %

  if nargin < 1
    opt = [];
  end
  
  [BIDS, opt, group] = setUpWorkflow(opt, 'realign and reslice');

  %% Loop through the groups, subjects, and sessions
  for iGroup = 1:length(group)

    groupName = group(iGroup).name;

    for iSub = 1:group(iGroup).numSub

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
                                         'realignReslice');
                                      
      saveAndRunWorkflow(matlabbatch, 'realign_reslice', opt, subID);
      
      copyFigures(BIDS, opt, subID);

    end
  end

end
