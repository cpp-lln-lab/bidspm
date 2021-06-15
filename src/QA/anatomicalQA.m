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

  % if input has no opt, load the opt.mat file
  if nargin < 1
    opt = [];
  end
  opt = loadAndCheckOptions(opt);

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  fprintf(1, ' ANATOMICAL: QUALITY CONTROL\n\n');

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub}; %#ok<*PFBNS>

    printProcessingSubject(iSub, subLabel, opt);

    [anatImage, anatDataDir] = getAnatFilename(BIDS, opt, subLabel);

    % get grey and white matter tissue probability maps
    TPMs = validationInputFile(anatDataDir, anatImage, 'c[12]');

    % sanity check that all images are in the same space.
    anatImage = fullfile(anatDataDir, anatImage);
    volumesToCheck = {anatImage; TPMs(1, :); TPMs(2, :)};
    spm_check_orientations(spm_vol(char(volumesToCheck)));

    % Basic QA for anatomical data is to get SNR, CNR, FBER and Entropy
    % This is useful to check coregistration worked fine
    anatQA = spmup_anatQA(anatImage, TPMs(1, :), TPMs(2, :)); %#ok<*NASGU>

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

end
