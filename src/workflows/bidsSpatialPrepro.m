% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function bidsSpatialPrepro(opt)
  %
  % Performs spatial preprocessing of the functional and structural data.
  %
  % USAGE::
  %
  %   bidsSpatialPrepro([opt])
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % The anatomical data are segmented, skulls-stripped [and normalized to MNI space].
  %
  % The functional data are re-aligned (unwarped), coregistered with the structural,
  % the anatomical data is skull-stripped [and normalized to MNI space].
  %
  % If you do not want to:
  %
  % - to perform realign AND unwarp, make sure you set
  %   ``opt.realign.useUnwarp`` to ``true``.
  % - normalize the data to MNI space, make sure you set
  %   ``opt.space`` to ``MNI``.
  %
  % If you want to:
  %
  % - use another type of anatomical data than ``T1w`` as a reference or want to specify
  %   which anatomical session is to be used as a reference, you can set this in
  %   ``opt.anatReference``::
  %
  %     opt.anatReference.type = 'T1w';
  %     opt.anatReference.session = 1;
  %
  % .. TODO:
  %
  %  - average T1s across sessions if necessarry
  %

  if nargin < 1
    opt = [];
  end

  [BIDS, opt, group] = setUpWorkflow(opt, 'spatial preprocessing');

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

      % if action is emtpy then only realign will be done
      action = [];
      if ~opt.realign.useUnwarp
        action = 'realign';
      end
      [matlabbatch, voxDim] = setBatchRealign(matlabbatch, BIDS, subID, opt, action);
      opt.orderBatches.realign = 2;

      % dependency from file selector ('Anatomical')
      matlabbatch = setBatchCoregistrationFuncToAnat(matlabbatch, BIDS, subID, opt);
      opt.orderBatches.coregister = 3;

      matlabbatch = setBatchSaveCoregistrationMatrix(matlabbatch, BIDS, subID, opt);

      % dependency from file selector ('Anatomical')
      matlabbatch = setBatchSegmentation(matlabbatch, opt);
      opt.orderBatches.segment = 5;

      matlabbatch = setBatchSkullStripping(matlabbatch, BIDS, subID, opt);

      if strcmp(opt.space, 'MNI')
        % dependency from segmentation
        % dependency from coregistration
        matlabbatch = setBatchNormalizationSpatialPrepro(matlabbatch, voxDim, opt);
      end

      % if no unwarping was done on func, we reslice the func, so we can use
      % them for the functionalQA
      if ~opt.realign.useUnwarp
        matlabbatch = setBatchRealign(matlabbatch, BIDS, subID, opt, 'reslice');
      end

      batchName = ['spatial_preprocessing-' upper(opt.space(1)) opt.space(2:end)];

      saveAndRunWorkflow(matlabbatch, batchName, opt, subID);

      copyFigures(BIDS, opt, subID);

    end
  end

end
