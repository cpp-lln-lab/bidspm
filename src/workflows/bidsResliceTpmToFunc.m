% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function bidsResliceTpmToFunc(opt)
  %
  % Reslices the tissue probability map (TPMs) from the segmentation to the mean
  % functional.
  %
  % USAGE::
  %
  %   bidsResliceTpmToFunc([opt])
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % Assumes that the anatomical has already been segmented by ``bidsSpatialPrepro()``
  % or ``bidsSegmentSkullStrip()``.
  %
  % It is necessary to run this workflow before running the ``functionalQA`` pipeline
  % as the computation of the tSNR by ``spmup`` requires the TPMs to have the same dimension
  % as the functional.
  %

  if nargin < 1
    opt = [];
  end

  [BIDS, opt, group] = setUpWorkflow(opt, ...
                                     'reslicing tissue probability maps to functional dimension');

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

      matlabbatch = [];
      matlabbatch = setBatchReslice(matlabbatch, ...
                                    fullfile(meanFuncDir, meanImage), ...
                                    cellstr(TPMs));

      saveAndRunWorkflow(matlabbatch, 'reslice_tpm', opt, subID);

      %% Compute brain mask of functional
      TPMs = validationInputFile(anatDataDir, anatImage, 'rc[123]');
      % greay matter
      input{1, 1} = TPMs(1, :);
      % white matter
      input{2, 1} = TPMs(2, :);
      % csf
      input{3, 1} = TPMs(3, :);

      output = strrep(meanImage, '.nii', '_mask.nii');

      expression = sprintf('(i1+i2+i3)>%f', opt.skullstrip.threshold);

      matlabbatch = [];
      matlabbatch = setBatchImageCalculation(matlabbatch, input, output, meanFuncDir, expression);

      saveAndRunWorkflow(matlabbatch, 'create_functional_brain_mask', opt, subID);

    end

  end

end
