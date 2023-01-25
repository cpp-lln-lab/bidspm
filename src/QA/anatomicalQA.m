function anatomicalQA(opt)
  %
  % Computes several metrics for anatomical image.
  %
  % Is run as part of:
  %
  % - ``bidsSpatialPrepro``
  %
  % USAGE::
  %
  %   anatomicalQA(opt)
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See also: checkOptions
  %

  % (C) Copyright 2020 bidspm developers

  opt.dir.input = opt.dir.preproc;

  [BIDS, opt] = setUpWorkflow(opt, 'preprocessing quality control');

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub}; %#ok<*PFBNS>

    printProcessingSubject(iSub, subLabel, opt);

    [anatImage, anatDataDir] = getAnatFilename(BIDS, opt, subLabel);
    anatImage = fullfile(anatDataDir, anatImage);

    [gm, wm] = getTpmFilename(BIDS, anatImage);

    % Basic QA for anatomical data is to get SNR, CNR, FBER and Entropy
    % This is useful to check coregistration worked fine
    [json, fig] = anatQA(anatImage, gm,  wm); %#ok<*NASGU>

    json.avgDistToSurf = getDist2surf(anatImage, opt);

    %% rename output to make it BIDS friendly
    outputDir = fullfile(anatDataDir, '..', 'reports');
    spm_mkdir(outputDir);

    bf = bids.File(anatImage);
    bf.entities.label = bf.suffix;

    bf.suffix = 'qametrics';
    bf.extension = '.json';

    bids.util.jsonwrite(fullfile(outputDir, bf.filename), json);

  end

end
