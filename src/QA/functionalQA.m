% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function functionalQA(opt)
  %
  % For functional data, QA consists in getting temporal SNR and then
  % check for motion - here we also compute additional regressors to
  % account for motion
  %
  % USAGE::
  %
  %   functionalQA(opt)
  %
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt: structure
  %
  % functionalQA(opt)
  %


  % if input has no opt, load the opt.mat file
  if nargin < 1
    opt = [];
  end
  opt = loadAndCheckOptions(opt);

  [group, opt, BIDS] = getData(opt);

  fprintf(1, ' FUNCTIONAL: QUALITY CONTROL\n\n');

  %% Loop through the groups, subjects, and sessions
  for iGroup = 1:length(group)

    groupName = group(iGroup).name;

    for iSub = 1:group(iGroup).numSub

      subID = group(iGroup).subNumber{iSub};

      printProcessingSubject(groupName, iSub, subID);

      % get grey and white matter and csf tissue probability maps
      [anatImage, anatDataDir] = getAnatFilename(BIDS, subID, opt);
      TPMs = validationInputFile(anatDataDir, anatImage, 'rc[123]');

      % load metrics from anat QA
      anatQA = spm_jsonread( ...
                            fullfile( ...
                                     anatDataDir,  ...
                                     strrep(anatImage, '.nii', '_qa.json')));

      [sessions, nbSessions] = getInfo(BIDS, subID, opt, 'Sessions');

      for iSes = 1:nbSessions

        % get all runs for that subject across all sessions
        [runs, nbRuns] = getInfo(BIDS, subID, opt, 'Runs', sessions{iSes});

        for iRun = 1:nbRuns

          % get the filename for this bold run for this task
          [fileName, subFuncDataDir] = getBoldFilename( ...
                                                       BIDS, ...
                                                       subID, ...
                                                       sessions{iSes}, ...
                                                       runs{iRun}, ...
                                                       opt);

          prefix = getPrefix('funcQA', opt);
          funcImage = validationInputFile(subFuncDataDir, fileName, prefix);

          % sanity check that all images are in the same space.
          volumesToCheck = {funcImage; TPMs(1, :); TPMs(2, :); TPMs(3, :)};
          spm_check_orientations(spm_vol(char(volumesToCheck)));

          fMRIQA = computeFuncQAMetrics(funcImage, TPMs, anatQA.avgDistToSurf, opt);

          spm_jsonwrite( ...
                        fullfile( ...
                                 subFuncDataDir, ...
                                 strrep(fileName, '.nii',  '_qa.json')), ...
                        fMRIQA, ...
                        struct('indent', '   '));

          outputFiles = spmup_first_level_qa( ...
                                             funcImage, ...
                                             'Voltera', 'on', ...
                                             'Radius', anatQA.avgDistToSurf);

          movefile( ...
                   fullfile(subFuncDataDir, 'spmup_QC.ps'), ...
                   fullfile(subFuncDataDir, strrep(fileName, '.nii',  '_qa.ps')));

          confounds = load(outputFiles.design);

          spm_save( ...
                   fullfile( ...
                            subFuncDataDir, ...
                            strrep(fileName, ...
                                   '_bold.nii',  ...
                                   '_desc-confounds_regressors.tsv')), ...
                   confounds);

          delete(outputFiles.design);

          createDataDictionary(subFuncDataDir, fileName, size(confounds, 2));

          % create carpet plot
          %             spmup_timeseriesplot(P, c1, c2, c3, ...
          %                 'motion', 'on', ...
          %                 'nuisances', 'on', ...
          %                 'correlation', 'on');

        end

      end

    end

  end

end

function fMRIQA = computeFuncQAMetrics(funcImage, TPMs, avgDistToSurf, opt)

  [subFuncDataDir, fileName, ext] = spm_fileparts(funcImage);

  prefix = getPrefix('funcQA', opt);

  fMRIQA.tSNR = spmup_temporalSNR( ...
                                  funcImage, ...
                                  {TPMs(1, :); TPMs(2, :); TPMs(3, :)}, ...
                                  'save');

  realignParamFile = getRealignParamFile(fullfile(subFuncDataDir, [fileName, ext]), prefix);
  fMRIQA.meanFD = mean(spmup_FD(realignParamFile, avgDistToSurf));

end
