% (C) Copyright 2020 CPP BIDS SPM-pipeline developpers

function bidsResliceTpmToFunc(opt)
  % bidsResliceTpmToFunc(opt)
  %
  % reslices the tissue probability map from the segmentation to the mean
  % functional

  % if input has no opt, load the opt.mat file
  if nargin < 1
    opt = [];
  end
  opt = loadAndCheckOptions(opt);

  [group, opt, BIDS] = getData(opt);

  fprintf(1, 'RESLICING TPM TO MEAN FUNCTIONAL\n\n');

  %% Loop through the groups, subjects, and sessions
  for iGroup = 1:length(group)

    groupName = group(iGroup).name;

    for iSub = 1:group(iGroup).numSub

      subID = group(iGroup).subNumber{iSub};

      printProcessingSubject(groupName, iSub, subID);

      [meanImage, meanFuncDir] = getMeanFuncFilename(BIDS, subID, opt);

      % get grey and white matter and CSF tissue probability maps
      [anatImage, anatDataDir] = getAnatFilename(BIDS, subID, opt);
      TPMs = validationInputFile(anatDataDir, anatImage, 'c[123]');

      matlabbatch = setBatchReslice( ...
                                    fullfile(meanFuncDir, meanImage), ...
                                    cellstr(TPMs));

      saveMatlabBatch(matlabbatch, 'reslice_tpm', opt, subID);
      spm_jobman('run', matlabbatch);

    end

  end

end
