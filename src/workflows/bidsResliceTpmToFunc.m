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

  [BIDS, opt] = setUpWorkflow(opt, 'reslicing tissue probability maps to functional dimension');

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel);

    [meanImage, meanFuncDir] = getMeanFuncFilename(BIDS, subLabel, opt);

    % get grey and white matter and CSF tissue probability maps
    [anatImage, anatDataDir] = getAnatFilename(BIDS, subLabel, opt);
    TPMs = validationInputFile(anatDataDir, anatImage, 'c[123]');

    matlabbatch = [];
    matlabbatch = setBatchReslice(matlabbatch, ...
                                  fullfile(meanFuncDir, meanImage), ...
                                  cellstr(TPMs));

    saveAndRunWorkflow(matlabbatch, 'reslice_tpm', opt, subLabel);

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

    saveAndRunWorkflow(matlabbatch, 'create_functional_brain_mask', opt, subLabel);

  end

end
