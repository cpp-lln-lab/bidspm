function skipped = bidsRoiBasedGLM(opt)
  %
  % Will run a GLM within a ROI using MarsBar.
  %
  % USAGE::
  %
  %   bidsRoiBasedGLM(opt)
  %
  % :param opt: Options chosen for the analysis.
  %             See also: ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % Returns:
  %
  % - skipped:
  %
  % Will compute the absolute maximum percent signal change
  % and the time course of the events
  % or blocks of contrast specified in the BIDS model
  % and save and plot the results
  % in tsv / json / jpeg files.
  %
  % .. warning::
  %
  %     If your blocks are modelled as series of fast paced "short" events,
  %     the results of this workflow might be misleading.
  %     It might be better to make sure that the each block has a single event
  %     with a "long" duration.
  %
  % Adapted from the MarsBar tutorial: lib/CPP_ROI/lib/marsbar-0.44/examples/batch
  %
  % See also: bidsCreateRoi, plotRoiTimeCourse, getEventSpecificationRoiGlm
  %

  % (C) Copyright 2021 bidspm developers

  opt.pipeline.type = 'stats';
  opt.dir.input = opt.dir.preproc;
  opt.fwhm.func = 0;

  description = 'ROI based GLMs';

  if ~isfield(opt.dir, 'roi')
    opt.dir.roi = spm_file(fullfile(opt.dir.derivatives, 'bidspm-roi'), 'cpath');
  end

  [BIDS, opt] = setUpWorkflow(opt, description);

  checks(opt);

  initBids(opt, 'description', description, 'force', false);

  skipped = struct('subject', {{}}, 'roi', {{}});

  visible = opt.verbosity > 0 && ~spm_get_defaults('cmdline');

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    [roiList, roiFolder] = getROIs(opt, subLabel);
    if iscell(roiFolder)
      roiFolder = roiFolder{1};
    end
    if noRoiFound(opt, roiList, 'folder', roiFolder)
      continue
    end

    msg = [' Using ROIs:' ...
           bids.internal.create_unordered_list(pathToPrint(roiList))];

    logger('INFO', msg, 'options', opt, 'filename', mfilename());

    outputDir = getFFXdir(subLabel, opt);

    spmFile = fullfile(outputDir, 'SPM.mat');

    if noSPMmat(opt, subLabel, spmFile)
      continue
    end
    load(spmFile, 'SPM');
    model = mardo(SPM);

    eventSpec = getEventSpecificationRoiGlm(spmFile, opt.model.file);

    for iROI = 1:size(roiList, 1)

      roiHeader = spm_vol(roiList{iROI, 1});
      roiVolume = spm_read_vols(roiHeader);

      % if there is a way to extract those info from marsbar object
      % I have yet to find it.
      roiSize.voxels = sum(roiVolume(:) > 0);
      if roiSize.voxels < 1
        msg = sprintf(['\nEmpty ROI.\n', ...
                       'Skipping:\n- subject: %s \n- ROI: %s\n'], ...
                      subLabel,  ...
                      spm_file(roiList{iROI, 1}, 'filename'));
        id = 'emptyRoi';
        logger('WARNING', msg, 'id', id, 'options', opt, 'filename', mfilename());
      end
      voxelVolume = prod(abs(diag(roiHeader.mat)));
      roiSize.volume = roiSize.voxels * voxelVolume;

      msg = sprintf('\n Processing ROI:\n\t%s\n', spm_file(roiList{iROI, 1}, 'filename'));
      logger('INFO', msg, 'options', opt, 'filename', mfilename());

      %% Do ROI based GLM
      % create ROI object for Marsbar
      % and convert to mat format to avoid delicacies of image format
      roiObject = maroi_image(struct('vol', roiHeader, ...
                                     'binarize', true, ...
                                     'func', []));
      roiObject = maroi_matrix(roiObject);

      % Extract data and do MarsBaR estimation
      data = get_marsy(roiObject, model, 'mean', 'v');
      try
        estimation = estimate(model, data);
      catch  ME
        if strcmp(ME.identifier, 'MATLAB:spdiags:InvalidSizeBFourInput')

          fprintf(1, '\n');

          msg = sprintf(['\n---------------------------------------------------', ...
                         '\nFAILED : Extract data & MarsBaR estimation.', ...
                         '\nSkipping:', ...
                         '\n- subject: %s', ...
                         '\n- ROI: %s', .....
                         '\n---------------------------------------------------', ...
                         '\n'], ...
                        subLabel,  ...
                        spm_file(roiList{iROI, 1}, 'filename'));
          id = 'roiGlmFailed';
          logger('WARNING', msg, 'filename', mfilename(), 'id', id);

          if ~strcmp(SPM.xVi.form(1:2), 'AR')
            msg = sprintf(['\n---------------------------------------------------', ...
                           '\nConsider using AR(1) instead of %s', ...
                           '\nfor SerialCorrelation correction', ...
                           '\nin your model specification.', ...
                           '\n---------------------------------------------------', ...
                           '\n'], SPM.xVi.form);
            id = 'roiGlmFailedFAST';
            logger('WARNING', msg, 'filename', mfilename(), 'id', id);
          end

          skipped.subject{end + 1} = subLabel;
          skipped.roi{end + 1} = spm_file(roiList{iROI, 1}, 'filename');
          continue
        end

      end

      timeCourse = {};
      dt = [];
      percentSignalChange = struct('absMax', [], 'max', []);

      for iCon = 1:numel(eventSpec)

        [timeCourse{1, iCon}, dt(:, iCon)] = event_fitted(estimation, ...
                                                          eventSpec(iCon).eventSpec, ...
                                                          eventSpec(iCon).duration); %#ok<*AGROW>

        % TODO Add contrast
        % Add contrast, return model, and contrast index
        %       [E Ic] = add_contrasts(E, 'stim_hrf', 'T', [1 0 0]);
        %
        % Get, store statistics
        %       stat_struct(ss) = compute_contrasts(E, Ic);

        percentSignalChange(:, iCon).absMax = event_signal(estimation, ...
                                                           eventSpec(iCon).eventSpec, ...
                                                           eventSpec(iCon).duration, ...
                                                           'abs max');

        percentSignalChange(:, iCon).max = event_signal(estimation, ...
                                                        eventSpec(iCon).eventSpec, ...
                                                        eventSpec(iCon).duration, ...
                                                        'max');

      end

      %% Save to TSV and JSON
      %  TODO refactor in separate function

      % Make fitted time course into percent signal change
      timeCourse = cellfun(@(x) x / mean(block_means(estimation)) * 100, ...
                           timeCourse, ...
                           'UniformOutput', false);

      nbTimePoints = max(cellfun('length', timeCourse));

      jsonContent = struct('SamplingFrequency', [], 'size', roiSize);
      if unique(dt) > 1
        error('temporal resolution different across conditions');
      else
        dt = dt(1);
      end
      jsonContent.SamplingFrequency = dt;

      for iCon = 1:numel(eventSpec)

        tsvContent.(eventSpec(iCon).name) = nan(nbTimePoints, 1);
        tsvContent.(eventSpec(iCon).name)(1:numel(timeCourse{1, iCon})) = timeCourse{1, iCon};

        jsonContent.(eventSpec(iCon).name) = struct('percentSignalChange', ...
                                                    percentSignalChange(:, iCon));
      end

      nameStructure = roiGlmOutputName(opt, subLabel, roiList{iROI, 1});

      nameStructure.suffix = 'timecourse';
      nameStructure.ext = '.json';
      bidsFile = bids.File(nameStructure);
      bids.util.jsonwrite(fullfile(outputDir, bidsFile.filename), jsonContent);

      nameStructure.ext = '.tsv';
      bidsFile = bids.File(nameStructure);
      bids.util.tsvwrite(fullfile(outputDir, bidsFile.filename), tsvContent);

      plotRoiTimeCourse(fullfile(outputDir, bidsFile.filename), visible);

      clear tsvContent;

    end

    saveRoiGlmSummaryTable(opt, subLabel, roiList, eventSpec);

    close all;

  end

  cleanUpWorkflow(opt);

  skippedRoiListFile = fullfile(pwd, ['skipped_roi_' timeStamp() '.tsv']);
  bids.util.tsvwrite(skippedRoiListFile, skipped);

end

function checks(opt)

  if numel(opt.space) > 1
    disp(opt.space);
    msg = sprintf('GLMs can only be run in one space at a time.\n');
    id = 'tooManySpaces';
    logger('ERROR', msg, 'id', id, 'filename', mfilename());
  end

  if ~opt.glm.roibased.do
    msg = '"opt.glm.roibased.do" must be set to true for this workflow to to run.';
    id = 'roiBasedAnalysis';
    logger('ERROR', msg, 'id', id, 'filename', mfilename());
  end

end
