function bidsResliceTpmToFunc(opt)
  %
  % Reslices the tissue probability map (TPMs) from the segmentation to the mean
  % functional and creates a mask for the bold mean image
  %
  % USAGE::
  %
  %   bidsResliceTpmToFunc(opt)
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
  %
  % (C) Copyright 2020 CPP_SPM developers

  % TODO consider renaming this function to highlight that it creates a mask as
  % well, though this might get confusing with `bidsWholeBrainFuncMask`

  [BIDS, opt] = setUpWorkflow(opt, 'reslicing tissue probability maps to functional dimension');

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    opt.query.space = 'individual';
    [meanImage, meanFuncDir] = getMeanFuncFilename(BIDS, subLabel, opt);

    % get grey and white matter and CSF tissue probability maps
    [greyMatter, whiteMatter, csf] = getTpmFilenames(BIDS, subLabel);
    TPMs = cat(1, greyMatter, whiteMatter, csf);

    matlabbatch = {};
    matlabbatch = setBatchReslice(matlabbatch, ...
                                  opt, ...
                                  fullfile(meanFuncDir, meanImage), ...
                                  cellstr(TPMs));

    saveAndRunWorkflow(matlabbatch, 'reslice_tpm', opt, subLabel);

    %% Compute brain mask of functional
    prefix = spm_get_defaults('realign.write.prefix');
    input{1, 1} = spm_file(greyMatter, 'prefix', prefix);
    input{2, 1} = spm_file(whiteMatter, 'prefix', prefix);
    input{3, 1} = spm_file(csf, 'prefix', prefix);

    p = bids.internal.parse_filename(meanImage);
    p.entities.label = p.suffix;
    p.suffix = 'mask';
    p.use_schema = false;
    output = bids.create_filename(p);

    expression = sprintf('(i1+i2+i3)>%f', opt.skullstrip.threshold);

    matlabbatch = {};
    matlabbatch = setBatchImageCalculation(matlabbatch, opt, ...
                                           input, output, meanFuncDir, expression);

    saveAndRunWorkflow(matlabbatch, 'create_functional_brain_mask', opt, subLabel);

  end

  bidsRename(opt);

end
