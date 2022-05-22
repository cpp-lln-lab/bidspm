function [matlabbatch, opt] = bidsFFX(action, opt)
  %
  % - specify the subject level fMRI model
  % - estimates it
  % - do both in one go
  % - or compute the contrasts at the subject level.
  %
  % To run this workflows get the BOLD input images from derivatives BIDS dataset
  % that contains the preprocessed data and get the condition, onsets, durations
  % from the events files in the raw BIDS dataset.
  %
  % For the model specification, if ``opt.model.designOnly`` is set to ``true``,
  % then it is possible to specify a model with no data:
  % this can useful for debugging or to quickly inspect designs specification.
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
  % - ``specify`` to specify the fMRI GLM
  % - ``specifyAndEstimate`` for fMRI design + estimate
  % - ``contrasts`` to estimate contrasts.
  %
  % See also: setBatchSubjectLevelGLMSpec, setBatchSubjectLevelContrasts
  %
  %
  % (C) Copyright 2020 CPP_SPM developers

  opt.pipeline.type = 'stats';

  opt.dir.input = opt.dir.preproc;
  opt.dir.output = opt.dir.stats;

  description = 'subject level GLM';

  [BIDS, opt] = setUpWorkflow(opt, description);

  checks(opt, action);

  initBids(opt, 'description', description, 'force', false);

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    if ~subjectHasData(BIDS, opt, subLabel)
      continue
    end

    printProcessingSubject(iSub, subLabel, opt);

    outputDir = getFFXdir(subLabel, opt);

    matlabbatch = {};

    switch action

      case 'specify'

        matlabbatch = setAction(action, matlabbatch, BIDS, opt, subLabel);

      case 'estimate'

        % TODO implement as currently subject level estimation
        % only works with batch dependencies
        if noSPMmat(opt, subLabel, fullfile(outputDir, 'SPM.mat'))
          continue
        end
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
            ismember(action, {'specifyAndEstimate', 'estimate'})

      repetitionTime = matlabbatch{1}.spm.stats.fmri_spec.timing.RT;
      plot_power_spectra_of_GLM_residuals(outputDir, repetitionTime);

      if ~opt.glm.keepResiduals
        deleteResidualImages(getFFXdir(subLabel, opt));
      end

    end

  end

end

function checks(opt, action)

  % assume this is the first node and this is run_level
  thisNode = opt.model.bm.getRootNode;
  if ismember(lower(thisNode.Level), {'session', 'subject'})
    notImplemented(mfilename(), ...
                   '"session" and "subject" level Node not implemented yet', ...
                   verbose);
  elseif ismember(lower(thisNode.Level), {'dataset'})
    msg = sprintf(['Your model seems to be having dataset Node at its root\n.', ...
                   'Validate it: https://bids-standard.github.io/stats-models/validator.html\n']);
    errorHandling(mfilename(), 'wrongLevel', msg, false, opt.verbosity);
  end

  checkGroupBy(thisNode);

  if numel(opt.space) > 1
    disp(opt.space);
    msg = sprintf('GLMs can only be run in one space at a time.\n');
    errorHandling(mfilename(), 'tooManySpaces', msg, false, opt.verbosity);
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

    msg = sprintf(['No data found for subject %s for filter:\n%s', ...
                   '\n\nAvailable spaces are:\n%s', ...
                   '\nAvailable tasks are:\n%s'], ...
                  subLabel, ...
                  createUnorderedList(filter), ...
                  createUnorderedList(bids.query(BIDS, 'spaces')), ...
                  createUnorderedList(bids.query(BIDS, 'tasks', filter)));

    errorHandling(mfilename(), 'noDataForSubjectGLM', msg, true, opt.verbosity);

  end

end

function batchName = createBatchName(opt, action)
  batchName = [action '_ffx_task-', strjoin(opt.taskName, ''), ...
               '_space-', char(opt.space), ...
               '_FWHM-', num2str(opt.fwhm.func)];
end

function matlabbatch = setAction(action, matlabbatch, BIDS, opt, subLabel)
  outputDir = getFFXdir(subLabel, opt);
  switch action
    case 'specify'
      matlabbatch = setBatchSubjectLevelGLMSpec(matlabbatch, BIDS, opt, subLabel);
      matlabbatch = setBatchPrintFigure(matlabbatch, opt, ...
                                        fullfile(outputDir, ...
                                                 designMatrixFigureName(opt, ...
                                                                        'before estimation', ...
                                                                        subLabel)));
    case 'estimate'
      matlabbatch = setBatchEstimateModel(matlabbatch, opt);
      matlabbatch = setBatchPrintFigure(matlabbatch, opt, ...
                                        fullfile(outputDir, ...
                                                 designMatrixFigureName(opt, ...
                                                                        'after estimation', ...
                                                                        subLabel)));

    case 'constrast'
      matlabbatch = setBatchSubjectLevelContrasts(matlabbatch, opt, subLabel);
  end
end
