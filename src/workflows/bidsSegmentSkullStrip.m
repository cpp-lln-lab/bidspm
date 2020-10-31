% (C) Copyright 2020 CPP BIDS SPM-pipeline developpers

function bidsSegmentSkullStrip(opt)
  %
  % Segments and skullstrips the anat image.
  %
  % USAGE::
  %
  %   bidsSegmentSkullStrip([opt])
  %
  % :param opt: options
  % :type opt: structure

  % if input has no opt, load the opt.mat file
  if nargin < 1
    opt = [];
  end
  opt = loadAndCheckOptions(opt);

  % load the subjects/Groups information and the task name
  [group, opt, BIDS] = getData(opt);

  fprintf(1, 'SEGMENTING AND SKULL STRIPPING ANAT\n');

  %% Loop through the groups, subjects, and sessions
  for iGroup = 1:length(group)

    groupName = group(iGroup).name;

    for iSub = 1:group(iGroup).numSub

      matlabbatch = [];
      % Get the ID of the subject
      % (i.e SubNumber doesnt have to match the iSub if one subject
      % is exluded for any reason)
      subID = group(iGroup).subNumber{iSub};

      printProcessingSubject(groupName, iSub, subID);

      matlabbatch = setBatchSelectAnat(matlabbatch, BIDS, opt, subID);
      opt.orderBatches.selectAnat = 1;

      % dependency from file selector ('Anatomical')
      matlabbatch = setBatchSegmentation(matlabbatch, opt);
      opt.orderBatches.segment = 2;

      matlabbatch = setBatchSkullStripping(matlabbatch, BIDS, subID, opt);

      saveMatlabBatch(matlabbatch, 'segment_skullstrip', opt, subID);

      spm_jobman('run', matlabbatch);

    end
  end

end
