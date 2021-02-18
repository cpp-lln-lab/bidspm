% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function bidsSegment(opt)
  %
  % Segments and skullstrips the anatomical image.
  %
  % USAGE::
  %
  %   bidsSegmentSkullStrip([opt])
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %

  if nargin < 1
    opt = [];
  end

  [BIDS, opt, group] = setUpWorkflow(opt, 'segmentation');

  %% Loop through the groups, subjects, and sessions
  for iGroup = 1:length(group)

    groupName = group(iGroup).name;

    for iSub = 1:group(iGroup).numSub

      subID = group(iGroup).subNumber{iSub};

      printProcessingSubject(groupName, iSub, subID);

      matlabbatch = [];
      matlabbatch = setBatchSelectAnat(matlabbatch, BIDS, opt, subID);
      opt.orderBatches.selectAnat = 1;

      % dependency from file selector ('Anatomical')
      matlabbatch = setBatchSegmentation(matlabbatch, opt);
      opt.orderBatches.segment = 2;

      saveAndRunWorkflow(matlabbatch, 'segment', opt, subID);

    end
  end

end
