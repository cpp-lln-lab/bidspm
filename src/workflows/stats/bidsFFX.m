function matlabbatch = bidsFFX(action, opt)
  %
  % - specify the subject level fMRI model
  % - estimates it
  % - do both in one go
  % - or compute the contrasts at the subject level.
  %
  % For the model specification, if ``opt.model.designOnly`` is set to
  % ``true``, then it is possible to specify a model with no data.
  %
  % For the model estimation, it is possible to do some rough QA, by setting
  % ``opt.QA.glm.do = true``.
  %
  % USAGE::
  %
  %  bidsFFX(action, opt)
  %
  % :param action: Action to be conducted:``specifyAndEstimate`` or ``contrasts``.
  % :type action: string
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % - ``specifyAndEstimate`` for fMRI design + estimate and
  % - ``contrasts`` to estimate contrasts.
  %
  % See also: setBatchSubjectLevelGLMSpec, setBatchSubjectLevelContrasts
  %
  % (C) Copyright 2020 CPP_SPM developers

  % TODO: get the space to run analysis in from the BIDS stats model input

  opt.pipeline.type = 'stats';
  opt.dir.input = opt.dir.preproc;

  [BIDS, opt] = setUpWorkflow(opt, 'subject level GLM');

  checks(opt, action);

  if isempty(opt.model.file)
    opt = createDefaultStatsModel(BIDS, opt);
    opt = overRideWithBidsModelContent(opt);
  end

  addStatsDatasetDescription(opt);

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    if ~subjectHasData(BIDS, opt, subLabel)
      continue
    end

    printProcessingSubject(iSub, subLabel, opt);

    matlabbatch = {};

    switch action

      case 'specify'

        matlabbatch = setAction(action, matlabbatch, BIDS, opt, subLabel);

      case 'estimate'

        % TODO: implement
        matlabbatch = setAction(action, matlabbatch, BIDS, opt, subLabel);

      case 'specifyAndEstimate'

        matlabbatch = setAction('specify', matlabbatch, BIDS, opt, subLabel);
        matlabbatch = setAction('estimate', matlabbatch, BIDS, opt, subLabel);

      case 'contrasts'

        matlabbatch = setBatchSubjectLevelContrasts(matlabbatch, opt, subLabel);

    end

    batchName = createBatchName(opt, action);

    saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

    if ~opt.dryRun && ...
            opt.QA.glm.do && ....
            ~opt.model.designOnly && ...
            ismember(action, {'specifyAndEstimate'})

      repetitionTime = matlabbatch{1}.spm.stats.fmri_spec.timing.RT;
      plot_power_spectra_of_GLM_residuals( ...
                                          getFFXdir(subLabel, opt), ...
                                          repetitionTime);

      deleteResidualImages(getFFXdir(subLabel, opt));

    end

  end

end

function checks(opt, action)

  if numel(opt.space) > 1
    disp(opt.space);
    msg = sprintf('GLMs can only be run in one space at a time.\n');
    errorHandling(mfilename(), 'tooManySpaces', msg, false, opt.verbosity);
  end

  if opt.glm.roibased.do
    msg = sprintf(['The option opt.glm.roibased.do is set to true.\n', ...
                   ' Change the option to false to use this workflow or\n', ...
                   ' use the bidsRoiBasedGLM workflow to run roi based GLM.']);
    errorHandling(mfilename(), 'roiGLMTrue', msg, false, opt.verbosity);
  end

  allowedActions = {'specify', 'specifyAndEstimate', 'contrasts'};
  if ~ismember(action, allowedActions)
    msg = sprintf('action must be: %s.\n%s was given.', createUnorderedList(allowedActions), ...
                  action);
    errorHandling(mfilename(), 'unknownAction', msg, false, opt.verbosity);
  end

end

function status = subjectHasData(BIDS, opt, subLabel)

  status = true;

  filter = fileFilterForGlm(opt, subLabel);
  filter.task =  opt.taskName;
  fileToProcess = bids.query(BIDS, 'data', filter);

  if isempty(fileToProcess)

    status = false;

    filter = rmfield(filter, 'space');
    filter = rmfield(filter, 'task');

    % spaces = bids.query(BIDS, 'space', filter);
    spaces = {'???'};

    tasks = bids.query(BIDS, 'tasks', filter);

    msg = sprintf(['No data found for subject %s for filter:\n%s', ...
                   '\n\nAvailable spaces are:\n%s', ...
                   '\nAvailable tasks are:\n%s'], ...
                  subLabel, ...
                  createUnorderedList(filter), ...
                  createUnorderedList(spaces), ...
                  createUnorderedList(tasks));

    errorHandling(mfilename(), 'noDataForSubjectGLM', msg, true, opt.verbosity);

  end

end

function batchName = createBatchName(opt, action)
  batchName = ...
      [action '_ffx_task-', strjoin(opt.taskName, ''), ...
       '_space-', char(opt.space), ...
       '_FWHM-', num2str(opt.fwhm.func)];
end

function filename = figureName(subLabel, opt, desc)
  p = struct( ...
             'suffix', 'designmatrix', ...
             'ext', '.png', ...
             'entities', struct( ...
                                'sub', subLabel, ...
                                'task', strjoin(opt.taskName, ''), ...
                                'space', opt.space));
  p.entities.desc = desc;
  bidsFile = bids.File(p);
  filename = bidsFile.filename;
end

function matlabbatch = setAction(action, matlabbatch, BIDS, opt, subLabel)
  switch action
    case 'specify'
      matlabbatch = setBatchSubjectLevelGLMSpec(matlabbatch, BIDS, opt, subLabel);
      matlabbatch = setBatchPrintFigure(matlabbatch, opt, ...
                                        fullfile(getFFXdir(subLabel, opt), ...
                                                 figureName(subLabel, opt, 'before estimation')));
    case 'estimate'
      matlabbatch = setBatchEstimateModel(matlabbatch, opt);
      matlabbatch = setBatchPrintFigure(matlabbatch, opt, ...
                                        fullfile(getFFXdir(subLabel, opt), ...
                                                 figureName(subLabel, opt, 'after estimation')));

    case 'constrast'
      matlabbatch = setBatchSubjectLevelContrasts(matlabbatch, opt, subLabel);
  end
end
