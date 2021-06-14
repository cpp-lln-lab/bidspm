function anatomicalQALesion(opt)
  %
  % Computes several metrics for anatomical image.
  %   Modify this version for ALI toolbox TO DO
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

  [BIDS, opt] = getData(opt);

  fprintf(1, ' ANATOMICAL: QUALITY CONTROL\n\n');

  parfor iSub = 1:numel(opt.subjects)

    subID = opt.subjects{iSub};

    printProcessingSubject(iSub, subID);

    [anatImage, anatDataDir] = getAnatFilename(BIDS, subID, opt);

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

    spm_jsonwrite( ...
                  strrep(anatImage, '.nii', '_qa.json'), ...
                  anatQA, ...
                  struct('indent', '   '));

  end

end
