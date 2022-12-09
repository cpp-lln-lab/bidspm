function functionalQA(opt)
  %
  % Is run as part of:
  %
  % - ``bidsSpatialPrepro``
  %
  % USAGE::
  %
  %   functionalQA(opt)
  %
  % For  each run works on the realigned (and unwarped) data:
  %
  % - plots motion, global signal, framewise displacement
  % - make a movie of the realigned time series
  % - computes additional confounds regressors depending on the options asked
  % - gets temporal SNR (TODO)
  % - creates a carpet plot of the data (TODO) ; warning this is slow
  %
  % Relevant options::
  %
  %   opt.QA.func.Basics = 'on';
  %   opt.QA.func.Motion = 'on';
  %   opt.QA.func.FD = 'on';
  %   opt.QA.func.Globals = 'on';
  %   opt.QA.func.Movie = 'on';
  %   opt.QA.func.Voltera = 'on';
  %   opt.QA.func.carpetPlot = true;
  %
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See also: checkOptions
  %
  % .. warning::
  %
  %    Because of a bug in spm_up, if ``Voltera = 'on'``, then the confound
  %    regressors of framewise displacement, RMS and global signal
  %    will not be saved.
  %

  % (C) Copyright 2020 bidspm developers

  % ASSUMPTIONS:
  %
  % - the functional images have been realigned and resliced using either:
  %
  %      - ``realign and unwarp``,
  %      - ``realign and reslice``,
  %
  % TODO - the tissue probability maps are in the "native" space of each subject
  %         and are resliced to the dimension of the functional

  if opt.anatOnly
    return
  end

  if isOctave()
    opt.QA.func.do = false;
    warning('\nfunctionalQA is not yet supported on Octave. This step will be skipped.');

  end

  if ~opt.QA.func.do
    return
  end

  opt.dir.input = opt.dir.preproc;

  [BIDS, opt] = setUpWorkflow(opt, 'quality control: functional');

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    % get grey and white matter and csf tissue probability maps
    % res = 'bold';
    % space = 'individual';
    % TODO need to reslice TPMs as part of spatial prepro first
    % [greyMatter, whiteMatter, csf] = getTpmFilenames(BIDS, subLabel, res, space);
    % tpms = char({greyMatter; whiteMatter; csf});

    % TODO get bias corrected image ?
    [anatImage, anatDataDir] = getAnatFilename(BIDS, opt, subLabel);
    anatImage = fullfile(anatDataDir, anatImage);

    distToSurf = getDist2surf(anatImage, opt);

    for iTask = 1:numel(opt.taskName)

      thisTask = opt.taskName{iTask};

      opt.query.task = thisTask;

      [sessions, nbSessions] = getInfo(BIDS, subLabel, opt, 'Sessions');

      for iSes = 1:nbSessions

        [runs, nbRuns] = getInfo(BIDS, subLabel, opt, 'Runs', sessions{iSes});

        for iRun = 1:nbRuns

          % get the filename for this bold run for this task
          % TODO improve prefixes?
          prefix = ['[', ...
                    spm_get_defaults('coreg.write.prefix'), ...
                    spm_get_defaults('unwarp.write.prefix'), ...
                    ']'];
          pattern = ['^', prefix, 'sub-', subLabel];
          if ~strcmp(sessions{iSes}, '')
            pattern = [pattern, '_ses-', sessions{iSes}]; %#ok<*AGROW>
          end
          pattern = [pattern, '.*', '_task-' thisTask, '.*'];
          if ~strcmp(runs{iRun}, '')
            pattern = [pattern, '_run-' runs{iRun}];
          end
          pattern = [pattern, '.*_' opt.bidsFilterFile.bold.suffix '.nii'];
          funcImage = spm_select('FPListRec', fullfile(BIDS.pth, ['sub-' subLabel]), pattern);

          if size(funcImage, 1) ~= 1
            msg = sprintf('too many files found:\n%s', createUnorderedList(funcImage));
            id = 'tooManyFiles';
            logger('WARNING', msg, 'id', id, 'filename', mfilename(), 'options', opt);
            continue
          end

          % sanity check that all images are in the same space.
          % TODO: need to reslice TPMs as part of spatial prepro first
          % volumesToCheck = {funcImage; greyMatter; whiteMatter; csf};
          % spm_check_orientations(spm_vol(char(volumesToCheck)));

          subFuncDataDir = spm_fileparts(funcImage);

          % TODO refactor so each step is saved after execution:
          % will help ith refactoring

          % TODO: need to reslice TPMs as part of spatial prepro first
          notImplemented(mfilename(), 'temporal SNR not implemented', opt.verbosity > 0);
          % funcQA.tSNR = spmup_temporalSNR(funcImage, ...
          %                                 {tpms(1, :); tpms(2, :); tpms(3, :)}, ...
          %                                 'save');

          % TODO use spm_select to get rp_ file
          realignParamFile = getRealignParamFilename(BIDS, subLabel, sessions{iSes}, runs{iRun}, opt);
          jsonContent.meanFD = mean(spmup_FD(realignParamFile, distToSurf));

          outputFiles = spmup_first_level_qa(funcImage, ...
                                             'MotionParameters', opt.QA.func.Motion, ...
                                             'FramewiseDisplacement', opt.QA.func.FD, ...
                                             'Globals', opt.QA.func.Globals, ...
                                             'Movie', opt.QA.func.Movie, ...
                                             'Basics', opt.QA.func.Basics, ...
                                             'Voltera', opt.QA.func.Voltera, ...
                                             'Radius', distToSurf);

          confounds = load(outputFiles.design);
          headers = bids.util.jsondecode(spm_file(outputFiles.design, 'ext', '.json'));

          for con = 1:size(confounds, 2)
            tsvContent.(headers.Columns{con}) = confounds(:, con);
          end
          % horrible hack to prevent the "abrupt" way spmup_volumecorr crashes
          % if nansum is not there
          if opt.QA.func.carpetPlot && exist('nansum', 'file') == 2
            notImplemented(mfilename(), 'carpet plot not implemented', opt.verbosity > 0);
            % TODO: need to reslice TPMs as part of spatial prepro first
            % spmup_timeseriesplot(funcImage, greyMatter, whiteMatter, csf, ...
            %                      'motion', 'on', ...
            %                      'nuisances', 'on', ...
            %                      'correlation', 'on', ...
            %                      'makefig', 'on');
          end

          %% save and rename output
          outputDir = fullfile(subFuncDataDir, '..', 'reports');
          spm_mkdir(outputDir);

          bf = bids.File(funcImage);
          bf.entities.label = bf.suffix;
          bf.prefix = '';

          % TODO find an output format that is leaner than a 3 Gb json file!!!
          bf.suffix = 'qametrics';
          bf.extension = '.json';

          bids.util.jsonwrite(fullfile(outputDir, bf.filename), jsonContent);

          bf.suffix = 'qa';
          bf.extension = '.pdf';

          movefile(fullfile(subFuncDataDir, 'spmup_QC.ps'), ...
                   fullfile(outputDir, bf.filename));

          bf.entities.desc = 'confounds';
          bf.entities.label = '';
          bf.suffix = 'regressors';
          bf.extension = '.tsv';

          bids.util.tsvwrite(spm_file(funcImage, 'filename', bf.filename), tsvContent);

          jsonContent = createDataDictionary(tsvContent);
          bf.extension = '.json';

          bids.util.jsonwrite(spm_file(funcImage, 'filename', bf.filename), jsonContent);

          delete(outputFiles.design);
          delete(spm_file(outputFiles.design, 'ext', '.json'));
          delete(realignParamFile);

        end

      end

    end

  end

end
