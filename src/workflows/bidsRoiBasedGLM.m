function bidsRoiBasedGLM(opt)
  %
  % Will run a GLM within a ROI using MarsBar.
  %
  % Will compute the percent signal change and the time course of the events
  % or blocks of contrast specified in the BIDS model.
  %
  % (C) Copyright 2021 CPP_SPM developers

  if ~opt.glm.roibased.do
    message = sprintf( ...
                      ['The option opt.glm.roibased.do is set to false.\n', ...
                       ' Change the option to true to use this workflow or\n', ...
                       ' use the bidsFFX workflow to run whole brain GLM.']);
    error(message);
  end

  funcFWHM = 0;

  [BIDS, opt] = setUpWorkflow(opt, 'roi based glm');

  opt.space = 'individual';
  opt.jobsDir = fullfile(opt.dir.stats, 'JOBS', opt.taskName);

  if isempty(opt.model.file)
    opt = createDefaultModel(BIDS, opt);
  end

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel);

    matlabbatch = {};

    matlabbatch = setBatchSubjectLevelGLMSpec(matlabbatch, BIDS, opt, subLabel, funcFWHM);

    batchName = ['specify_roi_based_GLM_task-', opt.taskName];

    saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

    load(fullfile(getFFXdir(subLabel, funcFWHM, opt), 'SPM.mat'));

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

    roiList = spm_select('FPList', ...
                         fullfile(opt.dir.roi, ['sub-' subLabel], 'roi'), ...
                         '^sub-.*_mask.nii$');

    model = mardo(SPM);

    for iROI = 1:size(roiList, 1)

      roiImage = deblank(roiList(iROI, :));

      % create ROI object for Marsbar
      % and convert to matrix format to avoid delicacies of image format
      roiObject = maroi_image(struct( ...
                                     'vol', spm_vol(roiImage), ...
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

      p = bids.internal.parse_filename(spm_file(roiImage, 'filename'));
      fields = {'hemi', 'desc', 'label'};
      for iField = 1:numel(fields)
        if ~isfield(p, fields{iField})
          p.(fields{iField}) = '';
        end
      end
      nameStructure = struct('entities', struct('sub', subLabel, ...
                                                'task', opt.taskName, ...
                                                'space', 'individual', ...
                                                'hemi', p.hemi, ...
                                                'desc', p.desc, ...
                                                'label', p.label), ...
                             'suffix', 'estimates', ...
                             'ext', '.mat');
      newName = bids.create_filename(nameStructure);

      save(fullfile(getFFXdir(subLabel, funcFWHM, opt), newName), ...
           'estimation', 'tc', 'dt', 'psc');

    end

  end

end
