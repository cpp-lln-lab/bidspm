% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function bidsSpatialPrepro(opt)
  % bidsSpatialPrepro(opt)
  %
  % Performs spatial preprocessing of the functional and structural data.
  %
  % TODO update description
  % The structural data are segmented and normalized to MNI space.
  % The functional data are re-aligned, coregistered with the structural and
  % normalized to MNI space.
  %
  % Assumptions:
  % - the batch is build using dependencies across the different batch modules

  % TO DO
  % - find a way to paralelize this over subjects
  % - average T1s across sessions if necessarry

  % if input has no opt, load the opt.mat file
  if nargin < 1
    opt = [];
  end
  opt = loadAndCheckOptions(opt);

  setGraphicWindow();

  % load the subjects/Groups information and the task name
  [group, opt, BIDS] = getData(opt);

  fprintf(1, 'DOING SPATIAL PREPROCESSING\n');

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

      batchName = ['spatial_preprocessing-' upper(opt.space(1)) opt.space(2:end)];
      saveMatlabBatch(matlabbatch, batchName, opt, subID);

      spm_jobman('run', matlabbatch);

      copyFigures(opt, subID);

    end
  end

end


function copyFigures(opt, subID)
  
  imgNb = copyGraphWindownOutput(opt, subID, 'realign');
  
  if  opt.realign.useUnwarp
    imgNb = copyGraphWindownOutput(opt, subID, 'unwarp', imgNb);
  end
  
  imgNb = copyGraphWindownOutput(opt, subID, 'func2anatCoreg', imgNb); %#ok<NASGU>
  
end