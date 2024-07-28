function [matlabbatch, opt] = bidsFFX(varargin)
  %
  % - specify the subject level fMRI model
  % - estimates it
  % - do both in one go
  % - or compute the contrasts
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
  %   bidsFFX(action, opt, 'nodeName', 'run_level')
  %
  %
  % :param action: Action to be conducted
  % :type action: char
  %
  % - ``'specify'`` to specify the fMRI GLM
  % - ``'specifyAndEstimate'`` for fMRI design + estimate
  % - ``'contrasts'`` to estimate contrasts.
  %
  % :param opt: Options chosen for the analysis.
  %             See :func:`checkOptions`.
  % :type opt: structure
  %
  % :param nodeName: Only for action ``'contrasts'``. Specifies which Node to
  %                  work on.
  % :type nodeName: char
  %
  % See also: setBatchSubjectLevelGLMSpec, setBatchSubjectLevelContrasts
  %
  %

  % (C) Copyright 2020 bidspm developers

  % TODO implement nodeName for 'specify', 'specifyAndEstimate'
  % - will require adapting the subject level folder name to take into account
  % the nodeName

  %%
  allowedActions = @(x) ismember(x, {'specify', ...
                                     'estimate', ...
                                     'specifyAndEstimate', ...
                                     'contrasts'});

  args = inputParser;

  addRequired(args, 'action', allowedActions);
  addRequired(args, 'opt', @isstruct);
  addParameter(args, 'nodeName', '', @ischar);

  parse(args, varargin{:});

  action = args.Results.action;
  opt = args.Results.opt;
  nodeName = args.Results.nodeName;

  %%
  opt.pipeline.type = 'stats';

  opt.dir.input = opt.dir.preproc;
  opt.dir.output = opt.dir.stats;

  description = 'subject level GLM';

  [BIDS, opt] = setUpWorkflow(opt, description);

  checkRootNode(opt);

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
        if opt.glm.concatenateRuns
          [matlabbatch, nbScans] = concatenateRuns(matlabbatch, opt);
        end

      case 'estimate'

        if noSPMmat(opt, subLabel, fullfile(outputDir, 'SPM.mat'))
          continue
        end
        matlabbatch = setAction(action, matlabbatch, BIDS, opt, subLabel);

      case 'specifyAndEstimate'

        matlabbatch = setAction('specify', matlabbatch, BIDS, opt, subLabel);
        matlabbatch = setAction('estimate', matlabbatch, BIDS, opt, subLabel);

      case 'contrasts'

        opt.model.bm.validateConstrasts();

        if isempty(nodeName)
          matlabbatch = setBatchSubjectLevelContrasts(matlabbatch, opt, subLabel);
        else
          matlabbatch = setBatchSubjectLevelContrasts(matlabbatch, opt, subLabel, nodeName);
        end

    end

    batchName = createBatchName(opt, action);

    status = saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

    if status && ...
       opt.QA.glm.do && ....
       ~opt.model.designOnly && ...
       ismember(action, {'specifyAndEstimate', 'estimate'})

      repetitionTime = matlabbatch{1}.spm.stats.fmri_spec.timing.RT;
      plot_power_spectra_of_GLM_residuals(outputDir, repetitionTime);

      if ~opt.glm.keepResiduals
        deleteResidualImages(getFFXdir(subLabel, opt));
      end

    end

    if status
      renamePng(getFFXdir(subLabel, opt));
    end

    if strcmp(action, 'specify') && opt.glm.concatenateRuns
      outputDir = getFFXdir(subLabel, opt);
      spm_fmri_concatenate(fullfile(outputDir, 'SPM.mat'), nbScans);
    end

  end

  cleanUpWorkflow(opt);

end

function checkRootNode(opt)
  %
  % This only concerns 'specify' and 'specifyAndEstimate'
  %

  thisNode = opt.model.bm.get_root_node;

  if ismember(lower(thisNode.Level), {'session', 'subject'})

    notImplemented(mfilename(), ...
                   '"session" and "subject" level Node not implemented yet');

  elseif ismember(lower(thisNode.Level), {'dataset'})

    msg = sprintf(['Your model seems to be having dataset Node at its root\n.', ...
                   'Validate it: https://bids-standard.github.io/stats-models/validator.html\n']);
    id = 'wrongLevel';
    logger('ERROR', msg, 'id', id, 'filename', mfilename());

  end

  checkGroupBy(thisNode);

  % should not be necessary
  % mostly in case users did not validate the model inputs
  %   those should be array and not strings
  if ischar(opt.space)
    opt.space = cellstr(opt.space);
  end

  if numel(opt.space) > 1
    disp(opt.space);
    msg = sprintf('GLMs can only be run in one space at a time.\n');
    id = 'tooManySpaces';
    logger('ERROR', msg, 'id', id, 'filename', mfilename());
  end

  msg = sprintf('\n PROCESSING NODE: %s\n', thisNode.Name);
  logger('INFO', msg, 'options', opt, 'filename', mfilename());

end

function status = subjectHasData(BIDS, opt, subLabel)

  status = true;

  filter = fileFilterForBold(opt, subLabel);
  fileToProcess = bids.query(BIDS, 'data', filter);

  if isempty(fileToProcess)

    status = false;

    filter.space = strjoin(filter.space, ', ');
    filter.task = strjoin(filter.task, ', ');

    msg = sprintf(['No data found in %s', ...
                   '\nfor subject %s for filter:\n%s', ...
                   '\n\nAvailable spaces are:\n%s', ...
                   '\nAvailable tasks are:\n%s'], ...
                  BIDS.pth, ...
                  subLabel, ...
                  bids.internal.create_unordered_list(filter), ...
                  bids.internal.create_unordered_list(bids.query(BIDS, 'spaces')), ...
                  bids.internal.create_unordered_list(bids.query(BIDS, 'tasks', filter)));

    id = 'noDataForSubjectGLM';
    logger('WARNING', msg, 'id', id, 'filename', mfilename(), 'options', opt);

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
      matlabbatch = setBatchEstimateModel(matlabbatch, opt, subLabel);
      matlabbatch = setBatchPrintFigure(matlabbatch, opt, ...
                                        fullfile(outputDir, ...
                                                 designMatrixFigureName(opt, ...
                                                                        'after estimation', ...
                                                                        subLabel)));
  end
end
