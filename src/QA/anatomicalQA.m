function anatomicalQA(opt)
  %
  % Computes several metrics for anatomical image.
  %
  % USAGE::
  %
  %   anatomicalQA(opt)
  %
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt: structure
  %
  % (C) Copyright 2020 CPP_SPM developers

  if isOctave()
    warning('\nanatomicalQA is not yet supported on Octave. This step will be skipped.');
    return
  end

  opt.dir.input = opt.dir.preproc;

  [BIDS, opt] = setUpWorkflow(opt, 'quality control: anatomical');

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub}; %#ok<*PFBNS>

    printProcessingSubject(iSub, subLabel, opt);

    % get bias corrected image
    opt.query.desc = 'biascor';
    [anatImage, anatDataDir] = getAnatFilename(BIDS, opt, subLabel);
    anatImage = fullfile(anatDataDir, anatImage);

    [gm, wm] = getTpmFilename(BIDS, subLabel);

    % sanity check that all images are in the same space.
    volumesToCheck = {anatImage; gm; wm};
    spm_check_orientations(spm_vol(char(volumesToCheck)));

    % Basic QA for anatomical data is to get SNR, CNR, FBER and Entropy
    % This is useful to check coregistration worked fine
    anatQA = spmup_anatQA(anatImage, gm,  wm); %#ok<*NASGU>

    anatQA.avgDistToSurf = spmup_comp_dist2surf(anatImage);

    %% rename output to make it BIDS friendly
    p = bids.internal.parse_filename(anatImage);
    p.entities.label = p.suffix;
    p.suffix = 'qametrics';
    p.ext = '.json';
    p.use_schema = false;
    spm_jsonwrite( ...
                  fullfile(anatDataDir, bids.create_filename(p)), ...
                  anatQA, ...
                  struct('indent', '   '));

    p = bids.internal.parse_filename(anatImage);
    p.entities.label = p.suffix;
    p.suffix = 'mask';
    p.ext = '.pdf';
    p.use_schema = false;
    movefile(fullfile(anatDataDir, [spm_file(anatImage, 'basename') '_AnatQC.pdf']), ...
             fullfile(anatDataDir,  bids.create_filename(p)));

    delete(fullfile(anatDataDir, [spm_file(anatImage, 'basename') '_anatQA.txt']));

  end

  bidsRename(opt);

end
