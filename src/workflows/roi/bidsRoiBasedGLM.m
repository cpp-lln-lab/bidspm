function skipped = bidsRoiBasedGLM(opt)
  %
  % Will run a GLM within a ROI using MarsBar.
  %
  % USAGE::
  %
  %   bidsRoiBasedGLM(opt)
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % Will compute the absolute maximum percent signal change and the time course of the events
  % or blocks of contrast specified in the BIDS model and save and plot the results
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
  % (C) Copyright 2021 CPP_SPM developers

  opt.pipeline.type = 'stats';
  opt.dir.input = opt.dir.preproc;
  opt.fwhm.func = 0;

  description = 'ROI based GLMs';

  [BIDS, opt] = setUpWorkflow(opt, description);

  checks(opt);

  initBids(opt, 'description', description, 'force', false);

  skipped = struct('subject', {{}}, 'roi', {{}});

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    [roiList, roiFolder] = getROIs(opt, subLabel);
    if noRoiFound(opt, roiList, 'folder', roiFolder)
      continue
    end

    printToScreen(['\n Using ROIs:' createUnorderedList(roiList)], opt);

    outputDir = getFFXdir(subLabel, opt);

    spmFile = fullfile(outputDir, 'SPM.mat');

    if noSPMmat(opt, subLabel, spmFile)
      continue
    end
    load(spmFile);
    model = mardo(SPM);

    eventSpec = getEventSpecificationRoiGlm(spmFile, opt.model.file);

    dataToCompile = {};

    for iROI = 1:size(roiList, 1)

      roiHeader = spm_vol(roiList{iROI, 1});
      roiVolume = spm_read_vols(roiHeader);

      % if there is a way to extrat those info from marsbar object
      % I have yet to find it.
      roiSize.voxels = sum(roiVolume(:) > 0);
      voxelVolume = prod(abs(diag(roiHeader.mat)));
      roiSize.volume = roiSize.voxels * voxelVolume;

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
      catch
        fprintf('\n');
        warning('Skipping:\n- subject: %s \n- ROI: %s\n', ...
                subLabel,  ...
                spm_file(roiList{iROI, 1}, 'filename'));
        skipped.subject{end + 1} = subLabel;
        skipped.roi{end + 1} = spm_file(roiList{iROI, 1}, 'filename');
        continue
      end

      timeCourse = {};
      dt = [];
      percentSignalChange = [];

      for iCon = 1:numel(eventSpec)

        [timeCourse{1, iCon}, dt(:, iCon)] = event_fitted(estimation, ...
                                                          eventSpec(iCon).eventSpec, ...
                                                          eventSpec(iCon).duration);

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

      % Make fitted time course into percent signal change
      timeCourse = cellfun(@(x) x / mean(block_means(estimation)) * 100, ...
                           timeCourse, ...
                           'UniformOutput', false);

      nbTimePoints = max(cellfun('length', timeCourse));

      %% Save to TSV and JSON
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

      nameStructure = outputName(opt, subLabel, roiList{iROI, 1});

      nameStructure.suffix = 'timecourse';
      nameStructure.ext = '.json';
      bidsFile = bids.File(nameStructure);
      dataToCompile{end + 1, 1} = fullfile(outputDir, bidsFile.filename);
      bids.util.jsonwrite(fullfile(outputDir, bidsFile.filename), jsonContent);

      nameStructure.ext = '.tsv';
      bidsFile = bids.File(nameStructure);
      bids.util.tsvwrite(fullfile(outputDir, bidsFile.filename), tsvContent);

      plotRoiTimeCourse(fullfile(outputDir, bidsFile.filename), opt.verbosity > 0);

      clear tsvContent;

    end

    close all;

    %% Save summary table for all rois and conditions as tidy data
    psc = {'max', 'absMax'};
    row = 1;
    for i = 1:numel(dataToCompile)

      bidsFile = bids.File(dataToCompile{i});
      jsonContent = bids.util.jsondecode(dataToCompile{i});

      for iCon = 1:numel(eventSpec)

        tsvContent.label{row} = bidsFile.entities.label;
        if isfield(bidsFile.entities, 'hemi')
          tsvContent.hemi{row} = bidsFile.entities.hemi;
        else
          tsvContent.hemi{row} = nan;
        end

        tsvContent.voxels(row) = jsonContent.size.voxels;
        tsvContent.volume(row) = jsonContent.size.volume;

        conName = eventSpec(iCon).name;
        tsvContent.contrast_name{row} = conName;

        for j = 1:numel(psc)
          value = jsonContent.(conName).percentSignalChange.(psc{j});
          tsvContent.(['percent_signal_change_' psc{j}])(row) = value;
        end

        row = row + 1;

      end

    end

    bidsFile = bids.File(outputDir);
    bidsFile.suffix = 'summary';
    bidsFile.extension = '.tsv';
    bids.util.tsvwrite(fullfile(outputDir, bidsFile.filename), tsvContent);

  end

end

function checks(opt)

  if numel(opt.space) > 1
    disp(opt.space);
    msg = sprintf('GLMs can only be run in one space at a time.\n');
    errorHandling(mfilename(), 'tooManySpaces', msg, false, opt.verbosity);
  end

end

function outputNameSpec = outputName(opt, subLabel, roiFileName)

  p = bids.File(roiFileName);
  fields = {'hemi', 'desc', 'label'};
  for iField = 1:numel(fields)
    if ~isfield(p.entities, fields{iField})
      p.entities.(fields{iField}) = '';
    end
  end
  outputNameSpec = struct('entities', struct( ...
                                             'sub', subLabel, ...
                                             'task', strjoin(opt.taskName, ''), ...
                                             'hemi', p.entities.hemi, ...
                                             'space', p.entities.space, ...
                                             'label', p.entities.label, ...
                                             'desc', p.entities.desc));

end
