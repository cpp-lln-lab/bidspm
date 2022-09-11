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
  % :type  BIDS: structure
  % :param BIDS: dataset layout.
  %              See also: bids.layout, getData.
  %
  % :param opt: Options chosen for the analysis.
  %             See also: ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type  opt: structure
  %
  % :param subLabel: subject label
  % :type  subLabel: char
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
  % (C) Copyright 2020 bidspm developers

  if ~opt.skullstrip.do
    return
  end

  printBatchName('skull stripping', opt);

  % if the input image is mean func image instead of anatomical
  if opt.skullstrip.mean
    [imageToSkullStrip, dataDir] = getMeanFuncFilename(BIDS, subLabel, opt);
  else
    [imageToSkullStrip, dataDir] = getAnatFilename(BIDS, opt, subLabel);
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

  % if this is part of a pipeline we get the segmentation dependency to get
  % the input from.
  % Otherwise the files to process are stored in a cell
  if isfield(opt, 'orderBatches') && ...
      isfield(opt.orderBatches, 'segment') && ...
      opt.orderBatches.segment > 0

    input(1) = cfg_dep('Segment: Bias Corrected (1)', ...
                       returnDependency(opt, 'segment'), ...
                       substruct('.', 'channel', '()', {1}, ...
                                 '.', 'biascorr', '()', {':'}));

    input(2) = cfg_dep('Segment: c1 Images', ...
                       returnDependency(opt, 'segment'), ...
                       substruct('.', 'tiss', '()', {1}, ...
                                 '.', 'c', '()', {':'}));

    input(3) = cfg_dep('Segment: c2 Images', ...
                       returnDependency(opt, 'segment'), ...
                       substruct('.', 'tiss', '()', {2}, ...
                                 '.', 'c', '()', {':'}));

    input(4) = cfg_dep('Segment: c3 Images', ...
                       returnDependency(opt, 'segment'), ...
                       substruct('.', 'tiss', '()', {3}, ...
                                 '.', 'c', '()', {':'}));

  else

    % bias corrected image
    anatFile = bids.File(imageToSkullStrip);
    filter = struct('suffix',  anatFile.suffix, ...
                    'sub', anatFile.entities.sub, ...
                    'prefix', '', ...
                    'desc', 'biascor', ...
                    'space', 'individual');
    biasCorrectedAnatImage = bids.query(BIDS, 'data', filter);

    % tissue probability maps
    filter = struct('suffix',  'probseg', ...
                    'res', '', ...
                    'sub', anatFile.entities.sub, ...
                    'prefix', '', ...
                    'space', 'individual');

    filter.label = 'GM';
    gmTpm = bids.query(BIDS, 'data', filter);

    filter.label = 'WM';
    wmTpm = bids.query(BIDS, 'data', filter);

    filter.label = 'CSF';
    csfTpm = bids.query(BIDS, 'data', filter);

    input{1} = biasCorrectedAnatImage;
    % grey matter
    input{2} = gmTpm;
    % white matter
    input{3} = wmTpm;
    % csf
    input{4} = csfTpm;

    if any(cellfun('isempty', input))
      msg = sprintf('Missing data for skullstripping: run the segmentation.');
      id = 'missingDataForSkullstripping';
      errorHandling(mfilename(), id, msg, true, opt.verbosity);
    end

    if any(cellfun(@(x) numel(x), input) > 1)
      msg = sprintf(['Too much data for skullstripping: ', ...
                     'should have only bias corrected image + 1 TPM per tissue class.']);
      id = 'tooMuchDataForSkullstripping';
      errorHandling(mfilename(), id, msg, true, opt.verbosity);
    end

    input = {input{1}, input{2}, input{3}, input{4}};

  end

  output = returnNameSkullstripOutput(imageToSkullStrip, 'image');
  saveMetadataImage(dataDir, opt, output, imageToSkullStrip);

  expression = sprintf('i1.*((i2+i3+i4)>%f)', opt.skullstrip.threshold);

  matlabbatch = setBatchImageCalculation(matlabbatch, opt, input, output, dataDir, expression);

  %% Add a batch to output the mask
  maskOutput = returnNameSkullstripOutput(imageToSkullStrip, 'mask');
  saveMetadataImage(dataDir, opt, maskOutput, imageToSkullStrip);

  matlabbatch{end + 1} = matlabbatch{end};

  matlabbatch{end}.spm.util.imcalc.expression = sprintf('(i2+i3+i4)>%f', ...
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

    json.content.Type = 'brain';
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
