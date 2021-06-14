function anatomicalQALesion(opt)
  %
  % Computes several metrics for anatomical image.
  %   Modify this version for ALI toolbox TO DO
  %
  % USAGE::
  %
  %   anatomicalQALesion(opt)
  %
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % See `` lesion_get_option()``.
  % :type opt: structure
  %
  % (C) Copyright 2021 CPP_SPM developers

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

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel);

    [anatImage, anatDataDir] = getAnatFilename(BIDS, subLabel, opt);

    % get grey and white matter tissue probability maps
    TPMs = validationInputFile(anatDataDir, anatImage, 'rc[12]'); 
        
    % sanity check that all images are in the same space.
    
    % setbatchreslice
    batchName = 'reslice_anat_lesion'; 
    matlabbatch = [];
    matlabbatch = setBatchReslice(matlabbatch, TPMs(1, :), fullfile(anatDataDir, anatImage));   
    saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);
    prefix = [spm_get_defaults('realign.write.prefix')];
    anatImage = fullfile(anatDataDir, [prefix, anatImage]); 
    
    volumesToCheck = {anatImage; TPMs(1, :); TPMs(2, :)};
    spm_check_orientations(spm_vol(char(volumesToCheck)));

    % Basic QA for anatomical data is to get SNR, CNR, FBER and Entropy
    % This is useful to check coregistration worked fine
    anatQA = spmup_anatQA(anatImage, TPMs(1, :), TPMs(2, :)); %#ok<*NASGU>

    anatQA.avgDistToSurf = spmup_comp_dist2surf(anatImage);

%     spm_jsonwrite( ...
%                   strrep(anatImage, '.nii', '_qa.json'), ...
%                   anatQA, ...
%                   struct('indent', '   '));

  end

end
