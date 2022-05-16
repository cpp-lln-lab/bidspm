function matlabbatch = setBatchSkullStripping(matlabbatch, BIDS, opt, subLabel)
  %
  % Creates a batch to compute a brain mask based on the tissue probability maps
  % from the segmentation.
  %
  % USAGE::
  %
  %   matlabbatch = setBatchSkullStripping(matlabbatch, BIDS, opt, subLabel)
  %
  % :param matlabbatch: list of SPM batches
  % :type matlabbatch: structure
  %
  % :param BIDS: BIDS layout returned by ``getData``.
  % :type BIDS: structure
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % :param subLabel: subject label
  % :type subLabel: string
  %
  % :returns: - :matlabbatch: (structure) The matlabbatch ready to run the spm job
  %
  % This function will get its inputs from the segmentation batch by reading
  % the dependency from ``opt.orderBatches.segment``. If this field is not specified it will
  % try to get the results from the segmentation by relying on the ``anat``
  % image returned by ``getAnatFilename``.
  %
  % The threshold for inclusion in the mask can be set by::
  %
  %   opt.skullstrip.threshold (default = 0.75)
  %
  % Any voxel with p(grayMatter) +  p(whiteMatter) + p(CSF) > threshold
  % will be included in the skull stripping mask.
  %
  % It is also possible to segment a functional image by setting
  % ``opt.skullstrip.mean`` to ``true``
  %
  % Skullstripping can be skipped by setting
  % ``opt.skullstrip.do`` to ``false``
  %
  % (C) Copyright 2020 CPP_SPM developers

  if ~opt.skullstrip.do
    return
  end

  printBatchName('skull stripping', opt);

  [imageToSkullStrip, dataDir] = getAnatFilename(BIDS, opt, subLabel);

  % if the input image is mean func image instead of anatomical
  if opt.skullstrip.mean
    [imageToSkullStrip, dataDir] = getMeanFuncFilename(BIDS, subLabel, opt);
  end

  bf = bids.File(imageToSkullStrip, 'use_schema', false);
  if isSkullstripped(bf)
    errorHandling(mfilename(), ...
                  'imageAlreadySkullstripped', ...
                  'The image is already skullstripped. Skipping skullstripping batch.', ...
                  true, ...
                  opt.verbosity);
    return
  end

  expression = sprintf('i1.*((i2+i3+i4)>%f)', opt.skullstrip.threshold);

  % if this is part of a pipeline we get the segmentation dependency to get
  % the input from.
  % Otherwise the files to process are stored in a cell
  if isfield(opt, 'orderBatches') && isfield(opt.orderBatches, 'segment')

    input(1) = ...
        cfg_dep( ...
                'Segment: Bias Corrected (1)', ...
                returnDependency(opt, 'segment'), ...
                substruct( ...
                          '.', 'channel', '()', {1}, ...
                          '.', 'biascorr', '()', {':'}));

    input(2) = ...
        cfg_dep( ...
                'Segment: c1 Images', ...
                returnDependency(opt, 'segment'), ...
                substruct( ...
                          '.', 'tiss', '()', {1}, ...
                          '.', 'c', '()', {':'}));

    input(3) = ...
        cfg_dep( ...
                'Segment: c2 Images', ...
                returnDependency(opt, 'segment'), ...
                substruct( ...
                          '.', 'tiss', '()', {2}, ...
                          '.', 'c', '()', {':'}));

    input(4) = ...
        cfg_dep( ...
                'Segment: c3 Images', ...
                returnDependency(opt, 'segment'), ...
                substruct( ...
                          '.', 'tiss', '()', {3}, ...
                          '.', 'c', '()', {':'}));

  else

    % TODO: using 'm' prefixes might not work and should probably be changed for
    % a bids.query

    % bias corrected image
    biasCorrectedAnatImage = validationInputFile(anatDataDir, anatImage, 'm');
    % get the tissue probability maps in native space for that subject
    TPMs = validationInputFile(anatDataDir, anatImage, 'c[123]');

    input{1} = biasCorrectedAnatImage;
    % grey matter
    input{2} = TPMs(1, :);
    % white matter
    input{3} = TPMs(2, :);
    % csf
    input{4} = TPMs(3, :);

  end

  output = returnNameSkullstripOutput(imageToSkullStrip, 'image');
  saveMetadataImage(dataDir, opt, output, imageToSkullStrip);

  matlabbatch = setBatchImageCalculation(matlabbatch, opt, input, output, dataDir, expression);

  %% Add a batch to output the mask
  maskOutput = returnNameSkullstripOutput(imageToSkullStrip, 'mask');
  saveMetadataImage(dataDir, opt, maskOutput, imageToSkullStrip);

  matlabbatch{end + 1} = matlabbatch{end};
  matlabbatch{end}.spm.util.imcalc.expression = sprintf( ...
                                                        '(i2+i3+i4)>%f', ...
                                                        opt.skullstrip.threshold);
  matlabbatch{end}.spm.util.imcalc.output = maskOutput;

  %%
  addSkullstrippedMetadataToRoot(BIDS);

end

function saveMetadataImage(dataDir, opt, output, imageToSkullStrip)

  bf = bids.File(output);

  json = bids.derivatives_json(output);

  if strcmp(bf.suffix, 'mask')
    json.content.Description = sprintf(['mask used for skullstripping values with', ...
                                        '"p(GM) + p(WM) + p(CSF) > %f'], opt.skullstrip.threshold);

  else
    json.content.Description = sprintf(['image skullstripped for values with', ...
                                        '"p(GM) + p(WM) + p(CSF) > %f'], opt.skullstrip.threshold);
  end

  json.content.Sources{1} = relPath(imageToSkullStrip);

  % TODO RawSources
  % will depend on if it is bold or not,
  % if we are skullstripping a normalise)

  if isfield(bf.entities, 'space') && strcmp(bf.entities.space, 'individual')
    json.content.SpatialReference{1} = 'scanner space';
  end

  bids.util.jsonencode(fullfile(dataDir, json.filename), ...
                       json.content);

end

function value = relPath(imageToSkullStrip)
  bf = bids.File(imageToSkullStrip);
  value = fullfile(bf.bids_path, bf.filename);
end

function addSkullstrippedMetadataToRoot(BIDS)
  metadata = struct('SkullStripped', true);
  filename = fullfile(BIDS.pth, 'desc-skullstripped.json');
  bids.util.jsonencode(filename, metadata);
end
