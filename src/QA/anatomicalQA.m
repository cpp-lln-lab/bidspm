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

  if isOctave()
    notImplemented(mfilename(), ...
                   'anatomicalQA is not yet supported on Octave. This step will be skipped.');
    opt.QA.anat.do = false;
  end

  if ~opt.QA.anat.do
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

    bf = bids.File(anatImage);
    bf.entities.label = bf.suffix;

    bf.suffix = 'qametrics';
    bf.extension = '.json';

    bids.util.jsonwrite(fullfile(outputDir, bf.filename), anatQA);

  end

end
