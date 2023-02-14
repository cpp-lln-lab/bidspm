function bidsQApreproc(opt)
  %
  %
  % USAGE::
  %
  %   bidsQApreproc(opt)
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See also: checkOptions
  %
  %
  % For each run works on the realigned (and unwarped) data:
  %
  % - plots motion, global signal, framewise displacement

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

  if opt.dryRun
    return
  end

  opt.dir.input = opt.dir.preproc;

  [BIDS, opt] = setUpWorkflow(opt, 'preprocessing quality control');

  if opt.verbosity > 1
    visible = 'on';
  end

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub}; %#ok<*PFBNS>

    printProcessingSubject(iSub, subLabel, opt);

    %% Anat
    [anatImage, anatDataDir] = getAnatFilename(BIDS, opt, subLabel);
    anatImage = fullfile(anatDataDir, anatImage);

    [gm, wm] = getTpmFilename(BIDS, anatImage);
    surfaceFile = createPialSurface(gm, wm, opt);
    bf = bids.File(surfaceFile);
    anatBf = bids.File(anatImage);
    spec.suffix = anatBf.suffix;
    spec.entities.label = 'pial';
    spec.ext = '.gii';
    bf.rename('spec', spec, ...
              'dry_run', false, ...
              'force', true, ...
              'verbose', opt.verbosity > 1);

    % Basic QA for anatomical data is to get SNR, CNR, FBER and Entropy
    % This is useful to check coregistration worked fine
    [anatJson, fig] = anatQA(anatImage, gm,  wm, 'visible', visible);

    anatJson.avgDistToSurf = getDist2surf(anatImage, opt);

    %% save output
    outputDir = fullfile(anatDataDir, '..', 'reports');
    spm_mkdir(outputDir);
    logger('DEBUG', sprintf('Saving anat QA results to:\n\t%s', outputDir), ...
           'filename', mfilename(), 'options', opt);

    bf = bids.File(anatImage);
    bf.entities.label = bf.suffix;
    bf.suffix = 'qa';

    bf.extension = '.json';
    bids.util.jsonwrite(fullfile(outputDir, bf.filename), anatJson);

    bf.extension = '.png';
    print(fig, fullfile(outputDir, bf.filename), '-dpng', '-noui', '-painters');

    if opt.anatOnly
      continue
    end

    %% functional
    for iTask = 1:numel(opt.taskName)

      thisTask = opt.taskName{iTask};

      opt.query.task = thisTask;

      [sessions, nbSessions] = getInfo(BIDS, subLabel, opt, 'Sessions');

      for iSes = 1:nbSessions

        [runs, nbRuns] = getInfo(BIDS, subLabel, opt, 'Runs', sessions{iSes});

        for iRun = 1:nbRuns

          filter = struct('sub', subLabel, ...
                          'ses', sessions{iSes}, ...
                          'task', thisTask, ...
                          'space', 'individual', ...
                          'run', runs{iRun}, ...
                          'desc', 'preproc', ...
                          'suffix', opt.bidsFilterFile.bold.suffix, ...
                          'extension', '.nii');
          funcImage = bids.query(BIDS, 'data', filter);

          if numel(funcImage) ~= 1
            msg = sprintf('too many files found:\n%s\n\nfor filter:%s', ...
                          bids.internal.create_unordered_list(funcImage));
            id = 'wrongNumberOFFiles';
            logger('ERROR', msg, 'id', id, 'filename', mfilename(), 'options', opt);
          end
          funcImage = funcImage{1};

          % TODO: need to reslice TPMs as part of spatial prepro first
          % notImplemented(mfilename(), 'temporal SNR not implemented', opt);
          % funcQA.tSNR = spmup_temporalSNR(funcImage, ...
          %                                 {tpms(1, :); tpms(2, :); tpms(3, :)}, ...
          %                                 'save');

          filter = struct('sub', subLabel, ...
                          'ses', sessions{iSes}, ...
                          'task', thisTask, ...
                          'run', runs{iRun}, ...
                          'suffix', 'motion', ...
                          'extension', '.tsv');
          realignParamFile = bids.query(BIDS, 'data', filter);
          if numel(realignParamFile) ~= 1
            msg = sprintf('too many files found:\n%s\n\nfor filter:%s', ...
                          bids.internal.create_unordered_list(realignParamFile));
            id = 'wrongNumberOFFiles';
            logger('ERROR', msg, 'id', id, 'filename', mfilename(), 'options', opt);
          end
          realignParamFile = realignParamFile{1};
          [confoundsTsv, fig] = realignQA(funcImage, realignParamFile, ...
                                          'radius', anatJson.avgDistToSurf, ...
                                          'visible', 'on');

          %% save QA output
          subFuncDataDir = spm_fileparts(funcImage);
          outputDir = fullfile(subFuncDataDir, '..', 'reports');
          spm_mkdir(outputDir);
          logger('DEBUG', sprintf('Saving func QA results to:\n\t%s', outputDir), ...
                 'filename', mfilename(), 'options', opt);

          bf = bids.File(funcImage);
          bf.entities.label = bf.suffix;
          bf.suffix = 'qa';
          bf.entities.space = '';
          bf.extension = '.png';
          print(fig, fullfile(outputDir, bf.filename), '-dpng', '-noui', '-painters');

          % save confounds
          bf = bids.File(funcImage);
          bf.entities.desc = 'confounds';
          bf.entities.space = '';
          bf.entities.label = '';
          bf.suffix = 'timeseries';
          bf.extension = '.tsv';
          outputFile = spm_file(funcImage, 'filename', bf.filename);
          logger('DEBUG', sprintf('Saving confounds to:\n\t%s', outputFile), ...
                 'filename', mfilename(), 'options', opt);
          bids.util.tsvwrite(outputFile, confoundsTsv);
          jsonContent = createDataDictionary(confoundsTsv);
          bf.extension = '.json';
          bids.util.jsonwrite(spm_file(funcImage, 'filename', bf.filename), jsonContent);

        end

      end

    end

  end

end
