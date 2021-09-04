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
  % or blocks of contrast specified in the BIDS model.
  %
  %
  % (C) Copyright 2021 CPP_SPM developers

  if ~opt.glm.roibased.do
    msg = sprintf( ...
                  ['The option opt.glm.roibased.do is set to false.\n', ...
                   ' Change the option to true to use this workflow or\n', ...
                   ' use the bidsFFX workflow to run whole brain GLM.']);
    errorHandling(mfilename(), 'roiGLMFalse', msg, false, true);
  end

  opt.fwhm.func = 0;

  opt.pipeline.type = 'stats';

  opt.space = 'individual';

  opt.dir.input = opt.dir.preproc;
  opt.dir.jobs = fullfile(opt.dir.stats, 'jobs', opt.taskName);

  [BIDS, opt] = setUpWorkflow(opt, 'roi based glm');

  if isempty(opt.model.file)
    opt = createDefaultModel(BIDS, opt);
  end

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    matlabbatch = {};

    matlabbatch = setBatchSubjectLevelGLMSpec(matlabbatch, BIDS, opt, subLabel);

    batchName = ['specify_roi_based_GLM_task-', opt.taskName];

    saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

    load(fullfile(getFFXdir(subLabel, opt), 'SPM.mat'));

    nbRuns = numel(SPM.Sess);

    conditions = {};
    runs = [];
    durations = [];
    for iRun = 1:nbRuns
      tmp = cat(2, SPM.Sess(iRun).U(:).name);
      conditions = cat(2, conditions,  tmp);
      runs = [runs ones(size(tmp)) * iRun];
      for iCdt = 1:numel(tmp)
        durations = [durations mean(SPM.Sess(iRun).U(iCdt).dur)];
      end
    end

    names = unique(conditions);
    events = [];
    for iEvent = 1:numel(conditions)
      events(end + 1) = find(strcmp(conditions(iEvent), names));
    end

    use_schema = false;
    BIDS_ROI = bids.layout(opt.dir.roi, use_schema);
    roiList = bids.query(BIDS_ROI, 'data', 'sub', subLabel);

    model = mardo(SPM);

    for iROI = 1:size(roiList, 1)

      % create ROI object for Marsbar
      % and convert to matrix format to avoid delicacies of image format
      roiObject = maroi_image(struct( ...
                                     'vol', spm_vol(roiList{iROI, 1}), ...
                                     'binarize', true, ...
                                     'func', []));
      roiObject = maroi_matrix(roiObject);

      % Extract data and do MarsBaR estimation
      data = get_marsy(roiObject, model, 'mean');
      estimation = estimate(model, data);

      % -------------------- IMPROVE ------------------------ %

      % currently this only computes this averages over all all events
      % we will want to use the bids model to know which event to fit
      % based on the contrasts.

      % Fitted time courses
      [tc, dt] = event_fitted(estimation, [runs; events], durations);

      % Get percent signal change
      psc = event_signal(estimation, [runs; events], durations, 'abs max');

      % -------------------- IMPROVE ------------------------ %

      p = bids.internal.parse_filename(roiList{iROI, 1});
      fields = {'hemi', 'desc', 'label'};
      for iField = 1:numel(fields)
        if ~isfield(p, fields{iField})
          p.(fields{iField}) = '';
        end
      end
      nameStructure = struct('entities', struct( ...
                                                'sub', subLabel, ...
                                                'task', opt.taskName, ...
                                                'space', 'individual', ...
                                                'hemi', p.entities.hemi, ...
                                                'label', p.entities.label, ...
                                                'desc', p.entities.desc), ...
                             'suffix', 'estimates', ...
                             'ext', '.mat', ...
                             'use_schema', false);
      newName = bids.create_filename(nameStructure);

      save(fullfile(getFFXdir(subLabel, opt), newName), ...
           'estimation', 'tc', 'dt', 'psc');

    end

  end

end
