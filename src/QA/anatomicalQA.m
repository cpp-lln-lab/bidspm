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
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt: structure
  %
  % (C) Copyright 2020 CPP_SPM developers

  if ~opt.QA.anat.do
    return
  end

  if isOctave()
    warning('\nanatomicalQA is not yet supported on Octave. This step will be skipped.');
    return
  end

  opt.dir.input = opt.dir.preproc;

  [BIDS, opt] = setUpWorkflow(opt, 'quality control: anatomical');

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub}; %#ok<*PFBNS>

    printProcessingSubject(iSub, subLabel, opt);

    % TODO get bias corrected image ?
    [anatImage, anatDataDir] = getAnatFilename(BIDS, opt, subLabel);
    anatImage = fullfile(anatDataDir, anatImage);

    [gm, wm] = getTpmFilename(BIDS, anatImage);

    % sanity check that all images are in the same space.
    volumesToCheck = {anatImage; gm; wm};
    spm_check_orientations(spm_vol(char(volumesToCheck)));

    % Basic QA for anatomical data is to get SNR, CNR, FBER and Entropy
    % This is useful to check coregistration worked fine
    anatQA = spmup_anatQA(anatImage, gm,  wm); %#ok<*NASGU>

    anatQA.avgDistToSurf = getDist2surf(anatImage, opt);

    %% rename output to make it BIDS friendly
    outputDir = fullfile(anatDataDir, '..', 'reports');
    spm_mkdir(outputDir);

    p = bids.internal.parse_filename(anatImage);
    p.entities.label = p.suffix;

    p.suffix = 'qametrics';
    p.ext = '.json';
    bidsFile = bids.File(p);
    bids.util.jsonwrite(fullfile(outputDir, bidsFile.filename), anatQA);

    p.suffix = 'qa';
    p.ext = '.pdf';
    bidsFile = bids.File(p);
    movefile(fullfile(anatDataDir, [spm_file(anatImage, 'basename') '_AnatQC.pdf']), ...
             fullfile(outputDir,  bidsFile.filename));

    delete(fullfile(anatDataDir, [spm_file(anatImage, 'basename') '_anatQA.txt']));

  end

end
