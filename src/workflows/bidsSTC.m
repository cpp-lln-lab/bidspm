% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function bidsSTC(opt)
  % Performs SLICE TIMING CORRECTION of the functional data. The
  % script for each subject and can handle multiple sessions and multiple
  % runs.
  %
  % Slice timing units is in milliseconds to be BIDS compliant and not in slice number
  % as is more traditionally the case with SPM.
  %
  % In the case the slice timing information was not specified in the json FILES
  % in the BIDS data set (e.g it couldnt be extracted from the trento old scanner),
  % then add this information manually in opt.sliceOrder field.
  %
  % If this is empty the slice timing correction will not be performed
  %
  % If not specified this function will take the mid-volume time point as reference
  % to do the slice timing correction
  %
  % See README.md for more information about slice timing correction
  %
  % INPUT:
  % opt - options structure defined by the getOption function. If no inout is given
  % this function will attempt to load a opt.mat file in the same directory
  % to try to get some options

  % if input has no opt, load the opt.mat file
  if nargin < 1
    opt = [];
  end
  opt = loadAndCheckOptions(opt);

  % load the subjects/Groups information and the task name
  [group, opt, BIDS] = getData(opt);

  fprintf(1, 'DOING SLICE TIME CORRECTION\n');

  %% Loop through the groups, subjects, and sessions
  for iGroup = 1:length(group)

    groupName = group(iGroup).name;

    for iSub = 1:group(iGroup).numSub

      % Get the ID of the subject
      % (i.e SubNumber doesnt have to match the iSub if one subject is exluded)
      subID = group(iGroup).subNumber{iSub};

      printProcessingSubject(groupName, iSub, subID);

      matlabbatch = setBatchSTC(BIDS, opt, subID);

      if ~isempty(matlabbatch)
        saveMatlabBatch(matlabbatch, 'STC', opt, subID);

        spm_jobman('run', matlabbatch);
      end

    end
  end

end
