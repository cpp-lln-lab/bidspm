function bidsRoiBasedGLM(opt)
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
  % Will compute the percent signal change and the time course of the events
  % or blocks of contrast specified in the BIDS model and save and plot the results
  % in tsv / json / jpeg files.
  %
  % ..warning::
  %
  %   If your blocks are modelled as series of fast paced "short" events,
  %   the results of this workflow might be misleading.
  %   It might be better to make sure that the each block has a single event
  %   with a "long" duration.
  %
  % Adapted from the MarsBar tutorial: lib/CPP_ROI/lib/marsbar-0.44/examples/batch
  %
  % See also: bidsCreateRoi, plotRoiTimeCourse, getEventSpecificationRoiGlm
  %
  % (C) Copyright 2021 CPP_SPM developers

  opt.pipeline.type = 'stats';
  opt.dir.input = opt.dir.preproc;
  opt.fwhm.func = 0;

  [BIDS, opt] = setUpWorkflow(opt, 'roi based glm');

  checks(opt);

  if isempty(opt.model.file)
    opt = createDefaultStatsModel(BIDS, opt);
    opt = overRideWithBidsModelContent(opt);
  end

  addStatsDatasetDescription(opt);

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    %% Specify Model

    matlabbatch = {};

    matlabbatch = setBatchSubjectLevelGLMSpec(matlabbatch, BIDS, opt, subLabel);

    batchName = ['specify_roi_based_GLM_task-', strjoin(opt.taskName, '')];

    saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

    spmFile = fullfile(getFFXdir(subLabel, opt), 'SPM.mat');
    load(spmFile);

    eventSpec = getEventSpecificationRoiGlm(spmFile, opt.model.file);

    use_schema = false;
    BIDS_ROI = bids.layout(opt.dir.roi, use_schema);
    roiList = bids.query(BIDS_ROI, 'data', ...
                         'sub', subLabel, ...
                         'space', opt.space);

    model = mardo(SPM);

    for iROI = 1:size(roiList, 1)

      %% Do ROI based GLM
      % create ROI object for Marsbar
      % and convert to mat format to avoid delicacies of image format
      roiObject = maroi_image(struct( ...
                                     'vol', spm_vol(roiList{iROI, 1}), ...
                                     'binarize', true, ...
                                     'func', []));
      roiObject = maroi_matrix(roiObject);

      % Extract data and do MarsBaR estimation
      data = get_marsy(roiObject, model, 'mean');
      estimation = estimate(model, data);

      timeCourse = [];
      dt = [];
      percentSignalChange = [];

      for iCon = 1:numel(eventSpec)

        [timeCourse(:, iCon), dt(:, iCon)] = event_fitted(estimation, ...
                                                          eventSpec(iCon).eventSpec, ...
                                                          eventSpec(iCon).duration);

        % TODO
        % Add contrast, return model, and contrast index
        %       [E Ic] = add_contrasts(E, 'stim_hrf', 'T', [1 0 0]);
        %
        % Get, store statistics
        %       stat_struct(ss) = compute_contrasts(E, Ic);

        percentSignalChange(:, iCon) = event_signal(estimation, ...
                                                    eventSpec(iCon).eventSpec, ...
                                                    eventSpec(iCon).duration, ...
                                                    'abs max');

      end

      % Make fitted time course into ~% signal change
      timeCourse = timeCourse / mean(block_means(estimation)) * 100;

      %% Save to TSV and JSON
      jsonContent = struct('SamplingFrequency', []);
      if unique(dt) > 1
        error('temporal resolution different across conditions');
      else
        dt = dt(1);
      end
      jsonContent.SamplingFrequency = dt;

      for iCon = 1:numel(eventSpec)
        tsvContent.(eventSpec(iCon).name) = timeCourse(:, iCon);
        jsonContent.(eventSpec(iCon).name) = struct('percentSignalChange', ...
                                                    percentSignalChange(:, iCon));
      end

      nameStructure = outputName(opt, subLabel, roiList{iROI, 1});

      nameStructure.suffix = 'estimates';
      nameStructure.ext = '.mat';
      bidsFile = bids.File(nameStructure);
      save(fullfile(getFFXdir(subLabel, opt), bidsFile.filename), 'estimation');

      nameStructure.suffix = 'timecourse';
      nameStructure.ext = '.json';
      bidsFile = bids.File(nameStructure);
      bids.util.jsonwrite(fullfile(getFFXdir(subLabel, opt), bidsFile.filename), jsonContent);

      nameStructure.ext = '.tsv';
      bidsFile = bids.File(nameStructure);
      bids.util.tsvwrite(fullfile(getFFXdir(subLabel, opt), bidsFile.filename), tsvContent);

      plotRoiTimeCourse(fullfile(getFFXdir(subLabel, opt), bidsFile.filename));

    end

  end

end

function checks(opt)

  if numel(opt.space) > 1
    disp(opt.space);
    msg = sprintf('GLMs can only be run in one space at a time.\n');
    errorHandling(mfilename(), 'tooManySpaces', msg, false, opt.verbosity);
  end

  if ~opt.glm.roibased.do
    msg = sprintf( ...
                  ['The option opt.glm.roibased.do is set to false.\n', ...
                   ' Change the option to true to use this workflow or\n', ...
                   ' use the bidsFFX workflow to run whole brain GLM.']);
    errorHandling(mfilename(), 'roiGLMFalse', msg, false, true);
  end

end

function outputNameSpec = outputName(opt, subLabel, roiFileName)

  p = bids.internal.parse_filename(roiFileName);
  fields = {'hemi', 'desc', 'label'};
  for iField = 1:numel(fields)
    if ~isfield(p, fields{iField})
      p.(fields{iField}) = '';
    end
  end
  outputNameSpec = struct('entities', struct( ...
                                             'sub', subLabel, ...
                                             'task', opt.taskName, ...
                                             'hemi', p.entities.hemi, ...
                                             'space', 'individual', ...
                                             'label', p.entities.label, ...
                                             'desc', p.entities.desc));

end
