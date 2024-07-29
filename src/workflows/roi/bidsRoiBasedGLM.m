function skipped = bidsRoiBasedGLM(opt)
  %
  % Will run a GLM within a ROI using MarsBar.
  %
  % USAGE::
  %
  %   bidsRoiBasedGLM(opt)
  %
  % :param opt: Options chosen for the analysis.
  %             See :func:`checkOptions`.
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
  % See: :func:`bidsCreateRoi`, :func:`plotRoiTimeCourse`, :func:`getEventSpecificationRoiGlm`
  %

  % (C) Copyright 2021 bidspm developers

  opt.pipeline.type = 'stats';
  opt.dir.input = opt.dir.preproc;
  opt.fwhm.func = 0;

  description = 'ROI based GLMs';

  if ~isfield(opt.dir, 'roi')
    opt.dir.roi = spm_file(fullfile(opt.dir.derivatives, 'bidspm-roi'), 'cpath');
  end

  [~, opt] = setUpWorkflow(opt, description);

  checks(opt);

  initBids(opt, 'description', description, 'force', false);

  skipped = struct('subject', {{}}, 'roi', {{}});

  visible = opt.verbosity > 0 && ~spm_get_defaults('cmdline');

  tempDir = tempName();

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
           bids.internal.create_unordered_list(bids.internal.format_path(roiList))];

    logger('INFO', msg, 'options', opt, 'filename', mfilename());

    outputDir = getFFXdir(subLabel, opt);
    if ~checkSpmMat(outputDir, opt, strict)
      continue
    end
    spmMatFile = fullfile(outputDir, 'SPM.mat');
    load(spmMatFile, 'SPM');
    model = mardo(SPM);

    eventSpec = getEventSpecificationRoiGlm(spmMatFile, opt.model.file);

    subTempDir = fullfile(tempDir, ['sub-' subLabel]);
    spm_mkdir(subTempDir);

    for iROI = 1:size(roiList, 1)

      % Check that ROI has same dimension as BOLD images,
      % if not we reslice it and store the resliced image in the tmp dir.
      % The roibased GLM will then be run on this image.
      % ASSUMPTION: the ROI is at least coregistered to the BOLD
      status = checkRoiResolution(SPM, roiList{iROI, 1});
      if ~status
        roiHeader = resliceRoiIntoTempDir(opt, subTempDir, SPM, roiList{iROI, 1});
      else
        roiHeader = spm_vol(roiList{iROI, 1});
      end

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
      voxelVolume = prod(diag(sqrt(roiHeader.mat(1:3, 1:3).^2)));
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
      try
        data = get_marsy(roiObject, model, 'mean', 'v');
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

        elseif strcmp(ME.identifier, 'MATLAB:unassignedOutputs')

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

  rmdir(tempDir, 's');

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

function status = checkRoiResolution(SPM, roiFile)
  firstBoldVolume = deblank(SPM.xY.P(1, :));
  imagesToCheck = char({firstBoldVolume, roiFile});
  volumesToCheck = spm_vol(imagesToCheck);
  status = spm_check_orientations(volumesToCheck, false);
end

function roiHeader = resliceRoiIntoTempDir(opt, subTempDir, SPM, roiFile)
  if isZipped(roiFile)
    roiFile = gunzip(roiFile);
    wasUnzipped = true;
  else
    wasUnzipped = false;
  end

  if iscell(roiFile)
    roiFile = char(roiFile);
  end

  firstBoldVolume = deblank(SPM.xY.P(1, :));

  matlabbatch = {};
  interp = 0;
  matlabbatch = setBatchReslice(matlabbatch, ...
                                opt, ...
                                firstBoldVolume, ...
                                roiFile, ...
                                interp);
  files = spm_jobman('run', matlabbatch);

  if wasUnzipped
    if bids.internal.is_octave()
      gzip(roiFile);
    else
      delete(roiFile);
    end
  end

  reslicedRoi = files{1}.rfiles{1}(1:end - 2);
  tmpRoi = fullfile(subTempDir, spm_file(reslicedRoi, 'filename'));
  movefile(reslicedRoi, tmpRoi);
  roiHeader = spm_vol(tmpRoi);

  % sanity check
  imagesToCheck = char({firstBoldVolume, tmpRoi});
  volumesToCheck = spm_vol(imagesToCheck);
  spm_check_orientations(volumesToCheck);
end
