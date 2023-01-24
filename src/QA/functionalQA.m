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
  % For each run works on the realigned (and unwarped) data:
  %
  % - plots motion, global signal, framewise displacement
  % - gets temporal SNR (TODO)
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See also: checkOptions
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
    notImplemented(mfilename(), ...
                   'functionalQA is not yet supported on Octave. This step will be skipped.');
    opt.QA.func.do = false;
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

          prefix = ['[', ...
                    spm_get_defaults('coreg.write.prefix'), ...
                    spm_get_defaults('unwarp.write.prefix'), ...
                    ']'];
          filter = struct('prefix', prefix, ...
                          'sub', subLabel, ...
                          'ses', sessions{iSes}, ...
                          'task', thisTask, ...
                          'run', runs{iRun}, ...
                          'suffix', opt.bidsFilterFile.bold.suffix, ...
                          'extension', '.nii');
          funcImage = bids.query(BIDS, 'data', filter);

          if numel(funcImage) ~= 1
            msg = sprintf('too many files found:\n%s\n\nfor filter:%s', ...
                          createUnorderedList(funcImage));
            id = 'tooManyFiles';
            logger('ERROR', msg, 'id', id, 'filename', mfilename(), 'options', opt);
            continue
          end
          funcImage = funcImage{1};

          % sanity check that all images are in the same space.
          % TODO: need to reslice TPMs as part of spatial prepro first
          % volumesToCheck = {funcImage; greyMatter; whiteMatter; csf};
          % spm_check_orientations(spm_vol(char(volumesToCheck)));

          subFuncDataDir = spm_fileparts(funcImage);

          % TODO refactor so each step is saved after execution:
          % will help ith refactoring

          % TODO: need to reslice TPMs as part of spatial prepro first
          notImplemented(mfilename(), 'temporal SNR not implemented', opt);
          % funcQA.tSNR = spmup_temporalSNR(funcImage, ...
          %                                 {tpms(1, :); tpms(2, :); tpms(3, :)}, ...
          %                                 'save');

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

          %%
          tsvContent = returnTsvContent(outputFiles);
          bids.util.tsvwrite(spm_file(funcImage, 'filename', bf.filename), tsvContent);

          %%
          jsonContent = createDataDictionary(tsvContent);
          bf.extension = '.json';

          bids.util.jsonwrite(spm_file(funcImage, 'filename', bf.filename), jsonContent);

          %%
          delete(outputFiles.design);
          delete(spm_file(outputFiles.design, 'ext', '.json'));
          delete(realignParamFile);

        end

      end

    end

  end

end

function tsvContent = returnTsvContent(outputFiles)
  confounds = load(outputFiles.design);
  headers = bids.util.jsondecode(spm_file(outputFiles.design, 'ext', '.json'));

  for con = 1:size(confounds, 2)
    tsvContent.(headers.Columns{con}) = confounds(:, con);
  end

end
